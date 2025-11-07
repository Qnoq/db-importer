#!/bin/bash

# Local script to deploy to production VPS
# Usage: ./deploy/push-to-prod.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if SSH config exists
if [ ! -f "deploy/config.sh" ]; then
    echo -e "${RED}❌ Error: deploy/config.sh not found${NC}"
    echo -e "${YELLOW}Please create deploy/config.sh with your VPS details:${NC}"
    echo ""
    echo "SSH_USER=\"your-user\""
    echo "SSH_HOST=\"your-vps-ip-or-domain\""
    echo "SSH_PORT=\"22\""
    echo "APP_DIR=\"/var/www/db-importer\""
    echo ""
    exit 1
fi

# Load configuration
source deploy/config.sh

echo -e "${BLUE}🚀 Deploying to Production VPS...${NC}"
echo -e "${BLUE}Host: ${SSH_USER}@${SSH_HOST}${NC}"
echo ""

# Push to git (assuming you have a git remote 'prod' or 'origin')
echo -e "${BLUE}📤 Pushing code to git repository...${NC}"
git push origin main

# SSH into VPS and run deployment script
echo -e "${BLUE}🔗 Connecting to VPS and deploying...${NC}"
ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "bash ${APP_DIR}/deploy/deploy.sh"

echo ""
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo -e "${GREEN}🌐 Check your application at your domain${NC}"
