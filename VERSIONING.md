# Gestion des versions

Ce projet utilise **Semantic Versioning (SemVer)** pour la numérotation des versions.

## Format de version : `MAJOR.MINOR.PATCH`

### Quand incrémenter chaque partie ?

| Composant | Quand l'incrémenter | Exemple |
|-----------|---------------------|---------|
| **MAJOR** | Changements incompatibles de l'API (breaking changes) | 1.5.3 → 2.0.0 |
| **MINOR** | Ajout de fonctionnalités rétro-compatibles | 1.5.3 → 1.6.0 |
| **PATCH** | Corrections de bugs rétro-compatibles | 1.5.3 → 1.5.4 |

## Exemples concrets

### PATCH (1.0.0 → 1.0.1)
- Correction d'un bug dans la validation des dates
- Fix d'une faute de frappe dans l'UI
- Amélioration des performances sans changement d'API
- Correction d'une faille de sécurité mineure

### MINOR (1.0.1 → 1.1.0)
- Ajout d'un nouveau format d'export (JSON en plus de SQL)
- Support d'une nouvelle base de données (Oracle en plus de MySQL/PostgreSQL)
- Nouvelle fonctionnalité de prévisualisation
- Ajout d'un endpoint API `/preview`

### MAJOR (1.1.0 → 2.0.0)
- Changement du format de l'API REST (structure JSON différente)
- Suppression d'un endpoint API existant
- Changement du format du fichier de configuration
- Modification du comportement par défaut qui casse la compatibilité

## Comment changer la version

### 1. Modifier la version dans le code

**Frontend** : Éditer `frontend/src/version.ts`
```typescript
export const APP_VERSION = '1.1.0' // Changer ici
```

**Backend** : Éditer `backend/version/version.go`
```go
const AppVersion = "1.1.0" // Changer ici
```

### 2. Créer un tag Git

```bash
# Créer un tag annoté avec message
git tag -a v1.1.0 -m "Release version 1.1.0: Add JSON export feature"

# Pousser le tag sur le dépôt
git push origin v1.1.0
```

### 3. Créer une release GitHub (optionnel)

```bash
gh release create v1.1.0 \
  --title "v1.1.0 - JSON Export Support" \
  --notes "### New Features
- Add JSON export format
- Improve column mapping algorithm

### Bug Fixes
- Fix date validation for edge cases"
```

## Workflow de développement

### Développement actif
```
1.0.0-dev → Version en développement (non publiée)
```

### Pre-release
```
1.1.0-alpha.1 → Version alpha
1.1.0-beta.1  → Version beta
1.1.0-rc.1    → Release candidate
```

### Release stable
```
1.1.0 → Version stable publiée
```

## Checklist pour une nouvelle version

- [ ] Mettre à jour `frontend/src/version.ts`
- [ ] Mettre à jour `backend/version/version.go`
- [ ] Tester l'application (frontend + backend)
- [ ] Mettre à jour le `CHANGELOG.md` (si présent)
- [ ] Créer un commit : `git commit -m "chore: bump version to X.Y.Z"`
- [ ] Créer un tag Git : `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Pousser le code et le tag : `git push && git push origin vX.Y.Z`
- [ ] (Optionnel) Créer une release GitHub avec notes de version

## Liens utiles

- **SemVer officiel** : https://semver.org/
- **Keep a Changelog** : https://keepachangelog.com/
- **Git tagging** : https://git-scm.com/book/en/v2/Git-Basics-Tagging

## Notes

- La version est synchronisée entre frontend et backend pour éviter les décalages
- Le endpoint `/health` expose la version actuelle du backend
- Le footer de l'application affiche la version du frontend
- Les versions doivent toujours être identiques entre frontend et backend
