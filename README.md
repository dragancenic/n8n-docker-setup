```
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃   🚀 n8n Docker Setup                         ┃
    ┃   Production-Ready | HTTPS | PostgreSQL      ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![n8n](https://img.shields.io/badge/n8n-Latest-orange.svg)](https://n8n.io/)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/your-username/n8n-docker-setup)

Production-ready n8n installation with Docker, PostgreSQL, Traefik reverse proxy, and automatic HTTPS.

[Quick Start](QUICK_START.md) • [Documentation](docs/) • [FAQ](docs/FAQ.md) • [Troubleshooting](docs/06-troubleshooting.md)

## 🚀 Features

- **HTTPS out of the box** - Automatic SSL certificates via Let's Encrypt
- **PostgreSQL database** - Reliable data persistence
- **Traefik reverse proxy** - Modern routing and certificate management
- **Docker Compose** - Simple deployment and management
- **Easy updates** - Update to latest n8n version with single command
- **Backup scripts** - Automated backup and restore procedures

## 📋 Prerequisites

- Ubuntu Server 20.04 or newer (or any Docker-compatible Linux)
- Root or sudo access
- Domain name pointing to your server's IP
- Ports 80 and 443 available

## ⚡ Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-username/n8n-docker-setup.git
cd n8n-docker-setup
```

### 2. Configure environment

```bash
cp .env.example .env
nano .env
```

Update the following variables:
- `DOMAIN` - your domain name (e.g., automata.example.com)
- `EMAIL` - your email for Let's Encrypt notifications
- `N8N_BASIC_AUTH_USER` - n8n admin username
- `N8N_BASIC_AUTH_PASSWORD` - n8n admin password
- `POSTGRES_PASSWORD` - PostgreSQL password

### 3. Run installation script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 4. Access n8n

Open your browser and navigate to: `https://your-domain.com`

Login with credentials you set in `.env` file.

## 📚 Documentation

Detailed guides are available in the `docs/` directory:

1. [Server Preparation](docs/01-server-preparation.md) - Prepare your Ubuntu server
2. [DNS Configuration](docs/02-dns-configuration.md) - Set up your domain
3. [Installation Guide](docs/03-installation.md) - Step-by-step installation
4. [Update Guide](docs/04-update-guide.md) - How to update n8n
5. [Backup & Restore](docs/05-backup-restore.md) - Backup strategies
6. [Troubleshooting](docs/06-troubleshooting.md) - Common issues and solutions

## 🔄 Updating n8n

To update to the latest n8n version:

```bash
./scripts/update.sh
```

Or manually:

```bash
docker-compose down
docker-compose pull n8n
docker-compose up -d
```

## 💾 Backup

Create a backup:

```bash
./scripts/backup.sh
```

Restore from backup:

```bash
./scripts/restore.sh /path/to/backup.tar.gz
```

## 🛠️ Tech Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| n8n | latest | Workflow automation |
| PostgreSQL | 15 | Database |
| Traefik | v2.11 | Reverse proxy & SSL |
| Docker | latest | Containerization |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Security Notes

- Change default passwords in `.env` file
- Keep your system and Docker updated
- Regularly backup your data
- Consider using firewall rules to restrict access

## 🔗 Useful Links

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [Docker Documentation](https://docs.docker.com/)

## 📧 Support

If you encounter any issues, please check the [Troubleshooting Guide](docs/06-troubleshooting.md) or open an issue on GitHub.

---

## 🌟 Star History

If you find this project helpful, please consider giving it a star! ⭐

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Internet                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTPS (443)
                     │ HTTP  (80)
                     ▼
          ┌──────────────────────┐
          │      Traefik         │
          │  Reverse Proxy       │
          │  SSL Termination     │
          └──────────┬───────────┘
                     │
                     │ Internal Network
                     │
        ┌────────────┴──────────────┐
        │                           │
        ▼                           ▼
┌───────────────┐          ┌────────────────┐
│     n8n       │          │   PostgreSQL   │
│  Workflows    │◄─────────┤   Database     │
│  Automation   │          │                │
└───────────────┘          └────────────────┘
        │                           │
        │                           │
        ▼                           ▼
┌───────────────┐          ┌────────────────┐
│  n8n_data     │          │ postgres_data  │
│  Volume       │          │  Volume        │
└───────────────┘          └────────────────┘
```

## 🎯 Perfect For

- 🏢 Small to medium teams
- 👨‍💻 Individual developers
- 🧪 Development environments
- 🚀 Production deployments
- 📚 Learning automation
- 🔧 Self-hosting enthusiasts

## 📈 What's Included

| Component | Version | Purpose |
|-----------|---------|---------|
| n8n | latest | Workflow automation platform |
| PostgreSQL | 15 | Database for data persistence |
| Traefik | v2.11 | Reverse proxy & SSL management |
| Docker | latest | Container runtime |
| Automated Scripts | - | Backup, restore, update |

---

<div align="center">

**Made with ❤️ for the n8n community**

[⬆ Back to Top](#-n8n-docker-setup)

</div>