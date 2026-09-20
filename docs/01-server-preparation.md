# Server Preparation

This guide will help you prepare a fresh Ubuntu server for n8n installation.

## System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04 LTS or newer (or any Docker-compatible Linux)
- **CPU**: 1 core
- **RAM**: 2 GB
- **Disk**: 20 GB
- **Network**: Public IP address

### Recommended Requirements
- **CPU**: 2+ cores
- **RAM**: 4+ GB
- **Disk**: 50+ GB SSD
- **Network**: Public IP with good bandwidth

## Initial Server Setup

### 1. Connect to Your Server

```bash
ssh root@your-server-ip
```

Or if using a non-root user:

```bash
ssh username@your-server-ip
```

### 2. Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### 3. Install Required Packages

```bash
sudo apt install -y curl wget git ufw
```

### 4. Configure Firewall

```bash
# Allow SSH (IMPORTANT: do this first!)
sudo ufw allow OpenSSH

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

Expected output:
```
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

### 5. Set Timezone

```bash
# Check current timezone
timedatectl

# Set timezone (example: Europe/Belgrade)
sudo timedatectl set-timezone Europe/Belgrade

# Verify
timedatectl | grep "Time zone"
```

### 6. Create Swap File (Optional but Recommended)

If your server has limited RAM (less than 4GB), create a swap file:

```bash
# Create 2GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
sudo swapon --show
free -h
```

### 7. Install Docker

```bash
# Install Docker
sudo apt install -y docker.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add your user to docker group
sudo usermod -aG docker $USER

# Verify Docker installation
docker --version
```

**Important**: Log out and log back in for the docker group changes to take effect.

### 8. Install Docker Compose

```bash
# Install Docker Compose
sudo apt install -y docker-compose-plugin

# Verify installation
docker compose --version
```

### 9. Create Non-Root User (Optional)

If you're logged in as root, it's recommended to create a non-root user:

```bash
# Create new user
adduser n8nuser

# Add to sudo group
usermod -aG sudo n8nuser

# Add to docker group
usermod -aG docker n8nuser

# Switch to new user
su - n8nuser
```

## Security Recommendations

### 1. Configure SSH Key Authentication

On your local machine:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id username@your-server-ip
```

### 2. Disable Password Authentication

```bash
sudo nano /etc/ssh/sshd_config
```

Change the following lines:
```
PasswordAuthentication no
PubkeyAuthentication yes
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

### 3. Install Fail2Ban (Optional)

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Verification

Before proceeding to installation, verify everything is working:

```bash
# Check Docker
docker run hello-world

# Check firewall
sudo ufw status

# Check timezone
timedatectl

# Check available disk space
df -h

# Check memory
free -h
```

## Next Steps

Your server is now ready for n8n installation! 

Continue to: [DNS Configuration](02-dns-configuration.md)
