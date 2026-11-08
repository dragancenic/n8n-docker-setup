# Deploy on a server with Docker already installed

Use this path for a new n8n installation on a prepared Ubuntu or another Docker-compatible Linux server. It reuses Docker and Compose. It does not require the separate `docker-setup` repository.

The default `setup.sh` path prepares an Ubuntu host and changes firewall and system timezone settings. The `--existing-docker` path only checks prerequisites and configuration; it does not install packages or start services.

## 1. Check the server

Docker Engine and the Docker Compose plugin must already be installed and accessible to the account running the commands. If access requires root, use `sudo` consistently for the check and subsequent Docker commands. No Docker group or permission changes are made automatically.

The domain must point to the server. Allow inbound TCP 80 and 443 through the host firewall, provider firewall, and router if applicable. These ports must be free: this stack starts its own Traefik proxy. If another proxy already uses them, plan an integration before starting this stack; do not stop existing services blindly.

## 2. Clone and configure

```bash
git clone https://github.com/dragancenic/n8n-docker-setup.git n8n
cd n8n
cp .env.example .env
chmod 600 .env
nano .env
```

Set `DOMAIN` to your hostname without a URL scheme or path, and set `EMAIL` to your certificate contact address. Set a unique `POSTGRES_PASSWORD` and `N8N_ENCRYPTION_KEY`. Keep the pinned image versions from the example unless you have reviewed and tested an update.

For a new installation, generate each secret separately with:

```bash
openssl rand -hex 32
```

Keep the encryption key backed up securely. For an existing n8n deployment, recover its exact existing key and back up its data instead of generating a new key.

The container timezone comes from `GENERIC_TIMEZONE` and `TZ` in `.env`; changing the host timezone is unnecessary. Choose a unique `COMPOSE_PROJECT_NAME` if other stacks exist on this Docker host. For an existing deployment, preserve its project name to keep using its existing volumes.

## 3. Run checks

```bash
bash scripts/setup.sh --existing-docker
```

For a host where Docker requires sudo:

```bash
sudo bash scripts/setup.sh --existing-docker
```

The check validates Docker daemon access and runs `docker compose config --quiet` without printing the resolved configuration or executing `.env` as shell code. If `ss` is available, it also rejects occupied TCP ports 80/443. It does not verify DNS, external reachability, image availability, or whether example secrets have been replaced; confirm those before launching.

## 4. Start and verify

```bash
docker compose pull
docker compose up -d
docker compose ps
docker compose logs --tail=50 traefik n8n
```

Use `sudo docker compose ...` for all commands above if necessary. Wait for initialization and certificate issuance, then open `https://YOUR_DOMAIN` and create the initial n8n owner account in the browser. This account is separate from the PostgreSQL credentials in `.env`.

Named Docker volumes store the database, n8n data, and certificates; manual `data/` directories are unnecessary for this Compose file. See [Backup & Restore](05-backup-restore.md) before storing production data.
