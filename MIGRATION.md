# 🎉 Migration vers Supabase - Configuration terminée !

Ta configuration a été mise à jour avec succès ! Voici ce qui a changé et comment utiliser la nouvelle structure.

---

## 📦 Ce qui a été fait

### ✅ Fichiers créés

| Fichier | Description |
|---------|-------------|
| `.env.local` | Configuration pour le développement (Supabase DEV) |
| `.env.production` | Configuration pour la production (Supabase PROD) |
| `backend/.env.example` | Template pour backend |
| `frontend/.env.example` | Template pour frontend |
| `DEV.md` | Guide complet de développement local |
| `MIGRATION.md` | Ce fichier |

### ✏️ Fichiers modifiés

| Fichier | Changements |
|---------|-------------|
| `docker-compose.yml` | ❌ Retiré PostgreSQL local<br>❌ Retiré Adminer<br>✅ Configuration Supabase |
| `.gitignore` | ✅ Protection des fichiers .env |

---

## 🗄️ Configuration Supabase

Tu as maintenant **2 projets Supabase** configurés :

### Projet DEV (Développement)
- **Project Ref** : `uklviiulqzchlnirwvio`
- **Dashboard** : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio
- **Utilisé pour** : Développement local sur ton PC

### Projet PROD (Production)
- **Project Ref** : `olhtetlbomwhzcrskjxu`
- **Dashboard** : https://supabase.com/dashboard/project/olhtetlbomwhzcrskjxu
- **Utilisé pour** : Déploiement sur VPS Hostinger

---

## 🚀 Comment lancer le projet maintenant ?

### En développement (SANS Docker)

**1. Installer les dépendances** (première fois seulement)
```bash
# Backend
cd backend
go mod download
cd ..

# Frontend
cd frontend
npm install
cd ..
```

**2. Lancer le backend** (Terminal 1)
```bash
cd backend
ln -s ../.env.local .env  # Créer le lien symbolique
go run main.go
```

**3. Lancer le frontend** (Terminal 2)
```bash
cd frontend
ln -s ../.env.local .env  # Créer le lien symbolique
npm run dev
```

**4. Accéder à l'application**
- Frontend : http://localhost:5173
- Backend API : http://localhost:8080

### En production (AVEC Docker sur VPS)

**1. Sur ton VPS Hostinger**
```bash
ssh user@ton-vps.com
cd /chemin/vers/db-importer
```

**2. Copier le fichier de configuration prod**
```bash
cp .env.production .env
```

**3. ⚠️ IMPORTANT : Modifier les secrets de production**
```bash
# Générer de nouveaux secrets JWT
openssl rand -base64 32  # Pour JWT_ACCESS_SECRET
openssl rand -base64 32  # Pour JWT_REFRESH_SECRET

# Éditer .env
nano .env

# Remplacer :
# - JWT_ACCESS_SECRET
# - JWT_REFRESH_SECRET
# - ALLOWED_ORIGINS (mettre ton vrai domaine)
# - VITE_API_URL (mettre ton vrai domaine backend)
```

**4. Lancer avec Docker**
```bash
docker-compose up -d
```

**5. Vérifier que tout fonctionne**
```bash
docker-compose logs -f
```

---

## 🔐 Sécurité - IMPORTANT !

### ⚠️ Actions à faire AVANT de commit/push

1. **Vérifie que .env.local et .env.production ne sont PAS trackés**
   ```bash
   git status
   # Tu ne devrais PAS voir .env.local ou .env.production
   ```

2. **Change les secrets JWT en production**
   - Les secrets actuels dans `.env.production` sont des placeholders
   - Génère de nouveaux secrets : `openssl rand -base64 32`
   - Remplace-les dans `.env.production` sur ton VPS

3. **⚠️ ATTENTION** : Tes mots de passe Supabase sont actuellement dans `.env.local` et `.env.production`
   - Ces fichiers sont dans `.gitignore` donc ne seront pas commités
   - Mais **garde-les en sécurité** !
   - Si tu penses qu'ils ont été exposés, change-les sur Supabase

---

## 📊 Comparaison Ancien vs Nouveau

### Avant (avec PostgreSQL local)

```
Docker Compose
├── Backend (container)
├── Frontend (container)
├── PostgreSQL (container) ← En local
└── Adminer (container)
```

