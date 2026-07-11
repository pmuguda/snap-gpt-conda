# Changelog

All notable changes to this project are documented here. The package version
tracks the packaged **SNAP** version; this changelog tracks the **recipe**.

## [Unreleased]
### Added
- Initial conda recipe for `snap-gpt`: headless ESA SNAP `gpt` with the full SAR
  stack (`snap` + `s1tbx` + `rstb`), optical `s2tbx`/`s3tbx` pruned.
- Multi-version support (SNAP 9.0–13.0) driven by `versions.yaml`.
- `activate.d`/`deactivate.d` hooks that expose the real `snap`/`gpt` on `PATH`
  (pyroSAR-friendly) and pin the JVM to the env's `openjdk`.
- GitHub Actions matrix (version × OS) publishing to anaconda.org + Releases.
- pyroSAR `ExamineSnap()` acceptance test.

### Notes
- Not yet build-tested end to end; first validation target is SNAP 13 / osx-arm64.
- `sha256` values in `versions.yaml` are filled by `scripts/compute-hashes.py`.
