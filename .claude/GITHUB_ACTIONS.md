# GitHub Actions Deployment Guide

## Overview

This project uses GitHub Actions with the **Hostinger Deploy Action** to automatically deploy your application to a Hostinger VPS.

## Workflow Configuration

The deployment workflow is located at `.github/workflows/deploy-production.yml` and is configured for **manual deployment only**.

### Trigger Method

**Manual deployment** - Click "Run workflow" in GitHub Actions tab
- Gives you full control over when to deploy to production
- No automatic deployments on push (intentional for safety)

## Required Secrets and Variables

### Secrets (GitHub → Settings → Secrets and variables → Actions → Secrets)

These contain sensitive information and are encrypted by GitHub:

| Secret Name | Description | Example/Notes |
|------------|-------------|---------------|
| `HOSTINGER_API_KEY` | Hostinger API key for deployment | Get from Hostinger dashboard |
| `DATABASE_URL` | Supabase Connection Pooler URL | **IMPORTANT:** Do NOT include `DATABASE_URL=` prefix |
| `JWT_ACCESS_SECRET` | Secret for access tokens | Generate with `openssl rand -base64 32` |
| `JWT_REFRESH_SECRET` | Secret for refresh tokens | Generate with `openssl rand -base64 32` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | From Supabase Project Settings |

### Variables (GitHub → Settings → Secrets and variables → Actions → Variables)

These are non-sensitive configuration values:

| Variable Name | Description | Example |
|--------------|-------------|---------|
| `HOSTINGER_VM_ID` | Your Hostinger VM number | `829722` |
| `PORT` | Backend port | `8080` |
| `ALLOWED_ORIGINS` | CORS allowed origins | `http://168.231.76.18:8081` |
| `VITE_API_URL` | Frontend API URL | `http://168.231.76.18:8080` |
| `SUPABASE_URL` | Supabase project URL | `https://xxxxx.supabase.co` |
| `SUPABASE_PROJECT_REF` | Supabase project reference | `xxxxx` |

## Critical Configuration Notes

### ⚠️ DATABASE_URL Secret Format

**VERY IMPORTANT:** The `DATABASE_URL` secret must contain **ONLY the connection string**, not the variable name.

✅ **CORRECT:**
```
postgresql://postgres.xxxxx:password@aws-0-region.pooler.supabase.com:5432/postgres
```

❌ **WRONG (causes errors):**
```
DATABASE_URL=postgresql://postgres.xxxxx:password@...
```

**Why?** The Hostinger action automatically prefixes it with `DATABASE_URL=`. If your secret already contains it, you'll get:
```
DATABASE_URL=DATABASE_URL=postgresql://...
```
This causes the "unknown driver" error.

### Database URL Requirements

- **Must use Supabase Connection Pooler URL** (not direct connection)
- Format: `postgresql://postgres.PROJECT_REF:PASSWORD@aws-0-REGION.pooler.supabase.com:5432/postgres`
- Use **Session mode** (port 5432), not Transaction mode (port 6543)
- Session mode is required for database migrations

**How to get it:**
1. Supabase Dashboard → Project Settings → Database
2. Scroll to "Connection pooling"
3. Select "Session mode"
4. Copy the connection string

## How to Deploy

### Method 1: Manual Deployment (Recommended)

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **Deploy to Production VPS** workflow
4. Click **Run workflow** button
5. Select branch (usually `main`)
6. Click green **Run workflow** button

The workflow will:
- Checkout code from the selected branch
- Use Hostinger API to deploy to your VPS
- Create/update `.env` file with all secrets and variables
- Run `docker compose build`
- Run `docker compose up -d`
- Restart your application

### Method 2: From Pull Request

After merging a PR into `main`:
1. Go to **Actions** tab
2. Manually trigger deployment (see Method 1)

**Note:** Deployment does NOT happen automatically on push to `main` - this is intentional for production safety.

## What the Workflow Does

```yaml
1. Checkout code
2. Use Hostinger Deploy Action with:
   - API Key authentication
   - VM ID to target correct server
   - docker-compose.yml path
   - All environment variables from secrets/vars
3. On Hostinger VPS, the action:
   - Pulls latest code
   - Creates .env with all variables
   - Runs: docker compose build
   - Runs: docker compose up -d
```

## Monitoring Deployments

### View Deployment Logs

