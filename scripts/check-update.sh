#!/usr/bin/env bash
# Check the latest 3x-ui release and print the download URL for this machine's
# architecture. Bump the version in the Dockerfile, then rebuild.
#
# Usage:
#   ./check-update.sh            # just print
#   VERSION=v3.5.0 ./check-update.sh   # pin a specific version
set -euo pipefail

if [ -n "${VERSION:-}" ]; then
  ver="${VERSION}"
else
  ver="$(curl -fsSL https://api.github.com/repos/MHSanaei/3x-ui/releases/latest \
          | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
fi
[ -n "${ver}" ] || { echo "[!] could not determine latest version" >&2; exit 1; }

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64)  BIN="x-ui-linux-amd64" ;;
  aarch64|arm64) BIN="x-ui-linux-arm64" ;;
  *)             BIN="x-ui-linux-amd64" ;;
esac

echo "latest : ${ver}"
echo "binary : ${BIN}"
echo "url    : https://github.com/MHSanaei/3x-ui/releases/download/${ver}/${BIN}.tar.gz"
