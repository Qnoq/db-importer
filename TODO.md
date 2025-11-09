# 📋 TODO - DB Importer Improvements

> Suivi de l'implémentation des améliorations proposées dans IMPROVEMENTS.md
> Dernière mise à jour: 2025-11-09

## 📊 Progression Globale

- **Priorité 1**: ✅ Terminée
- **Priorité 2**: ⏸️ À faire
- **Priorité 3**: ⏸️ À faire
- **Priorité 4**: ⏸️ À faire

---

## 🔥 Priorité 1 - À faire immédiatement

### 1.1 Refactoring Backend ✅
**Impact**: ⭐⭐⭐⭐⭐ | **Effort**: 🔨🔨🔨🔨

- [x] Créer la nouvelle structure de dossiers
  - [x] `backend/cmd/server/` pour le point d'entrée
  - [x] `backend/internal/server/` pour la configuration serveur
  - [x] `backend/internal/config/` pour la configuration
  - [x] `backend/internal/handlers/` pour les handlers HTTP
  - [x] `backend/internal/middleware/` pour les middlewares (déjà existant)
- [x] Créer le nouveau `cmd/server/main.go` simplifié
- [x] Implémenter `internal/config/loader.go`
- [x] Implémenter `internal/server/server.go`
- [x] Implémenter `internal/server/routes.go`
- [x] Créer les handlers modulaires
  - [x] `handlers/public.go` (regroupe schema, sql, validation, health)
- [x] Migrer le code de l'ancien `main.go` vers la nouvelle structure
- [x] Tester que tout compile (✅ Build réussi)
- [ ] Supprimer l'ancien `main.go` (à faire après tests complets)

### 1.2 Scripts de Développement ✅
**Impact**: ⭐⭐⭐⭐ | **Effort**: 🔨🔨

- [x] Créer le répertoire `scripts/`
- [x] Créer `scripts/dev.sh` (sans Docker)
  - [x] Fonction de vérification des dépendances
  - [x] Setup de l'environnement
  - [x] Démarrage backend avec Air (hot reload) ou go run
  - [x] Démarrage frontend avec Vite
  - [x] Gestion des logs
  - [x] Cleanup propre des processus
- [x] Créer `scripts/setup-env.sh`
  - [x] Génération des secrets JWT
  - [x] Création des fichiers .env
  - [x] Vérification de la configuration
- [x] Rendre les scripts exécutables (`chmod +x`)
- [ ] Tester les scripts (à faire lors du prochain démarrage)

### 1.3 Validation SQL Sécurisée ✅
**Impact**: ⭐⭐⭐⭐⭐ | **Effort**: 🔨🔨

- [x] Créer `frontend/src/utils/sqlValidation.ts`
  - [x] Fonction `validateSQL()`
  - [x] Détection des mots-clés dangereux
  - [x] Détection des patterns d'injection SQL
  - [x] Warnings pour fichiers volumineux
  - [x] Fonctions supplémentaires (countInserts, estimateRowCount, etc.)
- [x] Créer `frontend/src/utils/sqlSanitization.ts`
  - [x] Fonction `sanitizeValue()`
  - [x] Gestion des types SQL (int, float, boolean, date, datetime, json, uuid, etc.)
  - [x] Échappement des quotes et caractères spéciaux
  - [x] Détection d'injection SQL
  - [x] Fonctions utilitaires (sanitizeRow, removeComments, etc.)
- [ ] Intégrer la validation dans le composable `useImport` (Priorité 2)
- [ ] Tester avec différents cas (valide, injection, etc.) (Priorité 2)

---

## 🎯 Priorité 2 - Court terme

### 2.1 Configuration Centralisée
**Impact**: ⭐⭐⭐⭐ | **Effort**: 🔨🔨

- [ ] Créer `.env.example` avec tous les paramètres
- [ ] Créer `.env.development`
- [ ] Créer `.env.production`
- [ ] Implémenter la hiérarchie de configuration
- [ ] Ajouter validation de configuration au démarrage
- [ ] Documenter toutes les variables d'environnement

