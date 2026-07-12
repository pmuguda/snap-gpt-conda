# Jupyter Usage

`esa-snap-s1tbx-gpt` can be used from Jupyter notebooks. The important rule is
that the notebook kernel must run inside the conda environment where the package
is installed.

## Create A Notebook Environment

```bash
mamba create -n snap-notebook -c sarforge -c conda-forge \
  esa-snap-s1tbx-gpt=13.0.0 python ipykernel pyrosar
conda activate snap-notebook
python -m ipykernel install --user --name snap-notebook --display-name "Python (SNAP GPT)"
```

Then select `Python (SNAP GPT)` as the notebook kernel.

## Check GPT From A Notebook

```python
import shutil
import subprocess

print(shutil.which("gpt"))
subprocess.run(["gpt", "-h"], check=True)
```

## Run A GPT Graph

```python
from pathlib import Path
import subprocess

graph = Path("calibration.xml")
source = Path("S1_scene.zip")
target = Path("calibrated.dim")

subprocess.run(
    [
        "gpt",
        str(graph),
        f"-Pinput={source}",
        f"-Poutput={target}",
    ],
    check=True,
)
```

Exact graph parameters depend on the XML graph you are running.

## pyroSAR

pyroSAR can call SNAP through `gpt` after it detects the installation:

```python
from pyroSAR.examine import ExamineSnap

snap = ExamineSnap()
print(snap.gpt)
```

For full pyroSAR geocoding workflows, install any additional external tools you
need, such as `snaphu` for phase unwrapping:

```bash
mamba install -c conda-forge snaphu
```

## What This Does Not Provide

This package does not provide SNAP's old `snappy`/`jpy` Python-Java bridge. In
notebooks, use one of these patterns instead:

- call `gpt` with `subprocess`;
- use pyroSAR, which drives SNAP through `gpt`;
- generate graph XML programmatically and execute it with `gpt`.

That separation is intentional: the package is a reliable headless GPT runtime,
not a Python binding for SNAP's internal Java API.
