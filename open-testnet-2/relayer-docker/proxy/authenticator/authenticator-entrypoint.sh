#!/usr/bin/env sh
set -e


API_URL="http://api:8987"

check_service() {
    local url="$1"
    # Try a HEAD request, capture HTTP code; empty code means connection failed
    local code
    code=$(wget -qSO- --spider "$url" 2>&1 | awk '/^  HTTP/{print $2}' | tail -n1 || true)
    if [ -z "$code" ]; then
        return 1
    fi
    return 0
}


echo "[entrypoint] Waiting for API service at $API_URL ..."
until check_service "$API_URL"; do
    echo "[entrypoint] API not reachable, retrying in 3s..."
    sleep 3
done
echo "[entrypoint] ✅ API is reachable"

echo "[entrypoint] Starting Nginx..."
exec nginx -g "daemon off;"