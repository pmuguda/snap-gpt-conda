# esa-snap-s1tbx-gpt Documentation

`esa-snap-s1tbx-gpt` packages the headless ESA SNAP Graph Processing Tool for
conda-based SAR workflows.

## Install

```bash
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
conda activate snap13
gpt -h
```

Use the package version to select the SNAP version:

```bash
mamba create -n snap11 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0.0
```

## Pages

- [Packaging rationale](packaging-rationale.md): why old SNAP versions matter,
  why the package is structured this way, and why the retained build matrix is
  intentional.
- [Jupyter usage](jupyter.md): how to use `gpt` and pyroSAR from notebooks.

The repository README remains the canonical package landing page on GitHub.
