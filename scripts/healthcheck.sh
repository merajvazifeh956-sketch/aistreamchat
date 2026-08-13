#!/usr/bin/env bash
# Liveness check for the panel (and optionally a proxy port).
#
# Usage:
#   ./healthcheck.sh               # check panel only
#   ./healthcheck.sh 443           # also check proxy port 443
#
# Exits 0 when healthy, 1 otherwise. Safe to use in cron / monitoring.
set -euo pipefail

WEB_PORT="${WEB_PORT:-2053}"
HOST="${HOST:-127.0.0.1}"
fail=0

if curl -sS --max-time 8 -o /dev/null "http://${HOST}:${WEB_PORT}/"; then
  echo "panel (${HOST}:${WEB_PORT}): ok"
else
  echo "panel (${HOST}:${WEB_PORT}): DOWN"
  fail=1
fi

if [ -n "${1:-}" ]; then
  p="${1}"
  # xray ports aren't HTTP, so just test TCP reachability
  if (exec 3<>"/dev/tcp/${HOST}/${p}") 2>/dev/null; then
    echo "proxy port ${p}: open"
  else
    echo "proxy port ${p}: DOWN"
    fail=1
  fi
fi

exit "${fail}"
