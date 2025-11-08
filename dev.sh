#!/bin/bash

# 🚀 Script de développement - Lance backend (Air) + frontend (Vite)

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}🚀 DB Importer - Dev Mode${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Fonction pour nettoyer les processus à l'arrêt
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt des serveurs...${NC}"

    # Tuer les processus enfants
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi

    # Tuer tous les processus air et vite restants
    pkill -f "air" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true

    echo -e "${GREEN}✅ Serveurs arrêtés${NC}"
    exit 0
}

# Capturer Ctrl+C pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier que Go est installé
if ! command -v go &> /dev/null; then
    echo -e "${RED}❌ Go n'est pas installé${NC}"
    echo "Installe Go depuis https://go.dev/doc/install"
    exit 1
fi

# Vérifier que Node.js est installé
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js n'est pas installé${NC}"
    echo "Installe Node.js depuis https://nodejs.org/"
    exit 1
fi

# Vérifier que Air est installé
if ! command -v air &> /dev/null; then
    echo -e "${YELLOW}⚠️  Air n'est pas installé. Installation...${NC}"
    go install github.com/air-verse/air@latest

    # Ajouter GOPATH/bin au PATH si nécessaire
    export PATH=$PATH:$(go env GOPATH)/bin

    if ! command -v air &> /dev/null; then
        echo -e "${RED}❌ Impossible d'installer Air${NC}"
        echo "Exécute manuellement : go install github.com/air-verse/air@latest"
        echo "Puis ajoute $(go env GOPATH)/bin à ton PATH"
        exit 1
    fi
    echo -e "${GREEN}✅ Air installé${NC}"
fi

# Créer les liens symboliques .env si nécessaire
echo -e "${BLUE}📝 Configuration des variables d'environnement...${NC}"

if [ ! -e backend/.env ]; then
    echo -e "${YELLOW}   Création du lien backend/.env → .env.local${NC}"
    cd backend
    ln -sf ../.env.local .env
    cd ..
else
    echo -e "${GREEN}   backend/.env déjà configuré${NC}"
fi

if [ ! -e frontend/.env ]; then
    echo -e "${YELLOW}   Création du lien frontend/.env → .env.local${NC}"
    cd frontend
    ln -sf ../.env.local .env
    cd ..
else
    echo -e "${GREEN}   frontend/.env déjà configuré${NC}"
fi

echo -e "${GREEN}✅ Variables d'environnement configurées${NC}"
echo ""

# Installer les dépendances si nécessaire
if [ ! -d "backend/vendor" ] && [ ! -f "backend/go.sum" ]; then
    echo -e "${BLUE}📦 Installation des dépendances backend...${NC}"
    cd backend
    go mod download
    cd ..
    echo -e "${GREEN}✅ Dépendances backend installées${NC}"
    echo ""
fi

if [ ! -d "frontend/node_modules" ]; then
    echo -e "${BLUE}📦 Installation des dépendances frontend...${NC}"
    cd frontend
    npm install
    cd ..
    echo -e "${GREEN}✅ Dépendances frontend installées${NC}"
    echo ""
fi

# Créer le fichier .air.toml si nécessaire
if [ ! -f "backend/.air.toml" ]; then
    echo -e "${BLUE}⚙️  Création de la configuration Air...${NC}"
    cat > backend/.air.toml << 'AIREOF'
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ."
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_error = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true
AIREOF
    echo -e "${GREEN}✅ Configuration Air créée${NC}"
    echo ""
fi

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}🎯 Lancement des serveurs...${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Lire le port depuis .env.local
BACKEND_PORT=$(grep -E "^PORT=" .env.local | cut -d '=' -f2)
BACKEND_PORT=${BACKEND_PORT:-3000}

# Lancer le backend avec Air
echo -e "${BLUE}🔧 Backend (Go + Air)${NC} → http://localhost:${BACKEND_PORT}"
cd backend
air > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Attendre que le backend démarre
sleep 2

# Lancer le frontend avec Vite
echo -e "${BLUE}🎨 Frontend (Vue + Vite)${NC} → http://localhost:5173"
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ Serveurs lancés !${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}📍 URLs :${NC}"
echo -e "   Frontend : ${GREEN}http://localhost:5173${NC}"
echo -e "   Backend  : ${GREEN}http://localhost:${BACKEND_PORT}${NC}"
echo ""
echo -e "${BLUE}📋 Logs :${NC}"
echo -e "   Backend  : ${YELLOW}tail -f backend.log${NC}"
echo -e "   Frontend : ${YELLOW}tail -f frontend.log${NC}"
echo ""
echo -e "${YELLOW}💡 Appuie sur Ctrl+C pour arrêter tous les serveurs${NC}"
echo ""

# Afficher les logs en temps réel (frontend par défaut)
tail -f frontend.log
