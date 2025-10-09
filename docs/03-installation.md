# Installation Guide

Step-by-step guide to install n8n with Docker, PostgreSQL, and automatic HTTPS.

## Prerequisites

Before starting, make sure you have completed:
- ✅ [Server Preparation](01-server-preparation.md)
- ✅ [DNS Configuration](02-dns-configuration.md)

Verify DNS is working:
```bash
nslookup your-domain.com
```

## Quick Installation (Recommended)

### Step 1: Clone the Repository

```bash
cd ~
git clone https://github.com/your-username/n8n-docker-setup.git
cd n8n-docker-setup
```

### Step 2: Configure Environment

```bash
cp .env.example .env
nano .env
```

Update the following variables:

```bash
# Your domain (without https://)
DOMAIN=automata.yourdomain.com

# Email for Let's Encrypt notifications
EMAIL=admin@yourdomain.com

# n8n login credentials
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=YourStrongPassword123!

# PostgreSQL password
POSTGRES_PASSWORD=AnotherStrongPassword456!
```

**Important**: Use strong, unique passwords!

### Step 3: Run Installation Script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The script will:
- Install Docker and docker-compose (if needed)
- Configure firewall
- Set timezone
- Create necessary directories
- Start all services

### Step 4: Wait for Services

Wait about 1-2 minutes for:
- Services to start
- Let's Encrypt to issue SSL certificate
- n8n to initialize database

### Step 5: Access n8n

Open your browser and navigate to:
```
https://your-domain.com
```

Login with credentials from your `.env` file.

## Manual Installation

If you prefer manual installation:

### Step 1: Create Project Directory

```bash
mkdir ~/n8n && cd ~/n8n
```

### Step 2: Create .env File

```bash
nano .env
```

Add configuration:
```bash
DOMAIN=automata.yourdomain.com
EMAIL=admin@yourdomain.com
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=change_this_password
POSTGRES_USER=n8n
POSTGRES_PASSWORD=change_this_db_password
POSTGRES_DB=n8n
GENERIC_TIMEZONE=Europe/Belgrade
TZ=Europe/Belgrade
```

### Step 3: Create docker-compose.yml

```bash
nano docker-compose.yml
```

Copy the contents from the repository's `docker-compose.yml` file.

### Step 4: Start Services

```bash
docker-compose up -d
```

### Step 5: Check Status

```bash
docker-compose ps
```

All services should show "Up" status.

## Verification

### Check Running Services

```bash
docker-compose ps
```

Expected output:
```
NAME                SERVICE    STATUS      PORTS
n8n-n8n-1          n8n        Up          
n8n-postgres-1     postgres   Up          5432/tcp
n8n-traefik-1      traefik    Up          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

### View Logs

```bash
# All services
docker-compose logs

# n8n only
docker-compose logs n8n

# Follow logs in real-time
docker-compose logs -f n8n
```

### Test HTTPS

```bash
curl -I https://your-domain.com
```

Should return `HTTP/2 200` with valid SSL certificate.

### Check n8n Version

```bash
docker exec $(docker-compose ps -q n8n) n8n --version
```

## First Login

1. Open `https://your-domain.com` in your browser
2. You'll see a login screen
3. Enter credentials from your `.env` file:
   - Username: (your N8N_BASIC_AUTH_USER)
   - Password: (your N8N_BASIC_AUTH_PASSWORD)
4. You'll be redirected to n8n dashboard

## Post-Installation Setup

### Change Admin Password

After first login, it's recommended to change your password:

1. Stop services: `docker-compose down`
2. Edit `.env` file: `nano .env`
3. Change `N8N_BASIC_AUTH_PASSWORD`
4. Start services: `docker-compose up -d`

### Configure n8n Settings

In the n8n interface:
1. Click on your profile (bottom left)
2. Go to **Settings**
3. Configure:
   - Personal settings
   - Credentials
   - Variables
   - External secrets

## Common Issues

### 1. Can't Access n8n (Connection Refused)

**Check if services are running:**
```bash
docker-compose ps
```

**Check logs:**
```bash
docker-compose logs traefik
docker-compose logs n8n
```

**Possible solutions:**
- Wait 2-3 minutes for services to fully start
- Verify DNS is resolving correctly
- Check firewall rules: `sudo ufw status`

### 2. SSL Certificate Error

**Problem**: Browser shows "Your connection is not private"

**Solutions:**
- Wait a few minutes for Let's Encrypt to issue certificate
- Check Traefik logs: `docker-compose logs traefik`
- Verify domain resolves to correct IP: `nslookup your-domain.com`
- Make sure ports 80 and 443 are open
- Ensure no Cloudflare proxy is enabled (use DNS-only mode)

### 3. Database Connection Error

**Check PostgreSQL:**
```bash
docker-compose logs postgres
```

**Restart services:**
```bash
docker-compose down
docker-compose up -d
```

### 4. Port Already in Use

**Error**: `Bind for 0.0.0.0:80 failed: port is already allocated`

**Solution:**
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting service (example: Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### 5. Permission Denied Errors

**Solution:**
```bash
# Make sure you're in docker group
sudo usermod -aG docker $USER

# Log out and log back in
exit

# Or use sudo for docker commands
sudo docker-compose up -d
```

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Update n8n
docker-compose pull n8n
docker-compose up -d

# Access n8n container shell
docker exec -it $(docker-compose ps -q n8n) sh

# Access PostgreSQL
docker exec -it $(docker-compose ps -q postgres) psql -U n8n
```

## Next Steps

Now that n8n is installed and running:

- [Update Guide](04-update-guide.md) - Keep n8n up to date
- [Backup & Restore](05-backup-restore.md) - Protect your data
- [n8n Documentation](https://docs.n8n.io/) - Learn to create workflows

## Security Reminders

- ✅ Use strong passwords
- ✅ Keep system updated: `sudo apt update && sudo apt upgrade`
- ✅ Regularly backup your data
- ✅ Monitor logs for suspicious activity
- ✅ Consider setting up automated backups