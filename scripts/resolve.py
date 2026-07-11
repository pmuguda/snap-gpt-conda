#!/usr/bin/env python3
"""Resolve the installer for a (SNAP version, conda subdir) into build env vars.

Reads ``versions.yaml`` and prints shell ``KEY=VALUE`` lines that both the local
build and CI ``eval`` before calling ``conda build``. Keeps ``versions.yaml`` as
the single source of truth so the recipe never hardcodes URLs/hashes.

Usage:
    eval "$(python scripts/resolve.py 13.0.0 osx-arm64)"
    # -> exports SNAP_VERSION, SNAP_SUBDIR, SNAP_INSTALLER_URL,
    #            SNAP_INSTALLER_FILE, SNAP_INSTALLER_SHA256, SNAP_JDK

Exit codes:
    0  resolved (prints env)
    3  cell intentionally absent upstream (prints ``SNAP_SKIP=1``) — build should no-op
    1  error (unknown version/subdir, or sha256 not yet computed)
"""
from __future__ import annotations

import os
import sys

try:
    import yaml
except ImportError:  # pragma: no cover
    sys.stderr.write("PyYAML required: pip/conda install pyyaml\n")
    sys.exit(1)

HERE = os.path.dirname(os.path.abspath(__file__))
VERSIONS_YAML = os.path.join(os.path.dirname(HERE), "versions.yaml")


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        sys.stderr.write(f"usage: {argv[0]} <snap_version> <conda_subdir>\n")
        return 1
    version, subdir = argv[1], argv[2]

    with open(VERSIONS_YAML) as fh:
        data = yaml.safe_load(fh)

    versions = data["versions"]
    if version not in versions:
        sys.stderr.write(f"unknown SNAP version {version!r}; "
                         f"known: {', '.join(versions)}\n")
        return 1

    entry = versions[version]
    installers = entry["installers"]
    if subdir not in installers:
        sys.stderr.write(f"unknown subdir {subdir!r}\n")
        return 1

    cell = installers[subdir]
    if cell is None:
        # Intentionally absent upstream (e.g. no arm64 mac for SNAP 9).
        print("SNAP_SKIP=1")
        return 3

    fname = cell["file"]
    sha256 = cell.get("sha256")
    if not sha256:
        sys.stderr.write(
            f"sha256 for {version}/{subdir} ({fname}) is empty — "
            f"run `python scripts/compute-hashes.py` first.\n")
        return 1

    url = f"{data['base_url']}/{entry['dir']}/installers/{fname}"

    out = {
        "SNAP_VERSION": version,
        "SNAP_SUBDIR": subdir,
        "SNAP_INSTALLER_URL": url,
        "SNAP_INSTALLER_FILE": fname,
        "SNAP_INSTALLER_SHA256": sha256,
        "SNAP_JDK": str(entry.get("jdk", "11")),
    }
    for k, v in out.items():
        print(f"{k}={v}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
