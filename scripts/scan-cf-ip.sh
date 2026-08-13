#!/usr/bin/env bash
# Download and run CloudflareSpeedTest (XIU2/CloudflareSpeedTest) to find
# fast Cloudflare IPs for your client. Run this on YOUR OWN machine, not the
# server, so the latency numbers reflect your network path.
#
# Usage:
#   ./scan-cf-ip.sh
#   N=300 T=5 DN=10 SL=5 ./scan-cf-ip.sh
#
# Output: a table of IPs sorted by speed. Use the top IP in your client as the
# "address", keep SNI/Host = your own Cloudflare-proxied domain.
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${ARCH}" in
  x86_64|amd64)  A="amd64" ;;
  aarch64|arm64) A="arm64" ;;
  *) echo "[!] unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

case "${OS}" in
  Linux)                 F="CloudflareST_linux_${A}.tar.gz"; EXT="tar.gz" ;;
  Darwin)                F="CloudflareST_darwin_${A}.zip";    EXT="zip" ;;
  MINGW*|MSYS*|CYGWIN*)  F="CloudflareST_windows_${A}.zip";   EXT="zip" ;;
  *) echo "[!] unsupported os: ${OS}" >&2; exit 1 ;;
esac

URL="https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/${F}"
WORK="$(mktemp -d)"

echo "==> downloading ${URL}"
curl -fsSL "${URL}" -o "${WORK}/cfst.${EXT}"

if [ "${EXT}" = "tar.gz" ]; then
  tar xzf "${WORK}/cfst.${EXT}" -C "${WORK}"
else
  (cd "${WORK}" && unzip -o cfst.${EXT} >/dev/null)
fi

chmod +x "${WORK}"/CloudflareST* 2>/dev/null || true
echo "==> scanning (this can take a few minutes)..."
"${WORK}"/CloudflareST -n "${N:-200}" -t "${T:-5}" -dn "${DN:-10}" -sl "${SL:-5}"
