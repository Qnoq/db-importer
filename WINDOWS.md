# 🪟 Guide Windows pour DB Importer

Ce guide explique comment configurer et utiliser DB Importer sur Windows (fonctionne aussi sur macOS et Linux).

## 🚀 Installation Rapide

### Prérequis

1. **Node.js** (v18 ou supérieur)
   - Télécharge depuis: https://nodejs.org/
   - Vérifie: `node --version`

2. **Go** (v1.21 ou supérieur)
   - Télécharge depuis: https://go.dev/doc/install
   - Vérifie: `go version`

3. **Air** (hot reload pour Go)
   ```bash
   go install github.com/air-verse/air@latest
   ```

   Assure-toi que `%GOPATH%\bin` est dans ton PATH:
   - Ouvre "Modifier les variables d'environnement système"
   - Variables d'environnement > PATH
   - Ajoute: `%USERPROFILE%\go\bin`

### Configuration Initiale

```bash
# 1. Clone le projet (si pas encore fait)
git clone <repo-url>
cd db-importer

# 2. Configuration initiale (crée .env.local)
npm run setup

# 3. Édite .env.local avec tes vrais secrets
# (ouvre avec notepad, VS Code, etc.)

# 4. Installe toutes les dépendances
npm run install:all
```

## 🎯 Utilisation

### Lancer le projet en développement

```bash
# Option 1: Via npm (recommandé pour Windows)
npm run dev

# Option 2: Via make (nécessite make pour Windows)
make dev
```

Le projet lance automatiquement:
- **Backend (Go + Air)**: http://localhost:3000
- **Frontend (Vue + Vite)**: http://localhost:5173

### Arrêter les serveurs

```bash
# Option 1: Via npm
npm run stop

# Option 2: Via make
make stop

# Option 3: Ctrl+C dans la console où npm run dev tourne
```

### Autres commandes utiles

```bash
# Tests
npm test                    # Tous les tests
npm run test:backend        # Tests backend uniquement
npm run test:frontend       # Tests frontend uniquement

# Build
npm run build               # Build complet
npm run build:backend       # Build backend uniquement
npm run build:frontend      # Build frontend uniquement

# Réinstaller les dépendances
npm run install:all
```

## 🛠️ Avec Make (optionnel)

Si tu as `make` installé sur Windows (via chocolatey, scoop, ou WSL):

```bash
make help           # Voir toutes les commandes
make setup          # Configuration initiale
make install        # Installer les dépendances
make dev            # Lancer en dev
make stop           # Arrêter les serveurs
make test           # Lancer les tests
make build          # Build production
```

### Installer Make sur Windows

**Option 1: Chocolatey** (recommandé)
```powershell
choco install make
```

**Option 2: Scoop**
```powershell
scoop install make
```

**Option 3: Utiliser directement npm** (pas besoin de make)
```bash
npm run <command>
```

## 🔧 Dépannage

### Le backend ne démarre pas

1. Vérifie que Go est installé: `go version`
2. Vérifie que Air est installé: `air -v`
3. Vérifie que le port 3000 est libre:
   ```powershell
   netstat -ano | findstr :3000
   ```
4. Si un processus bloque le port, tue-le:
   ```powershell
   taskkill /PID <pid> /F
   ```

### Air n'est pas trouvé

Ajoute `%GOPATH%\bin` à ton PATH:
```powershell
# PowerShell (en admin)
$env:Path += ";$env:USERPROFILE\go\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
```

### Les liens symboliques ne fonctionnent pas

Ce n'est plus un problème ! Les scripts utilisent maintenant des **copies de fichiers** au lieu de liens symboliques, ce qui fonctionne parfaitement sur Windows.

### Erreur "npm run dev" ne lance pas le backend

1. Vérifie que tu as bien installé les dépendances:
   ```bash
   npm run install:all
   ```

2. Vérifie que Air est bien installé:
   ```bash
   air -v
   ```

3. Lance les serveurs séparément pour déboguer:
   ```bash
   # Terminal 1 - Backend
   cd backend
   air

   # Terminal 2 - Frontend
   cd frontend
   npm run dev
   ```

### Le processus ne s'arrête pas avec Ctrl+C

Utilise le script d'arrêt:
```bash
npm run stop
```

## 📁 Structure du Projet

```
db-importer/
├── backend/              # Code Go (API)
│   ├── .env             # Variables d'environnement backend (copie de .env.local)
│   ├── .air.toml        # Configuration Air (hot reload)
│   └── cmd/server/      # Point d'entrée
├── frontend/            # Code Vue.js (UI)
│   ├── .env             # Variables d'environnement frontend (copie de .env.local)
│   └── src/
├── scripts/             # Scripts Node.js cross-platform
│   ├── setup.js         # Configuration initiale
│   └── stop.js          # Arrêt des serveurs
├── .env.local           # Tes secrets (ne pas commit)
├── .env.example         # Template des variables
├── package.json         # Scripts npm cross-platform
└── Makefile             # Commandes make (optionnel)
```

## 🎨 Workflow de Développement

1. **Première fois:**
   ```bash
   npm run setup
   npm run install:all
   ```

2. **Chaque jour:**
   ```bash
   npm run dev
   # Travaille sur ton code...
   npm run stop  # Quand tu as fini
   ```

3. **Après un git pull:**
   ```bash
   npm run install:all  # Réinstalle les dépendances
   ```

## 🐛 Support

Si tu rencontres des problèmes:
1. Vérifie que tous les prérequis sont installés
2. Consulte la section "Dépannage" ci-dessus
3. Ouvre une issue sur GitHub

## 💡 Conseils

- Utilise **Windows Terminal** pour une meilleure expérience
- Configure ton éditeur (VS Code) pour ouvrir les liens localhost directement
- Les logs sont sauvegardés dans `backend.log` et `frontend.log` si tu utilises les anciens scripts bash
- Avec `npm run dev`, les logs s'affichent directement dans la console avec des couleurs

Bon développement ! 🚀
