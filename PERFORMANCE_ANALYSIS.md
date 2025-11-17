# Analyse de Performance - Import Excel

## 🎯 Objectif

Ce document explique comment identifier les goulots d'étranglement de performance lors de l'import de fichiers Excel volumineux (2000+ lignes), notamment lors de la transition de l'**Étape 3** (Upload Data) vers l'**Étape 4** (Mapping).

## 🔍 Mesures de Performance Ajoutées

Des logs de performance ont été ajoutés dans la console du navigateur pour mesurer chaque opération :

### Étape 3 : Upload Data (`frontend/src/pages/UploadData.vue`)

| Opération | Description | Ce qui est mesuré |
|-----------|-------------|-------------------|
| `⏱️ [STEP 3] XLSX.read()` | Parsing du fichier Excel | **SheetJS** (bibliothèque JavaScript) lit et parse le fichier .xlsx |
| `⏱️ [STEP 3] Get worksheet` | Récupération de la feuille | Accès à la première feuille du classeur |
| `⏱️ [STEP 3] sheet_to_json()` | Conversion en JSON | **SheetJS** convertit les cellules Excel en tableau JavaScript |
| `⏱️ [STEP 3] Process headers/rows` | Traitement des données | Extraction des en-têtes et filtrage des lignes vides |
| `⏱️ [STEP 3] Store data (setExcelData)` | Stockage dans Pinia | Sauvegarde des données dans le store Vue.js |
| `⏱️ [STEP 3] Save to session` | Sauvegarde session | Appel API backend pour sauvegarder (utilisateurs authentifiés) |
| `⏱️ [STEP 3] Total Excel Parsing` | **TOTAL ÉTAPE 3** | Temps total de parsing Excel |

### Transition 3 → 4 : Navigation

| Opération | Description | Ce qui est mesuré |
|-----------|-------------|-------------------|
| `⏱️ [STEP 3→4] Navigation time` | Navigation Vue Router | Temps de transition entre les pages |

### Étape 4 : Mapping (`frontend/src/pages/Mapping.vue`)

| Opération | Description | Ce qui est mesuré |
|-----------|-------------|-------------------|
| `⏱️ [STEP 4] Initialize mapping from store` | Initialisation du mapping | Copie des mappings depuis le store Pinia |
| `⏱️ [STEP 4] Auto-mapping` | Auto-mapping des colonnes | Algorithme qui associe automatiquement colonnes Excel ↔ champs DB |
| `⏱️ [STEP 4] Sync field-to-excel mapping` | Synchronisation du mapping | Création de la map bidirectionnelle (si mapping existe déjà) |
| `⏱️ [STEP 4] Initial validation` | Validation des données | Validation de toutes les lignes (types, contraintes, NULL, etc.) |
| `⏱️ [STEP 4] Total Page Load` | **TOTAL ÉTAPE 4** | Temps total de chargement de la page Mapping |

## 📊 Comment Utiliser

### 1. Ouvrir la Console du Navigateur

- **Chrome/Edge** : `F12` ou `Ctrl+Shift+J` (Windows/Linux) / `Cmd+Option+J` (Mac)
- **Firefox** : `F12` ou `Ctrl+Shift+K` (Windows/Linux) / `Cmd+Option+K` (Mac)
- **Safari** : `Cmd+Option+C` (Mac)

### 2. Aller dans l'onglet "Console"

### 3. Uploader un fichier Excel de 2000+ lignes

### 4. Observer les logs

Vous verrez des logs comme ceci :

```
⏱️ [STEP 3] XLSX.read(): 145.23ms
⏱️ [STEP 3] Get worksheet: 0.12ms
⏱️ [STEP 3] sheet_to_json(): 89.45ms
⏱️ [STEP 3] Process headers/rows: 12.34ms
⏱️ [STEP 3] Store data (setExcelData): 5.67ms
⏱️ [STEP 3] Save to session: 234.56ms
⏱️ [STEP 3] Total Excel Parsing: 487.37ms
✅ [STEP 3] Parsed 2500 rows with 25 columns
```

### 5. Cliquer sur "Continue to Column Mapping"

