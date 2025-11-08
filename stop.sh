#!/bin/bash

# 🛑 Script pour arrêter tous les serveurs de développement

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛑 Arrêt de tous les serveurs de développement...${NC}"
echo ""

# Arrêter Air (backend)
if pgrep -f "air" > /dev/null; then
    echo -e "${BLUE}Arrêt du backend (Air)...${NC}"
    pkill -f "air"
    echo -e "${GREEN}✅ Backend arrêté${NC}"
else
    echo -e "${YELLOW}⚠️  Aucun processus Air en cours${NC}"
fi

# Arrêter Vite (frontend)
if pgrep -f "vite" > /dev/null; then
    echo -e "${BLUE}Arrêt du frontend (Vite)...${NC}"
    pkill -f "vite"
    echo -e "${GREEN}✅ Frontend arrêté${NC}"
else
    echo -e "${YELLOW}⚠️  Aucun processus Vite en cours${NC}"
fi

# Arrêter go run si présent
if pgrep -f "go run" > /dev/null; then
    echo -e "${BLUE}Arrêt des processus Go...${NC}"
    pkill -f "go run"
    echo -e "${GREEN}✅ Processus Go arrêtés${NC}"
fi

# Arrêter npm run dev si présent
if pgrep -f "npm run dev" > /dev/null; then
    echo -e "${BLUE}Arrêt des processus npm...${NC}"
    pkill -f "npm run dev"
    echo -e "${GREEN}✅ Processus npm arrêtés${NC}"
fi

echo ""
echo -e "${GREEN}✅ Tous les serveurs sont arrêtés${NC}"
