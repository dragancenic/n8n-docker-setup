# Backup & Restore

Complete guide for backing up and restoring your n8n installation.

## Why Backup?

Protect against:
- 💥 Hardware failures
- 🐛 Software bugs
- 👤 Human errors
- 🔧 Failed updates
- 🔒 Security incidents

## What to Backup

Your n8n installation includes:

1. **PostgreSQL Database** - Workflows, executions, credentials
2. **n8n Data Directory** - Binary data, encryption keys
3. **Configuration Files** - `.env`, `docker-compose.yml`

## Quick Backup (Recommended)

### Using Backup Script

```bash
cd ~/n8n-docker-setup
./scripts/backup.sh
```

This creates a complete backup in `backups/` directory.

Backup includes:
- ✅ PostgreSQL dump
- ✅ n8n data volume
- ✅ Configuration files
- ✅ Timestamped filename

## Manual Backup

If you prefer manual backup:

### Step 1: Create Backup Directory

```bash
mkdir -p ~/n8n-backups
cd ~/n8n-backups
```

### Step 2: Backup PostgreSQL Database

```bash
docker-compose exec -T postgres pg_dump -U n8n n8n > n8n_db_$(date +%Y%m%d_%H%M%S).sql
```

### Step 3: Backup n8n Data Volume

```bash
docker run --rm \
  -v n8n_n8n_data:/data:ro \
  -v $(pwd):/backup \
  alpine tar czf /backup/n8n_data_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

### Step 4: Backup Configuration Files

```bash
cp ~/n8n-docker-setup/.env ./env_backup_$(date +%Y%m%d).txt
cp ~/n8n-docker-setup/docker-compose.yml ./docker-compose_backup_$(date +%Y%m%d).yml
```

## Automated Backups

### Daily Backup with Cron

Create backup script:

```bash
nano ~/backup-n8n.sh
```

Add content:
```bash
#!/bin/bash
cd ~/n8n-docker-setup
./scripts/backup.sh

