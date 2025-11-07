# 🚀 Production Deployment Guide - Hostinger VPS

This guide will help you set up automatic deployment to your Hostinger VPS with a simple `./deploy/push-to-prod.sh` command.

---

## 📋 Prerequisites

- ✅ VPS with Docker and Docker Compose installed
- ✅ SSH access to your VPS
- ✅ Git installed on VPS
- ✅ Domain name (optional, can use IP)

---

## 🔧 One-Time Setup (VPS)

### 1. SSH into your VPS

```bash
ssh root@your-vps-ip
```

### 2. Create application directory

```bash
mkdir -p /var/www/db-importer
cd /var/www/db-importer
```

### 3. Clone your repository

```bash
# If using GitHub/GitLab
git clone https://github.com/yourusername/db-importer.git .

# Or initialize and add remote
git init
git remote add origin https://github.com/yourusername/db-importer.git
git fetch origin
git checkout main
```

### 4. Create production .env file

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

**⚠️ CRITICAL**: Set `ALLOWED_ORIGINS` to your actual domain, NOT `*`

### 5. Make deployment script executable

```bash
chmod +x deploy/deploy.sh
```

### 6. Initial deployment (manual)

```bash
cd /var/www/db-importer
docker-compose build
docker-compose up -d
```

Verify containers are running:

```bash
docker-compose ps
```

---

## 🖥️ One-Time Setup (Local Machine)

### 1. Configure SSH for easy access (optional but recommended)

Edit your SSH config:

```bash
nano ~/.ssh/config
```

Add entry for your VPS:

```
Host db-importer-prod
    HostName your-vps-ip-or-domain.com
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa
```

Now you can SSH with just: `ssh db-importer-prod`

### 2. Create deployment configuration

```bash
cd /path/to/db-importer
cp deploy/config.sh.example deploy/config.sh
nano deploy/config.sh
```

Fill in your VPS details:

```bash
SSH_USER="root"
SSH_HOST="your-vps-ip-or-domain.com"
SSH_PORT="22"
APP_DIR="/var/www/db-importer"
```

### 3. Make deployment script executable

```bash
chmod +x deploy/push-to-prod.sh
```

### 4. Add config.sh to .gitignore

```bash
echo "deploy/config.sh" >> .gitignore
```

---

## 🚀 Deploying to Production

### Simple Command

```bash
./deploy/push-to-prod.sh
```

That's it! This script will:

1. ✅ Push your latest code to git
2. ✅ SSH into your VPS
3. ✅ Pull latest changes
4. ✅ Rebuild Docker images
5. ✅ Restart containers
6. ✅ Show deployment status

### Manual Deployment (if script fails)

SSH into VPS and run:

```bash
cd /var/www/db-importer
bash deploy/deploy.sh
```

---

## 🌐 Setting Up Domain & SSL (Optional)

### Option 1: Using Nginx Reverse Proxy (Recommended)

**Install Nginx on VPS:**

```bash
apt update
apt install nginx certbot python3-certbot-nginx -y
```

**Create Nginx config:**

```bash
nano /etc/nginx/sites-available/db-importer
```

Add configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Increase limits for file uploads
        client_max_body_size 100M;
    }
}
```

**Enable site:**

```bash
ln -s /etc/nginx/sites-available/db-importer /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

**Setup SSL with Let's Encrypt:**

```bash
certbot --nginx -d your-domain.com
```

### Option 2: Direct Access (No Domain)

Access via:
- Frontend: `http://your-vps-ip:8081`
- Backend: `http://your-vps-ip:8080`

---

## 🔒 Security Checklist

Before going live:

- [ ] Change `ALLOWED_ORIGINS` from `*` to your actual domain
- [ ] Set strong passwords for SSH
- [ ] Enable firewall (ufw)
- [ ] Use SSH keys instead of passwords
- [ ] Keep Docker images updated
- [ ] Review SECURITY.md file
- [ ] Setup SSL/HTTPS
- [ ] Configure backup strategy

### Quick Firewall Setup

```bash
# Enable firewall
ufw enable

# Allow SSH
ufw allow 22/tcp

# Allow HTTP/HTTPS (if using nginx)
ufw allow 80/tcp
ufw allow 443/tcp

# Or allow Docker ports directly
ufw allow 8080/tcp
ufw allow 8081/tcp

# Check status
ufw status
```

---

## 📊 Monitoring & Logs

### View application logs

```bash
cd /var/www/db-importer

# All logs
docker-compose logs

# Follow logs (live)
docker-compose logs -f

# Backend only
docker-compose logs -f backend

# Frontend only
docker-compose logs -f frontend

# Last 100 lines
docker-compose logs --tail=100
```

### Check container health

```bash
docker-compose ps
docker-compose top
```

### Restart services

```bash
# Restart all
docker-compose restart

# Restart backend only
docker-compose restart backend

# Restart frontend only
docker-compose restart frontend
```

---

## 🔄 Updating the Application

### Regular Updates

Just run from your local machine:

```bash
./deploy/push-to-prod.sh
```

### Rollback to Previous Version

SSH into VPS:

```bash
cd /var/www/db-importer
git log --oneline -10  # See recent commits
git reset --hard <commit-hash>
docker-compose down
docker-compose build
docker-compose up -d
```

---

## 🆘 Troubleshooting

### Deployment script fails

**Check SSH connection:**

```bash
ssh root@your-vps-ip
```

**Check if git remote is correct:**

```bash
git remote -v
```

### Containers won't start

**Check logs:**

```bash
docker-compose logs
```

**Check disk space:**

```bash
df -h
```

**Clean up Docker:**

```bash
docker system prune -a
```

### Can't connect to application

**Check if containers are running:**

```bash
docker-compose ps
```

**Check firewall:**

```bash
ufw status
```

**Check Nginx (if using):**

```bash
systemctl status nginx
nginx -t
```

### Backend can't connect

**Check CORS settings in .env:**

```bash
cat /var/www/db-importer/.env | grep ALLOWED_ORIGINS
```

Should be your domain, not `*` in production.

---

## 📝 Useful Commands

```bash
# Deploy to production
./deploy/push-to-prod.sh

# SSH to VPS
ssh root@your-vps-ip

# View logs
docker-compose logs -f

# Restart app
docker-compose restart

# Rebuild and restart
docker-compose down && docker-compose build && docker-compose up -d

# Check status
docker-compose ps

# Access backend container
docker-compose exec backend sh

# Access frontend container
docker-compose exec frontend sh
```

---

## 🎯 Quick Start Checklist

- [ ] VPS setup complete with Docker installed
- [ ] Repository cloned to `/var/www/db-importer`
- [ ] Production `.env` file created on VPS
- [ ] `ALLOWED_ORIGINS` set to actual domain (not `*`)
- [ ] `deploy/config.sh` created locally with VPS details
- [ ] SSH access working
- [ ] `./deploy/push-to-prod.sh` runs successfully
- [ ] Application accessible via browser
- [ ] SSL certificate installed (optional)
- [ ] Firewall configured
- [ ] Backups configured

---

## 📞 Support

If you encounter issues:

1. Check logs: `docker-compose logs`
2. Review this guide
3. Check SECURITY.md for security best practices
4. Verify all environment variables are set correctly

---

**🎉 You're all set! Happy deploying!**
