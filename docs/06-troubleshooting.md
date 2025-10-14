# Troubleshooting

Common issues and solutions for n8n Docker installation.

## Quick Diagnostics

Run these commands first:

```bash
# Check all services status
docker-compose ps

# View all logs
docker-compose logs --tail=100

# Check system resources
df -h  # Disk space
free -h  # Memory
top  # CPU usage
```

## Connection Issues

### Can't Access n8n (Connection Refused/Timeout)

**Symptoms**:
- Browser shows "Connection refused"
- Can't reach https://your-domain.com

**Diagnostic Steps**:

```bash
# 1. Check if services are running
docker-compose ps

# 2. Check if ports are open
sudo netstat -tlnp | grep -E ':(80|443)'

# 3. Check DNS resolution
nslookup your-domain.com

# 4. Test local connection
curl -I http://localhost:80
curl -I https://localhost:443

# 5. Check firewall
sudo ufw status
```

**Solutions**:

1. **Services not running**:
```bash
docker-compose down
docker-compose up -d
```

2. **Firewall blocking**:
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

3. **DNS not resolving**:
- Wait for DNS propagation (5-60 minutes)
- Verify A record points to correct IP
- Clear DNS cache on your computer

4. **Port conflict**:
```bash
# Find what's using port 80/443
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting service (example)
sudo systemctl stop apache2
```

### Can Access HTTP but not HTTPS

**Symptoms**:
- `http://your-domain.com` works
- `https://your-domain.com` shows certificate error

**Diagnostic Steps**:

```bash
# Check Traefik logs
docker-compose logs traefik | grep -i error

# Check certificate file
docker exec $(docker-compose ps -q traefik) ls -la /letsencrypt/acme.json
```

**Solutions**:

1. **Wait for certificate generation** (2-5 minutes)
2. **Verify domain resolves correctly**:
```bash
curl -I http://your-domain.com
```

3. **Check Let's Encrypt rate limits**:
- 5 certificates per domain per week
- Wait 1 week if exceeded

4. **Disable Cloudflare proxy** (if using):
- Go to DNS settings
- Turn proxy off (gray cloud icon)

5. **Restart Traefik**:
```bash
docker-compose restart traefik
```

## SSL Certificate Issues

### Certificate Not Valid / Self-Signed Certificate Error

**Solutions**:

```bash
# 1. Check Traefik configuration
docker-compose logs traefik

# 2. Remove old certificates
docker-compose down
docker volume rm n8n_letsencrypt
docker-compose up -d

# Wait 2-3 minutes for new certificate
```

### Certificate Expired

```bash
# Traefik automatically renews, but if needed:
docker-compose restart traefik

# Force certificate refresh
docker-compose down
docker volume rm n8n_letsencrypt
docker-compose up -d
```

## Service Issues

### n8n Container Keeps Restarting

**Check logs**:
```bash
docker-compose logs n8n
```

**Common causes**:

1. **Database connection failed**:
```bash
# Check PostgreSQL
docker-compose logs postgres

# Verify credentials in .env match docker-compose.yml
cat .env | grep POSTGRES
```

2. **Out of memory**:
```bash
# Check memory usage
free -h

# Add swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

3. **Permission issues**:
```bash
# Fix permissions
docker-compose down
sudo chown -R 1000:1000 $(docker volume inspect n8n_n8n_data | grep Mountpoint | awk '{print $2}' | tr -d '",')
docker-compose up -d
```

### PostgreSQL Won't Start

**Check logs**:
```bash
docker-compose logs postgres
```

**Solutions**:

1. **Data corruption**:
```bash
docker-compose down
docker volume rm n8n_postgres_data
docker-compose up -d postgres

# Restore from backup
./scripts/restore.sh /path/to/backup.tar.gz
```

2. **Port conflict**:
```bash
# Check if port 5432 is used
sudo lsof -i :5432

# Change port in docker-compose.yml if needed
```

### Traefik Shows 404 Error

**Symptoms**: Traefik is running but shows "404 page not found"

**Solutions**:

```bash
# 1. Check n8n is running
docker-compose ps

