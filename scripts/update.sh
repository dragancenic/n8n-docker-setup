#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "=========================================="
echo "n8n Update Script"
echo "=========================================="
echo ""

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo "❌ Error: docker-compose.yml not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Check current version
echo "📊 Current n8n version:"
docker exec $(docker compose ps -q n8n 2>/dev/null) n8n --version 2>/dev/null || echo "Unable to detect version"
echo ""

# Ask for confirmation
read -r -p "Pull the image versions currently pinned in .env? (y/n) " REPLY
echo ""
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

# Create backup before update
echo ""
echo "💾 Creating backup before update..."
if [ -f scripts/backup.sh ]; then
    ./scripts/backup.sh
    echo "✅ Backup created"
else
    echo "⚠️  Backup script not found. Continuing without backup..."
fi

# Stop services
echo ""
echo "🛑 Stopping services..."
docker compose down

# Pull the explicitly configured images
echo ""
echo "📥 Pulling configured images..."
docker compose pull

# Start services
echo ""
echo "🚀 Starting services with new images..."
docker compose up -d

# Wait for services
echo ""
echo "⏳ Waiting for services to start..."
sleep 20

# Check if services are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "=========================================="
    echo "✅ Update completed successfully!"
    echo "=========================================="
    echo ""
    echo "📊 New n8n version:"
    docker exec $(docker compose ps -q n8n) n8n --version
    echo ""
    echo "🌐 Access n8n at your configured domain"
    echo ""
    echo "📝 Check logs: docker compose logs -f n8n"
else
    echo ""
    echo "❌ Something went wrong. Check logs with:"
    echo "   docker compose logs"
    echo ""
    echo "To rollback, restore from backup using:"
    echo "   ./scripts/restore.sh /path/to/backup.tar.gz"
fi
