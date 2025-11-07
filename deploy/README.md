# 🚀 Deployment Options

This directory contains everything you need to deploy db-importer to production.

---

## 🎯 Choose Your Deployment Method

### Option 1: GitHub Actions (Recommended ⭐)

**Automatic deployment when you push to GitHub**

✅ Push to GitHub → Automatically deploys
✅ No manual commands needed
✅ Free for public/private repos
✅ View deployment status in GitHub UI

**Setup**: [GITHUB_ACTIONS_SETUP.md](./GITHUB_ACTIONS_SETUP.md)

**Usage**:
```bash
git push origin main  # That's it! Auto-deploys 🎉
```

---

### Option 2: Manual Script Deployment

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

| Feature | GitHub Actions | Manual Script |
|---------|----------------|---------------|
| Automatic on push | ✅ Yes | ❌ No |
| GitHub required | ✅ Yes | ❌ No |
| Setup complexity | Medium | Easy |
| Deployment visibility | GitHub UI | Terminal only |
| Best for | Teams, CI/CD | Solo dev, quick deploys |

**Recommendation**: Use **GitHub Actions** for production. It's automatic and safer.
