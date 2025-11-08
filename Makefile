# Makefile pour DB Importer

.PHONY: help dev stop install clean logs logs-backend logs-frontend

# Afficher l'aide par défaut
help:
	@echo "🚀 DB Importer - Commandes disponibles"
	@echo ""
	@echo "  make dev              Lance le projet en mode développement (backend + frontend)"
	@echo "  make stop             Arrête tous les serveurs"
	@echo "  make install          Installe toutes les dépendances"
	@echo "  make clean            Nettoie les fichiers temporaires"
	@echo "  make logs             Affiche les logs du frontend"
	@echo "  make logs-backend     Affiche les logs du backend"
	@echo "  make logs-frontend    Affiche les logs du frontend"
	@echo ""

# Lancer en mode dev
dev:
	@chmod +x dev.sh
	@./dev.sh

# Arrêter les serveurs
stop:
	@chmod +x stop.sh
	@./stop.sh

# Installer les dépendances
install:
	@echo "📦 Installation des dépendances..."
	@cd backend && go mod download
	@cd frontend && npm install
	@echo "✅ Dépendances installées"

# Nettoyer
clean:
	@echo "🧹 Nettoyage..."
	@rm -f backend.log frontend.log
	@rm -rf backend/tmp
	@rm -rf frontend/dist
	@echo "✅ Nettoyé"

# Afficher les logs
logs:
	@tail -f frontend.log

logs-backend:
	@tail -f backend.log

logs-frontend:
	@tail -f frontend.log
