# Frequently Asked Questions (FAQ)

## General Questions

### What is n8n?

n8n is a fair-code licensed workflow automation tool that allows you to connect different services and automate tasks. It's like Zapier or Make (formerly Integrio), but self-hosted.

### Why self-host n8n?

Benefits of self-hosting:
- 💰 **Cost**: No monthly subscription fees
- 🔒 **Privacy**: Your data stays on your server
- 🚀 **Unlimited**: No execution limits
- ⚙️ **Control**: Full customization and control

### What does this setup include?

- n8n workflow automation
- PostgreSQL database for data persistence
- Traefik reverse proxy for routing
- Automatic HTTPS with Let's Encrypt
- Backup and restore scripts

## Installation Questions

### What are the minimum server requirements?

**Minimum**: 1 CPU, 2GB RAM, 20GB storage
**Recommended**: 2+ CPUs, 4GB RAM, 50GB SSD

### Can I install this on Windows or macOS?

This setup is designed for Ubuntu Linux servers. For Windows/macOS:
- Use WSL2 on Windows
- Use Docker Desktop on macOS
- Or deploy to a Linux VPS (recommended)

### Do I need a domain name?

Yes, a domain is required for:
- HTTPS/SSL certificates
- Webhook functionality
- Professional access URL

You can use a subdomain (e.g., `n8n.yourdomain.com`).

### Can I use a subdomain?

Yes! Subdomains work perfectly. Just set up an A record pointing to your server.

### How long does installation take?

- Setup script: 5-10 minutes
- DNS propagation: 5-60 minutes
- Total: Usually under 30 minutes

### Can I install on shared hosting?

No, you need a VPS or dedicated server with:
- Root/sudo access
- Docker support
- Ports 80 and 443 available

## Configuration Questions

### How do I change my password?

```bash
nano .env
# Change N8N_BASIC_AUTH_PASSWORD
docker-compose restart n8n
```

### Can I use custom domain without www?

Yes, just set `DOMAIN=yourdomain.com` in `.env`

### How do I change the timezone?

Edit `.env`:
```bash
GENERIC_TIMEZONE=Europe/Belgrade
TZ=Europe/Belgrade
```

Then restart:
```bash
docker-compose restart n8n
```

### Can I disable basic authentication?

Not recommended, but possible:
```bash
# In .env
N8N_BASIC_AUTH_ACTIVE=false
```

**Warning**: Your n8n will be publicly accessible!

### How do I add multiple users?

n8n basic auth supports only one user. For multiple users:
- Upgrade to n8n Enterprise (paid)
- Or share the single login credential (not recommended)

## Usage Questions

### How do I create my first workflow?

1. Login to n8n
2. Click "Create new workflow"
3. Add trigger node (webhook, schedule, etc.)
4. Add action nodes
5. Connect nodes
6. Click "Execute Workflow"

