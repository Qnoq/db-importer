#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ENV_FILE=${1:-.env.local}
EXAMPLE_FILE="backend/.env.example"

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     DB Importer Environment Setup      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"

# Function to generate a secret
generate_secret() {
    openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64
}

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo -e "${YELLOW}⚠️  openssl not found, using /dev/urandom for secret generation${NC}"
fi

# Create the .env file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    if [ ! -f "$EXAMPLE_FILE" ]; then
        echo -e "${RED}❌ $EXAMPLE_FILE not found${NC}"
        exit 1
    fi

    echo -e "${CYAN}📝 Creating $ENV_FILE from $EXAMPLE_FILE...${NC}"
    cp "$EXAMPLE_FILE" "$ENV_FILE"

    # Generate JWT secrets
    echo -e "${CYAN}🔐 Generating JWT secrets...${NC}"
    JWT_ACCESS=$(generate_secret)
    JWT_REFRESH=$(generate_secret)

    # Replace placeholders in the env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|JWT_ACCESS_SECRET=.*|JWT_ACCESS_SECRET=$JWT_ACCESS|" "$ENV_FILE"
        sed -i '' "s|JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$JWT_REFRESH|" "$ENV_FILE"
    else
        # Linux
        sed -i "s|JWT_ACCESS_SECRET=.*|JWT_ACCESS_SECRET=$JWT_ACCESS|" "$ENV_FILE"
        sed -i "s|JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$JWT_REFRESH|" "$ENV_FILE"
    fi

    echo -e "${GREEN}✅ Environment file created: $ENV_FILE${NC}"
else
    echo -e "${YELLOW}ℹ️  Environment file already exists: $ENV_FILE${NC}"
fi

# Verify important environment variables
echo -e "\n${CYAN}🔍 Checking configuration...${NC}"

check_var() {
    local key=$1
    local value=$(grep "^$key=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2)

    if [ -z "$value" ] || [ "$value" == "changeme" ] || [ "$value" == "your-secret-here" ] || [ "$value" == "" ]; then
        echo -e "${RED}  ❌ $key is not set or has default value${NC}"
        return 1
    else
        echo -e "${GREEN}  ✓ $key is configured${NC}"
        return 0
    fi
}

all_good=true

# Check JWT secrets
if ! check_var "JWT_ACCESS_SECRET"; then
    all_good=false
fi

if ! check_var "JWT_REFRESH_SECRET"; then
    all_good=false
fi

# Check DATABASE_URL (optional but recommended)
if grep -q "^DATABASE_URL=.*$" "$ENV_FILE" 2>/dev/null; then
    db_url=$(grep "^DATABASE_URL=" "$ENV_FILE" | cut -d'=' -f2)
    if [ -z "$db_url" ]; then
        echo -e "${YELLOW}  ⚠️  DATABASE_URL is not set (running in stateless mode)${NC}"
    else
        echo -e "${GREEN}  ✓ DATABASE_URL is configured${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  DATABASE_URL is not set (running in stateless mode)${NC}"
fi

# Check PORT
if grep -q "^PORT=.*$" "$ENV_FILE" 2>/dev/null; then
    echo -e "${GREEN}  ✓ PORT is configured${NC}"
else
    echo -e "${YELLOW}  ℹ️  PORT not set, will use default (8080)${NC}"
fi

# Create backend/.env symlink if needed
if [ ! -f "backend/.env" ] && [ -f "$ENV_FILE" ]; then
    echo -e "\n${CYAN}🔗 Creating backend/.env symlink...${NC}"
    ln -sf "../$ENV_FILE" "backend/.env"
    echo -e "${GREEN}✅ Symlink created${NC}"
fi

# Summary
echo -e "\n${GREEN}════════════════════════════════════════${NC}"
if [ "$all_good" = true ]; then
    echo -e "${GREEN}✅ Setup complete! You're ready to go.${NC}"
    echo -e "\n${CYAN}Next steps:${NC}"
    echo -e "  1. Review $ENV_FILE and update if needed"
    echo -e "  2. Run: ${YELLOW}./scripts/dev.sh${NC} to start development"
else
    echo -e "${YELLOW}⚠️  Setup complete with warnings${NC}"
    echo -e "\n${CYAN}Action required:${NC}"
    echo -e "  1. Edit $ENV_FILE and fill in missing values"
    echo -e "  2. Run this script again to verify"
    echo -e "  3. Run: ${YELLOW}./scripts/dev.sh${NC} to start development"
fi
echo -e "${GREEN}════════════════════════════════════════${NC}\n"

# Show configuration tips
echo -e "${CYAN}💡 Configuration tips:${NC}"
echo -e "  • ${YELLOW}DATABASE_URL${NC}: PostgreSQL connection string (optional for stateless mode)"
echo -e "  • ${YELLOW}ALLOWED_ORIGINS${NC}: Comma-separated list of allowed CORS origins"
echo -e "  • ${YELLOW}DEBUG_LOG${NC}: Set to 'true' for detailed logging"
echo -e "  • ${YELLOW}RATE_LIMIT_ENABLED${NC}: Set to 'false' to disable rate limiting"
echo ""
