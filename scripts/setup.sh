#!/bin/bash

set -e

echo "=========================================="
echo "n8n Docker Setup Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  This script requires sudo privileges for some operations."
    echo "You may be prompted for your password."
    echo ""
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create .env file from .env.example:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "❌ Error: DOMAIN and EMAIL must be set in .env file"
    exit 1
fi

echo "📋 Configuration:"
echo "  Domain: $DOMAIN"
echo "  Email: $EMAIL"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "✅ Docker installed"
    echo "⚠️  You need to log out and log back in for docker group changes to take effect"
    echo ""
else
    echo "✅ Docker is already installed"
fi

# Check if the Docker Compose plugin is installed
if ! docker compose version &> /dev/null; then
    echo "📦 Installing Docker Compose plugin..."
    sudo apt install -y docker-compose-plugin
    echo "✅ Docker Compose plugin installed"
else
    echo "✅ Docker Compose plugin is already installed"
fi

# Configure firewall
echo ""
echo "🔥 Configuring firewall..."
if command -v ufw &> /dev/null; then
    sudo ufw allow OpenSSH
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    echo "✅ Firewall configured (ports 22, 80, 443 open)"
else
    echo "⚠️  UFW not found. Please configure firewall manually."
fi

# Set timezone
echo ""
echo "🕐 Setting timezone to Europe/Belgrade..."
sudo timedatectl set-timezone Europe/Belgrade
echo "✅ Timezone set"

# Create necessary directories
echo ""
echo "📁 Creating directories..."
mkdir -p data/n8n data/postgres data/letsencrypt
echo "✅ Directories created"

echo ""
echo "=========================================="
echo "✅ Installation completed successfully!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in"
echo "   to apply Docker group changes."
echo ""
echo "After logging back in, start the services with:"
echo ""
echo "   cd $(pwd)"
echo "   docker compose up -d"
echo ""
echo "Wait about 1-2 minutes for services to start,"
echo "then access n8n at: https://$DOMAIN"
echo ""
echo "🔐 On first access, create the n8n owner account in the UI."
echo "   Keep N8N_ENCRYPTION_KEY from .env stored securely."
echo ""
echo "📝 Useful commands:"
echo "   Check status: docker compose ps"
echo "   View logs: docker compose logs -f n8n"
echo "   Stop services: docker compose down"
echo "   Update n8n: ./scripts/update.sh"
echo ""
