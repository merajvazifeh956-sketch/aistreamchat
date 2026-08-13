#!/usr/bin/env bash
# Generate vless:// share links from environment variables.
# Handy when you want to point the SAME client at several addresses
# (direct server IP, or several Cloudflare IPs) without clicking in the panel.
#
# Env:
#   VLESS_UUID      (required) client UUID
#   VLESS_PORT      (default 443)
#   VLESS_NET       (default ws)
#   VLESS_PATH      (default /ws)
#   VLESS_SECURITY  (default none)   -> "tls" when connecting to Cloudflare
#   VLESS_SNI       (optional) Host/SNI = your Cloudflare domain
#   VLESS_FLOW      (optional) xtls-rprx-vision (Reality)
#   ADDRS           comma-separated addresses (default 127.0.0.1)
#
# Example:
#   VLESS_UUID=xxx VLESS_SNI=vpn.example.com VLESS_SECURITY=tls \
#     ADDRS=104.26.0.1,104.26.1.1 ./gen-links.sh
set -euo pipefail

UUID="${VLESS_UUID:?set VLESS_UUID}"
PORT="${VLESS_PORT:-443}"
NET="${VLESS_NET:-ws}"
PATH_="${VLESS_PATH:-/ws}"
SECURITY="${VLESS_SECURITY:-none}"
FLOW="${VLESS_FLOW:-}"
SNI="${VLESS_SNI:-}"
ADDRS="${ADDRS:-127.0.0.1}"

IFS=',' read -r -a addrs <<< "${ADDRS}"
for a in "${addrs[@]}"; do
  link="vless://${UUID}@${a}:${PORT}?encryption=none&security=${SECURITY}&type=${NET}&path=${PATH_}"
  [ -n "${FLOW}" ] && link="${link}&flow=${FLOW}"
  [ -n "${SNI}" ]   && link="${link}&sni=${SNI}&host=${SNI}"
  echo "${link}"
done
