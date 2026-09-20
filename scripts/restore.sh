#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"
umask 077

if [ "$#" -ne 1 ]; then
  echo "Usage: ./scripts/restore.sh /path/to/backup.tar.gz"; exit 1
fi
ENV_FILE="${N8N_ENV_FILE:-.env}"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: environment file not found: $ENV_FILE"; exit 1
fi
BACKUP_FILE="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"; exit 1
fi
if tar -tzf "$BACKUP_FILE" | grep -Eq '(^/|(^|/)\.\.(/|$))'; then
  echo "Error: Backup archive contains unsafe paths."; exit 1
fi
for required_file in postgres_dump.sql n8n_data.tar.gz docker-compose.yml .env.backup; do
  tar -tzf "$BACKUP_FILE" | grep -qx "$required_file" || { echo "Error: archive is missing $required_file"; exit 1; }
done

echo "WARNING: This replaces the PostgreSQL data and n8n data volume."
read -r -p "Continue? (y/n) " reply
[[ "$reply" =~ ^[Yy]$ ]] || { echo "Restore cancelled."; exit 0; }

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
read -r -p "Restore the archived .env too? (y/n) " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then cp "$TEMP_DIR/.env.backup" "$ENV_FILE"; fi

set -a
source "$ENV_FILE"
set +a
N8N_CONTAINER_ID="$(docker compose ps -q n8n)"
N8N_VOLUME="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Name}}{{end}}{{end}}' "$N8N_CONTAINER_ID")"
if [ -z "$N8N_VOLUME" ]; then
  echo "Error: Could not identify the n8n data volume."; exit 1
fi

docker compose down
docker compose up -d postgres
postgres_ready=false
for _ in $(seq 1 30); do
  if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-n8n}" -d "${POSTGRES_DB:-n8n}" > /dev/null 2>&1; then postgres_ready=true; break; fi
  sleep 2
done
if [ "$postgres_ready" != true ]; then
  echo "Error: PostgreSQL did not become ready within 60 seconds."; exit 1
fi

docker compose exec -T postgres psql --set ON_ERROR_STOP=on -U "${POSTGRES_USER:-n8n}" -d "${POSTGRES_DB:-n8n}" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker compose exec -T postgres psql --set ON_ERROR_STOP=on -U "${POSTGRES_USER:-n8n}" -d "${POSTGRES_DB:-n8n}" < "$TEMP_DIR/postgres_dump.sql"

docker compose down
docker volume rm "$N8N_VOLUME" > /dev/null 2>&1 || true
docker volume create "$N8N_VOLUME" > /dev/null
docker run --rm -v "$N8N_VOLUME:/target" -v "$TEMP_DIR:/backup:ro" alpine sh -c "cd /target && tar xzf /backup/n8n_data.tar.gz"

docker compose up -d
for _ in $(seq 1 30); do
  if docker compose ps --status running --services | grep -qx 'n8n'; then
    echo "Restore completed. Verify the n8n UI and a webhook before returning to production traffic."
    exit 0
  fi
  sleep 2
done
echo "n8n did not reach the running state within 60 seconds. Check: docker compose logs n8n"
exit 1
