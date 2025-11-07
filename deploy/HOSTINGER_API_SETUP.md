# 🚀 Hostinger API Deployment - Quick Setup Guide

Deploy automatically to your Hostinger VPS by just pushing to GitHub!

---

## ✨ How It Works

1. You push code to GitHub (`git push origin main`)
2. GitHub Actions automatically triggers
3. Uses Hostinger API to deploy to your VPS
4. Docker containers rebuild and restart
5. Done! 🎉

**No SSH keys needed. No manual commands. Just push!**

---

## 📋 Prerequisites

- ✅ Hostinger VPS with Docker installed
- ✅ Hostinger API key
- ✅ GitHub repository (public or private)

---

## 🔧 Setup (5 Minutes)

### Step 1: Get Your Hostinger API Key

1. Login to [Hostinger](https://www.hostinger.com/)
2. Go to **VPS** section
3. Click on your VPS
4. Go to **Settings** → **API**
5. Click **Generate API Key**
6. **Copy the API key** (you'll need it for GitHub)

---

### Step 2: Get Your Virtual Machine ID

1. In Hostinger VPS panel
2. Click on your VPS
3. Look for **Virtual Machine ID** or **VM ID**
4. **Copy the ID** (usually a long string like `abc123def456`)

**Alternative**: You can find it in the URL when viewing your VPS:
```
https://hpanel.hostinger.com/vps/abc123def456
                                    ↑ This is your VM ID
```

---

### Step 3: Configure GitHub Secrets & Variables

Go to your GitHub repository:

**Settings** → **Secrets and variables** → **Actions**

#### Add Secret (1 secret)

Click **"New repository secret"**:

**Name**: `HOSTINGER_API_KEY`
**Value**: Your Hostinger API key from Step 1

---

#### Add Variables (2 required + optional)

Click on **"Variables"** tab, then **"New repository variable"**:

**Required Variables:**

1. **HOSTINGER_VM_ID**
   - Value: Your VM ID from Step 2
   - Example: `abc123def456`

2. **ALLOWED_ORIGINS**
   - Value: Your frontend domain
   - Example: `https://your-domain.com`
   - ⚠️ **CRITICAL**: Don't use `*` in production!

3. **VITE_API_URL**
   - Value: Your backend URL
   - Example: `https://api.your-domain.com` or `https://your-domain.com`

**Optional Variables** (with defaults):

4. **PORT** (default: `8080`)
5. **MAX_UPLOAD_SIZE** (default: `52428800`)
6. **DEBUG_LOG** (default: `false`)
7. **RATE_LIMIT_ENABLED** (default: `true`)
8. **RATE_LIMIT_REQUESTS** (default: `50`)
9. **RATE_LIMIT_WINDOW** (default: `60`)

---

### Step 4: Prepare Your VPS

**Option A: Using Hostinger Docker Manager (Recommended)**

1. Login to Hostinger panel
2. Go to **VPS** → **Docker Manager**
3. Your VPS should already have Docker installed
4. No additional setup needed!

**Option B: Manual Docker Setup (if needed)**

SSH into your VPS and install Docker:

```bash
ssh root@your-vps-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt-get update
apt-get install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

---

### Step 5: Deploy! 🚀

Just push to main:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

**That's it!** GitHub Actions will:
1. ✅ Checkout your code
2. ✅ Use Hostinger API to deploy
3. ✅ Build Docker images on your VPS
4. ✅ Start containers with your environment variables
5. ✅ Show success/failure status

---

## 📊 Monitor Deployment

### View Deployment in GitHub

1. Go to your repository
2. Click **"Actions"** tab
3. See your deployment running live
4. Click on any workflow run for detailed logs

### Deployment Status

- 🟡 **Yellow**: Deployment in progress (2-5 minutes)
- 🟢 **Green**: Deployment successful
- 🔴 **Red**: Deployment failed (check logs)

### Check Your VPS

Login to Hostinger panel:
1. Go to **VPS** → **Docker Manager**
2. See your containers running
3. View logs, restart, or manage containers

---

## 🌐 Access Your Application

After successful deployment:

- **Frontend**: `http://your-vps-ip:8081`
- **Backend**: `http://your-vps-ip:8080`

### Setup Domain (Optional)

Use Hostinger's DNS management:

1. Go to **Domains** → Your domain
2. Manage **DNS Records**
3. Add **A Record**:
   - Type: `A`
   - Name: `@` (for root domain) or `app` (for subdomain)
   - Points to: Your VPS IP address
   - TTL: `3600`

4. For SSL, use Hostinger's SSL manager or Let's Encrypt

---

## 🔄 How to Update Your App

Simple! Just push to GitHub:

```bash
# Make your changes
git add .
git commit -m "Update feature X"
git push origin main

# Deployment happens automatically! ✨
```

---

## 🆘 Troubleshooting

### Deployment fails with "Invalid API Key"

**Problem**: API key is incorrect or expired

**Solution**:
1. Generate new API key in Hostinger panel
2. Update GitHub secret `HOSTINGER_API_KEY`
3. Re-run the workflow

---

### Deployment fails with "Virtual machine not found"

**Problem**: VM ID is incorrect

**Solution**:
1. Verify your VM ID in Hostinger panel
2. Update GitHub variable `HOSTINGER_VM_ID`
3. Re-run the workflow

---

### Containers not starting

**Problem**: Docker Compose configuration issue

**Solution**:

1. Check logs in Hostinger Docker Manager
2. Verify `docker-compose.yml` is correct
3. Check environment variables in GitHub

---

### Can't access application

**Problem**: Firewall or port configuration

**Solution**:

Check Hostinger firewall settings:
1. Go to **VPS** → **Settings** → **Firewall**
2. Ensure ports are open:
   - `8080` (backend)
   - `8081` (frontend)
   - `80` (HTTP)
   - `443` (HTTPS) if using SSL

---

## 🔒 Security Best Practices

- ✅ Never commit API keys to git
- ✅ Use GitHub Secrets for sensitive data
- ✅ Set `ALLOWED_ORIGINS` to your domain (not `*`)
- ✅ Enable rate limiting in production
- ✅ Use HTTPS with SSL certificate
- ✅ Regularly rotate your API keys
- ✅ Use strong passwords for VPS access

---

## 📝 GitHub Secrets & Variables Summary

### Secrets (1 required)
| Name | Description | Example |
|------|-------------|---------|
| `HOSTINGER_API_KEY` | Your Hostinger API key | `hapi_abc123...` |

### Variables (3 required)
| Name | Description | Example |
|------|-------------|---------|
| `HOSTINGER_VM_ID` | Your VPS VM ID | `abc123def456` |
| `ALLOWED_ORIGINS` | Frontend domain | `https://app.example.com` |
| `VITE_API_URL` | Backend URL | `https://api.example.com` |

### Optional Variables (with defaults)
| Name | Default | Description |
|------|---------|-------------|
| `PORT` | `8080` | Backend port |
| `MAX_UPLOAD_SIZE` | `52428800` | Max file size (50MB) |
| `DEBUG_LOG` | `false` | Enable debug logs |
| `RATE_LIMIT_ENABLED` | `true` | Enable rate limiting |
| `RATE_LIMIT_REQUESTS` | `50` | Requests per window |
| `RATE_LIMIT_WINDOW` | `60` | Window in seconds |

---

## 🎯 Quick Checklist

Before your first deployment:

- [ ] Hostinger API key generated
- [ ] VM ID obtained
- [ ] GitHub secret `HOSTINGER_API_KEY` added
- [ ] GitHub variable `HOSTINGER_VM_ID` added
- [ ] GitHub variable `ALLOWED_ORIGINS` added
- [ ] GitHub variable `VITE_API_URL` added
- [ ] VPS has Docker installed
- [ ] Firewall ports opened (8080, 8081)
- [ ] Pushed to main branch
- [ ] Deployment succeeded in GitHub Actions
- [ ] Application accessible via browser

---

## 🎉 You're All Set!

Now every push to `main` automatically deploys to your Hostinger VPS!

```bash
git push origin main
# ✨ Auto-deploys to production!
```

**Happy deploying! 🚀**

---

## 📞 Need Help?

- **Hostinger Support**: https://www.hostinger.com/support
- **GitHub Actions Docs**: https://docs.github.com/actions
- **Hostinger Deploy Action**: https://github.com/hostinger/deploy-on-vps

---

## 🔗 Related Files

- `.github/workflows/deploy-production.yml` - GitHub Actions workflow
- `docker-compose.yml` - Docker configuration
- `deploy/README.md` - Deployment options overview
