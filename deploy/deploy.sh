#!/bin/bash

# Production Deployment Script for db-importer
# This script runs on the VPS to deploy the application

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Configuration
APP_DIR="/var/www/db-importer"
BRANCH="main"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Navigate to app directory
echo -e "${BLUE}📂 Navigating to ${APP_DIR}...${NC}"
cd "$APP_DIR"

# Pull latest changes
echo -e "${BLUE}📥 Pulling latest changes from ${BRANCH}...${NC}"
git fetch origin
git reset --hard origin/$BRANCH

# Stop existing containers
echo -e "${BLUE}🛑 Stopping existing containers...${NC}"
docker-compose down

# Remove old images to force rebuild
echo -e "${BLUE}🗑️  Removing old images...${NC}"
docker-compose rm -f || true

# Build new images
echo -e "${BLUE}🔨 Building new Docker images...${NC}"
docker-compose build --no-cache

# Start containers
echo -e "${BLUE}🚀 Starting containers...${NC}"
docker-compose up -d

# Wait for services to be healthy
echo -e "${BLUE}⏳ Waiting for services to be healthy...${NC}"
sleep 10

# Check container status
echo -e "${BLUE}📊 Container status:${NC}"
docker-compose ps

# Show logs
echo -e "${BLUE}📋 Recent logs:${NC}"
docker-compose logs --tail=50

# Cleanup old images
echo -e "${BLUE}🧹 Cleaning up old images...${NC}"
docker image prune -f

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Application should be available at your domain${NC}"