**Problèmes** :
- ❌ Si tu supprimes le volume → données perdues
- ❌ Pas de backups automatiques
- ❌ Même DB dev et prod (dangereux)
- ❌ Docker obligatoire même en dev

### Après (avec Supabase)

```
Développement (ton PC)
├── Backend Go natif
├── Frontend Vue natif
└── Supabase DEV (cloud)

Production (VPS)
├── Backend (Docker)
├── Frontend (Docker)
└── Supabase PROD (cloud)
```

**Avantages** :
- ✅ Données sécurisées sur Supabase
- ✅ Backups automatiques
- ✅ 2 DBs séparées (dev/prod)
- ✅ Dev sans Docker = plus rapide
- ✅ Scaling facile si besoin

---

## 🎯 Prochaines étapes

### 1. Tester en local

```bash
# Terminal 1
cd backend && go run main.go

# Terminal 2
cd frontend && npm run dev
```

Ouvre http://localhost:5173 et vérifie que tout fonctionne.

### 2. Créer le schéma de base de données

Va sur Supabase DEV : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio

**Table Editor** → **New Table** → Crée tes tables

Exemple :
```sql
-- Table utilisateurs
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table imports (historique)
CREATE TABLE imports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  table_name TEXT NOT NULL,
  rows_imported INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. Tester les migrations

Une fois que ton schéma fonctionne en DEV, applique-le sur PROD :
- Copie le SQL depuis DEV
- Exécute-le sur PROD

Ou utilise Supabase CLI pour automatiser :
```bash
supabase db diff -f new_migration
supabase db push
```

### 4. Déployer en production

Suis les instructions dans `DEV.md` section "Déploiement en production".

---

## ❓ FAQ Rapide

### Docker a complètement disparu en dev ?

Oui ! En dev, tu n'as plus besoin de Docker. Juste :
- `go run main.go` pour le backend
- `npm run dev` pour le frontend

Docker est maintenant utilisé **uniquement en production** sur ton VPS.

### Où sont stockées mes données maintenant ?

Sur **Supabase** (cloud) :
- DEV : Projet `uklviiulqzchlnirwvio`
- PROD : Projet `olhtetlbomwhzcrskjxu`

Les données ne sont plus sur ton PC ni sur ton VPS. Elles sont sur les serveurs Supabase (AWS).

### Que se passe-t-il si je supprime un container Docker ?

**Aucun problème** ! Les données sont sur Supabase, pas dans les containers. Tu peux détruire et recréer les containers autant que tu veux.

### Comment accéder à ma base de données ?

**Dashboard Supabase** (le plus simple) :
- Table Editor : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio/editor
- SQL Editor : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio/sql

**CLI psql** :
```bash
psql "postgresql://postgres:1mH9cxAC98V3Hv6F@db.uklviiulqzchlnirwvio.supabase.co:5432/postgres"
```

### Les fichiers .env vont être commités ?

**NON** ! Ils sont dans `.gitignore`. Vérifie avec :
```bash
git status
```

Tu ne devrais voir que les fichiers `.env.example`.

---

## 📚 Ressources

- **Guide de développement complet** : Lis `DEV.md`
- **Documentation Supabase** : https://supabase.com/docs
- **Dashboard DEV** : https://supabase.com/dashboard/project/uklviiulqzchlnirwvio
- **Dashboard PROD** : https://supabase.com/dashboard/project/olhtetlbomwhzcrskjxu

---

## 🆘 Besoin d'aide ?

Si quelque chose ne fonctionne pas :

1. **Vérifie les logs** :
   ```bash
   # Backend
   cd backend && go run main.go
   # Regarde les erreurs

   # Frontend
   cd frontend && npm run dev
   # Regarde les erreurs
   ```

2. **Vérifie la connexion Supabase** :
   - Va sur le dashboard Supabase
   - Settings → Database → Connection String
   - Vérifie que c'est bien la même dans `.env.local`

3. **Teste la connexion** :
   ```bash
   psql "postgresql://postgres:1mH9cxAC98V3Hv6F@db.uklviiulqzchlnirwvio.supabase.co:5432/postgres"
   ```

---

**Tout est prêt ! Tu peux maintenant développer efficacement sans Docker en local, et déployer facilement en prod sur ton VPS ! 🎉**
