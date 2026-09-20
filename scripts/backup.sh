#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"
umask 077

echo "=========================================="
echo "n8n Backup Script"
echo "=========================================="
echo ""

ENV_FILE="${N8N_ENV_FILE:-.env}"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: environment file not found: $ENV_FILE"
    exit 1
fi

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

BACKUP_DIR="$PROJECT_DIR/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.tar.gz"

echo "📦 Creating backup..."
echo "Backup file: $BACKUP_FILE"
echo "⚠️  The archive contains .env and must be stored securely."
echo ""

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

if ! docker compose ps --status running --services | grep -qx 'postgres'; then
    echo "❌ Error: PostgreSQL is not running. Start the stack before creating a backup."
    exit 1
fi

N8N_CONTAINER_ID="$(docker compose ps -q n8n)"
if [ -z "$N8N_CONTAINER_ID" ]; then
    echo "❌ Error: n8n container was not found. Start the stack before creating a backup."
    exit 1
fi

N8N_VOLUME="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Name}}{{end}}{{end}}' "$N8N_CONTAINER_ID")"
if [ -z "$N8N_VOLUME" ]; then
    echo "❌ Error: Could not identify the n8n data volume."
    exit 1
fi

echo "💾 Backing up PostgreSQL database..."
docker compose exec -T postgres pg_dump --no-owner --no-privileges \
    -U "${POSTGRES_USER:-n8n}" "${POSTGRES_DB:-n8n}" > "$TEMP_DIR/postgres_dump.sql"
echo "✅ Database backup completed"

echo ""
echo "📁 Backing up n8n data..."
docker run --rm \
    -v "$N8N_VOLUME:/source:ro" \
    -v "$TEMP_DIR:/backup" \
    alpine tar czf /backup/n8n_data.tar.gz -C /source .
echo "✅ n8n data backup completed"

echo ""
echo "📋 Backing up configuration files..."
cp docker-compose.yml "$TEMP_DIR/"
cp "$ENV_FILE" "$TEMP_DIR/.env.backup"
echo "✅ Configuration files backed up"

echo ""
echo "🗜️  Creating and verifying compressed archive..."
tar -C "$TEMP_DIR" -czf "$BACKUP_FILE" postgres_dump.sql n8n_data.tar.gz docker-compose.yml .env.backup
tar -tzf "$BACKUP_FILE" > /dev/null
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

echo ""
echo "=========================================="
echo "✅ Backup completed successfully!"
echo "=========================================="
echo ""
echo "📦 Backup file: $BACKUP_FILE"
echo "💾 Size: $BACKUP_SIZE"
echo ""
echo "📝 To restore from this backup:"
echo "   ./scripts/restore.sh $BACKUP_FILE"
echo ""
