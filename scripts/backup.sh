#!/bin/bash

set -e

echo "=========================================="
echo "n8n Backup Script"
echo "=========================================="
echo ""

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Create backup directory
BACKUP_DIR="backups"
mkdir -p $BACKUP_DIR

# Generate backup filename with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.tar.gz"

echo "📦 Creating backup..."
echo "Backup file: $BACKUP_FILE"
echo ""

# Create temporary directory for backup
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Backup PostgreSQL database
echo "💾 Backing up PostgreSQL database..."
docker-compose exec -T postgres pg_dump -U ${POSTGRES_USER:-n8n} ${POSTGRES_DB:-n8n} > $TEMP_DIR/postgres_dump.sql
echo "✅ Database backup completed"

# Backup n8n data directory
echo ""
echo "📁 Backing up n8n data..."
docker run --rm \
    -v $(docker volume inspect $(docker-compose ps -q n8n | xargs docker inspect --format='{{range .Mounts}}{{.Name}}{{end}}' | grep n8n_data)| grep Mountpoint | awk '{print $2}' | tr -d '",'):/source:ro \
    -v $TEMP_DIR:/backup \
    alpine tar czf /backup/n8n_data.tar.gz -C /source .
echo "✅ n8n data backup completed"

# Backup configuration files
echo ""
echo "📋 Backing up configuration files..."
cp docker-compose.yml $TEMP_DIR/
cp .env $TEMP_DIR/.env.backup
echo "✅ Configuration files backed up"

# Create final compressed archive
echo ""
echo "🗜️  Creating compressed archive..."
cd $TEMP_DIR
tar czf $BACKUP_FILE postgres_dump.sql n8n_data.tar.gz docker-compose.yml .env.backup
cd - > /dev/null

# Calculate backup size
BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)

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