### 2.2 Error Boundary Vue
**Impact**: ⭐⭐⭐ | **Effort**: 🔨

- [ ] Créer `frontend/src/components/ErrorBoundary.vue`
- [ ] Implémenter le handler `onErrorCaptured`
- [ ] Ajouter l'UI d'erreur
- [ ] Intégrer dans `App.vue`
- [ ] Tester avec des erreurs volontaires

### 2.3 Composables Vue
**Impact**: ⭐⭐⭐⭐ | **Effort**: 🔨🔨🔨

- [ ] Créer `frontend/src/composables/useImport.ts`
  - [ ] Fonction `validateMapping()`
  - [ ] Fonction `generateSQL()`
  - [ ] Fonction `autoMap()`
  - [ ] Helper `findBestFieldMatch()`
- [ ] Créer `frontend/src/composables/useAuth.ts`
- [ ] Créer `frontend/src/composables/useToast.ts`
- [ ] Refactoriser les composants pour utiliser les composables
- [ ] Supprimer le code dupliqué

---

## 📚 Priorité 3 - Moyen terme

### 3.1 Documentation Swagger
**Impact**: ⭐⭐⭐ | **Effort**: 🔨🔨🔨

- [ ] Installer `swag` CLI
- [ ] Ajouter les annotations Swagger aux handlers
- [ ] Configurer Swagger dans le serveur
- [ ] Générer la documentation
- [ ] Ajouter l'endpoint `/swagger/` (dev only)
- [ ] Documenter tous les endpoints
- [ ] Ajouter des exemples de requêtes/réponses

### 3.2 CI/CD GitHub Actions
**Impact**: ⭐⭐⭐⭐ | **Effort**: 🔨🔨🔨🔨

- [ ] Créer `.github/workflows/main.yml`
- [ ] Job: Backend Lint & Format
- [ ] Job: Backend Build & Test
- [ ] Job: Frontend Lint & Type Check
- [ ] Job: Frontend Build
- [ ] Job: Docker Build & Push
- [ ] Job: Deploy (si applicable)
- [ ] Configurer les secrets GitHub
- [ ] Tester le pipeline complet

### 3.3 Makefile Amélioré
**Impact**: ⭐⭐⭐ | **Effort**: 🔨🔨

- [ ] Créer le Makefile à la racine
- [ ] Commandes de développement (`dev`, `stop`, `install`, `clean`)
- [ ] Commandes backend (`backend-run`, `backend-build`, `backend-lint`)
- [ ] Commandes frontend (`frontend-run`, `frontend-build`, `frontend-lint`)
- [ ] Commandes database (`migrate-up`, `migrate-down`, `migrate-create`)
- [ ] Commandes utilitaires (`setup`, `check`, `fmt`)
- [ ] Ajouter la commande `help` avec descriptions
- [ ] Tester toutes les commandes

---

## 🚀 Priorité 4 - Long terme

### 4.1 Monitoring & Métriques
**Impact**: ⭐⭐⭐ | **Effort**: 🔨🔨🔨🔨

- [ ] Créer `internal/metrics/metrics.go`
- [ ] Ajouter les métriques Prometheus
  - [ ] Métriques HTTP (requests, duration)
  - [ ] Métriques business (imports, rows)
  - [ ] Métriques système (DB connections)
- [ ] Créer `internal/middleware/metrics.go`
- [ ] Ajouter l'endpoint `/metrics`
- [ ] Configurer Prometheus (optionnel)
- [ ] Configurer Grafana (optionnel)
- [ ] Créer des dashboards

### 4.2 Structured Logging
**Impact**: ⭐⭐⭐ | **Effort**: 🔨🔨

- [ ] Créer `internal/logger/logger.go`
- [ ] Implémenter les niveaux de log (DEBUG, INFO, WARN, ERROR, FATAL)
- [ ] Format JSON pour les logs
- [ ] Ajouter contexte (caller, timestamp, fields)
- [ ] Remplacer tous les `fmt.Println` par le logger
- [ ] Configurer les logs selon l'environnement

