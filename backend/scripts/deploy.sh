#!/usr/bin/env bash
# Redeploy after a code change. Run on the server from /opt/an.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> building api image"
docker compose build api

echo "==> running migrations"
docker compose run --rm --no-deps -e NODE_ENV=production api node src/migrate.js

echo "==> restarting api"
docker compose up -d api

docker compose ps
echo "==> health:"
sleep 3
curl -fsS "http://127.0.0.1:8080/healthz" 2>/dev/null || \
  docker compose exec -T api wget -qO- http://127.0.0.1:8080/healthz || true
echo
