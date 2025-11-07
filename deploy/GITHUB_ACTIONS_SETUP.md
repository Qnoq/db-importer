# 🚀 GitHub Actions Auto-Deployment Setup

This guide will help you set up automatic deployment to your VPS whenever you push to the `main` branch on GitHub.

---

## 🎯 How It Works

1. You push code to GitHub (`git push origin main`)
2. GitHub Actions automatically triggers
3. GitHub SSHs into your VPS
4. Deployment script runs automatically
5. Your app is updated! 🎉

**No manual commands needed!**

---

## 📋 Prerequisites

- ✅ GitHub repository (public or private)
- ✅ VPS with Docker installed
- ✅ SSH access to your VPS
- ✅ SSH key for authentication (recommended)

---

## 🔧 One-Time Setup

### Step 1: Prepare Your VPS

SSH into your VPS:

```bash
ssh root@your-vps-ip
```

Create application directory and clone repo:

```bash
mkdir -p /var/www/db-importer
cd /var/www/db-importer
git clone https://github.com/your-username/db-importer.git .
```

Create production `.env` file:

```bash
nano .env
```

Add your production configuration:

```bash
# Backend Configuration
PORT=8080
ALLOWED_ORIGINS=https://your-domain.com  # ⚠️ IMPORTANT: Change this!
MAX_UPLOAD_SIZE=52428800
DEBUG_LOG=false
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=50
RATE_LIMIT_WINDOW=60

# Frontend Configuration
VITE_API_URL=https://your-domain.com
```

Make deployment script executable:

```bash
chmod +x deploy/deploy.sh
```

Initial manual deployment:

```bash
docker-compose build
docker-compose up -d
```

---

### Step 2: Generate SSH Key for GitHub Actions

On your **local machine** (not VPS), generate a dedicated SSH key:

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy
```

Press Enter when asked for a passphrase (leave it empty for automation).

This creates two files:
- `~/.ssh/github_actions_deploy` (private key) ← This goes to GitHub Secrets
- `~/.ssh/github_actions_deploy.pub` (public key) ← This goes to VPS

---

### Step 3: Add Public Key to VPS

Copy the public key:

```bash
cat ~/.ssh/github_actions_deploy.pub
```

SSH into your VPS and add it to authorized_keys:

```bash
ssh root@your-vps-ip

# Add the public key
nano ~/.ssh/authorized_keys
# Paste the public key content and save
```

Test the connection from your local machine:

```bash
ssh -i ~/.ssh/github_actions_deploy root@your-vps-ip
```

If it works without password, you're good! Exit the SSH session.

---

### Step 4: Configure GitHub Secrets

Go to your GitHub repository:

1. Click **Settings** (top menu)
2. Click **Secrets and variables** → **Actions** (left sidebar)
3. Click **New repository secret** (green button)

Add these **4 secrets**:

#### Secret 1: VPS_HOST

- **Name**: `VPS_HOST`
- **Value**: `your-vps-ip-or-domain.com`

Example: `123.45.67.89` or `vps.example.com`

#### Secret 2: VPS_USER

- **Name**: `VPS_USER`
- **Value**: `root`

(Or your SSH username if not root)

#### Secret 3: VPS_SSH_KEY

- **Name**: `VPS_SSH_KEY`
- **Value**: Your **private key** content

Get the private key:

```bash
cat ~/.ssh/github_actions_deploy
```

Copy the **entire output** including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

⚠️ **IMPORTANT**: This is your private key. Only paste it into GitHub Secrets, never commit it to git!

#### Secret 4: VPS_PORT

- **Name**: `VPS_PORT`
- **Value**: `22`

(Or your custom SSH port if different)

#### Secret 5: VPS_APP_DIR

- **Name**: `VPS_APP_DIR`
- **Value**: `/var/www/db-importer`

(Or your custom app directory)

---

### Step 5: Enable GitHub Actions

In your repository settings:

1. Go to **Settings** → **Actions** → **General**
2. Under **Actions permissions**, select:
   - ✅ **Allow all actions and reusable workflows**
3. Click **Save**

---

## 🚀 Deploy to Production

Now deployment is automatic! Just push to main:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

**That's it!** GitHub Actions will automatically:

1. ✅ Detect the push
2. ✅ SSH into your VPS
3. ✅ Pull latest code
4. ✅ Rebuild Docker images
5. ✅ Restart containers

---

## 📊 Monitor Deployment

### View Deployment Status

1. Go to your GitHub repository
2. Click **Actions** tab (top menu)
3. See your deployment running in real-time

### Deployment takes about 2-5 minutes

You'll see:
- 🟡 **Yellow dot**: Deployment in progress
- 🟢 **Green checkmark**: Deployment successful
- 🔴 **Red X**: Deployment failed

Click on any workflow run to see detailed logs.

---

## 🔄 Deploy from Different Branch

Want to deploy from a `production` branch instead of `main`?

Edit `.github/workflows/deploy-production.yml`:

```yaml
on:
  push:
    branches:
      - production  # Change this
