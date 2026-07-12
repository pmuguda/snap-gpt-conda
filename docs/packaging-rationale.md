# Packaging Rationale

`esa-snap-s1tbx-gpt` exists to make ESA SNAP GPT usable as normal conda
infrastructure while preserving scientific reproducibility.

## Why Keep Old SNAP Versions

SNAP versions are part of the scientific workflow, not just a convenience layer.
Older versions can matter because:

- published methods may have been validated with a specific SNAP release;
- graph XML files can depend on operators and defaults from that release;
- processor behavior, auxiliary-data handling, and toolbox internals can change;
- teams often need to reproduce older Sentinel-1 products exactly enough for
  comparisons or audits.

For that reason the package version tracks the upstream SNAP version exactly:

```text
esa-snap-s1tbx-gpt 11.0.0 -> SNAP 11.0.0
esa-snap-s1tbx-gpt 13.0.0 -> SNAP 13.0.0
```

Conda build numbers are reserved for packaging-only fixes.

## Why One Package Name

Using one package name and one channel gives users a trusted, homogeneous install
pattern:

```bash
mamba create -n snap11 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=11.0.0
mamba create -n snap13 -c sarforge -c conda-forge esa-snap-s1tbx-gpt=13.0.0
```

Splitting historical versions across unrelated channels would make old builds
look unofficial or second-class. Keeping the same name, channel, metadata, tests,
and layout is the trust signal.

## Why A Pruned SAR/GPT Package

The package targets headless SAR processing, not the full desktop SNAP
experience. The build keeps:

- SNAP engine and `gpt`;
- Sentinel-1 Toolbox (`s1tbx`);
- Radar/Polarimetric Toolbox (`rstb`);
- shared microwave/SAR support;
- the normal SNAP directory layout so tools can auto-detect it.

The optical Sentinel-2/3 clusters are removed because they are large and outside
the package's SAR/GPT purpose.

## Why The Retained Platform Matrix Is Smaller Than Upstream

Anaconda.org free storage is limited, while SNAP installers are large. The public
`sarforge` channel therefore keeps a deliberate matrix:

```text
SNAP 9-11: Linux only
SNAP 12:   Linux + Apple Silicon macOS
SNAP 13:   Linux + Windows + Apple Silicon macOS
```

Linux is kept for old releases because it is the most common platform for
reproducible, automated, server-side processing. SNAP 13 keeps the broadest
platform set because it is the current release line.

Cells that are not part of the retained matrix are set to `null` in
`versions.yaml`. That makes the workflow skip them intentionally instead of
accidentally rebuilding deleted artifacts.

## Why Not Conda-Forge Yet

This package currently repackages upstream installer binaries. That does not
fit the normal conda-forge expectation that packages are built from source in the
feedstock. The artifacts are also large, include native SNAP launchers and
toolbox binaries, and need version-specific installer handling.

A future source-built feedstock may be possible, but this repository focuses on
a practical, reproducible conda distribution of the official SNAP runtime.

## Runtime Defaults

SNAP is a desktop application platform even when only `gpt` is used. In headless
Linux environments, plain startup can trigger update/version-check or desktop
initialization paths that are not useful for batch processing. The package adds:

```text
-J-Dsnap.versionCheck.interval=NEVER
-J-Djava.awt.headless=true
```

to the packaged `snap.conf` so `gpt -h` and batch workflows behave consistently
on servers, CI, and notebooks.