See [n8n documentation](https://docs.n8n.io/) for detailed guides.

### What can I automate with n8n?

Common use cases:
- Social media posting
- Email automation
- Data synchronization
- API integrations
- Webhook processing
- Scheduled tasks
- Data transformation

### How many workflows can I create?

Unlimited! Self-hosted n8n has no restrictions.

### Can n8n send emails?

Yes, using:
- Email node (SMTP)
- Gmail node
- Other email service nodes

### How do webhooks work?

Webhook URL format:
```
https://your-domain.com/webhook/your-webhook-path
```

Create a webhook trigger in your workflow to receive data.

## Maintenance Questions

### How often should I update n8n?

**Recommended**: Monthly, after reading changelog

**For production**: Test updates in staging first

### Do I need to backup?

Yes! Always backup before:
- Updates
- Major workflow changes
- Configuration changes

Run daily automated backups: [Backup Guide](05-backup-restore.md)

### How much disk space do backups use?

Depends on:
- Number of workflows
- Execution history
- Stored data

Typical backup: 100MB - 1GB

### How do I monitor n8n?

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f n8n

# Check resource usage
docker stats
```

### What if my server runs out of space?

1. Clean old backups: `rm backups/old-backup-*.tar.gz`
2. Clear old executions in n8n settings
3. Clean Docker: `docker system prune -a`
4. Upgrade server storage

## Security Questions

### Is this setup secure?

Yes, when properly configured:
- ✅ HTTPS encryption
- ✅ Firewall protection
- ✅ Basic authentication
- ✅ Isolated Docker network

### Should I use Cloudflare?

Optional benefits:
- DDoS protection
- CDN caching
- Additional firewall rules

**Important**: Use DNS-only mode (not proxied) during initial setup.

### How do I add IP whitelist?

Use firewall rules:
```bash
sudo ufw allow from YOUR_IP to any port 443
sudo ufw deny 443
```

Or configure in Traefik (advanced).

### Are my credentials safe?

Yes, credentials are:
- Encrypted in database
- Stored in Docker volumes
- Not exposed in logs

Always backup your data securely.

## Troubleshooting Questions

### n8n won't start after update

```bash
# Restore from backup
./scripts/restore.sh /path/to/backup.tar.gz
```

See [Troubleshooting Guide](06-troubleshooting.md)

### Can't access n8n (connection refused)

Check:
1. Services running: `docker-compose ps`
2. Firewall: `sudo ufw status`
3. DNS: `nslookup your-domain.com`
4. Logs: `docker-compose logs traefik n8n`

### SSL certificate not working

Wait 2-3 minutes for Let's Encrypt, then:
```bash
docker-compose logs traefik | grep -i error
```

Common causes:
- DNS not resolving
- Ports not open
- Cloudflare proxy enabled

### Workflows not executing

Check:
1. Workflow is activated (toggle on)
2. Trigger conditions are met
3. Credentials are valid
4. Logs: `docker-compose logs n8n`

### How do I get support?

1. Check [Troubleshooting Guide](06-troubleshooting.md)
2. Search [n8n Community Forum](https://community.n8n.io/)
3. Ask in [n8n Discord](https://discord.gg/n8n)
4. Create [GitHub Issue](https://github.com/your-username/n8n-docker-setup/issues)

## Cost Questions

### Is n8n free?

Yes, n8n is open source with fair-code license. This setup is completely free.

### What about server costs?

You need to pay for:
- VPS/server hosting ($5-20/month)
- Domain name ($10-15/year)

No n8n subscription fees!

### Recommended VPS providers?

- DigitalOcean
- Linode
- Vultr
- Hetzner
- AWS Lightsail

All support Docker and Ubuntu.

## Migration Questions

### Can I migrate from n8n cloud?

Yes! Export workflows from cloud, import to self-hosted.

### How do I move to a new server?

1. Backup old server: `./scripts/backup.sh`
2. Set up new server
3. Restore backup: `./scripts/restore.sh`
4. Update DNS to new IP

### Can I upgrade server size?

Yes, without data loss:
1. Create backup
2. Upgrade server
3. Verify services still running

## Advanced Questions

### Can I use external PostgreSQL?

Yes, modify `docker-compose.yml` to point to external database.

### Can I add custom nodes?

Yes! Mount custom nodes directory in `docker-compose.yml`.

### How do I use different database?

n8n supports:
- PostgreSQL (recommended)
- MySQL
- SQLite (not recommended for production)

### Can I run multiple n8n instances?

Yes, use different:
- Domains
- `.env` files
- Docker Compose project names

### How do I enable debug logging?

Add to `.env`:
```bash
N8N_LOG_LEVEL=debug
```

Restart: `docker-compose restart n8n`

## Still Have Questions?

- 📚 [Full Documentation](../README.md)
- 💬 [Community Forum](https://community.n8n.io/)
- 📖 [n8n Official Docs](https://docs.n8n.io/)