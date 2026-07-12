# esa-snap-s1tbx-gpt

Headless ESA SNAP `gpt` packaged for conda.

This project repackages the official ESA SNAP installers into conda packages that
expose the SNAP Graph Processing Tool (`gpt`) and the SAR stack in a normal conda
environment. It is designed for reproducible Sentinel-1/SAR processing in shell
scripts, CI jobs, servers, and Jupyter notebooks without running the SNAP GUI
installer.

```bash
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
conda activate snap13
gpt -h
```

`conda` works too; `mamba` is simply faster at solving large environments.

> Unofficial packaging. This project is not affiliated with or endorsed by ESA.
> SNAP is developed by ESA and contributors and is licensed under GPL-3.0. The
> packaging scripts in this repository are Apache-2.0.

## Why This Exists

SNAP versions are not interchangeable in scientific workflows. Published
methods, graph XML files, processor behavior, and validation history often depend
on a specific SNAP release. At the same time, installing the GUI SNAP bundle by
hand is awkward on servers, CI, and managed conda environments.

This package gives users a homogeneous install pattern:

```bash
mamba create -n snap11 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0.0
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
```

See [docs/packaging-rationale.md](docs/packaging-rationale.md) for the longer
rationale, platform policy, and why this is intentionally separate from
conda-forge for now.

## What Is Included

The package keeps the headless SNAP runtime layout and the SAR toolboxes:

| Component | Purpose |
|---|---|
| `bin/gpt` | SNAP Graph Processing Tool |
| `bin/snap` | Standard SNAP launcher, kept so tools such as pyroSAR can locate the install |
| `snap` engine | GPF, raster operations, readers/writers |
| `s1tbx` | Sentinel-1 and SAR processing, calibration, InSAR, feature extraction, ocean tools |
| `rstb` | Polarimetry, decomposition, polarimetric calibration, classification |
| `microwavetbx` | Shared microwave/SAR support used by SNAP toolboxes |

The optical `s2tbx`, `s3tbx`, and `smostbx` clusters are pruned to keep the
package focused on SAR/GPT workflows.

Java/runtime behavior:

- Linux and macOS builds depend on conda-forge `openjdk`.
- Windows builds keep SNAP's bundled runtime because conda-forge does not provide
  the same Windows `openjdk` dependency path.
- Linux/macOS builds add headless and no-update-check JVM defaults to avoid
  desktop/update initialization crashes in server and notebook environments.

## Published Build Policy

The public `sarforge` channel intentionally keeps a storage-conscious, trusted
matrix:

| SNAP version | linux-64 | win-64 | osx-arm64 | Notes |
|---|---:|---:|---:|---|
| 9.0.0 | yes | no | no | Older reproducibility build |
| 10.0.0 | yes | no | no | Older reproducibility build |
| 11.0.0 | yes | no | no | Rebuild uses headless JVM defaults |
| 12.0.0 | yes | no | yes | ESA provides one Mac DMG; ARM build must pass native CI |
| 13.0.0 | yes | yes | yes | Current full platform set |

The recipe can represent other upstream installer cells, but unsupported or
intentionally unpublished cells are set to `null` in `versions.yaml` so CI skips
them instead of accidentally recreating deleted artifacts.

## Install

Latest available build:

```bash
mamba create -n snap -c sarforge -c conda-forge esa-snap-s1tbx-gpt
conda activate snap
gpt -h
```

Specific SNAP version:

```bash
mamba create -n snap11 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0.0
conda activate snap11
gpt -h
gpt Calibration -h
```

Check paths:

```bash
which gpt
which snap
echo "$CONDA_PREFIX"
```

Expected layout:

```text
$CONDA_PREFIX/opt/snap/bin/gpt
$CONDA_PREFIX/opt/snap/bin/snap
```

## Jupyter Notebooks

Yes. You can use this package from Jupyter notebooks as long as the notebook
kernel is running inside the same conda environment.

Install notebook tooling into the SNAP environment:

