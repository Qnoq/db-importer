# Plan de Refactoring du Composant Mapping.vue

**Date**: 16 novembre 2025
**Fichier cible**: `frontend/src/pages/Mapping.vue` (1,355 lignes)
**Objectif**: Diviser en 5-6 composants réutilisables
**Réduction estimée**: 1,355 → ~400 lignes dans le fichier principal

---

## 📊 Analyse Actuelle

### Structure du Fichier
| Section | Lignes | Description |
|---------|--------|-------------|
| Template (HTML) | ~492 lignes | Layout, alertes, mapping cards, modals |
| Script Setup | ~863 lignes | Logique métier, validation, API calls |
| Total | 1,355 lignes | Fichier monolithique |

### Problèmes Identifiés
1. **Trop de responsabilités** - Un seul composant gère: UI, validation, transformation, génération SQL, state management
2. **Difficile à tester** - Logique métier mélangée avec le rendu
3. **Duplication** - Certaines fonctions pourraient être des composables
4. **Performance** - Re-render complet sur chaque changement
5. **Maintenabilité** - Difficile de localiser et corriger des bugs

---

## 🎯 Architecture Cible

### Nouveaux Composants

#### 1. **MappingHeader.vue** ✅ (CRÉÉ)
**Localisation**: `frontend/src/components/mapping/MappingHeader.vue`
**Lignes**: ~130
**Responsabilité**: Afficher les alertes et bannières d'information

**Props**:
```typescript
interface Props {
  showMissingDataAlert?: boolean
  autoMappingStats?: AutoMappingStats | null
  sampleFieldNames?: string[]
  autoIncrementFields?: string[]
  isRestoring?: boolean
  tableName?: string
  dataRowCount?: number
  validationStats?: ValidationStats | null
}
```

**Émissions**:
- `start-over` - Redémarrer le workflow

**Contenu**:
- Missing data alert
- Auto-mapping success banner
- Info banner avec stats de validation
- Skeleton loading states

---

#### 2. **MappingCard.vue** ⏳ (À CRÉER)
**Localisation**: `frontend/src/components/mapping/MappingCard.vue`
**Lignes estimées**: ~250
**Responsabilité**: Afficher une ligne de mapping field → excel column

**Props**:
```typescript
interface Props {
  field: Field
  selectedExcelColumn: string | null
  excelHeaders: string[]
  selectedTransformation: TransformationType
  availableTransformations: { label: string; value: TransformationType }[]
  hasWarning: boolean
  isMapped: boolean
  sampleValue?: string
  isRestoring?: boolean
}
```

**Émissions**:
- `update:selectedExcelColumn` - Changement de colonne Excel sélectionnée
- `update:selectedTransformation` - Changement de transformation
- `preview-transformation` - Prévisualiser la transformation
- `skip-field` - Ignorer ce champ

**Contenu**:
- DB field info (nom, type, nullable, default)
- Flèche de mapping
- Sélecteur de colonne Excel avec suggestions
- Sélecteur de transformation
- Boutons d'action (preview, skip)
- Sample value display

---

#### 3. **MappingActions.vue** ⏳ (À CRÉER)
**Localisation**: `frontend/src/components/mapping/MappingActions.vue`
**Lignes estimées**: ~100
**Responsabilité**: Boutons d'action en haut de la section mapping

**Props**:
```typescript
interface Props {
  isRestoring?: boolean
  hasMapping?: boolean
}
```

**Émissions**:
- `auto-map` - Déclencher l'auto-mapping
- `clear-all` - Effacer tous les mappings

**Contenu**:
- Bouton "Auto-map Columns"
- Bouton "Clear All"
- States disabled pendant restoration

---

#### 4. **ValidationSummary.vue** ⏳ (À CRÉER)
**Localisation**: `frontend/src/components/mapping/ValidationSummary.vue`
**Lignes estimées**: ~200
**Responsabilité**: Afficher le résumé de validation et preview data table

**Props**:
```typescript
interface Props {
  validationErrors: string[]
  transformationWarnings: string[]
  previewData: CellValue[][]
  excelHeaders: string[]
  cellValidations: Map<string, ValidationResult>
}
```

**Méthodes**:
- `getCellValidationClass(rowIndex, colIndex)`
- `getCellValidationMessage(rowIndex, colIndex)`
- `getCellValidationIcon(rowIndex, colIndex)`
- `formatCellValue(value)`

