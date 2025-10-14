# Deployment Checklist

Use this checklist when deploying n8n to production.

## Pre-Deployment

### Server Preparation
- [ ] VPS/server provisioned (min 2GB RAM)
- [ ] Ubuntu 20.04+ installed
- [ ] Root or sudo access confirmed
- [ ] Server IP address noted
- [ ] SSH access configured and tested

### Domain Setup
- [ ] Domain name purchased/available
- [ ] DNS A record created pointing to server IP
- [ ] DNS propagation verified (`nslookup your-domain.com`)
- [ ] Domain resolves to correct IP

### Repository Setup
- [ ] Repository cloned to server
- [ ] All scripts present in `scripts/` directory
- [ ] Scripts are executable (`chmod +x scripts/*.sh`)

### Configuration
- [ ] `.env` file created from `.env.example`
- [ ] `DOMAIN` set correctly
- [ ] `EMAIL` set for Let's Encrypt notifications
- [ ] `N8N_BASIC_AUTH_USER` set
- [ ] `N8N_BASIC_AUTH_PASSWORD` set (strong password)
- [ ] `POSTGRES_PASSWORD` set (strong password)
- [ ] Timezone configured correctly

## Installation

- [ ] Firewall ports opened (22, 80, 443)
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] `setup.sh` executed successfully
- [ ] Logged out and logged back in (for Docker group changes)
- [ ] Services started with `docker-compose up -d`
- [ ] All services running (`docker-compose ps`)
- [ ] No error messages in logs

## Post-Installation Verification

### SSL/HTTPS
- [ ] HTTPS accessible in browser
- [ ] Valid SSL certificate (no warnings)
- [ ] HTTP redirects to HTTPS
- [ ] Certificate auto-renewal configured

### Application Access
- [ ] n8n login page loads
- [ ] Can login with configured credentials
- [ ] Dashboard accessible
- [ ] No console errors in browser

### Service Health
- [ ] All containers running (`docker-compose ps`)
- [ ] n8n container healthy
- [ ] PostgreSQL container healthy
- [ ] Traefik container healthy
- [ ] No restart loops

### Functionality Test
- [ ] Created test workflow
- [ ] Test workflow executes successfully
- [ ] Webhook test successful
- [ ] Data persists after container restart

## Security Hardening

- [ ] Strong passwords used (min 16 characters)
- [ ] SSH key authentication enabled
- [ ] Password authentication disabled (SSH)
- [ ] Firewall configured and enabled
- [ ] Only necessary ports open
- [ ] Fail2Ban installed (optional but recommended)
- [ ] Server timezone set correctly

## Backup Setup

- [ ] Backup script tested (`./scripts/backup.sh`)
- [ ] Backup created successfully
- [ ] Backup file verified (not empty)
- [ ] Restore tested in dev environment
- [ ] Automated backup configured (cron)
- [ ] Backup retention policy set
- [ ] Remote backup location configured (optional)

## Monitoring Setup

- [ ] Log rotation configured
- [ ] Disk space monitoring (alert at 80%)
- [ ] Memory usage monitoring
- [ ] Service uptime monitoring
- [ ] SSL certificate expiry monitoring

## Documentation

- [ ] Admin credentials documented (securely)
- [ ] Server details documented
- [ ] DNS configuration documented
- [ ] Backup location documented
- [ ] Recovery procedures documented
- [ ] Team members have access to documentation

## Performance Optimization

- [ ] Server resources adequate for workload
- [ ] Swap configured if needed
- [ ] Execution data retention configured
- [ ] Old executions cleanup scheduled
- [ ] Database vacuum scheduled (weekly)

## Maintenance Plan

- [ ] Update schedule defined
- [ ] Backup schedule defined (daily recommended)
- [ ] Monitoring alerts configured
- [ ] Incident response plan documented
- [ ] Team trained on basic operations

## Production Readiness

### High Priority
- [ ] All services running and healthy
- [ ] HTTPS working correctly
- [ ] Backups automated and tested
- [ ] Strong authentication configured
- [ ] Firewall properly configured

### Medium Priority
- [ ] Monitoring configured
- [ ] Automated updates considered
- [ ] Documentation complete
- [ ] Team trained

### Optional but Recommended
- [ ] Fail2Ban installed
- [ ] Remote backups configured
- [ ] Custom domain email configured
- [ ] Staging environment set up
- [ ] Load testing performed

## Go-Live

- [ ] Final backup created
- [ ] All team members notified
- [ ] Workflows imported/created
- [ ] Integrations configured
- [ ] Credentials added to n8n
- [ ] Test workflows executed
- [ ] Production workflows activated
- [ ] Monitoring confirmed working
- [ ] Documentation finalized

## Post Go-Live

### First Day
- [ ] Monitor logs for errors
- [ ] Verify workflows executing
- [ ] Check resource usage
- [ ] Confirm backups running

### First Week
- [ ] Daily log review
- [ ] Workflow execution monitoring
- [ ] Performance optimization if needed
- [ ] User feedback collection

### First Month
- [ ] Weekly backup verification
- [ ] Security update check
- [ ] Resource usage review
- [ ] Documentation update if needed

## Rollback Plan

In case of issues:
- [ ] Previous backup available
- [ ] Rollback procedure tested
- [ ] DNS can be reverted quickly
- [ ] Downtime notification process defined

## Notes

```
Deployment Date: _______________
Deployed By: _______________
Server IP: _______________
Domain: _______________
n8n Version: _______________
Special Considerations: 
_________________________________
_________________________________
_________________________________
```

## Sign-Off

- [ ] Technical lead approval
- [ ] Security review completed
- [ ] Stakeholder notification sent
- [ ] Go-live confirmed

---

**Remember**: This is a production deployment. Take time to verify each step!

**Emergency Contacts**:
- VPS Provider Support: ________________
- Domain Registrar Support: ________________
- Team Lead: ________________