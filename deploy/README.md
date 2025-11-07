# 🚀 Deployment Scripts

This directory contains scripts for deploying db-importer to production.

## Quick Start

### 1. First Time Setup

```bash
# Copy config template
cp deploy/config.sh.example deploy/config.sh

# Edit with your VPS details
nano deploy/config.sh

# Make scripts executable
chmod +x deploy/*.sh
```

### 2. Deploy to Production

```bash
./deploy/push-to-prod.sh
```

That's it! 🎉

## Files

- `push-to-prod.sh` - Local script to deploy from your machine
- `deploy.sh` - Remote script that runs on the VPS
- `config.sh.example` - Template for VPS configuration
- `config.sh` - Your VPS config (not committed to git)
- `DEPLOYMENT_GUIDE.md` - Complete deployment documentation

## Full Documentation

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for complete setup instructions.
