# esa-snap-s1tbx-gpt

**Headless ESA SNAP `gpt` (Graph Processing Tool), installable with conda alone.**
No Docker, no GUI installer, no `snappy`/`jpy` bridge — just:

```bash
conda install -c sarforge -c conda-forge esa-snap-s1tbx-gpt          # newest built SNAP
conda install -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0     # a specific SNAP version
gpt -h
```

`esa-snap-s1tbx-gpt` repackages the official ESA SNAP distribution into a conda
package that ships **only the headless `gpt`** command plus the **Sentinel-1/SAR
stack** — S1TBX, RSTB, SAR sensors, calibration, SAR processing, InSAR, and
polarimetry — using this conda environment's own `openjdk` as the JVM.

> **Unofficial.** This project is **not affiliated with or endorsed by ESA.** SNAP
> is developed by ESA and contributors and licensed under **GPL-3.0**. See
> [Licensing & attribution](#licensing--attribution).

---

## What's included

| Kept (SAR) | Purpose |
|---|---|
| `snap` engine | GPF, raster ops, readers/writers |
| `s1tbx` | **The SAR toolbox** — all-sensor IO (Sentinel-1, ERS, ENVISAT ASAR, RADARSAT-1/2, TerraSAR-X, ALOS PALSAR, Cosmo-SkyMed, RISAT, Kompsat-5, Gaofen-3, PAZ, SAOCOM, NovaSAR, Capella, **ICEYE**), calibration, SAR processing, InSAR (`jlinda`), feature extraction, ocean |
| `rstb` | Polarimetry — PolSAR decomposition, polarimetric calibration, classification, soil moisture |

**Pruned:** the optical `s2tbx` (Sentinel-2) and `s3tbx` (Sentinel-3) toolboxes, and
the installer's bundled JRE. Want optical too? See [Building](#building) — keep those
clusters for a full-SNAP build.

## Supported SNAP versions

`9.0` · `10.0` · `11.0` · `12.0` · `13.0` — pick with
`esa-snap-s1tbx-gpt=<version>`.
The conda package version equals the SNAP version. Native Apple-Silicon builds exist
for recent SNAP; older versions are Intel-only on macOS (run under Rosetta).

## Works with pyroSAR

[pyroSAR](https://github.com/johntruckenbrodt/pyroSAR) drives SNAP through `gpt` and
auto-detects the installation by finding the `snap` launcher on `PATH`.
`esa-snap-s1tbx-gpt` preserves the standard SNAP install layout (`bin/snap`,
`bin/gpt`, `etc/*.properties`) and puts the real binaries on `PATH`, so pyroSAR
detects it with **zero configuration**:

```python
from pyroSAR.examine import ExamineSnap
ex = ExamineSnap()
print(ex.snap, ex.gpt)      # both resolve into the conda env
```

> InSAR phase unwrapping additionally needs the external `snaphu` binary:
> `conda install -c conda-forge snaphu`.

---

## Building

Packages are built by CI (`.github/workflows/build.yml`) across a *version × OS*
matrix on native runners, then published to anaconda.org and attached to Releases.

`versions.yaml` is the single source of truth (installer filenames, sha256, JDK pin).

To build one package locally:

```bash
conda install -n base conda-build pyyaml ruamel.yaml
python scripts/compute-hashes.py --only 13.0.0/osx-arm64   # fill the real sha256
eval "$(python scripts/resolve.py 13.0.0 osx-arm64)"       # export build env vars
conda-build recipe/
```

Add a new SNAP version = one entry in `versions.yaml` + `compute-hashes.py` + add it
to the CI matrix input. No recipe-logic changes.

## Why not conda-forge?

This install-and-prune design can't go on the official conda-forge channel: it
repackages prebuilt binaries (conda-forge wants build-from-source), is ~1 GB,
targets multiple versions, and conda-forge's `openjdk` has no Windows build. A
from-source feedstock is a possible future v2. Until then: the `-c sarforge`
channel.

## Licensing & attribution

- **SNAP** © ESA and contributors — **Brockmann Consult**, **SkyWatch**, **CS Group**,
  and others — via the [STEP platform](https://step.esa.int). Licensed **GPL-3.0**.
  Each package ships SNAP's `LICENSE.txt` and `THIRDPARTY_LICENSES.txt`, and a
  `NOTICE.txt` with corresponding-source links to <https://github.com/senbox-org>.
- We redistribute a **pruned subset** of the official distribution with **SNAP's
  source unmodified** (GPLv3 §6 corresponding source is the upstream tag).
- Prior art gratefully acknowledged: [`snap-contrib/snap-conda`](https://github.com/snap-contrib/snap-conda)
  and [`snapista`](https://github.com/snap-contrib/snapista).
- **This project's own tooling** (recipe, scripts, CI) is licensed **Apache-2.0**
  (see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE)). The *packaged software* remains
  GPL-3.0 © ESA et al.
- **Not affiliated with or endorsed by ESA.** No ESA branding is used.
