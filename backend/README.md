# An — backend

Node (Fastify) + PostgreSQL, fronted by Nginx with Let's Encrypt TLS, all in
Docker Compose. Sized for a ~1.4 GB / 2 vCPU VPS.

```
mobile app ──HTTPS──▶ nginx ──▶ api (Fastify) ──▶ postgres
                                   │                  ▲
                             firebase-admin        db-backup (nightly pg_dump)
                             (verify ID token)
                        certbot renews TLS in the background
```

## API (v1)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/v1/auth/session` | Firebase ID token (Bearer) | verify token, upsert user, return app JWT |
| GET | `/v1/me` | app JWT | current user |
| PATCH | `/v1/me` | app JWT | update `name`, `plan_tier` |
| GET | `/v1/entries?since=<ISO>` | app JWT | journal entries (delta sync) |
| POST | `/v1/entries` | app JWT | create `{mood,intensity,tags,note,entry_date}` |
| PATCH | `/v1/entries/:id` | app JWT | update entry |
| DELETE | `/v1/entries/:id` | app JWT | delete entry |
| GET | `/v1/streak` | app JWT | consecutive-day streak |
| GET | `/healthz` | — | `{ok, db, firebase}` |

App JWT: `Authorization: Bearer <token>` from `/v1/auth/session` (30-day TTL).

## First deploy (on the server, as a deploy user)

```bash
sudo mkdir -p /opt/an && sudo chown "$USER" /opt/an
# copy this backend/ directory to /opt/an  (rsync from the repo)
cd /opt/an

cp .env.example .env && nano .env          # fill POSTGRES_PASSWORD, JWT_SECRET, DOMAIN, email
#   openssl rand -base64 36   for each secret; keep DATABASE_URL's password in sync

mkdir -p secrets && chmod 700 secrets
cp /path/to/firebase-service-account.json secrets/firebase-service-account.json
chmod 600 secrets/firebase-service-account.json

chmod 600 .env

bash scripts/init-letsencrypt.sh staging   # dry-run against LE staging
bash scripts/init-letsencrypt.sh           # real cert

docker compose run --rm api node src/migrate.js   # create tables
docker compose up -d

curl -sS https://$DOMAIN/healthz            # -> {"ok":true,"db":"up","firebase":"ready"}
```

## Redeploy after a code change

```bash
cd /opt/an && git pull   # or rsync
bash scripts/deploy.sh
```

## Backups

`db-backup` writes nightly gzipped dumps to `./backups/` (7 daily / 4 weekly /
6 monthly). **Copy them off-box** — a cron running `rclone` to Backblaze B2 /
S3 is strongly recommended.

Restore into a scratch DB to verify:
```bash
gunzip -c backups/daily/an-YYYYMMDD-HHMMSS.sql.gz | \
  docker compose exec -T db psql -U an -d an
```

## Client wiring

Build the Flutter app with:
```
--dart-define=AN_API_BASE_URL=https://api.justin.vn
```
`AuthApi.syncSession` should be updated to keep the returned `token` and send
it as `Authorization: Bearer` on `/v1/*` calls.
