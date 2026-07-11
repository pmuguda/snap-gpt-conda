#!/usr/bin/env python3
"""pyroSAR acceptance test for esa-snap-s1tbx-gpt (the real bar).

Run inside a conda env that has BOTH `esa-snap-s1tbx-gpt` and `pyrosar` installed
and is ACTIVATED (so the package's activate.d put snap/gpt on PATH):

    conda create -n esa-snap-s1tbx-gpt-test -c conda-forge -c sarforge esa-snap-s1tbx-gpt pyrosar
    conda activate esa-snap-s1tbx-gpt-test
    python tests/test_pyrosar.py

Passes if pyroSAR auto-detects our SNAP install (no hand-written ~/.pyrosar
config) and resolves both the `snap` and `gpt` executables into the conda env.
An end-to-end geocode() on a real Sentinel-1 GRD scene is the fuller check and is
left to the operator (needs a scene download + orbit/DEM auxdata).
"""
import os
import sys


def main() -> int:
    prefix = os.environ.get("CONDA_PREFIX", "")
    try:
        from pyroSAR.examine import ExamineSnap
    except ImportError:
        print("FAIL: pyroSAR not installed in this env")
        return 1

    ex = ExamineSnap()
    snap = getattr(ex, "snap_exe", None) or getattr(ex, "snap", None)
    gpt = getattr(ex, "gpt", None)
    print(f"CONDA_PREFIX = {prefix}")
    print(f"pyroSAR snap = {snap}")
    print(f"pyroSAR gpt  = {gpt}")

    ok = True
    if not gpt or not os.path.exists(gpt):
        print("FAIL: pyroSAR did not resolve a gpt executable")
        ok = False
    if prefix and gpt and prefix not in os.path.realpath(gpt):
        print("WARN: resolved gpt is outside CONDA_PREFIX (detection may be picking "
              "up another SNAP install)")
    if not snap:
        print("FAIL: pyroSAR did not resolve the snap launcher (locator missing)")
        ok = False

    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
