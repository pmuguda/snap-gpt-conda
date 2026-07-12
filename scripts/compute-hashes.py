#!/usr/bin/env python3
"""Verify installer URLs and fill real sha256 values into ``versions.yaml``.

For every (version, subdir) cell with a null sha256 this:
  1. HEAD-checks the configured URL; if it 404s, probes a few known filename
     variants (version-token and OS-token spellings changed across releases) and
     adopts the first that resolves;
  2. streams the installer and computes its sha256 (installers are ~1 GB, so this
     is bandwidth-heavy — use ``--only`` to scope);
  3. writes the confirmed filename + hash back into ``versions.yaml``.

Never invents a hash: a cell is only updated from bytes actually downloaded.

Usage:
    python scripts/compute-hashes.py                 # all null cells
    python scripts/compute-hashes.py --only 13.0.0   # one version
    python scripts/compute-hashes.py --only 13.0.0/osx-arm64
    python scripts/compute-hashes.py --check-only     # verify URLs, no download
"""
from __future__ import annotations

import argparse
import hashlib
import time
import sys
import urllib.error
import urllib.request

try:
    from ruamel.yaml import YAML  # preserves comments/formatting on write-back
    _RUAMEL = True
except ImportError:
    import yaml  # type: ignore
    _RUAMEL = False

import os

HERE = os.path.dirname(os.path.abspath(__file__))
VERSIONS_YAML = os.path.join(os.path.dirname(HERE), "versions.yaml")
UA = {"User-Agent": "esa-snap-s1tbx-gpt/compute-hashes"}
HEAD_TIMEOUT = 90
HEAD_ATTEMPTS = 3


def _load():
    if _RUAMEL:
        y = YAML()
        y.preserve_quotes = True
        with open(VERSIONS_YAML) as fh:
            return y, y.load(fh)
    with open(VERSIONS_YAML) as fh:
        return None, yaml.safe_load(fh)


def _dump(y, data):
    if _RUAMEL:
        with open(VERSIONS_YAML, "w") as fh:
            y.dump(data, fh)
    else:
        with open(VERSIONS_YAML, "w") as fh:
            yaml.safe_dump(data, fh, sort_keys=False)


def _exists(url: str) -> bool:
    req = urllib.request.Request(url, method="HEAD", headers=UA)
    for attempt in range(HEAD_ATTEMPTS):
        try:
            with urllib.request.urlopen(req, timeout=HEAD_TIMEOUT) as r:
                return 200 <= r.status < 400
        except urllib.error.HTTPError as e:
            return e.code in (403,)  # some mirrors block HEAD but allow GET
        except Exception:
            if attempt == HEAD_ATTEMPTS - 1:
                return False
            time.sleep(2 * (attempt + 1))
    return False


def _filename_variants(fname: str, version: str) -> list[str]:
    """Alternate spellings seen across SNAP releases."""
    major = version.split(".")[0]
    v_dot = version                      # 13.0.0
    v_us = version.replace(".", "_")     # 13_0_0
    v_short_us = f"{major}_0"            # 9_0  (old 2-part token)
    cand = [fname]
    for a, b in [("-" + v_dot, "_" + v_us), ("_" + v_us, "-" + v_dot),
                 ("_" + v_us, "_" + v_short_us), ("-" + v_dot, "_" + v_short_us)]:
        repaired = fname.replace(a, b)
        if a in fname and repaired not in cand:
            cand.append(repaired)
    # macos_intel <-> macos, unix <-> linux swaps
    for a, b in [("macos_intel", "macos"), ("macos", "macos_intel"),
                 ("unix", "linux"), ("linux", "unix")]:
        repaired = fname.replace(a, b)
        if a in fname and repaired not in cand:
            cand.append(repaired)
    return cand


def _sha256(url: str) -> str:
    h = hashlib.sha256()
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=120) as r:
        total = int(r.headers.get("Content-Length", 0))
        got = 0
        for chunk in iter(lambda: r.read(1 << 20), b""):
            h.update(chunk)
            got += len(chunk)
            if total:
                sys.stderr.write(f"\r    {got/1e6:7.1f} / {total/1e6:.1f} MB")
                sys.stderr.flush()
    sys.stderr.write("\n")
    return h.hexdigest()


def _selected(sel: str | None, version: str, subdir: str) -> bool:
    if not sel:
        return True
    if "/" in sel:
        return sel == f"{version}/{subdir}"
    return sel == version


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", help="VERSION or VERSION/SUBDIR to scope to")
    ap.add_argument("--check-only", action="store_true",
                    help="verify/repair URLs but do not download or hash")
    ap.add_argument("--force", action="store_true",
                    help="recompute even if sha256 already present")
    args = ap.parse_args(argv[1:])

    y, data = _load()
    base = data["base_url"]
    changed = False
    problems = []

    for version, entry in data["versions"].items():
        vdir = entry["dir"]
        for subdir, cell in entry["installers"].items():
            if cell is None or not _selected(args.only, version, subdir):
                continue
            if cell.get("sha256") and not args.force:
                continue
            fname = cell["file"]
            base_url = f"{base}/{vdir}/installers/"

            # 1. resolve a working filename
            resolved = None
            for cand in _filename_variants(fname, version):
                if _exists(base_url + cand):
                    resolved = cand
                    break
            if resolved is None:
                problems.append(f"{version}/{subdir}: no URL resolved "
                                f"(tried {base_url}{fname} + variants)")
                continue
            if resolved != fname:
                sys.stderr.write(f"[{version}/{subdir}] filename repaired: "
                                 f"{fname} -> {resolved}\n")
                cell["file"] = resolved
                changed = True
            url = base_url + resolved
            sys.stderr.write(f"[{version}/{subdir}] OK {url}\n")

            if args.check_only:
                continue

            # 2. download + hash
            digest = _sha256(url)
            cell["sha256"] = digest
            changed = True
            sys.stderr.write(f"[{version}/{subdir}] sha256={digest}\n")

    if changed:
        _dump(y, data)
        sys.stderr.write("versions.yaml updated.\n")
    if problems:
        sys.stderr.write("\nUNRESOLVED:\n  " + "\n  ".join(problems) + "\n")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
