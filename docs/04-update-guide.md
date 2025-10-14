# Update Guide

How to update n8n to the latest version safely.

## Why Update?

Regular updates provide:
- 🐛 Bug fixes
- ✨ New features and nodes
- 🔒 Security patches
- ⚡ Performance improvements

## Before You Update

### 1. Check Current Version

```bash
docker exec $(docker-compose ps -q n8n) n8n --version
```

### 2. Check Latest Version

Visit [n8n Releases](https://github.com/n8n-io/n8n/releases) to see what's new.

### 3. Review Changelog

Read the changelog for:
- Breaking changes
- New features
- Required migrations

### 4. Create Backup

**Always backup before updating!**

```bash
./scripts/backup.sh
```

Or manually:
```bash
# Backup database
docker-compose exec -T postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql

# Backup n8n data
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/n8n_data_$(date +%Y%m%d).tar.gz -C /data .
```

## Quick Update (Recommended)

### Using Update Script

```bash
cd ~/n8n
./scripts/update.sh
```

The script will:
1. Show current version
2. Create automatic backup
3. Stop services
4. Pull latest images
5. Start services with new version
6. Show new version

## Manual Update

If you prefer to update manually:

### Step 1: Navigate to Project Directory

```bash
cd ~/n8n
```

### Step 2: Create Backup

```bash
./scripts/backup.sh
```

### Step 3: Stop Services

```bash
docker-compose down
```

### Step 4: Pull Latest Images

Update only n8n:
```bash
docker-compose pull n8n
```

Or update all services:
```bash
docker-compose pull
```

### Step 5: Start Services

```bash
docker-compose up -d
```

### Step 6: Verify Update

```bash
# Check version
docker exec $(docker-compose ps -q n8n) n8n --version

# Check logs
docker-compose logs -f n8n

# Check status
docker-compose ps
```

### Step 7: Test n8n

Open your n8n instance and verify:
- ✅ Login works
- ✅ Workflows are intact
- ✅ Executions run correctly

## Update Specific Version

To update to a specific version instead of latest:

### Step 1: Edit docker-compose.yml

```bash
nano docker-compose.yml
```

### Step 2: Change Image Tag

Find the n8n service and change:
```yaml
# From this:
image: n8nio/n8n:latest

# To specific version (example):
image: n8nio/n8n:1.20.0
```

### Step 3: Apply Changes

```bash
docker-compose down
docker-compose pull n8n
docker-compose up -d
```

## Rollback to Previous Version

If something goes wrong after update:

### Option 1: Restore from Backup

```bash
./scripts/restore.sh /path/to/backup.tar.gz
```

### Option 2: Use Previous Docker Image

```bash
# Stop services
docker-compose down

# Edit docker-compose.yml and set previous version
nano docker-compose.yml

# Example: change to previous version
# image: n8nio/n8n:1.19.0

# Start with old version
docker-compose up -d
```

## Automated Updates

### Using Watchtower

Watchtower automatically updates Docker containers.

Add to your `docker-compose.yml`:

```yaml
  watchtower:
    image: containrrr/watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=86400  # Check daily
      - WATCHTOWER_INCLUDE_STOPPED=true
    command: n8n
```

Then restart services:
```bash
docker-compose up -d
```

**Note**: Automated updates skip backups. Consider manual updates for production.

## Update Schedule Recommendations

### Development/Testing
- Update frequently (every release)
- Test new features immediately

### Production
- Update monthly (after features are stable)
- Always backup first
- Update during maintenance windows
- Test in staging environment first

## Common Update Issues

### 1. Database Migration Fails

**Symptoms**: n8n won't start after update

**Solution**:
```bash
# Check logs
docker-compose logs n8n

# Restore from backup
./scripts/restore.sh /path/to/backup.tar.gz
```

### 2. Container Won't Start

**Check logs**:
```bash
docker-compose logs n8n
```

**Common causes**:
- Database connection issue
- Port conflict
- Permission problems

**Solution**:
```bash
# Restart all services
docker-compose down
docker-compose up -d

# Or restart specific service
docker-compose restart n8n
```

### 3. Workflows Not Working After Update

**Solution**:
1. Check n8n changelog for breaking changes
2. Update affected workflow nodes
3. Test workflows individually
4. Check credentials are still valid

### 4. SSL Certificate Issues After Update

**Solution**:
```bash
# Restart Traefik
docker-compose restart traefik

# Check Traefik logs
docker-compose logs traefik

# Verify certificate renewal
docker exec $(docker-compose ps -q traefik) ls -la /letsencrypt/
```

## Verify Update Success

After updating, verify:

### 1. Version Check
```bash
docker exec $(docker-compose ps -q n8n) n8n --version
```

### 2. Service Status
```bash
docker-compose ps
```
All services should be "Up"

### 3. Web Interface
- Open n8n in browser
- Login successfully
- Check workflows list
- Run a test workflow

### 4. Database Connection
```bash
# Check n8n logs for database errors
docker-compose logs n8n | grep -i error
```

### 5. SSL Certificate
```bash
curl -I https://your-domain.com
```
Should return HTTP/2 200

## Update Best Practices

1. **Always backup** before updating
2. **Read changelogs** to understand changes
3. **Test in staging** before production (if possible)
4. **Update during low-traffic** periods
5. **Monitor logs** after update
6. **Document** your update process
7. **Keep system updated**: `sudo apt update && sudo apt upgrade`

## Monitoring Updates

### Subscribe to n8n Releases

Watch the [n8n GitHub repository](https://github.com/n8n-io/n8n) for new releases.

### Join n8n Community

- [n8n Forum](https://community.n8n.io/)
- [n8n Discord](https://discord.gg/n8n)

## Next Steps

- [Backup & Restore](05-backup-restore.md) - Learn backup strategies
- [Troubleshooting](06-troubleshooting.md) - Fix common issues