# DNS Configuration

To access n8n via HTTPS with a custom domain, you need to configure DNS records properly.

## Prerequisites

- A registered domain name
- Access to your domain's DNS management panel
- Your server's public IP address

## Find Your Server's IP Address

On your server, run:

```bash
curl ifconfig.me
```

Or:

```bash
curl ipinfo.io/ip
```

Example output: `5.104.108.62`

## DNS Configuration Steps

### Step 1: Choose a Subdomain

Decide on a subdomain for your n8n instance. Common choices:
- `n8n.yourdomain.com`
- `automata.yourdomain.com`
- `workflows.yourdomain.com`

### Step 2: Create A Record

Log in to your DNS provider and create an **A record** pointing to your server's IP.

**Example:**
- **Type**: A
- **Name**: `automata` (or your chosen subdomain)
- **Value**: `5.104.108.62` (your server's IP)
- **TTL**: 3600 (or default)

## Provider-Specific Instructions

### Cloudflare

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain
3. Go to **DNS** → **Records**
4. Click **Add record**
5. Fill in:
   - **Type**: A
   - **Name**: automata
   - **IPv4 address**: your-server-ip
   - **Proxy status**: DNS only (gray cloud) - **Important!**
   - **TTL**: Auto
6. Click **Save**

**Important**: Make sure proxy is disabled (gray cloud icon) for Let's Encrypt to work properly.

### Namecheap

1. Log in to [Namecheap](https://www.namecheap.com/)
2. Go to **Domain List** → Select your domain
3. Click **Manage** → **Advanced DNS**
4. Click **Add New Record**
5. Fill in:
   - **Type**: A Record
   - **Host**: automata
   - **Value**: your-server-ip
   - **TTL**: Automatic
6. Click the green checkmark to save

### GoDaddy

1. Log in to [GoDaddy](https://www.godaddy.com/)
2. Go to **My Products** → **DNS**
3. Select your domain
4. Click **Add** under DNS Records
5. Fill in:
   - **Type**: A
   - **Name**: automata
   - **Value**: your-server-ip
   - **TTL**: 1 Hour
6. Click **Save**

### DigitalOcean

1. Log in to [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Go to **Networking** → **Domains**
3. Select your domain
4. In the **Create new record** section:
   - **Type**: A
   - **Hostname**: automata
   - **Will direct to**: your-server-ip
   - **TTL**: 3600
5. Click **Create Record**

### Generic DNS Provider

For any DNS provider, create an A record with:
- **Record Type**: A
- **Name/Host**: your-subdomain (e.g., automata)
- **Value/Points to**: your-server-ip
- **TTL**: 3600 or default

## Verify DNS Configuration

After creating the DNS record, wait a few minutes (up to 48 hours in some cases, but usually 5-15 minutes) for propagation.

### Check DNS Propagation

Use online tools:
- [whatsmydns.net](https://www.whatsmydns.net/)
- [dnschecker.org](https://dnschecker.org/)

Or use command line:

```bash
# Check if DNS resolves correctly
nslookup automata.yourdomain.com

# Or using dig
dig automata.yourdomain.com +short
```

Expected output should show your server's IP address.

### Test from Your Server

```bash
# Ping your domain
ping automata.yourdomain.com

# Should return your server's IP
```

## Common Issues

### DNS Not Resolving

**Problem**: Domain doesn't resolve to your IP

**Solutions**:
- Wait longer (DNS propagation can take time)
- Check if you created the correct record type (A record)
- Verify you entered the correct IP address
- Clear your local DNS cache:
  - **Linux**: `sudo systemd-resolve --flush-caches`
  - **macOS**: `sudo dscacheutil -flushcache`
  - **Windows**: `ipconfig /flushdns`

### Multiple IP Addresses

**Problem**: DNS returns multiple IPs

**Solution**: This is normal if using CDN/proxy. Disable proxy mode for initial setup.

### IPv6 Issues

If your server has IPv6, you might want to add an AAAA record:
- **Type**: AAAA
- **Name**: automata
- **Value**: your-ipv6-address

## Security Note

**Do NOT** use Cloudflare proxy (orange cloud) during initial setup. Let's Encrypt needs direct access to your server to issue certificates. You can enable proxy after SSL is set up, but it's not necessary.

## Next Steps

Once your DNS is properly configured and resolving:

Continue to: [Installation Guide](03-installation.md)