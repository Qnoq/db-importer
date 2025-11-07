# 🚀 Deployment Options

This directory contains everything you need to deploy db-importer to production.

---

## 🎯 Choose Your Deployment Method

### Option 1: Hostinger API (Recommended ⭐)

**Automatic deployment with Hostinger API - Easiest setup!**

✅ Push to GitHub → Automatically deploys
✅ No SSH keys needed
✅ Managed through Hostinger panel
✅ Uses official Hostinger GitHub Action
✅ 5-minute setup

**Setup**: [HOSTINGER_API_SETUP.md](./HOSTINGER_API_SETUP.md)

**Usage**:
```bash
git push origin main  # That's it! Auto-deploys 🎉
```

---

### Option 2: GitHub Actions with SSH

**Automatic deployment with SSH (for non-Hostinger VPS)**

✅ Push to GitHub → Automatically deploys
✅ Works with any VPS provider
✅ View deployment status in GitHub UI

**Setup**: [GITHUB_ACTIONS_SETUP.md](./GITHUB_ACTIONS_SETUP.md)

**Usage**:
```bash
git push origin main  # Auto-deploys
```

---

### Option 3: Manual Script Deployment

**Run deployment script from your machine**

✅ More control over deployment timing
✅ Good for local development workflows
✅ No GitHub dependency

**Setup**: [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

**Usage**:
```bash
./deploy/push-to-prod.sh  # Manual deploy
```

---

## 📁 Files in This Directory

### For GitHub Actions (Option 1)
- `GITHUB_ACTIONS_SETUP.md` - Complete GitHub Actions setup guide
- `deploy.sh` - Remote script that runs on VPS (used by GitHub Actions)

### For Manual Deployment (Option 2)
- `DEPLOYMENT_GUIDE.md` - Complete manual deployment guide
- `push-to-prod.sh` - Local script to deploy from your machine
- `deploy.sh` - Remote script that runs on VPS
- `config.sh.example` - Template for VPS configuration
- `config.sh` - Your VPS config (not committed to git)

### Workflow Definition
- `../.github/workflows/deploy-production.yml` - GitHub Actions workflow

---

## 🚀 Quick Start (GitHub Actions)

1. **Setup VPS** (one time)
   ```bash
   # On VPS
   mkdir -p /var/www/db-importer
   cd /var/www/db-importer
   git clone https://github.com/your-username/db-importer.git .
   # Create .env file
   docker-compose build && docker-compose up -d
   ```

2. **Configure GitHub Secrets** (one time)
   - Generate SSH key
   - Add to GitHub Secrets: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_PORT`, `VPS_APP_DIR`

3. **Deploy**
   ```bash
   git push origin main  # Automatic deployment! 🎉
   ```

See [GITHUB_ACTIONS_SETUP.md](./GITHUB_ACTIONS_SETUP.md) for detailed instructions.

---

## 🔄 Which Method Should I Use?

| Feature | Hostinger API | GitHub Actions SSH | Manual Script |
|---------|---------------|-------------------|---------------|
| **Automatic on push** | ✅ Yes | ✅ Yes | ❌ No |
| **Setup time** | 5 min | 10 min | 5 min |
| **SSH keys needed** | ❌ No | ✅ Yes | ✅ Yes |
| **GitHub required** | ✅ Yes | ✅ Yes | ❌ No |
| **VPS provider** | Hostinger only | Any | Any |
| **Deployment visibility** | GitHub UI | GitHub UI | Terminal |
| **Security** | API token | SSH key | SSH key |
| **Best for** | Hostinger users | Any VPS | Quick deploys |

**Recommendation**:
- **Hostinger VPS?** → Use **Hostinger API** (easiest!)
- **Other VPS?** → Use **GitHub Actions SSH**
- **Quick tests?** → Use **Manual Script**
