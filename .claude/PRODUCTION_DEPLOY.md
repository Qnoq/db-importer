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

---

## Supabase Database Configuration

### Prerequisites

This application requires a PostgreSQL database. We recommend using **Supabase** for its ease of setup and built-in features.

### Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Sign up/Login
3. Click "New Project"
4. Fill in project details:
   - Name: `db-importer-prod`
   - Database Password: Generate a strong password (save it!)
   - Region: Choose closest to your users
   - Plan: Free tier is sufficient to start

### Step 2: Get Connection Pooler URL

**Important:** Use the Connection Pooler URL, not the direct connection URL. The direct URL is IPv6-only and won't work in most Docker environments.

1. In your Supabase project, go to **Project Settings** (⚙️)
2. Click **Database** in sidebar
3. Scroll to **Connection pooling** section
4. Select **Session mode** (required for migrations)
5. Copy the connection string:

```
postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-region.pooler.supabase.com:5432/postgres
```

**Key differences:**
- ✅ Pooler: `aws-0-region.pooler.supabase.com` (IPv4 + IPv6)
- ❌ Direct: `db.xxxxx.supabase.co` (IPv6 only, will fail)

### Step 3: Configure Environment Variables

Add to your `.env` file:

```bash
# Supabase Database - Use Connection Pooler (Session mode)
DATABASE_URL=postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-region.pooler.supabase.com:5432/postgres
DB_MAX_OPEN_CONNS=25
DB_MAX_IDLE_CONNS=5
DB_CONN_MAX_LIFETIME=5m
DB_CONN_MAX_IDLE_TIME=10m

# JWT Secrets (generate with: openssl rand -base64 32)
JWT_ACCESS_SECRET=your-access-secret-here
JWT_REFRESH_SECRET=your-refresh-secret-here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=168h

# Supabase Config (optional, for Supabase client SDK)
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_PROJECT_REF=xxxxx
```

### Step 4: Run Migrations

Migrations run automatically on backend startup. Check logs to verify:

```bash
docker compose up -d
docker compose logs backend -f
```

You should see:
```
✅ Database connection established successfully
Database migrations completed successfully
```

### Troubleshooting Database Connection

**Error: `dial tcp [2a05:...]:5432: cannot assign requested address`**
- You're using the direct connection URL instead of the pooler
- Solution: Use the Connection Pooler URL (see Step 2)

**Error: `unknown driver DATABASE_URL=postgresql`**
- The `DATABASE_URL` in GitHub Secrets contains `DATABASE_URL=` prefix
- Solution: Secret should be just the URL, not `DATABASE_URL=url`

**Error: `failed to connect to user=appuser`**
- The `DATABASE_URL` environment variable is not set correctly
- Check for double `DATABASE_URL=DATABASE_URL=` in `.env` file
- Solution: Should be `DATABASE_URL=postgresql://...` (one equals sign)

**Migrations fail with "permission denied"**
- Make sure you're using **Session mode** pooler, not Transaction mode
- Transaction mode (port 6543) doesn't support DDL statements
- Session mode (port 5432) supports all PostgreSQL features

### Database Management

**View tables in Supabase:**
1. Go to **Table Editor** in Supabase dashboard
2. You should see:
   - `users` - User accounts
   - `refresh_tokens` - JWT refresh tokens
   - `imports` - Import history (if implemented)

**Run SQL queries:**
1. Go to **SQL Editor** in Supabase dashboard
2. Run queries to check data:
```sql
-- Check users
SELECT id, email, created_at FROM users;

-- Check import history
SELECT * FROM imports ORDER BY created_at DESC LIMIT 10;
```

**Reset database:**
```sql
-- WARNING: This deletes all data!
TRUNCATE users, refresh_tokens, imports CASCADE;
```

### Security Best Practices

1. **Never commit DATABASE_URL to Git**
   - It's in `.gitignore` - keep it there!
   - Use environment variables or secrets management

2. **Use strong JWT secrets**
   ```bash
   openssl rand -base64 32
   ```

3. **Enable Row Level Security (RLS) in Supabase**
   - Go to **Authentication** → **Policies**
   - Add policies to restrict access

4. **Rotate secrets regularly**
   - Database password: Every 90 days
   - JWT secrets: When team members leave

5. **Monitor database usage**
   - Supabase Dashboard → **Database** → **Usage**
   - Set up alerts for high connection counts

### Connection Pooling Benefits

Using Supabase Connection Pooler provides:

- ✅ **IPv4 compatibility** - Works in Docker without IPv6
- ✅ **Connection reuse** - Reduces connection overhead
- ✅ **Better performance** - Shared connection pool
- ✅ **Auto-scaling** - Handles traffic spikes
- ✅ **Free** - Included in all Supabase plans

### Additional Resources

- [Supabase Connection Pooling Guide](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler)
- [IPv6 Connection Issues (Medium)](https://medium.com/@lhc1990/solving-supabase-ipv6-connection-issues-96f8481f42c1)
- See `SUPABASE_CONNECTION.md` for detailed setup
- See `.claude/docs/ARCHITECTURE_AUTH_DB.md` for database schema


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
