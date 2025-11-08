# 🚀 Guide de Développement Local (Sans Docker)

Ce guide explique comment développer l'application **localement sans Docker** en utilisant **Supabase** pour la base de données.

---

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Architecture Dev vs Prod](#architecture-dev-vs-prod)
- [Installation initiale](#installation-initiale)
- [Lancer le projet en dev](#lancer-le-projet-en-dev)
- [Base de données Supabase](#base-de-données-supabase)
- [Hot Reload](#hot-reload)
- [Déploiement en production](#déploiement-en-production)
- [FAQ](#faq)

---

## ✅ Prérequis

### Logiciels requis

- **Go** 1.21+ ([installer](https://go.dev/doc/install))
- **Node.js** 18+ et npm ([installer](https://nodejs.org/))
- **Git**
- Un compte **Supabase** (gratuit)

### Vérifier les installations

```bash
go version        # Devrait afficher 1.21+
node --version    # Devrait afficher v18+
npm --version     # Devrait afficher 9+
```

---

## 🏗️ Architecture Dev vs Prod

### Développement (Local - Sans Docker)

```
Ton PC
├── Backend Go (natif)     → Port 8080
├── Frontend Vue (natif)   → Port 5173
└── Database               → Supabase DEV (cloud)
```

**Avantages** :
- ✅ Démarrage ultra-rapide
- ✅ Hot reload natif
- ✅ Debugging facile
- ✅ Moins de consommation RAM
- ✅ Pas besoin de Docker localement

### Production (VPS Hostinger - Avec Docker)

```
VPS Hostinger
├── Backend Docker         → Port 8080
├── Frontend Docker        → Port 8081
└── Database               → Supabase PROD (cloud)
```

**Avantages** :
- ✅ Isolation complète
- ✅ Déploiement simple
- ✅ Scalabilité
- ✅ Base de données managée (backups auto, HA)

---

## 🔧 Installation initiale

### 1. Cloner le projet

```bash
git clone <votre-repo>
cd db-importer
```

### 2. Configurer les variables d'environnement

Le projet utilise **2 fichiers .env** :
- `.env.local` → Pour le développement local
- `.env.production` → Pour la production sur VPS

**Pour le développement**, copie `.env.local` dans chaque service :

```bash
# Backend
cd backend
ln -s ../.env.local .env
cd ..

# Frontend
cd frontend
ln -s ../.env.local .env
cd ..
```

> **Note** : Les fichiers `.env.local` et `.env.production` sont déjà configurés avec les bonnes connection strings Supabase.

### 3. Installer les dépendances

**Backend** :
```bash
cd backend
go mod download
cd ..
```

**Frontend** :
```bash
cd frontend
npm install
cd ..
```

---

## 🚀 Lancer le projet en dev

### Méthode 1 : Deux terminaux séparés

**Terminal 1 - Backend** :
```bash
cd backend
go run main.go
```

Le backend démarre sur **http://localhost:8080**

**Terminal 2 - Frontend** :
```bash
cd frontend
npm run dev
```

Le frontend démarre sur **http://localhost:5173**

### Méthode 2 : Un seul terminal (avec &)

```bash
# Démarrer le backend en arrière-plan
cd backend && go run main.go &

# Démarrer le frontend
cd ../frontend && npm run dev
```

### Méthode 3 : Avec Air (Hot Reload pour Go)

Pour avoir le hot reload automatique sur le backend :

```bash
# Installer Air
go install github.com/cosmtrek/air@latest

# Lancer avec Air
cd backend
air
```

---

## 🗄️ Base de données Supabase

### Projets configurés

Le projet utilise **2 bases de données Supabase** :

| Environnement | Project Ref | URL |
|---------------|-------------|-----|
| **DEV** | `uklviiulqzchlnirwvio` | https://supabase.com/dashboard/project/uklviiulqzchlnirwvio |
| **PROD** | `olhtetlbomwhzcrskjxu` | https://supabase.com/dashboard/project/olhtetlbomwhzcrskjxu |

### Accéder à la base de données

**Option 1 : Supabase Dashboard** (recommandé)
- Va sur le dashboard Supabase
- Clique sur **"Table Editor"** ou **"SQL Editor"**
- Tu peux créer des tables, exécuter des requêtes, etc.

**Option 2 : psql (CLI)**
```bash
# Connexion au projet DEV
psql "postgresql://postgres:1mH9cxAC98V3Hv6F@db.uklviiulqzchlnirwvio.supabase.co:5432/postgres"
```

**Option 3 : Adminer/pgAdmin**
- Host: `db.uklviiulqzchlnirwvio.supabase.co`
- Port: `5432`
- Database: `postgres`
- User: `postgres`
- Password: `1mH9cxAC98V3Hv6F`

### Migrations de schéma

Pour créer/modifier le schéma de la base de données :

1. **Via Supabase Dashboard** (le plus simple)
   - Table Editor → New Table
   - SQL Editor → Exécuter du SQL

2. **Via migrations Go** (si configuré)
   ```bash
   cd backend
   go run migrations/migrate.go
   ```

### Synchroniser DEV → PROD

Quand tu es prêt à déployer un changement de schéma :

1. Teste d'abord sur **DEV**
2. Exporte le schéma depuis Supabase DEV
3. Applique-le sur Supabase PROD

Ou utilise les **Supabase Migrations** :
```bash
supabase db diff -f new_migration
supabase db push
```

---

## 🔥 Hot Reload

### Backend (Go)

**Option 1 : Air** (recommandé)
```bash
cd backend
air
```

**Option 2 : Nodemon + Go**
```bash
npm install -g nodemon
cd backend
nodemon --exec go run main.go --signal SIGTERM
```

### Frontend (Vue)

Le hot reload est **automatique** avec Vite :
```bash
cd frontend
npm run dev
```

Chaque modification `.vue`, `.ts`, `.css` est rechargée instantanément ! 🔥

---

## 📦 Déploiement en production

### 1. Préparer les secrets de production

**Générer des secrets JWT** :
```bash
openssl rand -base64 32  # JWT_ACCESS_SECRET
openssl rand -base64 32  # JWT_REFRESH_SECRET
```

**Éditer `.env.production`** :
```bash
# Remplace les valeurs suivantes :
ALLOWED_ORIGINS=https://ton-domaine.com
VITE_API_URL=https://api.ton-domaine.com
JWT_ACCESS_SECRET=<secret-généré-1>
JWT_REFRESH_SECRET=<secret-généré-2>
```

### 2. Déployer sur VPS Hostinger

**Se connecter au VPS** :
```bash
ssh user@ton-vps-hostinger.com
```

**Cloner le projet** :
```bash
git clone <votre-repo>
cd db-importer
```

**Copier le fichier de prod** :
```bash
cp .env.production .env
```

**Lancer avec Docker** :
```bash
docker-compose up -d
```

**Vérifier les logs** :
```bash
docker-compose logs -f
```

### 3. Accéder à l'application

- **Frontend** : http://ton-vps:8081
- **Backend API** : http://ton-vps:8080

### 4. Configuration Nginx (optionnel mais recommandé)

Pour avoir un nom de domaine avec HTTPS :

```nginx
# /etc/nginx/sites-available/db-importer
server {
    listen 80;
    server_name ton-domaine.com;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Puis :
```bash
sudo ln -s /etc/nginx/sites-available/db-importer /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Activer HTTPS avec Certbot
sudo certbot --nginx -d ton-domaine.com
```

---

## ❓ FAQ

### Pourquoi pas Docker en développement ?

Docker ajoute de la complexité et de l'overhead inutile pour le développement local :
- Temps de démarrage plus long
- Hot reload moins fiable avec les volumes
- Plus difficile à debugger
- Consommation RAM importante

En dev, **natif = plus rapide et plus simple** !

### Que se passe-t-il si je supprime le container Docker en prod ?

**Aucun problème** ! La base de données est sur **Supabase** (externe), donc :
- ✅ Les données restent intactes
- ✅ Tu peux recréer le container sans perte
- ✅ Les backups Supabase sont automatiques

### Comment basculer entre DEV et PROD ?

**En développement local** :
```bash
# Backend
cd backend
ln -sf ../.env.local .env

# Frontend
cd frontend
ln -sf ../.env.local .env
```

**Sur le VPS (prod)** :
```bash
cp .env.production .env
docker-compose up -d
```

### Puis-je utiliser PostgreSQL local au lieu de Supabase ?

Oui, mais **pas recommandé**. Si tu veux vraiment :

```bash
# Installer PostgreSQL
sudo apt install postgresql

# Créer une DB
sudo -u postgres createdb dbimporter

# Modifier DATABASE_URL dans .env.local
DATABASE_URL=postgresql://postgres:password@localhost:5432/dbimporter
```

Mais tu perds :
- ❌ Les backups automatiques
- ❌ Le dashboard Supabase
- ❌ L'Auth/Storage/Realtime de Supabase
- ❌ La même config dev/prod

### Comment voir les logs du backend en dev ?

Le backend Go affiche les logs directement dans le terminal où tu l'as lancé.

Pour avoir plus de détails, active `DEBUG_LOG=true` dans `.env.local`.

### Comment accéder au Supabase Studio ?

Supabase Studio est intégré au dashboard web :
- **DEV** : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio
- **PROD** : https://supabase.com/dashboard/project/olhtetlbomwhzcrskjxu

Tu peux y gérer :
- Tables (Table Editor)
- Requêtes SQL (SQL Editor)
- Auth (Authentication)
- Storage (fichiers)
- API Docs

---

## 🎯 Récapitulatif des commandes

```bash
# Installation initiale
cd backend && go mod download && cd ..
cd frontend && npm install && cd ..

# Lancer en dev (2 terminaux)
# Terminal 1
cd backend && go run main.go

# Terminal 2
cd frontend && npm run dev

# Lancer en prod (VPS)
docker-compose up -d

# Voir les logs prod
docker-compose logs -f

# Arrêter la prod
docker-compose down

# Rebuild après changements
docker-compose up -d --build
```

---

## 📚 Ressources

- [Documentation Supabase](https://supabase.com/docs)
- [Documentation Go](https://go.dev/doc/)
- [Documentation Vue 3](https://vuejs.org/)
- [Documentation Vite](https://vitejs.dev/)
- [Documentation Fiber](https://docs.gofiber.io/) (si utilisé)

---

**Bon développement ! 🚀**
