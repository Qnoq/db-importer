# Makefile pour DB Importer
# Usage: make <command>

.PHONY: help dev stop install clean logs logs-backend logs-frontend
.PHONY: setup sync update test test-coverage test-watch
.PHONY: fmt lint lint-backend lint-frontend
.PHONY: build build-backend build-frontend
.PHONY: docker-up docker-down docker-logs

# Variables
BACKEND_DIR = backend
FRONTEND_DIR = frontend
GO_PACKAGES = ./parser ./generator ./internal/...

#=============================================================================
# 📖 Aide & Documentation
#=============================================================================

# Afficher l'aide par défaut
help:
	@echo "🚀 DB Importer - Commandes disponibles"
	@echo ""
	@echo "📦 Installation & Setup:"
	@echo "  make setup            Configuration initiale (première fois)"
	@echo "  make install          Installe toutes les dépendances"
	@echo "  make sync             Réinstalle les dépendances (après git pull)"
	@echo "  make update           Git pull + sync automatique"
	@echo ""
	@echo "🔨 Développement:"
	@echo "  make dev              Lance le projet en mode développement"
	@echo "  make stop             Arrête tous les serveurs"
	@echo "  make clean            Nettoie les fichiers temporaires"
	@echo ""
	@echo "🧪 Tests:"
	@echo "  make test             Lance tous les tests"
	@echo "  make test-backend     Tests backend uniquement"
	@echo "  make test-coverage    Tests backend avec rapport de couverture"
	@echo "  make test-watch       Tests en mode watch (relance auto)"
	@echo ""
	@echo "🎨 Code Quality:"
	@echo "  make fmt              Formate le code (gofmt)"
	@echo "  make lint             Lint complet (backend + frontend)"
	@echo "  make lint-backend     Lint backend (go vet + gofmt check)"
	@echo "  make lint-frontend    Lint frontend (eslint + tsc)"
	@echo ""
	@echo "🏗️  Build:"
	@echo "  make build            Build production (backend + frontend)"
	@echo "  make build-backend    Build backend uniquement"
	@echo "  make build-frontend   Build frontend uniquement"
	@echo ""
	@echo "📋 Logs:"
	@echo "  make logs             Affiche les logs du frontend"
	@echo "  make logs-backend     Affiche les logs du backend"
	@echo "  make logs-frontend    Affiche les logs du frontend"
	@echo ""
	@echo "🐳 Docker (optionnel):"
	@echo "  make docker-up        Lance les containers Docker"
	@echo "  make docker-down      Arrête les containers Docker"
	@echo "  make docker-logs      Affiche les logs Docker"
	@echo ""

#=============================================================================
# 📦 Installation & Setup
#=============================================================================

# Configuration initiale (première fois)
setup:
	@echo "🚀 Configuration initiale du projet..."
	@echo ""
	@if [ ! -f .env.local ]; then \
		echo "📝 Création de .env.local depuis .env.example..."; \
		cp .env.example .env.local; \
		echo "⚠️  IMPORTANT: Édite .env.local avec tes vrais secrets:"; \
		echo "   - DATABASE_URL (Supabase)"; \
		echo "   - JWT_ACCESS_SECRET et JWT_REFRESH_SECRET"; \
		echo "   - SUPABASE_URL et SUPABASE_ANON_KEY"; \
		echo ""; \
	else \
		echo "✅ .env.local existe déjà"; \
	fi
	@echo "📦 Installation des dépendances..."
	@$(MAKE) install
	@echo ""
	@echo "✅ Setup terminé !"
	@echo ""
	@echo "Prochaines étapes:"
	@echo "  1. Édite .env.local avec tes secrets"
	@echo "  2. Lance: make dev"
	@echo ""

# Installer les dépendances
install:
	@echo "📦 Installation des dépendances..."
	@echo "   → Backend (Go)..."
	@cd $(BACKEND_DIR) && go mod download
	@echo "   → Frontend (npm)..."
	@cd $(FRONTEND_DIR) && npm install
	@echo "✅ Dépendances installées"

# Synchroniser les dépendances (après git pull)
sync:
	@echo "🔄 Synchronisation des dépendances..."
	@cd $(BACKEND_DIR) && go mod download && go mod tidy
	@cd $(FRONTEND_DIR) && npm install
	@echo "✅ Dépendances synchronisées"

# Git pull + sync automatique
update:
	@echo "📥 Récupération des changements..."
	@git pull
	@echo ""
	@$(MAKE) sync
	@echo ""
	@echo "✅ Projet à jour !"
	@echo ""
	@echo "Tu peux maintenant lancer: make dev"
	@echo ""

