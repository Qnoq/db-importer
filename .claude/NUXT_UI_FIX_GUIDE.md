# Guide de Correction des Problèmes Nuxt UI

## Résumé des Problèmes Identifiés et Solutions

### ✅ Problèmes Résolus

1. **UInput qui ne prennent pas toute la largeur dans Login/Register**
2. **USelect qui ne s'ouvrent pas dans Mapping.vue**  
3. **Boutons sans apparence correcte**
4. **Messages d'avertissement mal formatés**

## 📋 Étapes d'Implémentation

### Étape 1 : Créer le fichier de configuration global

Créez le fichier `frontend/app.config.ts` avec le contenu du fichier `/home/claude/app.config.ts`

```bash
cp /home/claude/app.config.ts frontend/app.config.ts
```

### Étape 2 : Corriger Login.vue

Remplacez `frontend/src/pages/Login.vue` avec le contenu corrigé :

**Changements principaux :**
- Ajout de `class="w-full"` et `:ui="{ base: 'w-full' }"` à tous les UInput
- Correction des propriétés UButton (variant, size, color)
- Correction de la propriété UAlert avec `title` et `description`

### Étape 3 : Corriger Register.vue

Remplacez `frontend/src/pages/Register.vue` avec le contenu corrigé :

**Changements principaux :**
- Ajout de `class="w-full"` et `:ui="{ base: 'w-full' }"` à tous les UInput
- Correction des propriétés UButton
- Mise à jour du UCheckbox avec les bonnes propriétés

### Étape 4 : Corriger Mapping.vue

Appliquez les corrections suivantes dans `frontend/src/pages/Mapping.vue` :

#### 4.1. Corriger les fonctions d'options

```javascript
// Remplacer getExcelColumnOptions()
function getExcelColumnOptions() {
  return [
    { 
      label: '-- Skip this field --', 
      value: '',
      disabled: false 
    },
    ...store.excelHeaders.map(header => ({ 
      label: header, 
      value: header,
      disabled: false
    }))
  ]
}

// Remplacer getTransformationOptions()
function getTransformationOptions(field: Field) {
  const excelCol = getMappedExcelColumn(field.name)
  
  if (!excelCol) {
    return [{ 
      label: transformations.none.label, 
      value: 'none',
      disabled: false 
    }]
  }

  const columnIndex = store.excelHeaders.indexOf(excelCol)
  const columnData = store.excelData.map(row => row[columnIndex])
  const transformationTypes = suggestTransformations(columnData, field.type)

  return transformationTypes.map(type => ({
    label: transformations[type].label,
    value: type,
    disabled: false
  }))
}
```

#### 4.2. Corriger les USelect dans le template

```vue
<!-- Pour les colonnes Excel -->
<USelect
  :modelValue="getMappedExcelColumn(field.name)"
  @update:modelValue="(value) => onFieldMappingChange(field.name, value)"
  :options="getExcelColumnOptions()"
  placeholder="Select column"
  :ui="{
    base: 'w-full',
    rounded: 'rounded-md',
    size: 'md'
  }"
/>

<!-- Pour les transformations -->
<USelect
  v-model="fieldTransformations[field.name]"
  @update:modelValue="() => onTransformationChange(field.name)"
  :options="getTransformationOptions(field)"
  :disabled="!getMappedExcelColumn(field.name)"
  placeholder="None"
  :ui="{
    base: 'w-full',
    rounded: 'rounded-md',
    size: 'md'
  }"
/>
```

### Étape 5 : Ajouter des styles CSS supplémentaires

Ajoutez à `frontend/src/style.css` :

```css
/* Fix pour les dropdowns de select */
[role="listbox"] {
  z-index: 50 !important;
}

/* Fix pour les modals */
[role="dialog"] {
  z-index: 100 !important;
}

/* Force la largeur complète pour les inputs/selects Nuxt UI */
.u-input,
.u-select {
  width: 100% !important;
}

/* Améliorer le curseur sur les boutons */
button:not(:disabled):not([aria-disabled="true"]) {
  cursor: pointer !important;
}

/* Fix pour les options de select */
[role="option"] {
  cursor: pointer !important;
}

[role="option"]:hover {
  background-color: rgb(243 244 246);
}

.dark [role="option"]:hover {
  background-color: rgb(55 65 81);
}
```

