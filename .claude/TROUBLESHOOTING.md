# Troubleshooting Guide

## Common Issues

### 1. "Failed to fetch" / "Cannot connect to backend server"

**Symptoms:**
- Upload SQL file shows "Upload Failed - Failed to fetch"
- Error message: "Cannot connect to backend server"

**Causes:**
- Backend container is not running
- Backend crashed during startup
- Port 8080 is not accessible

**Solutions:**

#### Check if backend is running:
```bash
docker compose -f docker-compose.dev.yml ps
```

You should see:
```
NAME                      STATUS
db-importer-backend-dev   Up
db-importer-frontend-dev  Up
```

#### Check backend logs:
```bash
docker compose -f docker-compose.dev.yml logs backend
```

Look for errors like:
- `rosetta error` - See "Apple Silicon Issues" below
- `port already in use` - Another process is using port 8080
- Compilation errors - Check your Go code

#### Restart backend:
```bash
docker compose -f docker-compose.dev.yml restart backend
```

#### Full rebuild:
```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml up --build
```

---

### 2. Apple Silicon (M1/M2/M3) - Rosetta Errors

**Symptoms:**
```
rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2
backend exited with code 133
```

**Cause:**
Docker is trying to run an x86-64 binary on ARM64 architecture.

**Solution:**
This should be fixed in the latest version. If you still see this:

1. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

2. **Remove old images:**
   ```bash
   docker compose -f docker-compose.dev.yml down --rmi all
   ```

3. **Rebuild from scratch:**
   ```bash
   docker compose -f docker-compose.dev.yml up --build
   ```

4. **Verify architecture:**
   ```bash
   docker compose -f docker-compose.dev.yml exec backend uname -m
   ```
   Should show: `aarch64` (ARM64) or `x86_64` (Intel)

---

### 3. CORS Errors

**Symptoms:**
- Browser console shows: `Access-Control-Allow-Origin` error
- Upload works in backend logs but fails in browser

**Solutions:**

#### Check ALLOWED_ORIGINS in docker-compose.dev.yml:
```yaml
environment:
  - ALLOWED_ORIGINS=*  # Should allow all origins in dev
```

#### For production, set specific origin:
```yaml
environment:
  - ALLOWED_ORIGINS=http://localhost:5173,https://yourdomain.com
```

---

### 4. Port Already in Use

**Symptoms:**
```
Error: bind: address already in use
```

**Solutions:**

#### Find what's using the port:
```bash
# macOS/Linux
lsof -i :8080
lsof -i :5173

# Windows
netstat -ano | findstr :8080
netstat -ano | findstr :5173
```

#### Kill the process or change ports in docker-compose.dev.yml:
```yaml
ports:
  - "8081:8080"  # Use different host port
```

---

### 5. Hot Reload Not Working

**Symptoms:**
- Changes to code don't reflect automatically
- Need to manually restart containers

**Solutions:**

#### Backend (Go):
- Ensure `backend/.air.toml` exists
- Check Air is running in logs:
  ```bash
  docker compose -f docker-compose.dev.yml logs backend | grep "air"
  ```

#### Frontend (Vue):
- Vite should auto-reload
- Check browser console for WebSocket errors
- Try hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)

---

### 6. Navigation Issues

**Symptoms:**
- Can't go back to previous steps
- Can skip to steps without completing current one

**Solutions:**

#### Navigation Rules:
- ✅ Can navigate **backward** to completed steps
- ❌ Cannot navigate **forward** without completing current step
- Use "Start Over" button to reset everything

#### If stuck:
1. Use browser DevTools → Application → Local Storage
2. Clear `db-importer-state`
3. Refresh page

---

### 7. File Upload Fails - Size Limit

**Symptoms:**
- Large SQL files fail to upload
- Error: "File size may exceed limit"

**Solutions:**

#### Increase limit in docker-compose.dev.yml:
```yaml
environment:
  - MAX_UPLOAD_SIZE=104857600  # 100MB (in bytes)
```

#### Default: 50MB (52428800 bytes)

---

## Quick Diagnostic Commands

### Check all containers:
```bash
docker compose -f docker-compose.dev.yml ps
```

### View all logs:
```bash
docker compose -f docker-compose.dev.yml logs -f
```

### View backend logs only:
```bash
docker compose -f docker-compose.dev.yml logs -f backend
```

### View frontend logs only:
```bash
docker compose -f docker-compose.dev.yml logs -f frontend
```

### Restart everything:
```bash
docker compose -f docker-compose.dev.yml restart
```

