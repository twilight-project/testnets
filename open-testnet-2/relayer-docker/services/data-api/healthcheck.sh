#!/usr/bin/env bash
set -Eeuo pipefail

# Load environment variables from /app/.env if it exists
if [ -f /app/.env ]; then
  set -a
  # shellcheck disable=SC1091
  source /app/.env
  set +a
fi
# --- Database check ---
pg_isready -d "${DATABASE_URL}" >/dev/null 2>&1 || exit 1

# --- Redis check ---
redis-cli -u "${REDIS_HOSTNAME}" ping | grep -q PONG || exit 1
# --- Kafka check (BROKER env var, e.g., kafka:29092) ---
BROKER_HOST="${BROKER%%:*}"
BROKER_PORT="${BROKER##*:}"
nc -z -w 2 "$BROKER_HOST" "$BROKER_PORT" || exit 1


# Fallback: check if archiver main process is running
pgrep -f '^/app/main(\s|$)' >/dev/null 2>&1 || exit 1