### Étape 6 : Vérifier package.json

Assurez-vous que `@nuxt/ui` est bien en version 4.x :

```json
{
  "dependencies": {
    "@nuxt/ui": "^4.1.0",
    // ...
  }
}
```

### Étape 7 : Nettoyer et redémarrer

```bash
# Nettoyer le cache
cd frontend
rm -rf node_modules/.cache
rm -rf .nuxt

# Réinstaller les dépendances si nécessaire
npm install

# Redémarrer le serveur
npm run dev
```

## 🔍 Points de Vérification

### ✓ Login.vue
- [ ] Les inputs prennent toute la largeur
- [ ] Les boutons ont l'apparence correcte
- [ ] Les messages d'erreur s'affichent correctement

### ✓ Register.vue  
- [ ] Les inputs prennent toute la largeur
- [ ] Les checkboxes fonctionnent
- [ ] Les boutons ont l'apparence correcte

### ✓ Mapping.vue
- [ ] Les selects Excel s'ouvrent correctement
- [ ] Les selects de transformation s'ouvrent
- [ ] Les tooltips s'affichent
- [ ] Les checkboxes fonctionnent

## 🚨 Problèmes Courants et Solutions

### Problème : Les selects ne s'ouvrent toujours pas

**Solution :** Vérifiez que :
1. La propriété est `options` et non `items`
2. Chaque option a une propriété `disabled: false`
3. Le z-index est correct dans le CSS

### Problème : Les inputs ne prennent pas toute la largeur

**Solution :** Ajoutez à la fois :
- `class="w-full"`
- `:ui="{ base: 'w-full' }"`

### Problème : Les boutons n'ont pas d'apparence

**Solution :** Spécifiez toujours :
- `variant` (solid, outline, soft, ghost)
- `color` (primary, green, red, etc.)
- `size` (xs, sm, md, lg, xl)

### Problème : Warnings dans la console

**Solution :** Vérifiez que :
- Toutes les props passées existent dans Nuxt UI v4
- Les événements utilisent `@update:modelValue` au lieu de `@input`
- Les composants sont importés correctement

## 📝 Notes Importantes

1. **Nuxt UI v4 vs v3** : Des changements majeurs dans l'API
2. **Props différentes** :
   - `items` → `options` pour les selects
   - `@input` → `@update:modelValue`
   - Structure des options : `{ label, value, disabled }`

3. **Propriété :ui** : Utilisée pour personnaliser les styles internes
4. **app.config.ts** : Configuration globale du thème

## 🔄 Script de Correction Automatique

```bash
#!/bin/bash
# fix-nuxt-ui.sh

echo "🔧 Application des corrections Nuxt UI..."

# Backup
cp -r frontend/src/pages frontend/src/pages.backup

# Corrections automatiques
find frontend/src -name "*.vue" -exec sed -i \
  -e 's/:items=/:options=/g' \
  -e 's/@input=/@update:modelValue=/g' \
  {} \;

# Ajouter w-full aux UInput
find frontend/src -name "*.vue" -exec sed -i \
  's/<UInput/<UInput class="w-full"/g' {} \;

echo "✅ Corrections appliquées !"
```

## 🎯 Résultat Attendu

Après application de toutes les corrections :

1. ✅ Tous les inputs prennent la largeur complète de leur conteneur
2. ✅ Les selects s'ouvrent et permettent la sélection
3. ✅ Les boutons ont une apparence cohérente
4. ✅ Les messages d'alerte sont correctement formatés
5. ✅ L'interface est cohérente en mode clair et sombre

## Support

Si des problèmes persistent :
1. Vérifiez la console pour les erreurs
2. Utilisez Vue DevTools pour inspecter les props
3. Consultez la documentation Nuxt UI v4 : https://ui.nuxt.com