**Contenu**:
- Section "Validation"
  - Liste d'erreurs de validation (si présentes)
  - Liste d'avertissements de transformation
- Section "Preview Data"
  - Table avec les 20 premières lignes
  - Highlighting des cellules avec erreurs/warnings
  - Tooltips de validation

---

#### 5. **GenerateSQLPanel.vue** ⏳ (À CRÉER)
**Localisation**: `frontend/src/components/mapping/GenerateSQLPanel.vue`
**Lignes estimées**: ~150
**Responsabilité**: Actions de génération SQL et preview

**Props**:
```typescript
interface Props {
  validationErrors: string[]
  isRestoring?: boolean
  isLoading?: boolean
  error?: string
}
```

**Émissions**:
- `generate-sql` - Générer le SQL sans sauvegarde
- `generate-and-save` - Générer et sauvegarder
- `preview-data` - Prévisualiser les données

**Contenu**:
- Bouton "Preview Data"
- Bouton "Generate SQL"
- Bouton "Generate & Save" (si authentifié)
- Loading spinner
- Error alert

---

#### 6. **TransformPreviewModal.vue** ⏳ (À CRÉER)
**Localisation**: `frontend/src/components/mapping/TransformPreviewModal.vue`
**Lignes estimées**: ~120
**Responsabilité**: Modal de prévisualisation des transformations

**Props**:
```typescript
interface Props {
  isOpen: boolean
  columnName: string | null
  transformationType: TransformationType
  transformationLabel: string
  transformationDescription: string
  previewData: Array<{ original: any; transformed: any }>
}
```

**Émissions**:
- `update:isOpen` - Fermer le modal

**Contenu**:
- Titre avec nom de colonne
- Description de la transformation
- Table Original vs Transformed
- Bouton Close

---

### 7. Composables (À CRÉER)

#### **useMapping.ts**
**Localisation**: `frontend/src/composables/useMapping.ts`
**Responsabilité**: Logique de mapping entre colonnes

**Exports**:
```typescript
export function useMapping() {
  const syncFieldToExcelMapping = () => { ... }
  const updateMapping = () => { ... }
  const autoMap = () => { ... }
  const confirmClearMappings = () => { ... }
  const levenshteinDistance = (str1, str2) => { ... }
  const normalizeFieldName = (name) => { ... }

  return {
    syncFieldToExcelMapping,
    updateMapping,
    autoMap,
    confirmClearMappings,
    levenshteinDistance,
    normalizeFieldName
  }
}
```

---

#### **useValidation.ts**
**Localisation**: `frontend/src/composables/useValidation.ts`
**Responsabilité**: Logique de validation de données

**Exports**:
```typescript
export function useValidation() {
  const validateData = () => { ... }
  const getCellValidationClass = (row, col) => { ... }
  const getCellValidationMessage = (row, col) => { ... }
  const getCellValidationIcon = (row, col) => { ... }

  return {
    validateData,
    validationStats,
    cellValidations,
    validationErrors,
    transformationWarnings,
    getCellValidationClass,
    getCellValidationMessage,
    getCellValidationIcon
  }
}
```

---

#### **useSQLGeneration.ts**
**Localisation**: `frontend/src/composables/useSQLGeneration.ts`
**Responsabilité**: Logique de génération SQL

**Exports**:
```typescript
export function useSQLGeneration() {
  const generateSQL = async () => { ... }
  const generateAndSave = async () => { ... }
  const previewDataFunc = () => { ... }

  return {
    generateSQL,
    generateAndSave,
    loading,
    error,
    serverValidationErrors,
    previewData,
    showPreview
  }
}
```

---

## 📦 Mapping.vue Refactorisé

### Nouvelle Structure (~ 400 lignes)