### 4.3 Rate Limiting Amélioré
**Impact**: ⭐⭐⭐ | **Effort**: 🔨🔨

- [ ] Créer `internal/middleware/ratelimit.go`
- [ ] Implémenter le rate limiter avec `golang.org/x/time/rate`
- [ ] Différencier guest vs authenticated
- [ ] Ajouter le cleanup automatique des visitors
- [ ] Headers de rate limit dans les réponses
- [ ] Messages d'erreur personnalisés
- [ ] Configuration via variables d'environnement

### 4.4 Store avec Persistance
**Impact**: ⭐⭐ | **Effort**: 🔨🔨

- [ ] Créer `frontend/src/store/base.store.ts`
- [ ] Implémenter la classe `PersistentStore`
- [ ] Gestion du versioning
- [ ] Gestion du quota localStorage
- [ ] Cleanup automatique des anciennes données
- [ ] Migrer les stores existants
- [ ] Tester la persistance

---

## 📝 Tests

### Tests Backend
- [ ] Tests unitaires pour les handlers
- [ ] Tests d'intégration pour l'API
- [ ] Tests pour le parser SQL
- [ ] Tests pour le générateur SQL
- [ ] Tests pour la validation
- [ ] Coverage > 70%

### Tests Frontend
- [ ] Tests unitaires pour les composables
- [ ] Tests pour les stores
- [ ] Tests E2E avec Playwright/Cypress
- [ ] Tests de validation SQL

---

## 📖 Documentation

- [ ] README.md complet
  - [ ] Installation
  - [ ] Configuration
  - [ ] Développement
  - [ ] Déploiement
  - [ ] Architecture
- [ ] CONTRIBUTING.md
- [ ] API.md (ou Swagger)
- [ ] DEPLOYMENT.md
- [ ] Diagrammes d'architecture

---

## 🔧 Infrastructure

### Non-Docker (Mode Dev Actuel)
- [x] Backend: `go run` ou `air` pour hot reload
- [x] Frontend: `npm run dev` avec Vite
- [ ] Script unifié `scripts/dev.sh`
- [ ] Makefile pour les commandes communes

### Docker (Mode Production)
- [ ] Dockerfile backend optimisé (multi-stage)
- [ ] Dockerfile frontend optimisé (multi-stage)
- [ ] docker-compose.yml
- [ ] Configuration nginx pour frontend
- [ ] Gestion des secrets
- [ ] Health checks

---

## 🎯 Prochaines Étapes Immédiates

1. ✅ Créer ce fichier TODO.md
2. ⏳ Créer la structure de dossiers backend
3. ⏳ Implémenter le config loader
4. ⏳ Créer le nouveau main.go
5. ⏳ Créer les handlers modulaires

---

## 📈 Métriques de Succès

- [ ] Taille du main.go < 100 lignes
- [ ] Temps de démarrage dev < 5 secondes
- [ ] Hot reload fonctionnel (backend + frontend)
- [ ] Zéro warning de sécurité
- [ ] Documentation API complète
- [ ] Pipeline CI/CD vert
- [ ] Logs structurés en production

---

## 💡 Notes & Décisions

### Décisions d'Architecture
- **Mode dev**: Pas de Docker, utilisation d'Air pour le hot reload Go
- **Mode prod**: Docker avec multi-stage builds
- **Base de données**: Supabase PostgreSQL
- **Frontend**: Vue 3 + Vite + TypeScript + PrimeVue
- **Backend**: Go 1.21+ avec stdlib HTTP

### À Discuter
- [ ] Utiliser un ORM (GORM) ou rester avec database/sql ?
- [ ] Ajouter Redis pour le cache ?
- [ ] WebSocket pour le progress en temps réel ?
- [ ] Quelle stratégie de versioning API ?

---

**Légende**:
- ✅ Terminé
- 🔄 En cours
- ⏸️ À faire
- ❌ Bloqué
- 🔨 Effort estimé (1-5)
- ⭐ Impact (1-5)
