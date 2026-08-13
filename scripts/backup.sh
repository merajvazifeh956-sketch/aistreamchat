#!/usr/bin/env bash
# Backup / restore the panel database (x-ui.db) + config.
#
# Usage:
#   ./backup.sh              # make a timestamped backup
#   ./backup.sh list         # list existing backups
#   ./backup.sh restore <file>   # restore a backup file
#
# Env:
#   DB_DIR      (default /etc/x-ui)
#   BACKUP_DIR  (default ${DB_DIR}/backups)
#   BACKUP_KEEP (default 20)  number of backups to keep
set -euo pipefail

DB_DIR="${DB_DIR:-/etc/x-ui}"
DB="${DB_DIR}/x-ui.db"
CFG="${DB_DIR}/config.json"
BACKUP_DIR="${BACKUP_DIR:-${DB_DIR}/backups}"
KEEP="${BACKUP_KEEP:-20}"

mkdir -p "${BACKUP_DIR}"

[ -f "${DB}" ] || { echo "[!] no database at ${DB}" >&2; exit 1; }

case "${1:-backup}" in
  backup)
    ts="$(date +%Y%m%d-%H%M%S)"
    out="${BACKUP_DIR}/x-ui-${ts}.db"
    if command -v sqlite3 >/dev/null 2>&1; then
      sqlite3 "${DB}" ".backup '${out}'"
    else
      cp -f "${DB}" "${out}"
    fi
    # also snapshot config.json alongside the db
    cp -f "${CFG}" "${out%.db}.config.json" 2>/dev/null || true
    # prune old backups
    ls -1t "${BACKUP_DIR}"/x-ui-*.db 2>/dev/null | tail -n +"$((KEEP+1))" | xargs -r rm -f
    echo "backup -> ${out}"
    ;;
  restore)
    src="${2:-}"
    [ -n "${src}" ] || { echo "usage: $0 restore <file.db>" >&2; exit 1; }
    [ -f "${src}" ] || { echo "[!] not found: ${src}" >&2; exit 1; }
    cp -f "${src}" "${DB}"
    echo "restored ${src} -> ${DB} (restart the panel to apply)"
    ;;
  list)
    ls -1t "${BACKUP_DIR}"/x-ui-*.db 2>/dev/null || echo "(no backups yet)"
    ;;
  *)
    echo "usage: $0 [backup|restore <file>|list]" >&2
    exit 1
    ;;
esac
