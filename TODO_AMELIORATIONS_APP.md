# TODO - Améliorations de l'Application DB-Importer

## Contexte

L'application actuelle est un importeur SQL stateless et sécurisé qui génère des INSERT statements à partir de fichiers Excel/CSV. Elle fonctionne sans base de données, uniquement avec localStorage.

## Décision Stratégique : Mode Hybride

**Objectif** : Garder l'accessibilité immédiate TOUT EN ajoutant des fonctionnalités avancées pour les utilisateurs réguliers.

```
Mode SANS COMPTE (gratuit)          Mode AVEC COMPTE (optionnel)
├─ Accès immédiat                   ├─ Historique des imports
├─ localStorage uniquement          ├─ Templates sauvegardés
├─ Limite : 3 imports/jour          ├─ Illimité
└─ Pas d'historique                 ├─ Partage d'équipe
                                    └─ API keys
```

---

## Fonctionnalités à Développer

### 🥇 Priorité 1 : Fondations

#### 1. Authentification JWT (Mode Hybride) ✅ COMPLÉTÉ
- [x] Schéma de base de données `users`
- [x] Endpoints `/api/v1/auth/register`, `/api/v1/auth/login`, `/api/v1/auth/refresh`
- [x] Middleware JWT pour routes protégées
- [x] Frontend : bouton "Se connecter" optionnel en header
- [x] Frontend : détection auto du mode (guest vs authenticated)
- [x] Rate limiting différencié (guest: 3/jour, auth: illimité)
- [x] Fix : Persistance du JWT lors du refresh de page
- [x] Fix : Validation et nettoyage des données localStorage corrompues
- [x] Fix : Redirection propre vers login lors d'expiration de session

**Temps réel** : 3 jours

---

#### 2. Historique des Imports ✅ COMPLÉTÉ
**Valeur** : ⭐⭐⭐ | **Complexité** : Faible

**Base de données** :
```sql
CREATE TABLE imports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  table_name VARCHAR(255) NOT NULL,
  row_count INTEGER NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'warning'
  generated_sql TEXT, -- compressé avec gzip
  error_count INTEGER DEFAULT 0,
  warning_count INTEGER DEFAULT 0,
  metadata JSONB, -- { source_file_name, mapping_summary, transformations }
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_user_created (user_id, created_at DESC)
);
```

**Backend** :
- [x] `POST /api/v1/imports` - Sauvegarder un import
- [x] `GET /api/v1/imports/list` - Lister l'historique (pagination)
- [x] `GET /api/v1/imports/get?id=xxx` - Récupérer un import spécifique
- [x] `GET /api/v1/imports/sql?id=xxx` - Récupérer avec SQL décompressé
- [x] `DELETE /api/v1/imports/delete?id=xxx` - Supprimer un import
- [x] `GET /api/v1/imports/stats` - Statistiques utilisateur
- [x] Compression gzip du SQL généré

**Frontend** :
- [x] Nouvelle page "Historique" dans le menu
- [x] Liste des imports avec filtres (table, statut)
- [x] Pagination complète avec DataTable
- [x] Télécharger à nouveau le SQL
- [x] Stats dashboard : total imports, rows, taux de succès, table favorite
- [x] Affichage détails (modal)
- [x] Suppression avec confirmation

**Temps réel** : 1 jour

---

#### 3. Templates de Mapping Réutilisables
**Valeur** : ⭐⭐⭐ | **Complexité** : Moyenne

**Base de données** :
```sql
CREATE TABLE mapping_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  source_type VARCHAR(50), -- 'excel', 'csv'
  table_name VARCHAR(255) NOT NULL,
  mapping_config JSONB NOT NULL, -- { column_mappings, transformations }
  is_favorite BOOLEAN DEFAULT false,
  usage_count INTEGER DEFAULT 0,
  last_used_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_user_table (user_id, table_name)
);
```

**Backend** :
- [ ] `POST /api/v1/templates` - Créer un template
- [ ] `GET /api/v1/templates` - Lister les templates
- [ ] `GET /api/v1/templates/:id` - Récupérer un template
- [ ] `PUT /api/v1/templates/:id` - Mettre à jour
- [ ] `DELETE /api/v1/templates/:id` - Supprimer
- [ ] `POST /api/v1/templates/:id/apply` - Appliquer à des données

**Frontend** :
- [ ] Bouton "Sauvegarder comme template" sur page Mapping
- [ ] Modal avec nom + description
- [ ] Dropdown "Charger un template" sur page Mapping
- [ ] Page "Mes Templates" avec gestion CRUD
- [ ] Badge "favoris" et tri par usage

**Estimation** : 4-5 jours

---