#=============================================================================
# 🔨 Développement
#=============================================================================

# Lancer en mode dev
dev:
	@chmod +x dev.sh
	@./dev.sh

# Arrêter les serveurs
stop:
	@chmod +x stop.sh
	@./stop.sh

# Nettoyer les fichiers temporaires
clean:
	@echo "🧹 Nettoyage..."
	@rm -f backend.log frontend.log
	@rm -rf $(BACKEND_DIR)/tmp
	@rm -rf $(BACKEND_DIR)/coverage.out
	@rm -rf $(FRONTEND_DIR)/dist
	@rm -rf $(FRONTEND_DIR)/node_modules/.vite
	@echo "✅ Nettoyé"

#=============================================================================
# 🧪 Tests
#=============================================================================

# Lancer tous les tests backend
test:
	@echo "🧪 Lancement des tests backend..."
	@cd $(BACKEND_DIR) && go test $(GO_PACKAGES) -v

# Tests backend uniquement
test-backend:
	@echo "🧪 Tests backend..."
	@cd $(BACKEND_DIR) && go test $(GO_PACKAGES) -v

# Tests avec couverture de code
test-coverage:
	@echo "🧪 Tests backend avec couverture..."
	@cd $(BACKEND_DIR) && go test $(GO_PACKAGES) -coverprofile=coverage.out
	@echo ""
	@echo "📊 Rapport de couverture:"
	@cd $(BACKEND_DIR) && go tool cover -func=coverage.out
	@echo ""
	@echo "💡 Pour voir le rapport HTML: cd backend && go tool cover -html=coverage.out"

# Tests en mode watch (relance automatiquement)
test-watch:
	@echo "🧪 Tests en mode watch (Ctrl+C pour arrêter)..."
	@echo "💡 Installe 'gow' si pas disponible: go install github.com/mitranim/gow@latest"
	@cd $(BACKEND_DIR) && gow test $(GO_PACKAGES) -v

#=============================================================================
# 🎨 Code Quality
#=============================================================================

# Formater le code Go
fmt:
	@echo "🎨 Formatage du code Go..."
	@cd $(BACKEND_DIR) && gofmt -s -w .
	@echo "✅ Code formaté"

# Lint complet (backend + frontend)
lint: lint-backend lint-frontend

# Lint backend
lint-backend:
	@echo "🔍 Lint backend..."
	@echo "   → go vet..."
	@cd $(BACKEND_DIR) && go vet ./...
	@echo "   → gofmt check..."
	@cd $(BACKEND_DIR) && if [ -n "$$(gofmt -s -l .)" ]; then echo "❌ Code non formaté:"; gofmt -s -l .; exit 1; fi
	@echo "✅ Backend lint passed"

# Lint frontend
lint-frontend:
	@echo "🔍 Lint frontend..."
	@cd $(FRONTEND_DIR) && npm run lint 2>/dev/null || echo "⚠️  Pas de script lint configuré"
	@echo "   → TypeScript check..."
	@cd $(FRONTEND_DIR) && npx vue-tsc --noEmit
	@echo "✅ Frontend lint passed"

#=============================================================================
# 🏗️  Build
#=============================================================================

# Build production (backend + frontend)
build: build-backend build-frontend
	@echo "✅ Build complet terminé"

# Build backend
build-backend:
	@echo "🏗️  Build backend..."
	@cd $(BACKEND_DIR) && go build -o ../bin/server ./cmd/server
	@echo "✅ Backend build: bin/server"

# Build frontend
build-frontend:
	@echo "🏗️  Build frontend..."
	@cd $(FRONTEND_DIR) && npm run build
	@echo "✅ Frontend build: frontend/dist"

#=============================================================================
# 📋 Logs
#=============================================================================

# Afficher les logs frontend
logs:
	@tail -f frontend.log

# Afficher les logs backend
logs-backend:
	@tail -f backend.log

# Afficher les logs frontend
logs-frontend:
	@tail -f frontend.log

#=============================================================================
# 🐳 Docker (optionnel)
#=============================================================================

# Lancer les containers Docker
docker-up:
	@echo "🐳 Lancement des containers Docker..."
	@docker-compose up -d
	@echo "✅ Containers lancés"
	@docker-compose ps

# Arrêter les containers Docker
docker-down:
	@echo "🐳 Arrêt des containers Docker..."
	@docker-compose down
	@echo "✅ Containers arrêtés"

# Afficher les logs Docker
docker-logs:
	@docker-compose logs -f
