# Install And Usage

Use the `sarforge` channel first, then `conda-forge` for dependencies.

```bash
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
conda activate snap13
gpt -h
```

`conda` can be used instead of `mamba`, but `mamba` usually resolves these large
environments faster.

## Select A SNAP Version

The package version equals the upstream SNAP version.

```bash
mamba create -n snap9  -c sarforge -c conda-forge esa-snap-s1tbx-gpt=9.0.0
mamba create -n snap10 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=10.0.0
mamba create -n snap11 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0.0
mamba create -n snap12 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=12.0.0
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
```

## Check The Install

```bash
conda activate snap13
which gpt
which snap
echo "$CONDA_PREFIX"
gpt -h
gpt Calibration -h
```

Expected launcher paths:

```text
$CONDA_PREFIX/opt/snap/bin/gpt
$CONDA_PREFIX/opt/snap/bin/snap
```

## pyroSAR

pyroSAR detects SNAP by finding the `snap` launcher on `PATH`. This package keeps
the standard SNAP layout, so no manual pyroSAR config should be needed.

```bash
mamba install -c conda-forge pyrosar
```

```python
from pyroSAR.examine import ExamineSnap

snap = ExamineSnap()
print(snap.gpt)
```

For InSAR phase unwrapping, install `snaphu` separately:

```bash
mamba install -c conda-forge snaphu
```

## Troubleshooting

If `gpt` starts but crashes during SNAP initialization, check that you are using
the fixed build for the version:

```bash
conda list | grep esa-snap-s1tbx-gpt
```

Packaging-only fixes are delivered as higher conda build numbers. For example,
`13.0.0-2` includes Linux/headless startup defaults.

If the solver keeps an old local cache, create a new environment or ask for the
exact build:

```bash
mamba create -n snap13-fixed -c sarforge -c conda-forge "esa-snap-s1tbx-gpt=13.0.0=*"
```
