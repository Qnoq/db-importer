# Cahier des charges — Outil d'import SQL (SaaS & App)

## Objectif
Créer une application permettant à un utilisateur :
1. D'importer un schéma de base de données (MySQL/MariaDB ou PostgreSQL).
2. D'extraire automatiquement la liste des tables + colonnes du schéma.
3. De sélectionner une table cible où il souhaite importer des données.
4. D'importer un fichier Excel/CSV contenant les données.
5. De mapper manuellement les colonnes du fichier avec les champs de la table.
6. De générer un fichier `.sql` contenant uniquement des commandes `INSERT`.
7. **Aucune connexion à la base du client.**  
   L'utilisateur exécute lui-même la requête finale dans son environnement.

---

## Stack Technique

### Frontend
- **Framework :** Vue.js 3
- **Bundler :** Vite
- **UI Components :** PrimeVue
- **CSS :** TailwindCSS
- **State management :** Pinia
- **Parsing Excel :** SheetJS (`xlsx`)
- **Communication avec backend :** REST API (Fetch)

### Backend
- **Langage :** Go
- **API Framework léger :** Fiber ou net/http
- **Parsing schéma SQL :**
  - MySQL/MariaDB → analyse du dump SQL (`CREATE TABLE`)
  - PostgreSQL → analyse du dump SQL (`CREATE TABLE`)
- **Génération du SQL final :** Templates `INSERT INTO ... VALUES ...`
- **Aucune connexion base distante, aucun driver DB requis.**

---

## Structure du Projet

project/
 ├─ backend/
 │   ├─ main.go (serveur API)
 │   ├─ parser/
 │   │   ├─ mysql.go
 │   │   └─ postgres.go
 │   ├─ generator/
 │   │   └─ insert.go
 │   └─ go.mod
 └─ frontend/
     ├─ src/
     │   ├─ pages/
     │   │   ├─ UploadSchema.vue
     │   │   ├─ SelectTable.vue
     │   │   ├─ UploadData.vue
     │   │   └─ Mapping.vue
     │   ├─ store/
     │   │   └─ mappingStore.ts
     │   ├─ components/
     │   ├─ App.vue
     │   └─ main.ts
     ├─ index.html
     └─ vite.config.js

---

## Endpoints API

### `POST /parse-schema`
Body: fichier `.sql` (multipart)  
Retour:
{
  "tables": [
    {
      "name": "customers",
      "fields": [
        { "name": "id", "type": "int", "nullable": false },
        { "name": "email", "type": "varchar", "nullable": false }
      ]
    }
  ]
}

### `POST /generate-sql`
Body:
{
  "table": "customers",
  "mapping": { "Email": "email", "Name": "name" },
  "rows": [
    ["john@test.com", "John"],
    ["sarah@test.com", "Sarah"]
  ]
}

Retour:
INSERT INTO customers (email, name) VALUES
('john@test.com', 'John'),
('sarah@test.com', 'Sarah');

---

## UX Flow (4 pages)

| Page | Action |
|------|--------|
| UploadSchema.vue | Import fichier dump + affichage tables |
| SelectTable.vue | Sélection de la table |
| UploadData.vue | Import Excel/CSV + affichage aperçu |
| Mapping.vue | Correspondance colonnes + bouton "Générer SQL" |

---

## Règles de mapping
- Suggestion automatique basée sur similarité (`strings.ToLower`, Levenshtein si besoin).
- L'utilisateur peut modifier les correspondances dans l’interface.
- Vérification simple :
  - Nombre de colonnes cohérent
  - Vérifier champ NOT NULL → valeur vide → alerte UI

---

## Output Final
- Un simple bouton **“Télécharger .sql”**
- Pas d’exécution
- Pas d’accès base