```vue
<template>
  <div class="mapping-page px-4 py-6 sm:px-8">
    <StepperNav />

    <!-- Scroll Button -->
    <UButton
      v-if="showScrollButton"
      @click="scrollToTopOrBottom"
      :icon="isNearBottom ? 'i-heroicons-arrow-up' : 'i-heroicons-arrow-down'"
      color="primary"
      size="lg"
      class="fixed bottom-8 right-8 z-50 shadow-lg"
    />

    <div class="main-card bg-white dark:bg-gray-950 rounded-lg border shadow-md p-6">
      <!-- Page Header -->
      <div class="page-header mb-6">
        <h2 class="page-title text-3xl font-bold mb-2">Map Columns</h2>
        <p class="page-subtitle text-gray-600">
          Match your Excel/CSV columns to database fields
        </p>
      </div>

      <!-- Header Alerts -->
      <MappingHeader
        :show-missing-data-alert="!sessionStore.isRestoring && (!store.hasExcelData || !store.hasSelectedTable)"
        :auto-mapping-stats="autoMappingStats"
        :sample-field-names="sampleFieldNames"
        :auto-increment-fields="autoIncrementFields"
        :is-restoring="sessionStore.isRestoring"
        :table-name="store.selectedTable?.name"
        :data-row-count="store.excelData.length"
        :validation-stats="validationStats"
        @start-over="router.push('/')"
      />

      <!-- Mapping Section -->
      <div v-if="store.hasExcelData && store.hasSelectedTable" class="mapping-section mb-6">
        <!-- Section Header with Actions -->
        <div class="section-header flex justify-between items-center mb-4">
          <h3 class="section-title text-lg font-semibold">Column Mapping</h3>
          <MappingActions
            :is-restoring="sessionStore.isRestoring"
            :has-mapping="Object.keys(localMapping).length > 0"
            @auto-map="autoMap"
            @clear-all="showClearDialog = true"
          />
        </div>

        <!-- Skeleton Loading -->
        <div v-if="sessionStore.isRestoring" class="mapping-list space-y-3">
          <div v-for="i in 5" :key="`skeleton-${i}`" class="mapping-card ...">
            <!-- Skeleton content -->
          </div>
        </div>

        <!-- Mapping Cards -->
        <div v-else class="mapping-list space-y-3">
          <MappingCard
            v-for="field in store.selectedTable.fields"
            :key="field.name"
            :field="field"
            :selected-excel-column="fieldToExcelMapping[field.name]"
            :excel-headers="store.excelHeaders"
            :selected-transformation="fieldTransformations[field.name] || 'none'"
            :available-transformations="getAvailableTransformationsForField(field)"
            :has-warning="hasYearWarning(field.name)"
            :is-mapped="!!getMappedExcelColumn(field.name)"
            :sample-value="getSampleValueForField(field.name)"
            :is-restoring="sessionStore.isRestoring"
            @update:selected-excel-column="(val) => onExcelColumnChange(field.name, val)"
            @update:selected-transformation="(val) => onTransformationChange(field.name, val)"
            @preview-transformation="showTransformPreviewForField(field.name)"
            @skip-field="toggleSkipField(field.name)"
          />
        </div>
      </div>

      <!-- Validation Summary -->
      <ValidationSummary
        v-if="!sessionStore.isRestoring"
        :validation-errors="validationErrors"
        :transformation-warnings="transformationWarnings"
        :preview-data="previewData"
        :excel-headers="mappedHeaders"
        :cell-validations="cellValidations"
      />

      <!-- Generate SQL Actions -->
      <GenerateSQLPanel
        v-if="!sessionStore.isRestoring"
        :validation-errors="validationErrors"
        :is-loading="loading"
        :error="error"
        @generate-sql="generateSQL"
        @generate-and-save="generateAndSave"
        @preview-data="showPreview = true"
      />
    </div>

    <!-- Transform Preview Modal -->
    <TransformPreviewModal
      v-model:is-open="showTransformPreview"
      :column-name="transformPreviewColumn"
      :transformation-type="transformPreviewColumn ? fieldTransformations[transformPreviewColumn] : 'none'"
      :transformation-label="transformPreviewColumn ? transformations[fieldTransformations[transformPreviewColumn]]?.label : ''"
      :transformation-description="transformPreviewColumn ? transformations[fieldTransformations[transformPreviewColumn]]?.description : ''"
      :preview-data="transformPreviewColumn ? getTransformPreview(transformPreviewColumn) : []"
    />

    <!-- Clear Confirmation Modal -->
    <UModal v-model:open="showClearDialog" title="Confirm Clear All">
      <!-- Modal content -->
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import MappingHeader from '../components/mapping/MappingHeader.vue'
import MappingCard from '../components/mapping/MappingCard.vue'
import MappingActions from '../components/mapping/MappingActions.vue'
import ValidationSummary from '../components/mapping/ValidationSummary.vue'
import GenerateSQLPanel from '../components/mapping/GenerateSQLPanel.vue'
import TransformPreviewModal from '../components/mapping/TransformPreviewModal.vue'
import { useMapping } from '../composables/useMapping'
import { useValidation } from '../composables/useValidation'
import { useSQLGeneration } from '../composables/useSQLGeneration'

// Use composables
const {
  localMapping,
  fieldToExcelMapping,
  autoMap,
  confirmClearMappings,
  onExcelColumnChange,
  toggleSkipField
} = useMapping()

const {
  validationStats,
  cellValidations,
  validationErrors,
  transformationWarnings,
  validateData
} = useValidation()

const {
  loading,
  error,
  generateSQL,
  generateAndSave,
  previewData
} = useSQLGeneration()

// Minimal component state
const showScrollButton = ref(false)
const isNearBottom = ref(false)
const showPreview = ref(false)
const showClearDialog = ref(false)
const showTransformPreview = ref(false)
const transformPreviewColumn = ref<string | null>(null)

// Lifecycle
onMounted(() => {
  if (!sessionStore.isRestoring && Object.keys(localMapping.value).length === 0) {
    autoMap()
  }
  validateData()
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>
```