```
🚀 [STEP 3→4] Navigating to mapping page...
⏱️ [STEP 3→4] Navigation time: 45.23ms
🔍 [STEP 4] Starting with 2500 rows and 25 columns
⏱️ [STEP 4] Initialize mapping from store: 2.34ms
⏱️ [STEP 4] Auto-mapping: 1234.56ms
⏱️ [STEP 4] Initial validation: 3456.78ms
⏱️ [STEP 4] Total Page Load: 4738.91ms
✅ [STEP 4] Page fully loaded and ready
```

## 🔧 Interpréter les Résultats

### Scénario 1 : Le problème est dans l'Étape 3 (Frontend - JavaScript)

**Symptômes :**
- `⏱️ [STEP 3] XLSX.read()` > 500ms
- `⏱️ [STEP 3] sheet_to_json()` > 300ms

**Cause :** Le parsing Excel par **SheetJS** (bibliothèque JavaScript) est lent.

**Solutions possibles :**
1. ✅ **Parser côté backend (Go)** au lieu du frontend
   - Go est beaucoup plus rapide pour parser de gros fichiers
   - Utiliser une bibliothèque Go comme `github.com/xuri/excelize/v2`
   - Envoyer le fichier brut au backend, qui retourne le JSON parsé

2. ⚡ **Web Workers** (parsing en arrière-plan)
   - Parser dans un Web Worker pour ne pas bloquer l'UI
   - L'utilisateur peut continuer à utiliser l'interface

3. 📦 **Streaming/Chunking**
   - Parser le fichier par morceaux au lieu de tout charger en mémoire

---

### Scénario 2 : Le problème est dans la Navigation

**Symptômes :**
- `⏱️ [STEP 3→4] Navigation time` > 500ms

**Cause :** Vue Router met du temps à charger la page Mapping.

**Solutions possibles :**
1. Lazy loading déjà implémenté
2. Vérifier les watchers/computed dans Mapping.vue qui s'exécutent au mount

---

### Scénario 3 : Le problème est dans l'Étape 4 - Auto-mapping

**Symptômes :**
- `⏱️ [STEP 4] Auto-mapping` > 1000ms

**Cause :** L'algorithme d'auto-mapping est O(n*m) où n = colonnes Excel, m = champs DB.

**Solutions possibles :**
1. ⚡ **Optimiser l'algorithme**
   - Créer un index/Map des noms de champs pour lookup O(1)
   - Éviter les boucles imbriquées

2. 🔄 **Debounce/Throttle**
   - Ne pas auto-mapper immédiatement au mount
   - Laisser le DOM se charger d'abord

3. ⏱️ **Defer l'auto-mapping**
   - Utiliser `nextTick()` ou `setTimeout()` pour exécuter après le rendu initial

---

### Scénario 4 : Le problème est dans l'Étape 4 - Validation

**Symptômes :**
- `⏱️ [STEP 4] Initial validation` > 3000ms (pour 2000+ lignes)

**Cause :** La validation parcourt **toutes les lignes** pour vérifier types, contraintes, NULL, etc.

**Solutions possibles :**
1. ⚡ **Validation paresseuse (Lazy Validation)**
   - Ne valider que les 100 premières lignes au chargement initial
   - Valider le reste seulement au clic sur "Generate SQL"
   - Afficher "Validating first 100 rows..." dans l'UI

2. 🔄 **Web Worker pour validation**
   - Valider dans un thread séparé
   - Afficher un indicateur de progression

3. 📊 **Validation par batch**
   - Valider par morceaux de 500 lignes
   - Utiliser `requestIdleCallback()` pour ne pas bloquer l'UI

4. 💾 **Cache de validation**
   - Si les données/mapping n'ont pas changé, ne pas revalider

---

### Scénario 5 : Le problème est dans le rendu de l'UI

**Symptômes :**
- Les timers sont rapides, mais l'interface reste figée quelques secondes après

**Cause :** Vue.js met du temps à rendre tous les composants `<MappingCard>`.

**Solutions possibles :**
1. 📜 **Virtualisation de liste**
   - Utiliser `vue-virtual-scroller` ou `tanstack-virtual`
   - Ne rendre que les 20 cartes visibles à l'écran
   - Particulièrement utile si vous avez 50+ colonnes

2. ⏳ **Rendu progressif**
   - Rendre 10 cartes à la fois avec `requestAnimationFrame()`
   - Afficher un skeleton loader pour les cartes non encore rendues