1. Go to **Actions** tab
2. Click on the running/completed workflow
3. Click on "Deploy to Hostinger VPS" job
4. Expand each step to see details

### Check Deployment Status

Look for these indicators in logs:

✅ **Successful deployment:**
```
🎉 Deployment successful!
Application is now live on your VPS
```

❌ **Failed deployment:**
```
⚠️ Deployment failed. Check the logs above.
```

### Verify on Server

After deployment, SSH to your server to verify:

```bash
ssh root@srv[VM_ID].hstgr.cloud
cd /docker/db-importer

# Check containers are running
docker compose ps

# Check backend logs
docker compose logs backend -f

# Should see:
# ✅ Database connection established successfully
# Database migrations completed successfully
```

## Troubleshooting

### Deployment Succeeds but App Doesn't Work

**Check backend logs:**
```bash
docker compose logs backend --tail=100
```

**Common issues:**

1. **Database connection fails:**
   - Error: `unknown driver DATABASE_URL=postgresql`
   - Solution: Remove `DATABASE_URL=` prefix from GitHub secret
   - Correct format: Just the connection URL

2. **IPv6 connection errors:**
   - Error: `dial tcp [2a05:...]:5432: cannot assign requested address`
   - Solution: Use Connection Pooler URL, not direct connection
   - See "Database URL Requirements" above

3. **Migrations fail:**
   - Error: `permission denied` or DDL errors
   - Solution: Use Session mode (port 5432), not Transaction mode
   - Transaction mode doesn't support migrations

### Workflow Fails to Start

**Error: Missing secrets**
- Check all required secrets are configured in GitHub
- Verify spelling matches exactly (case-sensitive)

**Error: Hostinger API authentication failed**
- Verify `HOSTINGER_API_KEY` is correct
- Verify `HOSTINGER_VM_ID` is correct
- Check Hostinger dashboard for API key status

### Environment Variables Not Applied

If you update secrets/variables but they don't take effect:

1. The Hostinger action **recreates** the `.env` file each time
2. Any manual changes on the server will be overwritten
3. To persist changes, update them in GitHub secrets/variables
4. Then re-run the deployment

## Security Best Practices

### 1. Secret Management

- ✅ Store sensitive data in GitHub Secrets (encrypted)
- ✅ Store non-sensitive config in GitHub Variables (visible)
- ❌ Never commit secrets to `.env` files in Git
- ❌ Never log secrets in workflow output

### 2. Access Control

- Limit who can trigger deployments:
  - GitHub repo Settings → Branches → Branch protection rules
  - Require PR reviews before merging to `main`
- Use environment protection rules for production:
  - Settings → Environments → New environment
  - Add required reviewers for deployments

### 3. Audit Trail

- All deployments are logged in GitHub Actions
- View history: Actions tab → Workflow runs
- Each run shows:
  - Who triggered it
  - When it ran
  - What was deployed (commit SHA)
  - Success/failure status

### 4. Rotate Secrets Regularly

Schedule regular rotation:
- Database password: Every 90 days
- JWT secrets: When team members leave
- API keys: Every 6 months

## Manual Deployment Alternative

If GitHub Actions is unavailable, you can deploy manually via SSH:

```bash
# 1. SSH to server
ssh root@srv829722.hstgr.cloud

# 2. Navigate to project
cd /docker/db-importer

# 3. Pull latest code
git pull origin main

# 4. Update .env if needed
nano .env

# 5. Rebuild and restart
docker compose down
docker compose build
docker compose up -d

# 6. Check logs
docker compose logs -f backend
```

## Workflow Customization

### Enable Auto-Deploy on Push

To automatically deploy when pushing to `main`:

```yaml
# .github/workflows/deploy-production.yml
on:
  workflow_dispatch:  # Keep manual option
  push:
    branches:
      - main  # Add auto-deploy
```

**Warning:** Auto-deploy to production can be risky. Consider using a staging environment first.

### Deploy to Multiple Environments

Create separate workflow files:

- `.github/workflows/deploy-staging.yml` - Auto-deploy on push
- `.github/workflows/deploy-production.yml` - Manual deploy only

## Additional Resources

- [Hostinger Deploy Action Docs](https://github.com/marketplace/actions/hostinger-deploy-on-vps)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Managing Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- See also: `.claude/PRODUCTION_DEPLOY.md` for server setup

---

**Last Updated:** 2025-11-11