# 2. Verify labels are correct
docker inspect $(docker-compose ps -q n8n) | grep -A 10 Labels

# 3. Restart all services
docker-compose restart
```

## Performance Issues

### n8n is Slow / High CPU Usage

**Diagnostic**:

```bash
# Check resource usage
docker stats

# Check workflow executions
docker-compose logs n8n | grep -i execution
```

**Solutions**:

1. **Increase resources**:
```bash
# Add to docker-compose.yml under n8n service:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

2. **Optimize workflows**:
- Reduce execution frequency
- Use webhooks instead of polling
- Limit data processing

3. **Clean old executions**:
In n8n interface: Settings → Executions → Clear all

### Database Growing Too Large

**Check size**:
```bash
docker exec $(docker-compose ps -q postgres) psql -U n8n -c "SELECT pg_size_pretty(pg_database_size('n8n'));"
```

**Solutions**:

1. **Clear old executions in n8n interface**
2. **Reduce execution retention**:
```yaml
# Add to n8n environment in docker-compose.yml
- EXECUTIONS_DATA_PRUNE=true
- EXECUTIONS_DATA_MAX_AGE=168  # 7 days in hours
```

3. **Vacuum database**:
```bash
docker exec $(docker-compose ps -q postgres) psql -U n8n -d n8n -c "VACUUM FULL;"
```

## Authentication Issues

### Can't Login / Wrong Password

**Solutions**:

1. **Verify credentials**:
```bash
cat .env | grep N8N_BASIC_AUTH
```

2. **Reset password**:
```bash
nano .env
# Change N8N_BASIC_AUTH_PASSWORD

docker-compose down
docker-compose up -d
```

3. **Clear browser cache and cookies**

### Login Page Doesn't Appear

**Check Basic Auth settings**:
```bash
docker-compose logs n8n | grep -i auth
```

**Solution**:
```bash
# Verify in .env
N8N_BASIC_AUTH_ACTIVE=true
```

## Workflow Issues

### Workflows Not Executing

**Check**:
```bash
# View n8n logs
docker-compose logs -f n8n

# Check workflow status in n8n interface
```

**Common causes**:
1. Workflow not activated
2. Trigger conditions not met
3. Credentials expired/invalid
4. Network connectivity issues

### Webhooks Not Working

**Verify webhook URL**:
```bash
# Check environment variables
docker exec $(docker-compose ps -q n8n) env | grep WEBHOOK
```

**Should show**:
```
WEBHOOK_URL=https://your-domain.com/
```

**Solutions**:

1. **Fix webhook URL in .env**:
```bash
nano .env
# Ensure WEBHOOK_TUNNEL_URL is not set (removed from newer configs)
```

2. **Restart n8n**:
```bash
docker-compose restart n8n
```

## Data Issues

### Lost Workflows After Restart

**Possible causes**:
1. Database connection lost
2. Volume not persisted
3. Wrong database configuration

**Recovery**:

```bash
# 1. Check volumes exist
docker volume ls | grep n8n

# 2. Check database connection
docker-compose logs n8n | grep -i database

# 3. Restore from backup
./scripts/restore.sh /path/to/backup.tar.gz
```

### Credentials Disappeared

**Check encryption key**:
```bash
docker exec $(docker-compose ps -q n8n) ls -la /home/node/.n8n/
```

**Important**: n8n uses encryption keys stored in the volume. If volume is lost, credentials cannot be recovered.

**Prevention**: Regular backups!

## Docker Issues

### Out of Disk Space

**Check space**:
```bash
df -h
docker system df
```

**Clean up**:
```bash
# Remove unused containers, images, volumes
docker system prune -a --volumes

# Keep n8n volumes safe:
# Don't run: docker volume prune
```

### Docker Commands Require Sudo

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in
exit
```

### Can't Pull Images

**Error**: `Error response from daemon: Get https://registry-1.docker.io/v2/: net/http: request canceled`

**Solutions**:

1. **Check internet connection**:
```bash
ping -c 3 google.com
```

2. **Restart Docker**:
```bash
sudo systemctl restart docker
```

3. **Use different registry mirror** (optional)