## 🚀 Recommandations Principales

### Pour 2000-5000 lignes :

**Option A : Parser côté Backend (Recommandé)**
```
Frontend → Upload fichier brut → Backend Go parse avec excelize → Retourne JSON → Frontend affiche
```

**Avantages :**
- Go est 10-50x plus rapide que JavaScript pour parser Excel
- Moins de charge sur le navigateur de l'utilisateur
- Pas besoin d'envoyer tout le fichier parsé au backend pour la session

**Inconvénients :**
- Nécessite des changements backend
- Upload de fichier peut être lent sur connexions lentes

---

**Option B : Optimiser la Validation (Quick Win)**

Modifier `frontend/src/composables/useValidation.ts` :

```typescript
// Au lieu de valider toutes les lignes :
function validateData() {
  const MAX_INITIAL_VALIDATION = 100 // Valider seulement 100 lignes au début
  const rowsToValidate = store.excelData.slice(0, MAX_INITIAL_VALIDATION)

  // ... validation sur rowsToValidate seulement

  if (store.excelData.length > MAX_INITIAL_VALIDATION) {
    console.warn(`⚠️ Only validated first ${MAX_INITIAL_VALIDATION} rows. Full validation will run on SQL generation.`)
  }
}
```

---

**Option C : Web Worker pour Validation (Avancé)**

Créer `frontend/src/workers/validation.worker.ts` :

```typescript
self.onmessage = (e) => {
  const { rows, mapping, fields } = e.data

  // Validation logic ici
  const errors = []
  const warnings = []

  // ... validation ...

  self.postMessage({ errors, warnings })
}
```

Puis dans `useValidation.ts` :
```typescript
const worker = new Worker(new URL('@/workers/validation.worker.ts', import.meta.url))
worker.postMessage({ rows, mapping, fields })
worker.onmessage = (e) => {
  validationErrors.value = e.data.errors
}
```

## 📈 Métriques de Performance Attendues

### Performances cibles (après optimisation) :

| Fichier | Lignes | STEP 3 Total | STEP 4 Auto-mapping | STEP 4 Validation | STEP 4 Total |
|---------|--------|--------------|---------------------|-------------------|--------------|
| Petit | < 500 | < 200ms | < 100ms | < 100ms | < 300ms |
| Moyen | 500-2000 | < 500ms | < 200ms | < 500ms | < 1000ms |
| Grand | 2000-5000 | < 1500ms | < 300ms | < 1000ms | < 2000ms |
| Très grand | 5000+ | Backend parsing | < 500ms | Lazy validation | < 1500ms |

## 🛠️ Prochaines Étapes

1. **Collecter des données réelles**
   - Tester avec vos fichiers Excel de 2000+ lignes
   - Noter les temps dans chaque section
   - Identifier le goulot d'étranglement principal

2. **Choisir une optimisation**
   - Si STEP 3 (parsing) > 50% du temps → Option A (backend parsing)
   - Si STEP 4 (validation) > 50% du temps → Option B (lazy validation)
   - Si rendu UI lent → Option virtualisation

3. **Implémenter et mesurer**
   - Appliquer l'optimisation choisie
   - Relancer les tests
   - Comparer les timings avant/après

## 📝 Notes Techniques

- **SheetJS (xlsx)** : Bibliothèque JavaScript pure, monothread
- **Go excelize** : Natif, multithread possible, beaucoup plus rapide
- **Pinia Store** : Réactif, mais peut être lent si on stocke 10,000+ lignes
- **Vue Reactivity** : Devenir non-réactif pour les grosses données (`markRaw()`)

## 🐛 Debugging

Si les logs ne s'affichent pas :
1. Vérifier que la console est ouverte avant de cliquer sur "Continue"
2. Recharger la page avec `Ctrl+F5` (hard refresh)
3. Vérifier les filtres de console (ne pas filtrer les "info" logs)

Si un timer ne se ferme jamais :
- Peut indiquer une erreur JavaScript qui interrompt le code
- Vérifier les erreurs dans l'onglet Console

---

**Créé le :** 2025-11-17
**Fichiers modifiés :**
- `frontend/src/pages/UploadData.vue` (Step 3 logging)
- `frontend/src/pages/Mapping.vue` (Step 4 logging)
