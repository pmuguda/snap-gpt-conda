# esa-snap-s1tbx-gpt

[![docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://pmuguda.github.io/snap-gpt-conda/)
[![Anaconda version](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/version.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![Anaconda platforms](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/platforms.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![Anaconda downloads](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/downloads.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![packaging license](https://img.shields.io/badge/packaging-Apache--2.0-blue)](LICENSE)
[![SNAP license](https://img.shields.io/badge/SNAP-GPL--3.0-orange)](NOTICE)
[![Ko-fi](https://img.shields.io/badge/support-Ko--fi-ff5e5b)](https://ko-fi.com/pavan_muguda)

Headless ESA SNAP `gpt` packaged for conda SAR workflows.

`esa-snap-s1tbx-gpt` repackages the official ESA SNAP installers so users can
install the Graph Processing Tool (`gpt`) and the Sentinel-1/SAR stack with
conda. It is meant for reproducible command-line, server, CI, pyroSAR, and
Jupyter workflows without running the SNAP GUI installer.

```bash
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
conda activate snap13
gpt -h
```

`conda` works too; `mamba` is just faster at solving large environments.

SNAP 14 is the newest release and is currently published for **Linux**; on Linux,
use `esa-snap-s1tbx-gpt=14.0.0`. SNAP 13 is the latest release available for
Windows and Apple Silicon macOS. See the build matrix below.

> Unofficial packaging. This project is not affiliated with or endorsed by ESA.
> SNAP is developed by ESA and contributors and is licensed under GPL-3.0. The
> packaging code in this repository is Apache-2.0.

## Documentation

Read the documentation at [pmuguda.github.io/snap-gpt-conda](https://pmuguda.github.io/snap-gpt-conda/).

## Support

If this package saves you time, you can support the work on
[Ko-fi](https://ko-fi.com/pavan_muguda).

## What Is Included

- SNAP headless runtime layout under `$CONDA_PREFIX/opt/snap`
- `gpt` and `snap` launchers on `PATH`
- SAR stack: SNAP engine, `s1tbx`, `rstb`, and shared microwave/SAR support
- optical `s2tbx`, `s3tbx`, and `smostbx` clusters pruned
- pyroSAR-friendly install layout

This package does not provide SNAP's old `snappy`/`jpy` Python-Java bridge. Use
`gpt` directly, call it from notebooks, or drive it with pyroSAR.

## Published Build Policy

The `sarforge` channel keeps a storage-conscious trusted matrix:

| SNAP version | linux-64 | win-64 | osx-arm64 |
|---|---:|---:|---:|
| 9.0.0 | yes | no | no |
| 10.0.0 | yes | no | no |
| 11.0.0 | yes | no | no |
| 12.0.0 | yes | no | no |
| 13.0.0 | yes | yes | yes |
| 14.0.0 | yes | no | no |

Unsupported or intentionally unpublished cells are set to `null` in
`versions.yaml`, so CI skips them.

## Quick Checks

```bash
which gpt
which snap
gpt -h
gpt Calibration -h
```

pyroSAR discovery:

```python
from pyroSAR.examine import ExamineSnap

snap = ExamineSnap()
print(snap.gpt)
```

## Repository Layout

```text
recipe/                 conda-build recipe and activation hooks
versions.yaml           SNAP versions, retained subdirs, installer names, JDK/build pins
scripts/                resolver, hash checker, local build helper
tests/                  runtime acceptance checks
docs/                   GitHub Pages documentation
.github/workflows/      package build/publish workflow
```

## License

- SNAP and packaged SNAP components: GPL-3.0, copyright ESA and contributors.
- Packaging scripts, workflows, and docs in this repository: Apache-2.0.
- Built packages include SNAP's `LICENSE.txt`, `THIRDPARTY_LICENSES.txt`, and a
  package `NOTICE.txt`.

See [NOTICE](NOTICE) and the [packaging rationale](https://pmuguda.github.io/snap-gpt-conda/packaging-rationale.html)
for attribution and corresponding-source notes.

## Acknowledgements

This project builds on the idea that SNAP should be installable through conda.
Prior art includes [snap-contrib/snap-conda](https://github.com/snap-contrib/snap-conda),
which packaged SNAP for unattended Linux/headless use, and the broader
`snap-contrib` ecosystem around SNAP automation.

`esa-snap-s1tbx-gpt` takes a narrower SAR/GPT-focused path: versioned SNAP 9-14
runtime packages, no `snappy/jpy` bridge, a pruned SAR stack, and a
pyroSAR-friendly layout.
