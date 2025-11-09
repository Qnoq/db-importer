# 🚀 Production Deployment Guide

## Quick Start (5 minutes)

### 1. Clone and Configure
```bash
git clone <your-repo-url>
cd db-importer
cp .env.production.example .env
nano .env  # Edit with your domains
```

### 2. Update .env
```bash
# Set these values:
ALLOWED_ORIGINS=https://your-frontend-domain.com
VITE_API_URL=https://your-backend-domain.com
DEBUG_LOG=false
```

### 3. Build and Deploy
```bash
docker compose build
docker compose up -d
```

### 4. Verify
```bash
# Check health
docker ps  # Should show "healthy" status
curl http://localhost:8080/health

# Check logs
docker compose logs -f
```

---

## Detailed Deployment

### Requirements
- Docker 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum
- 5GB disk space

### Step 1: Environment Configuration

Create `.env` from template:
```bash
cp .env.production.example .env
```

**Required variables**:
```bash
# Backend
PORT=8080
ALLOWED_ORIGINS=https://db-importer.company.com
MAX_UPLOAD_SIZE=52428800  # 50MB
DEBUG_LOG=false
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=50
RATE_LIMIT_WINDOW=60

# Frontend
VITE_API_URL=https://api.db-importer.company.com
```

### Step 2: SSL/TLS (Recommended)

Option A: Use nginx reverse proxy
```bash
# docker-compose.yml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

Option B: Use Traefik/Caddy (automatic HTTPS)

### Step 3: Build Images
```bash
# Build with no cache for clean build
docker compose build --no-cache

# Or build specific service
docker compose build backend
docker compose build frontend
```

### Step 4: Deploy
```bash
# Start in background
docker compose up -d

# Watch logs during startup
docker compose logs -f

# Stop watching with Ctrl+C (services keep running)
```

### Step 5: Verify Deployment
```bash
# 1. Check container status
docker ps
# Both should show "healthy"

# 2. Test backend health
curl http://localhost:8080/health
# Should return: {"status":"ok","version":"1.0.0"}

# 3. Test frontend
curl http://localhost:8081
# Should return HTML

# 4. Test CORS (from allowed origin)
curl -H "Origin: https://your-frontend-domain.com" \
     -H "Access-Control-Request-Method: POST" \
     -X OPTIONS \
     http://localhost:8080/parse-schema
```

---

## Troubleshooting

### Containers not healthy
```bash
# Check logs
docker compose logs backend
docker compose logs frontend

# Common issues:
# - Port already in use: Change PORT in .env
# - CORS errors: Check ALLOWED_ORIGINS matches frontend domain
# - Build errors: Run docker compose build --no-cache
```

### CORS errors
```bash
# Verify ALLOWED_ORIGINS includes your frontend domain
docker compose exec backend env | grep ALLOWED_ORIGINS

# Check frontend is sending correct Origin header
# In browser console: document.location.origin
```

### Rate limit errors
```bash
# Temporary increase
# Edit .env:
RATE_LIMIT_REQUESTS=200

# Restart
docker compose restart backend
```

### File upload fails
```bash
# Check MAX_UPLOAD_SIZE (in bytes)
# 50MB = 52428800
# 100MB = 104857600

# Edit .env and restart
docker compose restart backend
```

---

## Monitoring

### Health Checks
```bash
# Manual check
curl http://localhost:8080/health

# Automated monitoring with cron
*/5 * * * * curl -f http://localhost:8080/health || alert-script.sh
```

### Logs
```bash
# View logs
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100

# Specific service
docker compose logs -f backend

# Export logs
docker compose logs > app-logs-$(date +%Y%m%d).log
```

### Resource Usage
```bash
# Container stats
docker stats

# Disk usage
docker system df
```

---

## Updates and Maintenance

### Update Application
```bash
# 1. Pull latest code
git pull origin main

# 2. Rebuild images
docker compose build

# 3. Restart with new images
docker compose up -d
```

### Backup
```bash
# No database, just backup .env file
cp .env .env.backup

# And keep Docker images for rollback
docker save db-importer-backend:latest > backup-backend.tar
docker save db-importer-frontend:latest > backup-frontend.tar
```

### Rollback
```bash
# Stop current version
docker compose down

# Load old images
docker load < backup-backend.tar
docker load < backup-frontend.tar

# Start old version
docker compose up -d
```

---

## Security Hardening

### 1. Use non-root user in Dockerfile
Already implemented in both Dockerfiles ✅

### 2. Limit container resources
```yaml
# docker-compose.yml
services:
  backend:
    mem_limit: 512m
    cpus: 1.0
```

### 3. Regular updates
```bash
# Monthly: rebuild images for security patches
docker compose build --pull
docker compose up -d
```

### 4. Network security
```bash
# Use firewall to limit access
ufw allow 443/tcp  # HTTPS only
ufw deny 8080/tcp  # Block direct backend access
```

---

## Support

For issues:
1. Check logs: `docker compose logs -f`
2. Review SECURITY.md
3. Contact your DevOps team

---

**Last Updated**: 2025-11-07
