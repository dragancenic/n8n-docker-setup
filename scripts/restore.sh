#!/bin/bash

set -e

echo "=========================================="
echo "n8n Restore Script"
echo "=========================================="
echo ""

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide backup file path"
    echo "Usage: ./scripts/restore.sh /path/to/backup.tar.gz"
    echo ""
    echo "Available backups:"
    ls -lh backups/*.tar.gz 2>/dev/null || echo "No backups found in backups/ directory"
    exit 1
fi

BACKUP_FILE=$1

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "📦 Backup file: $BACKUP_FILE"
echo ""

# Ask for confirmation
read -p "⚠️  This will restore n8n from backup. Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract backup
echo ""
echo "📂 Extracting backup..."
tar xzf $BACKUP_FILE -C $TEMP_DIR
echo "✅ Backup extracted"

# Stop services
echo ""
echo "🛑 Stopping services..."
docker-compose down

# Restore configuration files (optional)
if [ -f $TEMP_DIR/.env.backup ]; then
    echo ""
    read -p "Do you want to restore .env configuration? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp $TEMP_DIR/.env.backup .env
        echo "✅ Configuration restored"
    fi
fi

# Start only PostgreSQL to restore database
echo ""
echo "🗄️  Starting PostgreSQL..."
docker-compose up -d postgres
sleep 10

# Load environment variables
source .env

# Restore PostgreSQL database
echo ""
echo "💾 Restoring PostgreSQL database..."
docker-compose exec -T postgres psql -U ${POSTGRES_USER:-n8n} -d ${POSTGRES_DB:-n8n} -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker-compose exec -T postgres psql -U ${POSTGRES_USER:-n8n} ${POSTGRES_DB:-n8n} < $TEMP_DIR/postgres_dump.sql
echo "✅ Database restored"

# Restore n8n data
echo ""
echo "📁 Restoring n8n data..."
docker-compose down
docker volume rm $(docker-compose config --volumes | grep n8n_data) 2>/dev/null || true
docker-compose up -d postgres
sleep 5
docker-compose up -d n8n
sleep 5
docker-compose down

# Extract n8n data to volume
docker run --rm \
    -v $(docker volume inspect n8n-docker-setup_n8n_data | grep Mountpoint | awk '{print $2}' | tr -d '",'):/target \
    -v $TEMP_DIR:/backup \
    alpine sh -c "cd /target && tar xzf /backup/n8n_data.tar.gz"
echo "✅ n8n data restored"

# Start all services
echo ""
echo "🚀 Starting all services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 20

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "=========================================="
    echo "✅ Restore completed successfully!"
    echo "=========================================="
    echo ""
    echo "🌐 Access n8n at your configured domain"
    echo ""
    echo "📝 Check logs: docker-compose logs -f n8n"
else
    echo ""
    echo "❌ Something went wrong. Check logs with:"
    echo "   docker-compose logs"
fi