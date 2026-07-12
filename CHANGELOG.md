# Changelog

All notable changes to this project are documented here. The package version
tracks the packaged **SNAP** version; this changelog tracks the **recipe**.

## [Unreleased]
### Added
- Initial conda recipe for `esa-snap-s1tbx-gpt`: headless ESA SNAP `gpt` with
  the Sentinel-1/SAR stack (`snap` + `s1tbx` + `rstb`), optical `s2tbx`/`s3tbx`
  pruned.
- Multi-version support (SNAP 9.0–13.0) driven by `versions.yaml`.
- `activate.d`/`deactivate.d` hooks that expose the real `snap`/`gpt` on `PATH`
  (pyroSAR-friendly) and pin the JVM to the env's `openjdk`.
- GitHub Actions matrix (version × OS) publishing to anaconda.org + Releases.
- pyroSAR `ExamineSnap()` acceptance test.
- Manual workflow `subdirs` input for targeted platform rebuilds.
- Documentation pages for packaging rationale and Jupyter usage.

### Changed
- Public `sarforge` retention matrix now keeps SNAP 9-12 on Linux and SNAP 13
  on Linux + Windows + Apple Silicon macOS.
- Linux/macOS builds add headless/no-update-check JVM defaults to `snap.conf` so
  `gpt` behaves consistently in servers, CI, and notebooks.

### Notes
- `sha256` values in `versions.yaml` are filled by `scripts/compute-hashes.py`.
