# Maintainer Guide

This page collects packaging details that should not crowd the README.

## Key Files

```text
versions.yaml           supported SNAP versions and retained platform cells
recipe/meta.yaml        conda-build metadata
recipe/build.sh         Linux/macOS installer execution and pruning
recipe/bld.bat          Windows installer execution and pruning
recipe/activate.*       expose SNAP_HOME, gpt, snap, and Java settings
scripts/resolve.py      turns versions.yaml into build environment variables
scripts/compute-hashes.py verifies installer URLs and fills sha256 values
.github/workflows/build.yml package build and publish workflow
```

## Retained Matrix

The public channel intentionally retains:

```text
SNAP 9:  linux-64
SNAP 10: linux-64
SNAP 11: linux-64
SNAP 12: linux-64
SNAP 13: linux-64, win-64, osx-arm64
```

Other cells are represented as `null` in `versions.yaml`; the workflow resolves
them as intentional skips.

## Build Numbers

The package version is the SNAP version. Use the conda build number for
packaging-only fixes:

```text
13.0.0-1  Java 21 packaging fix
13.0.0-2  Linux/headless startup defaults
11.0.0-1  Linux/headless startup defaults
12.0.0-1  Linux/headless startup defaults
```

## Local Build

```bash
mamba install -n base -c conda-forge conda-build pyyaml ruamel.yaml
python scripts/compute-hashes.py --only 13.0.0/linux-64
eval "$(python scripts/resolve.py 13.0.0 linux-64)"
conda-build recipe/ --output-folder out
```

Or:

```bash
scripts/build-local.sh 13.0.0 linux-64
```

## Publishing

Manual workflow inputs:

```text
versions = 11.0.0 12.0.0 13.0.0
subdirs  = linux-64
publish  = true
```

Required repository secrets:

```text
ANACONDA_TOKEN
ANACONDA_OWNER
```

The workflow resolves `versions.yaml`, skips `null` cells, builds on native
runners, runs smoke tests, runs pyroSAR discovery on Unix, and uploads to
Anaconda.org when `publish=true`.

## GitHub Pages

The Pages workflow publishes the `docs/` directory. In repository settings, set:

```text
Settings -> Pages -> Source -> GitHub Actions
```

Expected URL:

```text
https://pmuguda.github.io/snap-gpt-conda/
```
