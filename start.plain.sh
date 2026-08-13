#!/bin/bash
set -euo pipefail

#  Master source — edit here, then regenerate start.sh:
#    base64 -w0 start.plain.sh
#  (start.sh is the obfuscated copy; do not push this file:
#   it is listed in .gitignore)

# --- port (fixed) -----------------------------------------
WEB_PORT="${WEB_PORT:-2053}"

# --- location ---------------------------------------------
LOCATION="${LOCATION:-${RAILWAY_REPLICA_REGION:-${RAILWAY_SERVICE_NAME:-unknown}}}"

# --- stealth panel path ------------------------------------
if [ -z "${WEB_PATH+x}" ]; then
  WEB_PATH="$(head -c6 /dev/urandom 2>/dev/null | base64 2>/dev/null | tr -dc 'a-zA-Z0-9' | head -c8)"
  [ -n "${WEB_PATH}" ] || WEB_PATH="panel"
fi
WEB_PATH="${WEB_PATH#/}"
WEB_PATH="${WEB_PATH%/}"

if [ -n "${WEB_PATH}" ]; then
  WEB_BASE="/${WEB_PATH}"
  URL_PATH="/${WEB_PATH}"
else
  WEB_BASE="/"
  URL_PATH=""
fi

# --- decoy process name ------------------------------------
APP_NAME="${APP_NAME:-webapp}"

CONFIG_DIR="${CONFIG_DIR:-/etc/x-ui}"
mkdir -p "${CONFIG_DIR}"

cat > "${CONFIG_DIR}/config.json" <<EOF
{
  "webPort": ${WEB_PORT},
  "webBasePath": "${WEB_BASE}",
  "webListen": "0.0.0.0",
  "logLevel": "info"
}
EOF

# --- print & save panel info -------------------------------
PANEL_URL=""
PROXY_ADDR=""
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  PANEL_URL="https://${RAILWAY_PUBLIC_DOMAIN}${URL_PATH}"
fi
if [ -n "${RAILWAY_TCP_PROXY_DOMAIN:-}" ]; then
  PROXY_ADDR="${RAILWAY_TCP_PROXY_DOMAIN}:${RAILWAY_TCP_PROXY_PORT:-443}"
fi

{
  echo "=============================================="
  echo "  location : ${LOCATION}"
  echo "  login    : admin / admin"
  if [ -n "${PANEL_URL}" ]; then
    echo "  panel    : ${PANEL_URL}"
  fi
  if [ -n "${PROXY_ADDR}" ]; then
    echo "  proxy    : ${PROXY_ADDR}"
    echo "             (use THIS in your client config, not port 443)"
  fi
  echo "=============================================="
} | tee "${CONFIG_DIR}/panel-info.txt"

# --- optional runtime vars passed straight to x-ui ----------
# XUI_DB_TYPE / XUI_DB_DSN / XUI_DB_FOLDER      (database backend)
# XUI_LOG_LEVEL                                 (debug|info|warning|error)
# XUI_ENABLE_FAIL2BAN                           (true|false)
# XUI_TUNNEL_HEALTH_URL / _INTERVAL / _TIMEOUT / _FAILURES
# XUI_TUNNEL_HEALTH_MONITOR / XUI_TUNNEL_HEALTH_PROXY
# (these are read by x-ui from the environment as-is)

# --- run, with a neutral process name + crash watchdog -------
cd /opt/app

_term() {
  echo "[watchdog] stop signal received" >&2
  kill -TERM "${XUI_PID:-0}" 2>/dev/null || true
  exit 0
}
trap _term TERM INT

launch() {
  exec -a "${APP_NAME}" ./x-ui
}

while :; do
  ( launch ) &
  XUI_PID=$!
  set +e
  wait "${XUI_PID}"
  code=$?
  set -e
  XUI_PID=
  echo "[watchdog] x-ui exited (code ${code}), restarting in 3s" | tee -a "${CONFIG_DIR}/panel-info.txt"
  sleep 3
done
