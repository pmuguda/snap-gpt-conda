#!/usr/bin/env bash
# Convenience: build one esa-snap-s1tbx-gpt package locally for the current platform.
#
#   scripts/build-local.sh 13.0.0            # auto-detect this machine's subdir
#   scripts/build-local.sh 13.0.0 osx-arm64  # explicit subdir
#
# Requires: conda-build, pyyaml, ruamel.yaml in the active env.
set -euo pipefail

VERSION="${1:?usage: build-local.sh <snap_version> [conda_subdir]}"
SUBDIR="${2:-}"

if [ -z "${SUBDIR}" ]; then
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64)   SUBDIR=linux-64 ;;
    Darwin-arm64)   SUBDIR=osx-arm64 ;;
    Darwin-x86_64)  SUBDIR=osx-64 ;;
    *) echo "cannot auto-detect subdir; pass it explicitly" >&2; exit 1 ;;
  esac
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

echo ">> ensuring sha256 for ${VERSION}/${SUBDIR}"
python scripts/compute-hashes.py --only "${VERSION}/${SUBDIR}"

echo ">> resolving build env"
eval "$(python scripts/resolve.py "${VERSION}" "${SUBDIR}")"

echo ">> conda build (SNAP ${SNAP_VERSION}, ${SUBDIR})"
python -m conda_build.cli.main_build recipe/ --output-folder "${ROOT}/out"

echo ">> done. Test with:"
echo "   conda create -n esa-snap-s1tbx-gpt-test -c conda-forge --use-local esa-snap-s1tbx-gpt=${VERSION}"
echo "   conda activate esa-snap-s1tbx-gpt-test && gpt -h"