### 🥈 Priorité 2 : Amélioration UX

#### 4. Schémas SQL Favoris
**Valeur** : ⭐⭐ | **Complexité** : Faible

**Base de données** :
```sql
CREATE TABLE schemas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  sql_content TEXT NOT NULL,
  database_type VARCHAR(50), -- 'mysql', 'postgresql'
  table_count INTEGER,
  is_favorite BOOLEAN DEFAULT false,
  last_used_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_user_favorite (user_id, is_favorite, last_used_at DESC)
);
```

**Backend & Frontend** :
- [ ] CRUD complet pour schémas
- [ ] Bouton "Sauvegarder ce schéma" après parse
- [ ] Page "Mes Schémas" avec recherche
- [ ] Sélection rapide au lieu d'upload

**Estimation** : 2-3 jours

---

#### 5. Validation Rules Personnalisées
**Valeur** : ⭐⭐ | **Complexité** : Moyenne-Haute

**Base de données** :
```sql
CREATE TABLE validation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  schema_id UUID REFERENCES schemas(id),
  table_name VARCHAR(255) NOT NULL,
  column_name VARCHAR(255) NOT NULL,
  rule_type VARCHAR(50) NOT NULL, -- 'regex', 'range', 'enum', 'custom'
  rule_config JSONB NOT NULL,
  error_message TEXT,
  is_blocking BOOLEAN DEFAULT true, -- true = error, false = warning
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Exemples de règles** :
- Regex : code postal français `^\d{5}$`
- Range : age entre 18 et 120
- Enum : statut dans ['active', 'inactive', 'pending']
- Custom : fonction JavaScript pour validation complexe

**Estimation** : 5-6 jours

---

### 🥉 Priorité 3 : Fonctionnalités Avancées

#### 6. Projets Multi-Tables
**Valeur** : ⭐⭐ | **Complexité** : Moyenne

Gérer des imports complexes avec dépendances entre tables (FK).

**Base de données** :
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  schema_id UUID REFERENCES schemas(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE project_imports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  import_id UUID REFERENCES imports(id),
  table_name VARCHAR(255) NOT NULL,
  execution_order INTEGER NOT NULL,
  dependencies JSONB, -- { depends_on: [table1, table2] }
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Estimation** : 5-7 jours

---

#### 7. Partage d'Équipe
**Valeur** : ⭐ | **Complexité** : Haute

**Base de données** :
```sql
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE team_members (
  team_id UUID NOT NULL REFERENCES teams(id),
  user_id UUID NOT NULL REFERENCES users(id),
  role VARCHAR(50) NOT NULL, -- 'owner', 'admin', 'member'
  joined_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (team_id, user_id)
);

