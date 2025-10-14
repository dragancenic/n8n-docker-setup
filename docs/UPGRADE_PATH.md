# Upgrade Path

Guide for migrating from other n8n setups to this Docker-based installation.

## From n8n Cloud to Self-Hosted

### Step 1: Export from n8n Cloud

1. Login to your n8n cloud account
2. For each workflow:
   - Open the workflow
   - Click ⋮ (three dots) → **Download**
   - Save JSON file

Or export all workflows at once (if available in your plan).

### Step 2: Setup Self-Hosted

Follow the [Installation Guide](03-installation.md).

### Step 3: Import Workflows

1. Login to your self-hosted n8n
2. Click **Add Workflow** → **Import from File**
3. Select each JSON file
4. Click **Import**
5. Reconfigure credentials (they don't export for security)

### Step 4: Test Workflows

- Test each workflow individually
- Verify all credentials
- Check webhook URLs (they will be different)
- Update any external services pointing to old webhooks

### Step 5: Switch Over

1. Deactivate workflows in cloud
2. Activate workflows in self-hosted
3. Monitor for 24-48 hours
4. Cancel cloud subscription

## From Manual Docker Installation

### If Using SQLite Database

**Warning**: This setup uses PostgreSQL. SQLite data must be migrated.

```bash
# On old server - export workflows
n8n export:workflow --all --output=workflows.json
n8n export:credentials --all --output=credentials.json

# Setup new server with this repository
# Then import on new server:
n8n import:workflow --input=workflows.json
n8n import:credentials --input=credentials.json
```

### If Already Using PostgreSQL

1. **Backup old database**:
```bash
pg_dump -U your_user your_database > n8n_backup.sql
```

2. **Setup new server** with this repository

3. **Stop new n8n**:
```bash
docker-compose stop n8n
```

4. **Import database**:
```bash
cat n8n_backup.sql | docker-compose exec -T postgres psql -U n8n n8n
```

5. **Start n8n**:
```bash
docker-compose start n8n
```

## From npm/Binary Installation

### Step 1: Export Data

```bash
# Export workflows
n8n export:workflow --all --output=/tmp/workflows.json

# Export credentials  
n8n export:credentials --all --output=/tmp/credentials.json

# If using PostgreSQL, backup database
pg_dump -U n8n_user n8n_db > /tmp/n8n_backup.sql
```

### Step 2: Install Docker Version

Follow [Installation Guide](03-installation.md).

### Step 3: Import Data

```bash
# Copy exports to new server
scp /tmp/workflows.json user@new-server:/tmp/
scp /tmp/credentials.json user@new-server:/tmp/

# Import into Docker n8n
docker exec $(docker-compose ps -q n8n) n8n import:workflow --input=/tmp/workflows.json
docker exec $(docker-compose ps -q n8n) n8n import:credentials --input=/tmp/credentials.json
```

### Step 4: Stop Old Installation

```bash
# Stop npm version
pm2 stop n8n  # if using pm2
# or
systemctl stop n8n  # if using systemd
```

## From Other Docker Compose Setup

### If Configuration is Similar

1. **Backup old installation**:
```bash
docker-compose exec postgres pg_dump -U n8n n8n > old_backup.sql
```

2. **Clone this repository**:
```bash
git clone https://github.com/your-username/n8n-docker-setup.git n8n
cd n8n
```

3. **Configure .env** with same domain and credentials

4. **Stop old installation**:
```bash
cd /path/to/old/installation
docker-compose down
```

5. **Start new installation**:
```bash
cd /path/to/n8n
docker-compose up -d
```

6. **Restore data if needed**:
```bash
cat old_backup.sql | docker-compose exec -T postgres psql -U n8n n8n
```

## From Different Server

### Complete Migration

1. **On old server - Create backup**:
```bash
# Export workflows and credentials
docker exec n8n n8n export:workflow --all --output=/tmp/workflows.json
docker exec n8n n8n export:credentials --all --output=/tmp/credentials.json

# Backup database
docker exec postgres pg_dump -U n8n n8n > backup.sql

# Backup n8n data
docker run --rm -v old_n8n_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/n8n_data.tar.gz -C /data .
```

2. **Transfer files to new server**:
```bash
scp workflows.json backup.sql n8n_data.tar.gz user@new-server:/tmp/
```

3. **On new server - Setup**:
```bash
# Clone and configure
git clone https://github.com/your-username/n8n-docker-setup.git n8n
cd n8n
cp .env.example .env
nano .env  # Configure with OLD domain or new domain

# Install
./scripts/setup.sh

# Log out and log back in
exit

# After logging back in, start services
cd n8n
docker-compose up -d
```

4. **Restore data**:
```bash
# Stop n8n temporarily
docker-compose stop n8n

# Restore database
cat /tmp/backup.sql | docker-compose exec -T postgres psql -U n8n n8n

# Restore n8n data
docker run --rm \
  -v n8n_n8n_data:/target \
  -v /tmp:/backup \
  alpine sh -c "cd /target && tar xzf /backup/n8n_data.tar.gz"

# Start n8n
docker-compose start n8n
```

5. **Update DNS**:
- Point domain to new server IP
- Wait for DNS propagation

6. **Verify and decommission old server**

## From Docker without Traefik (nginx/Apache)

### Step 1: Backup Current Setup

```bash
# Backup database
docker exec postgres pg_dump -U n8n n8n > backup.sql

# Export workflows
docker exec n8n n8n export:workflow --all --output=/tmp/workflows.json
```

### Step 2: Install This Setup

Follow [Installation Guide](03-installation.md).

This setup includes Traefik, so you can remove nginx/Apache.

### Step 3: Remove Old Reverse Proxy

```bash
# Stop and disable nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# Or Apache
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### Step 4: Import Data

Use restore script or manual import as shown above.

## Version Compatibility

### n8n Version Differences

If migrating between different n8n versions:

1. Check [n8n changelog](https://github.com/n8n-io/n8n/releases) for breaking changes
2. Update workflows if needed
3. Test thoroughly before going live

### Database Schema

PostgreSQL schema is managed by n8n migrations. When starting with existing data:
- n8n automatically runs migrations
- Check logs for migration status: `docker-compose logs n8n`

## Common Migration Issues

### Credentials Not Working

**Cause**: Encryption keys are different

**Solution**:
1. Export credentials from old installation
2. Re-enter sensitive data in new installation

### Webhook URLs Changed

**Cause**: Different domain or setup

**Solution**:
1. Update webhook URLs in external services
2. Update webhook nodes in workflows

### Timezone Issues

**Cause**: Different server timezone

**Solution**:
```bash
# Set in .env
GENERIC_TIMEZONE=Europe/Belgrade
TZ=Europe/Belgrade

# Restart
docker-compose restart n8n
```

### Executions Missing

**Cause**: Execution history not migrated

**Solution**:
- Execution history is stored in database
- If database restored, executions should be there
- Check n8n settings for execution retention

## Post-Migration Checklist

- [ ] All workflows imported
- [ ] All credentials reconfigured
- [ ] Workflows execute successfully
- [ ] Webhooks updated in external services
- [ ] Scheduled workflows running
- [ ] Email notifications working
- [ ] Backups configured
- [ ] Old installation decommissioned
- [ ] DNS updated (if changed)
- [ ] SSL certificate valid

## Rollback Plan

If migration fails:

1. **Keep old server running** until new setup verified
2. **Don't delete old data** for at least 1 week
3. **DNS can be reverted** quickly if needed
4. **Document all changes** made during migration

## Migration Timeline

**Recommended migration schedule**:

### Week 1: Preparation
- Setup new server
- Test basic installation
- Practice data migration in test environment

### Week 2: Migration
- Perform actual migration
- Import all data
- Test workflows
- Run both systems in parallel

### Week 3: Verification
- Monitor new installation
- Verify all workflows
- Check for issues
- Keep old system as backup

### Week 4: Finalization
- Decommission old server (if all OK)
- Document new setup
- Update team procedures

## Testing Migration

Before migrating production:

1. **Test in staging**:
```bash
# Create test server
# Perform migration steps
# Verify everything works
```

2. **Test critical workflows**:
- Run each important workflow manually
- Verify outputs are correct
- Check integrations work

3. **Load testing** (if high volume):
- Simulate production load
- Monitor performance
- Adjust resources if needed

## Need Help?

Migration questions:
- Check [Troubleshooting Guide](06-troubleshooting.md)
- Ask in [n8n Community](https://community.n8n.io/)
- Open [GitHub Issue](https://github.com/your-username/n8n-docker-setup/issues)

## Migration Support

For complex migrations:
- Consider hiring n8n expert
- Engage n8n professional services
- Consult with DevOps specialist

---

**Remember**: Always backup before migration! Test thoroughly before going live.