## System Issues

### Server Running Out of Memory

**Check memory**:
```bash
free -h
```

**Solutions**:

1. **Add swap**:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

2. **Limit container memory**:
```yaml
# In docker-compose.yml
services:
  n8n:
    mem_limit: 1g
```

### High CPU Usage

**Find culprit**:
```bash
docker stats
top
```

**Solutions**:
- Optimize workflows
- Reduce execution frequency
- Upgrade server

## Update/Upgrade Issues

### Update Failed

**Symptoms**: n8n won't start after update

**Recovery**:

```bash
# 1. Check logs
docker-compose logs n8n

# 2. Restore from backup
./scripts/restore.sh /path/to/backup.tar.gz

# 3. Or rollback to previous version
nano docker-compose.yml
# Change image tag to previous version
docker-compose up -d
```

### Database Migration Failed

```bash
# Check migration logs
docker-compose logs n8n | grep -i migration

# Restore database from pre-update backup
./scripts/restore.sh /path/to/backup.tar.gz
```

## Network Issues

### Can't Connect to External APIs

**Test connectivity**:
```bash
# From n8n container
docker exec $(docker-compose ps -q n8n) wget -O- https://httpbin.org/ip

# Check DNS
docker exec $(docker-compose ps -q n8n) nslookup google.com
```

**Solutions**:

1. **Check firewall on server**:
```bash
sudo ufw status
# Ensure outbound connections are allowed (UFW allows by default)
```

2. **Check Docker network**:
```bash
docker network inspect n8n_n8n-network
```

## Logs and Debugging

### View Detailed Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs n8n
docker-compose logs postgres
docker-compose logs traefik

# Follow logs in real-time
docker-compose logs -f n8n

# Last 100 lines
docker-compose logs --tail=100 n8n

# Logs since specific time
docker-compose logs --since 30m n8n
```

### Enable Debug Mode

Add to `.env`:
```bash
N8N_LOG_LEVEL=debug
```

Restart:
```bash
docker-compose restart n8n
```

### Access Container Shell

```bash
# n8n container
docker exec -it $(docker-compose ps -q n8n) sh

# PostgreSQL container
docker exec -it $(docker-compose ps -q postgres) bash
```

## Getting Help

### Before Asking for Help

Collect this information:

```bash
# 1. System info
uname -a
docker --version
docker-compose --version

# 2. Services status
docker-compose ps

# 3. Recent logs
docker-compose logs --tail=100 > logs.txt

# 4. Configuration (remove sensitive data!)
cat docker-compose.yml
cat .env | grep -v PASSWORD

# 5. Resource usage
df -h
free -h
docker stats --no-stream
```

### Where to Get Help

- 📚 [n8n Documentation](https://docs.n8n.io/)
- 💬 [n8n Community Forum](https://community.n8n.io/)
- 💭 [n8n Discord](https://discord.gg/n8n)
- 🐛 [GitHub Issues](https://github.com/n8n-io/n8n/issues)

### Community Guidelines

When asking for help:
1. Describe what you're trying to do
2. Show what you've tried
3. Include error messages
4. Share relevant logs
5. Mention your environment (OS, Docker version)

## Preventive Measures

To avoid issues:

- ✅ **Regular backups** - Daily automated backups
- ✅ **Monitor resources** - CPU, memory, disk space
- ✅ **Keep updated** - Regular updates with backups
- ✅ **Test changes** - Use staging environment
- ✅ **Document changes** - Keep notes of modifications
- ✅ **Review logs** - Weekly log checks
- ✅ **Test workflows** - Validate after changes

## Emergency Recovery

If everything fails:

1. **Stop services**: `docker-compose down`
2. **Backup current state**: `./scripts/backup.sh`
3. **Restore from last known good backup**: `./scripts/restore.sh`
4. **If that fails, reinstall from scratch**: [Installation Guide](03-installation.md)

## Quick Reference Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f n8n

# Check status
docker-compose ps

# Update
./scripts/update.sh

# Backup
./scripts/backup.sh

# Restore
./scripts/restore.sh /path/to/backup.tar.gz

# Clean up
docker system prune -a
```