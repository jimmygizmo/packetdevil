#!/usr/bin/env bash
# Script: vendor/tzsp2pcap/build.sh
# Purpose: apply patches/*.patch on top of upstream/ and build tzsp2pcap into build/
# Requires: C build toolchain (gcc/clang, make); no root required
# Rollback: rm -rf build/
set -euo pipefail

VENDOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_DIR="${VENDOR_DIR}/upstream"
PATCHES_DIR="${VENDOR_DIR}/patches"
BUILD_DIR="${VENDOR_DIR}/build"

if [[ ! -f "${UPSTREAM_DIR}/UPSTREAM_COMMIT" ]] || grep -q "^TODO" "${UPSTREAM_DIR}/UPSTREAM_COMMIT" 2>/dev/null; then
  echo "error: upstream/ has not been vendored yet (see vendor/tzsp2pcap/README.md)" >&2
  exit 1
fi

rm -rf "${BUILD_DIR}"
cp -r "${UPSTREAM_DIR}" "${BUILD_DIR}"

shopt -s nullglob
patches=("${PATCHES_DIR}"/*.patch)
shopt -u nullglob
if (( ${#patches[@]} > 0 )); then
  for patch in "${patches[@]}"; do
    echo "applying $(basename "${patch}")"
    patch -d "${BUILD_DIR}" -p1 < "${patch}"
  done
else
  echo "no patches to apply yet"
fi

echo "build step not yet implemented: add the upstream project's actual" \
     "build invocation (make/cmake/etc.) here once vendored." >&2
exit 1