### Clean rebuild:
```bash
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml up --build
```

### Check backend health:
```bash
curl http://localhost:8080/health
```

Should return:
```json
{
  "status": "ok",
  "version": "1.0.0",
  "config": {
    "maxUploadSize": 52428800,
    "rateLimitEnabled": false
  }
}
```

---

## Still Having Issues?

1. Check GitHub Issues: [link-to-your-repo/issues]
2. Enable debug logging:
   ```yaml
   environment:
     - DEBUG_LOG=true
   ```
3. Share logs when reporting issues:
   ```bash
   docker compose -f docker-compose.dev.yml logs > logs.txt
   ```

---

## Development Tips

### Watch backend rebuild on code changes:
```bash
docker compose -f docker-compose.dev.yml logs -f backend
```

### Access containers directly:
```bash
# Backend shell
docker compose -f docker-compose.dev.yml exec backend sh

# Frontend shell
docker compose -f docker-compose.dev.yml exec frontend sh
```

### Check Go modules:
```bash
docker compose -f docker-compose.dev.yml exec backend go mod tidy
```

### Rebuild only frontend:
```bash
docker compose -f docker-compose.dev.yml up -d --build frontend
```

### Rebuild only backend:
```bash
docker compose -f docker-compose.dev.yml up -d --build backend
```

---

## Supabase Database Issues

### 8. Supabase IPv6 Connection Errors

**Symptoms:**
```
dial tcp [2a05:...]:5432: connect: cannot assign requested address
unknown driver DATABASE_URL=postgresql
failed to connect to user=appuser database=
Database migrations failed (continuing anyway)
Failed to connect to database, running in stateless mode
```

**Cause:**
Supabase now uses IPv6-only for direct database connections (`db.xxxxx.supabase.co`). If your server/Docker environment doesn't support IPv6, connections will fail.

**Solution: Use Supabase Connection Pooler (IPv4 compatible)**

#### Step 1: Get Connection Pooler URL

1. Go to https://supabase.com/dashboard
2. Select your project
3. **Project Settings** → **Database**
4. Scroll to **Connection pooling**
5. Copy the **Session mode** URL (port 5432)

It looks like:
```
postgresql://postgres.xxxxx:[PASSWORD]@aws-0-region.pooler.supabase.com:5432/postgres
```

**Important:**
- Use **Session mode** (port 5432) - required for migrations
- NOT Transaction mode (port 6543) - doesn't support DDL statements

#### Step 2: Update DATABASE_URL

**In GitHub Secrets** (for GitHub Actions deployment):
1. Go to repo **Settings** → **Secrets and variables** → **Actions**
2. Update `DATABASE_URL` secret with the pooler URL
3. **IMPORTANT:** Only put the URL, NOT `DATABASE_URL=url`
   - ✅ Correct: `postgresql://postgres.xxxxx:pwd@aws-0-region.pooler.supabase.com:5432/postgres`
   - ❌ Wrong: `DATABASE_URL=postgresql://...` (causes double `DATABASE_URL=DATABASE_URL=`)

**On your server** (manual configuration):
```bash
cd /docker/db-importer
nano .env
```

Update the DATABASE_URL line:
```env
# BEFORE (IPv6 only - fails)
DATABASE_URL=postgresql://postgres:pwd@db.xxxxx.supabase.co:5432/postgres

# AFTER (IPv4+IPv6 pooler - works)
DATABASE_URL=postgresql://postgres.xxxxx:pwd@aws-0-region.pooler.supabase.com:5432/postgres
```

**Common mistake:** Double `DATABASE_URL=`
```env
# ❌ WRONG (causes "unknown driver" error)
DATABASE_URL=DATABASE_URL=postgresql://...

# ✅ CORRECT
DATABASE_URL=postgresql://...
```

#### Step 3: Restart Application

```bash
docker compose down
docker compose up -d
docker compose logs backend -f
```

You should see:
```
✅ Database connection established successfully
Database migrations completed successfully
```

#### Benefits of Connection Pooler

✅ **IPv4 + IPv6 support** - Works in any environment
✅ **Connection pooling** - Better performance for production
✅ **Free** - Included in all Supabase plans
✅ **No network config** - No server changes needed
✅ **Scalable** - Handles many concurrent connections

#### Additional References

- [Medium Article: Supabase IPv6 Connection Issues](https://medium.com/@lhc1990/solving-supabase-ipv6-connection-issues-96f8481f42c1)
- [Supabase Connection Pooling Docs](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler)
- See also: `SUPABASE_CONNECTION.md` in project root

---