```

---

## 🆘 Troubleshooting

### Deployment fails with "Permission denied"

**Problem**: SSH key not configured correctly

**Solution**:

1. Verify public key is in VPS `~/.ssh/authorized_keys`
2. Check VPS SSH key permissions:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Verify GitHub secret `VPS_SSH_KEY` contains the **entire private key**

### Deployment fails with "Host key verification failed"

**Problem**: VPS host key not trusted

**Solution**: Add `script_stop: true` to workflow:

```yaml
- name: 🚀 Deploy to Production VPS
  uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.VPS_HOST }}
    username: ${{ secrets.VPS_USER }}
    key: ${{ secrets.VPS_SSH_KEY }}
    port: ${{ secrets.VPS_PORT }}
    script_stop: true  # Add this
    script: |
      cd ${{ secrets.VPS_APP_DIR }}
      bash deploy/deploy.sh
```

### Deployment succeeds but app doesn't update

**Problem**: Git not pulling on VPS

**Solution**: SSH into VPS and check:

```bash
cd /var/www/db-importer
git status
git log -1  # Check last commit
```

Manually pull if needed:

```bash
git pull origin main
```

### Container build fails

**Problem**: Docker build error

**Solution**: Check logs on VPS:

```bash
ssh root@your-vps-ip
cd /var/www/db-importer
docker-compose logs
```

---

## 🔒 Security Best Practices

- ✅ Use dedicated SSH key for GitHub Actions (not your personal key)
- ✅ Never commit private keys to git
- ✅ Use GitHub Secrets for all sensitive data
- ✅ Limit SSH key to specific IP if possible (GitHub Actions IPs)
- ✅ Use non-root user on VPS (create a deploy user)
- ✅ Review workflow logs for any exposed secrets

### Optional: Create Dedicated Deploy User

Instead of using `root`, create a `deploy` user:

```bash
# On VPS
adduser deploy
usermod -aG docker deploy

# Add public key to deploy user
su - deploy
mkdir ~/.ssh
nano ~/.ssh/authorized_keys
# Paste public key

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Update GitHub Secret `VPS_USER` to `deploy`.

---

## 📝 Workflow File Location

The workflow is defined in:

```
.github/workflows/deploy-production.yml
```

You can customize:
- Trigger branches
- Deployment steps
- Notifications
- Environment variables

---

## 🎯 Quick Checklist

- [ ] VPS setup complete with Docker
- [ ] App cloned to `/var/www/db-importer` on VPS
- [ ] Production `.env` file created on VPS
- [ ] SSH key pair generated
- [ ] Public key added to VPS `~/.ssh/authorized_keys`
- [ ] Private key added to GitHub Secret `VPS_SSH_KEY`
- [ ] All 5 GitHub Secrets configured
- [ ] GitHub Actions enabled in repository settings
- [ ] Test deployment by pushing to main branch
- [ ] Verify app updates on VPS

---

## 🎉 You're Done!

Now every time you push to `main`, your app automatically deploys to production!

```bash
git push origin main
# ✨ Magic happens! Your app updates automatically
```

**Happy deploying! 🚀**