**Réduction**: 1,355 lignes → ~400 lignes (**-70%**)

---

## 🎯 Bénéfices Attendus

### 1. Maintenabilité
- ✅ Code divisé en responsabilités claires
- ✅ Chaque composant < 250 lignes
- ✅ Facile de localiser et corriger des bugs
- ✅ Réutilisabilité des composants

### 2. Testabilité
- ✅ Composants isolés = tests unitaires faciles
- ✅ Composables testables indépendamment
- ✅ Mocking simplifié

### 3. Performance
- ✅ Re-renders optimisés (seulement les cartes affectées)
- ✅ Lazy loading possible pour les modals
- ✅ Memoization au niveau composant

### 4. Developer Experience
- ✅ Code plus lisible
- ✅ TypeScript strict appliqué
- ✅ Props/Events bien documentés
- ✅ Easier onboarding pour nouveaux devs

---

## 📋 Plan d'Implémentation

### Phase 1: Créer les Composants (2-3h)
- [x] MappingHeader.vue ✅
- [ ] MappingCard.vue
- [ ] MappingActions.vue
- [ ] ValidationSummary.vue
- [ ] GenerateSQLPanel.vue
- [ ] TransformPreviewModal.vue

### Phase 2: Créer les Composables (1-2h)
- [ ] useMapping.ts
- [ ] useValidation.ts
- [ ] useSQLGeneration.ts

### Phase 3: Refactoriser Mapping.vue (1h)
- [ ] Importer les nouveaux composants
- [ ] Remplacer les sections par les composants
- [ ] Utiliser les composables
- [ ] Tester le comportement

### Phase 4: Tests (2h)
- [ ] Tests unitaires pour chaque composant
- [ ] Tests d'intégration pour le flux complet
- [ ] Tests de validation

### Phase 5: Optimisation (1h)
- [ ] Performance profiling
- [ ] Lazy loading des modals
- [ ] Memoization si nécessaire

**Temps Total Estimé**: 7-9 heures

---

## 🔄 Migration Progressive

Pour minimiser les risques, nous pouvons migrer progressivement:

1. **Étape 1**: Créer `MappingHeader` et l'intégrer (déjà fait ✅)
2. **Étape 2**: Créer `MappingActions` et l'intégrer
3. **Étape 3**: Créer `MappingCard` et l'intégrer (le plus gros morceau)
4. **Étape 4**: Créer `ValidationSummary` et `GenerateSQLPanel`
5. **Étape 5**: Créer les composables et nettoyer

À chaque étape, valider que tout fonctionne avant de passer à la suivante.

---

## 🎓 Leçons Apprises

### À Faire
- ✅ Diviser les composants dès qu'ils dépassent 300-400 lignes
- ✅ Séparer UI (template) et logique (composables)
- ✅ Typer strictement les Props et Events
- ✅ Documenter les interfaces TypeScript

### À Éviter
- ❌ Composants > 500 lignes
- ❌ Mélanger logique métier et rendu
- ❌ Props non typées
- ❌ Duplication de logique entre composants

---

**Prochaine Action**: Créer les 5 composants restants et les 3 composables, puis refactoriser Mapping.vue pour les utiliser.