```bash
mamba create -n snap-notebook -c sarforge -c conda-forge \
  esa-snap-s1tbx-gpt=13.0.0 python ipykernel pyrosar
conda activate snap-notebook
python -m ipykernel install --user --name snap-notebook --display-name "Python (SNAP GPT)"
```

Inside a notebook:

```python
import subprocess

subprocess.run(["gpt", "-h"], check=True)
```

For SAR workflows, use `pyroSAR` or call `gpt` with graph XML files. This package
does not provide the old SNAP `snappy`/`jpy` Python-Java bridge. See
[docs/jupyter.md](docs/jupyter.md) for examples and limitations.

## pyroSAR

[pyroSAR](https://github.com/johntruckenbrodt/pyroSAR) drives SNAP through `gpt`
and auto-detects SNAP by finding the `snap` launcher on `PATH`. This package
preserves the standard SNAP install layout, so detection should work without a
hand-written pyroSAR config:

```python
from pyroSAR.examine import ExamineSnap

ex = ExamineSnap()
print(ex.gpt)
```

Validation snippet:

```bash
python - <<'PY'
import os, shutil
from pyroSAR.examine import ExamineSnap

ex = ExamineSnap()
print("CONDA_PREFIX =", os.environ.get("CONDA_PREFIX"))
print("pyroSAR gpt  =", ex.gpt)
print("PATH snap    =", shutil.which("snap"))
assert ex.gpt and os.path.exists(ex.gpt)
assert shutil.which("snap")
print("PASS")
PY
```

InSAR phase unwrapping still needs an external `snaphu` binary:

```bash
mamba install -c conda-forge snaphu
```

## Repository Layout

```text
recipe/                 conda-build recipe and activation hooks
versions.yaml           supported SNAP versions, retained subdirs, installer names, JDK/build pins
scripts/resolve.py      converts versions.yaml into conda-build environment variables
scripts/compute-hashes.py verifies installer URLs and fills sha256 values
tests/test_pyrosar.py   runtime acceptance test for pyroSAR discovery
.github/workflows/      native platform build/publish workflow
docs/                   user and packaging rationale pages
```

## Building Locally

Install build tooling:

```bash
mamba install -n base -c conda-forge conda-build pyyaml ruamel.yaml
```

Build one version/subdir:

```bash
python scripts/compute-hashes.py --only 13.0.0/linux-64
eval "$(python scripts/resolve.py 13.0.0 linux-64)"
conda-build recipe/ --output-folder out
```

Or use the helper:

```bash
scripts/build-local.sh 13.0.0 linux-64
```

## Publishing

Publishing is driven by `.github/workflows/build.yml`.

Manual workflow inputs:

```text
versions = 11.0.0 12.0.0 13.0.0
subdirs  = linux-64 osx-arm64
publish  = true
```

The workflow:

1. Resolves `versions.yaml`.
2. Skips cells set to `null`.
3. Builds on native GitHub-hosted runners.
4. Runs `gpt -h` and SAR operator smoke tests.
5. Runs the pyroSAR discovery test on Unix platforms.
6. Uploads to Anaconda.org when `publish=true`.

Required secrets:

- `ANACONDA_TOKEN`
- `ANACONDA_OWNER` (for example, `sarforge`)

## Versioning

The conda package version equals the SNAP version. The conda build number is used
for packaging fixes that do not change the upstream SNAP version.

Examples:

- `13.0.0-1`: Java 21 packaging fix.
- `13.0.0-2`: Linux/headless startup defaults.
- `11.0.0-1`, `12.0.0-1`: rebuilds with the same startup defaults.

## Licensing And Attribution

- SNAP is developed by ESA and contributors, including Brockmann Consult,
  SkyWatch, CS Group, and others. SNAP is GPL-3.0.
- Each built package ships SNAP's `LICENSE.txt`, `THIRDPARTY_LICENSES.txt`, and a
  package `NOTICE.txt`.
- The package redistributes a pruned, unmodified SNAP distribution. Corresponding
  source is the upstream tag in <https://github.com/senbox-org>.
- This repository's packaging scripts, CI, and docs are Apache-2.0.
- This project is not affiliated with or endorsed by ESA.
