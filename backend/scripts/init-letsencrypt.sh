#!/usr/bin/env bash
# One-time TLS bootstrap: seed a dummy cert so nginx can start, then swap it
# for a real Let's Encrypt cert. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f .env ] || { echo "!! .env missing"; exit 1; }
set -a; . ./.env; set +a
: "${DOMAIN:?set DOMAIN in .env}"
: "${LETSENCRYPT_EMAIL:?set LETSENCRYPT_EMAIL in .env}"

STAGING="${1:-}"   # pass "staging" for a dry run against LE staging

compose() { docker compose "$@"; }
cbrun() { local entrypoint="$1"; shift; compose run --rm --entrypoint "$entrypoint" certbot "$@"; }

live="/etc/letsencrypt/live/${DOMAIN}"

echo "==> pulling images"
compose pull db nginx certbot db-backup

echo "==> seeding dummy certificate for ${DOMAIN}"
cbrun sh -c "\
  mkdir -p '${live}' && \
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout '${live}/privkey.pem' \
    -out '${live}/fullchain.pem' \
    -subj '/CN=${DOMAIN}'"

echo "==> starting nginx with dummy cert"
compose up -d --build api
compose up -d nginx
sleep 3

echo "==> deleting dummy certificate"
cbrun sh -c "rm -rf /etc/letsencrypt/live/${DOMAIN} \
  /etc/letsencrypt/archive/${DOMAIN} \
  /etc/letsencrypt/renewal/${DOMAIN}.conf"

echo "==> requesting Let's Encrypt certificate"
staging_arg=""
[ "$STAGING" = "staging" ] && staging_arg="--staging" && echo "   (STAGING)"
cbrun certbot certonly --webroot -w /var/www/certbot \
  $staging_arg \
  -d "${DOMAIN}" \
  --email "${LETSENCRYPT_EMAIL}" \
  --agree-tos --no-eff-email --non-interactive

echo "==> reloading nginx"
compose exec nginx nginx -s reload

echo "==> bringing up the full stack"
compose up -d

echo "==> done. check:  curl -sS https://${DOMAIN}/healthz"
