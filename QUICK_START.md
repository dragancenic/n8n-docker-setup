# Quick Start Guide

Get n8n running in 5 minutes!

## Prerequisites

- Ubuntu Server 20.04+ with root access
- Domain name pointing to your server
- Ports 80 and 443 available

## Installation in 4 Steps

### 1. Clone and Configure

```bash
# Clone repository
git clone https://github.com/your-username/n8n-docker-setup.git n8n
cd n8n

# Configure environment
cp .env.example .env
nano .env
```

**Update these values in .env:**
```bash
DOMAIN=your-domain.com
EMAIL=your-email@example.com
N8N_BASIC_AUTH_PASSWORD=YourStrongPassword123
POSTGRES_PASSWORD=AnotherStrongPassword456
```

### 2. Run Setup Script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 3. Wait 2 Minutes

The script will:
- ✅ Install Docker
- ✅ Configure firewall
- ✅ Start services
- ✅ Generate SSL certificate

### 4. Access n8n

Open in browser: `https://your-domain.com`

Login with credentials from your `.env` file.

## That's It! 🎉

Your n8n is now running with:
- ✅ HTTPS enabled
- ✅ PostgreSQL database
- ✅ Automatic SSL renewal
- ✅ Persistent data storage

## Next Steps

- [Create your first workflow](https://docs.n8n.io/courses/level-one/)
- [Set up automated backups](docs/05-backup-restore.md#automated-backups)
- [Learn about updates](docs/04-update-guide.md)

## Common First-Time Issues

**Can't access n8n?**
```bash
# Check if services are running
docker-compose ps

# View logs
docker-compose logs -f
```

**Need help?** Check [Troubleshooting Guide](docs/06-troubleshooting.md)