# Keep only last 7 backups
cd backups
ls -t | tail -n +8 | xargs -r rm
```

Make executable:
```bash
chmod +x ~/backup-n8n.sh
```

Add to crontab:
```bash
crontab -e
```

Add this line (runs daily at 2 AM):
```
0 2 * * * /home/yourusername/backup-n8n.sh >> /home/yourusername/backup.log 2>&1
```

### Backup to Remote Storage

#### Using rsync to Remote Server

```bash
#!/bin/bash
BACKUP_FILE=$(ls -t ~/n8n-docker-setup/backups/*.tar.gz | head -1)
rsync -avz $BACKUP_FILE user@backup-server:/path/to/backups/
```

#### Using AWS S3

Install AWS CLI:
```bash
sudo apt install -y awscli
aws configure
```

Upload backup:
```bash
#!/bin/bash
BACKUP_FILE=$(ls -t ~/n8n-docker-setup/backups/*.tar.gz | head -1)
aws s3 cp $BACKUP_FILE s3://your-bucket/n8n-backups/
```

## Restore from Backup

### Using Restore Script

```bash
cd ~/n8n-docker-setup

# List available backups
ls -lh backups/

# Restore from specific backup
./scripts/restore.sh backups/n8n_backup_20241009_143022.tar.gz
```

### Manual Restore

If you prefer manual restoration:

#### Step 1: Stop Services

```bash
cd ~/n8n-docker-setup
docker-compose down
```

#### Step 2: Restore Database

```bash
# Start only PostgreSQL
docker-compose up -d postgres
sleep 10

# Drop and recreate database
docker-compose exec postgres psql -U n8n -c "DROP DATABASE IF EXISTS n8n;"
docker-compose exec postgres psql -U n8n -c "CREATE DATABASE n8n;"

# Restore from backup
cat /path/to/backup.sql | docker-compose exec -T postgres psql -U n8n n8n
```

#### Step 3: Restore n8n Data

```bash
# Remove old volume
docker volume rm n8n_n8n_data

# Create new volume and restore
docker-compose up -d postgres n8n
sleep 5
docker-compose down

docker run --rm \
  -v n8n_n8n_data:/data \
  -v /path/to:/backup \
  alpine sh -c "cd /data && tar xzf /backup/n8n_data_backup.tar.gz"
```

#### Step 4: Restore Configuration (Optional)

```bash
cp /path/to/env_backup.txt .env
cp /path/to/docker-compose_backup.yml docker-compose.yml
```

#### Step 5: Start All Services

```bash
docker-compose up -d
```

#### Step 6: Verify

```bash
# Check services
docker-compose ps

# Check logs
docker-compose logs -f n8n

# Test access
curl -I https://your-domain.com
```

## Backup Strategies

### Strategy 1: Simple Daily Backup

**Best for**: Small teams, development

- Daily automated backups
- Keep last 7 days
- Local storage only

### Strategy 2: 3-2-1 Backup Rule

**Best for**: Production environments

- **3** copies of data
- **2** different storage types
- **1** offsite copy

Implementation:
1. Original data (live n8n)
2. Local backup (on server)
3. Remote backup (cloud storage)

### Strategy 3: Continuous Backup

**Best for**: Critical workflows

- Backup after major changes
- Daily automated backups
- Weekly full backups to remote storage
- Monthly archival backups

## Backup Testing

**Test your backups regularly!**

### Monthly Restore Test

```bash
# 1. Create test backup
./scripts/backup.sh

# 2. Note current workflows count
# (check in n8n interface)

# 3. Restore in test environment
# (or use separate Docker Compose project)

# 4. Verify workflows count matches

# 5. Test sample workflow execution
```

## Export/Import Workflows

### Export Single Workflow

In n8n interface:
1. Open workflow
2. Click ⋮ (three dots)
3. Select **Download**
4. Save JSON file

### Export All Workflows

```bash
# Install n8n CLI (if needed)
npm install -g n8n

# Export all workflows
docker exec $(docker-compose ps -q n8n) n8n export:workflow --all --output=/home/node/.n8n/workflows_export.json

# Copy from container
docker cp $(docker-compose ps -q n8n):/home/node/.n8n/workflows_export.json ./
```

### Import Workflows

In n8n interface:
1. Click **Add Workflow** → **Import from File**
2. Select JSON file
3. Click **Import**

## Disaster Recovery Plan

### If Server Crashes

1. **Spin up new server** ([Server Preparation](01-server-preparation.md))
2. **Configure DNS** (point to new server)
3. **Install n8n** ([Installation Guide](03-installation.md))
4. **Restore from backup** (this guide)
5. **Verify everything works**

### If Database Corrupts

```bash
# Stop n8n
docker-compose stop n8n

# Restore database only
docker-compose exec postgres psql -U n8n -c "DROP DATABASE n8n;"
docker-compose exec postgres psql -U n8n -c "CREATE DATABASE n8n;"
cat backup.sql | docker-compose exec -T postgres psql -U n8n n8n

# Restart n8n
docker-compose start n8n
```

### If Configuration Lost

```bash
# Restore .env from backup
cp backups/.env.backup .env

# Restart services
docker-compose down
docker-compose up -d
```

## Backup Size Management

### Check Backup Sizes

```bash
du -sh backups/*
```

### Clean Old Backups

```bash
# Keep only last 10 backups
cd backups
ls -t *.tar.gz | tail -n +11 | xargs -r rm
```

### Compress Backups

```bash
# Backups are already compressed with tar.gz
# For additional compression, use:
xz -9 backup.tar.gz  # Creates backup.tar.gz.xz
```

## Security Considerations

### Encrypt Backups

```bash
# Encrypt backup with GPG
gpg --symmetric --cipher-algo AES256 backup.tar.gz

# Decrypt when needed
gpg --decrypt backup.tar.gz.gpg > backup.tar.gz
```

### Secure Storage

- ✅ Store backups on separate physical device
- ✅ Use encrypted storage
- ✅ Limit backup file permissions:
  ```bash
  chmod 600 backup.tar.gz
  ```
- ✅ Don't store passwords in backup scripts
- ✅ Use cloud storage with encryption

## Monitoring Backups

### Check Last Backup

```bash
ls -lht backups/ | head -5
```

### Backup Alert Script

```bash
#!/bin/bash
BACKUP_DIR=~/n8n-docker-setup/backups
LATEST=$(ls -t $BACKUP_DIR/*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
    echo "ERROR: No backups found!"
    exit 1
fi

AGE=$(( ($(date +%s) - $(stat -c %Y "$LATEST")) / 86400 ))

if [ $AGE -gt 2 ]; then
    echo "WARNING: Last backup is $AGE days old!"
    # Send alert (email, Slack, etc.)
fi
```

## Best Practices

1. **Automate backups** - Don't rely on manual backups
2. **Test restores** - Verify backups work monthly
3. **Multiple locations** - Local + remote storage
4. **Monitor backup jobs** - Set up alerts
5. **Document process** - Keep recovery instructions
6. **Version control** - Track configuration changes
7. **Encrypt sensitive data** - Especially for remote storage
8. **Regular cleanup** - Remove old backups to save space

## Next Steps

- [Troubleshooting](06-troubleshooting.md) - Fix common issues
- Set up automated backups
- Test your restore process