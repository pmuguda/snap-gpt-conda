# esa-snap-s1tbx-gpt

[![build](https://github.com/pmuguda/snap-gpt-conda/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/pmuguda/snap-gpt-conda/actions/workflows/build.yml)
[![pages](https://github.com/pmuguda/snap-gpt-conda/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/pmuguda/snap-gpt-conda/actions/workflows/pages.yml)
[![docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://pmuguda.github.io/snap-gpt-conda/)
[![Anaconda version](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/version.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![Anaconda platforms](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/platforms.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![Anaconda downloads](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt/badges/downloads.svg)](https://anaconda.org/sarforge/esa-snap-s1tbx-gpt)
[![license](https://img.shields.io/github/license/pmuguda/snap-gpt-conda)](LICENSE)

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

> Unofficial packaging. This project is not affiliated with or endorsed by ESA.
> SNAP is developed by ESA and contributors and is licensed under GPL-3.0. The
> packaging code in this repository is Apache-2.0.

## Documentation

Read the documentation at [pmuguda.github.io/snap-gpt-conda](https://pmuguda.github.io/snap-gpt-conda/).

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
.github/workflows/      package build/publish and Pages workflows
```

## License

- SNAP and packaged SNAP components: GPL-3.0, copyright ESA and contributors.
- Packaging scripts, workflows, and docs in this repository: Apache-2.0.
- Built packages include SNAP's `LICENSE.txt`, `THIRDPARTY_LICENSES.txt`, and a
  package `NOTICE.txt`.

See [NOTICE](NOTICE) and [docs/packaging-rationale.md](docs/packaging-rationale.md)
for attribution and corresponding-source notes.