CREATE TABLE shared_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_type VARCHAR(50) NOT NULL, -- 'template', 'schema', 'project'
  resource_id UUID NOT NULL,
  team_id UUID NOT NULL REFERENCES teams(id),
  permissions JSONB, -- { can_view, can_edit, can_delete }
  shared_by UUID REFERENCES users(id),
  shared_at TIMESTAMP DEFAULT NOW()
);
```

**Estimation** : 7-10 jours

---

#### 8. API Keys pour Automatisation
**Valeur** : ⭐⭐ | **Complexité** : Moyenne

Permettre l'intégration CI/CD.

**Base de données** :
```sql
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  key_hash VARCHAR(255) NOT NULL UNIQUE, -- bcrypt hash
  key_prefix VARCHAR(20) NOT NULL, -- pour affichage (ex: "sk_abc...")
  name VARCHAR(255) NOT NULL,
  scopes JSONB, -- { read_imports, write_imports, manage_templates }
  rate_limit INTEGER DEFAULT 100,
  last_used_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_key_hash (key_hash)
);
```

**Estimation** : 3-4 jours

---

#### 9. Analytics & Monitoring
**Valeur** : ⭐ | **Complexité** : Faible

**Base de données** :
```sql
CREATE TABLE import_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  total_imports INTEGER DEFAULT 0,
  total_rows INTEGER DEFAULT 0,
  total_errors INTEGER DEFAULT 0,
  avg_validation_time_ms INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_id, date)
);
```

**Estimation** : 2-3 jours

---

## Architecture Technique

### Stack Proposé

**Base de Données** : PostgreSQL 15+
- Support natif de JSONB
- Performance excellente
- Déjà supporté par le parser

**Backend (Go)** :
- Framework : `gin-gonic/gin` (plus simple que net/http pur)
- Auth : `golang-jwt/jwt`
- ORM : `sqlx` (léger) ou `gorm` (full ORM)
- Migrations : `golang-migrate/migrate`
- Hashing : `bcrypt`
- Compression : `compress/gzip`

**Frontend (Vue 3)** :
- Store Pinia : mode hybride (localStorage OU API)
- Composables : `useAuth()`, `useImports()`, `useTemplates()`
- Router : routes protégées avec navigation guards

---

## Plan de Migration (4 Sprints)

### Sprint 1 : Fondations (2 semaines) ✅ COMPLÉTÉ
- [x] Setup PostgreSQL (docker-compose)
- [x] Migrations initiales (users + refresh_tokens)
- [x] Authentification JWT complète (backend)
- [x] Adaptation frontend mode hybride (Login/Register pages + authStore)
- [x] Rate limiting différencié (guest: 3/jour, auth: illimité)
- [x] Navigation guards et auto-refresh des tokens
- [x] Documentation complète (docs/AUTHENTICATION.md)

### Sprint 2 : Historique (2 semaines) ✅ COMPLÉTÉ
- [x] Modèle + endpoints imports
- [x] Frontend : page historique avec stats et filtres
- [x] Compression/décompression SQL avec gzip
- [x] Navigation et intégration complète

### Sprint 3 : Templates (2 semaines)
- [ ] Modèle + endpoints templates
- [ ] Frontend : gestion templates
- [ ] Apply template logic
- [ ] Tests E2E

### Sprint 4 : Schémas Favoris (1 semaine)
- [ ] Modèle + endpoints schemas
- [ ] Frontend : gestion schémas
- [ ] Tests E2E

---

## Modèle Freemium

### Plan Gratuit (Sans Compte)
- ✅ 3 imports par jour
- ✅ Toutes les fonctionnalités de base
- ✅ localStorage uniquement
- ❌ Pas d'historique
- ❌ Pas de templates

### Plan Gratuit (Avec Compte)
- ✅ 10 imports par jour
- ✅ Historique 30 jours
- ✅ 5 templates max
- ✅ 3 schémas favoris

### Plan Pro (€9/mois)
- ✅ Imports illimités
- ✅ Historique illimité
- ✅ Templates illimités
- ✅ Schémas favoris illimités
- ✅ Validation rules personnalisées
- ✅ Projets multi-tables

### Plan Team (€29/mois)
- ✅ Tout du Plan Pro
- ✅ Jusqu'à 5 membres
- ✅ Partage de templates/schémas
- ✅ 2 API keys
- ✅ Support prioritaire

---

## Commandes Rapides

### Setup Développement
```bash
# Base de données
docker-compose -f docker-compose.dev.yml up -d postgres

# Migrations
cd backend
make migrate-up

# Dev backend
make dev

# Dev frontend
cd frontend
npm run dev
```

### Migrations
```bash
# Créer une migration
migrate create -ext sql -dir migrations -seq add_users_table

# Appliquer
migrate -path migrations -database "postgres://..." up

# Rollback
migrate -path migrations -database "postgres://..." down 1
```

---

## Ressources & Documentation

### À Créer
- [ ] `docs/API.md` - Documentation API complète
- [ ] `docs/AUTHENTICATION.md` - Flow d'authentification
- [ ] `docs/DATABASE_SCHEMA.md` - Schéma complet
- [ ] `docs/DEPLOYMENT.md` - Guide de déploiement avec BDD
- [ ] `CONTRIBUTING.md` - Guide de contribution

### Références
- JWT Best Practices : https://datatracker.ietf.org/doc/html/rfc8725
- PostgreSQL JSONB : https://www.postgresql.org/docs/current/datatype-json.html
- Vue 3 Auth Patterns : https://vuejs.org/guide/best-practices/security.html

---

## Notes Importantes

⚠️ **Sécurité** :
- Hashing bcrypt pour passwords (cost 12+)
- Rate limiting strict pour endpoints publics
- Validation input côté serveur TOUJOURS
- HTTPS obligatoire en production
- Rotation des JWT tokens (refresh tokens)

⚠️ **Performance** :
- Pagination sur tous les endpoints de liste
- Compression gzip pour SQL stocké
- Index sur colonnes fréquemment requêtées
- Cache Redis pour sessions (optionnel)

⚠️ **UX** :
- Garder la simplicité actuelle
- Mode guest DOIT rester rapide
- Animations de chargement pour appels API
- Messages d'erreur clairs

---

## Prochaine Étape Immédiate

**Action** : Décider si on commence l'implémentation

**Questions à résoudre** :
1. Valider le modèle freemium
2. Choisir ORM (sqlx vs gorm)
3. Définir la stratégie de déploiement (où héberger la BDD ?)
4. Créer les maquettes UI pour les nouvelles pages

---

**Dernière mise à jour** : 2025-11-07
**Auteur** : Claude
**Version** : 1.0
