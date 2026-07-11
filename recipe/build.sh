#!/usr/bin/env bash
# Build snap-gpt on Linux and macOS:
#   install ESA SNAP unattended -> prune to the SAR stack -> wire up conda's JDK.
# The installer is fetched by conda-build as `source` (see meta.yaml) and lives in
# ${SRC_DIR}/installer/. Env vars (SNAP_VERSION, SNAP_INSTALLER_FILE, ...) come
# from scripts/resolve.py via `eval` before `conda build`.
set -euxo pipefail

SNAP_DEST="${PREFIX}/opt/snap"
INSTALLER_DIR="${SRC_DIR}/installer"
INSTALLER="$(find "${INSTALLER_DIR}" -maxdepth 1 -type f \
             \( -name '*.sh' -o -name '*.dmg' \) | head -n1)"
test -n "${INSTALLER}"

mkdir -p "${SNAP_DEST}"

# ---------------------------------------------------------------------------
# 1. Unattended install into the build prefix
# ---------------------------------------------------------------------------
case "${INSTALLER}" in
  *.sh)
    # install4j unix installer (Linux, and Intel mac for SNAP 8/9). Self-contained
    # (bundles a JRE to run the installer itself). -q = unattended, -dir = target.
    sh "${INSTALLER}" -q -dir "${SNAP_DEST}" -overwrite
    ;;
  *.dmg)
    # macOS 10+: mount the dmg, run the install4j app bundle unattended, detach.
    MNT="$(mktemp -d)"
    hdiutil attach -nobrowse -readonly -mountpoint "${MNT}" "${INSTALLER}"
    trap 'hdiutil detach "${MNT}" || true' EXIT
    APP="$(find "${MNT}" -maxdepth 1 -name '*.app' | head -n1)"
    test -n "${APP}"
    STUB="$(find "${APP}/Contents/MacOS" -maxdepth 1 -type f | head -n1)"
    test -n "${STUB}"
    "${STUB}" -q -dir "${SNAP_DEST}" -overwrite
    hdiutil detach "${MNT}" || true
    trap - EXIT
    ;;
  *)
    echo "unsupported installer type: ${INSTALLER}" >&2; exit 1 ;;
esac

test -f "${SNAP_DEST}/bin/gpt"
test -f "${SNAP_DEST}/bin/snap"

# ---------------------------------------------------------------------------
# 2. Capture upstream license files for the package (meta.yaml license_file)
# ---------------------------------------------------------------------------
mkdir -p "${SRC_DIR}/installer_licenses"
cp "${SNAP_DEST}/LICENSE.txt"            "${SRC_DIR}/installer_licenses/" || true
cp "${SNAP_DEST}/THIRDPARTY_LICENSES.txt" "${SRC_DIR}/installer_licenses/" || true

# ---------------------------------------------------------------------------
# 3. Prune to the SAR stack: drop optical toolboxes + the bundled JRE.
#    Keep: snap (engine), s1tbx (SAR), rstb (polarimetry), platform, ide, bin, etc.
# ---------------------------------------------------------------------------
rm -rf "${SNAP_DEST}/s2tbx" "${SNAP_DEST}/s3tbx" "${SNAP_DEST}/smostbx"
# Remove any bundled JRE — we use this conda env's openjdk.
rm -rf "${SNAP_DEST}/jre" "${SNAP_DEST}/jbr" \
       "${SNAP_DEST}/.install4j/jre.bundle" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 4. Register only the kept clusters
# ---------------------------------------------------------------------------
cat > "${SNAP_DEST}/etc/snap.clusters" <<'EOF'
etc
ide
platform
bin
snap
s1tbx
rstb
EOF

# ---------------------------------------------------------------------------
# 5. Config tweaks: portable heap default (installer sets -Xmx to a huge value).
# ---------------------------------------------------------------------------
if [ -f "${SNAP_DEST}/etc/snap.conf" ]; then
  sed -i.bak -E 's/-J-Xmx[0-9]+[GgMm]/-J-Xmx4G/' "${SNAP_DEST}/etc/snap.conf" || true
  rm -f "${SNAP_DEST}/etc/snap.conf.bak"
fi

# ---------------------------------------------------------------------------
# 6. Install activate/deactivate hooks (PATH + JDK override; pyroSAR-friendly)
# ---------------------------------------------------------------------------
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/activate.sh"   "${PREFIX}/etc/conda/activate.d/snap-gpt.sh"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/snap-gpt.sh"

# ---------------------------------------------------------------------------
# 7. Corresponding-source / attribution NOTICE inside the package (GPLv3)
# ---------------------------------------------------------------------------
mkdir -p "${PREFIX}/share/snap-gpt"
cat > "${PREFIX}/share/snap-gpt/NOTICE.txt" <<EOF
snap-gpt ${SNAP_VERSION:-unknown} — unofficial community repackaging of ESA SNAP.

This package contains a SUBSET of the official ESA SNAP ${SNAP_VERSION:-} "sentinel"
distribution: the optical Sentinel-2/3 toolboxes (s2tbx/s3tbx) and the bundled JRE
were removed. SNAP's own source code is UNMODIFIED.

SNAP is developed by ESA and contributors (Brockmann Consult, SkyWatch, CS Group,
and others) and licensed under GNU GPL-3.0. See LICENSE.txt and
THIRDPARTY_LICENSES.txt (shipped in opt/snap/).

Corresponding source (GPLv3 §6): https://github.com/senbox-org
  snap-engine, snap-desktop, s1tbx, rstb — use the tag matching version ${SNAP_VERSION:-}.
Written offer: the maintainer will provide the corresponding source on request via
https://github.com/pmuguda/snap-gpt-conda .

NOT affiliated with or endorsed by ESA.
EOF

echo "snap-gpt build complete: ${SNAP_DEST}"
