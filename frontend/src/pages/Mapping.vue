<template>
  <div class="mapping-page">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <Card class="main-card">
      <template #content>
      <!-- Header -->
      <div class="page-header">
        <div>
          <h2 class="page-title">Map Columns</h2>
          <p class="page-subtitle">
            Match your Excel/CSV columns to database fields and apply transformations
          </p>
        </div>
      </div>

      <Message v-if="!store.hasExcelData || !store.hasSelectedTable" severity="warn">
        <p>Missing data. Please complete previous steps.</p>
        <button @click="router.push('/')" class="restart-button">
          <i class="pi pi-arrow-left mr-2"></i>
          Start over
        </button>
      </Message>

      <div v-else>
        <!-- Auto-mapping Success Banner -->
        <Message
          v-if="autoMappingStats"
          :severity="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'success' : 'warn'"
          class="auto-mapping-banner"
        >
          <div class="banner-content">
            <div class="banner-icon">
              <i
                class="banner-icon-large"
                :class="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'pi pi-check-circle' : 'pi pi-exclamation-triangle'"
              ></i>
            </div>
            <div class="banner-text">
              <h3 class="banner-title">
                <template v-if="autoMappingStats.mapped > autoMappingStats.total / 2">
                  Auto-mapping successful!
                </template>
                <template v-else>
                  Limited auto-mapping
                </template>
              </h3>
              <p class="banner-description">
                The system automatically mapped <strong>{{ autoMappingStats.mapped }} of {{ autoMappingStats.total }} columns</strong>
                by comparing your Excel column names with database field names.
              </p>

              <!-- Low match warning -->
              <div v-if="autoMappingStats.mapped < autoMappingStats.total / 2" class="low-match-warning">
                <p class="warning-title">💡 Tip: Improve auto-mapping</p>
                <p class="warning-text">
                  Only <strong>{{ Math.round((autoMappingStats.mapped / autoMappingStats.total) * 100) }}%</strong> of columns were auto-mapped.
                  For better results, <strong>rename your Excel headers to match database field names</strong>
                  (e.g., <code class="code-example">{{ store.selectedTable?.fields[0]?.name }}</code>,
                  <code class="code-example">{{ store.selectedTable?.fields[1]?.name }}</code>).
                </p>
              </div>

              <p class="banner-footer">
                <i class="pi pi-info-circle mr-1"></i>
                Review the mappings below and adjust if needed.
                <template v-if="getAutoIncrementFieldNames().length > 0">
                  ID fields (<strong>{{ getAutoIncrementFieldNames().join(', ') }}</strong>)
                  were automatically skipped as they are auto-incremented.
                </template>
              </p>
            </div>
          </div>
        </Message>

        <!-- Info Banner -->
        <Message severity="info" class="info-banner">
          <div class="info-content">
            <p>
              <i class="pi pi-info-circle mr-2"></i>
              Target table: <strong>{{ store.selectedTable?.name }}</strong> |
              Data rows: <strong>{{ store.excelData.length }}</strong>
            </p>
          </div>
          <div v-if="validationStats" class="validation-stats">
            <span class="stat-success">
              <i class="pi pi-check-circle"></i> {{ validationStats.validRowCount }} valid
            </span>
            <span v-if="validationStats.warningCount > 0" class="stat-warning">
              <i class="pi pi-exclamation-triangle"></i> {{ validationStats.warningCount }} warnings
            </span>
            <span v-if="validationStats.errorCount > 0" class="stat-error">
              <i class="pi pi-times-circle"></i> {{ validationStats.errorCount }} errors
            </span>
          </div>
        </Message>

        <!-- Column Mapping -->
        <div class="mapping-section">
          <div class="section-header">
            <h3 class="section-title">Column Mapping</h3>
            <div class="action-buttons">
              <Button
                label="Auto-map Columns"
                icon="pi pi-bolt"
                @click="autoMap"
                severity="info"
              />
              <Button
                label="Clear All"
                icon="pi pi-times"
                @click="showClearDialog = true"
                severity="secondary"
              />
            </div>
          </div>

          <div class="mapping-list">
            <div
              v-for="(field, index) in store.selectedTable?.fields"
              :key="index"
              class="mapping-card"
              :class="{
                'mapped': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                'warning': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                'unmapped': !getMappedExcelColumn(field.name)
              }"
            >
              <div class="mapping-grid">
                <!-- DB Field (Target) -->
                <div class="field-column">
                  <label class="field-label">Database Field</label>
                  <div class="field-content">
                    <div class="field-icon">
                      <i class="pi pi-database"></i>
                    </div>
                    <div class="field-info">
                      <div class="field-name-row">
                        <p class="field-name" :title="field.name">
                          {{ field.name }}{{ field.nullable ? '' : ' *' }}
                        </p>
                        <span v-if="isAutoIncrementField(field)" class="badge badge-success">AUTO</span>
                        <span v-if="hasYearWarning(field.name)" class="badge badge-warning">
                          <i class="pi pi-exclamation-triangle"></i> YEAR
                        </span>
                      </div>
                      <p class="field-type">{{ field.type }}</p>
                    </div>
                  </div>
                </div>

                <!-- Arrow -->
                <div class="arrow-column">
                  <i
                    class="pi pi-arrow-left mapping-arrow"
                    :class="{
                      'arrow-mapped': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                      'arrow-warning': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                      'arrow-unmapped': !getMappedExcelColumn(field.name)
                    }"
                  ></i>
                </div>

                <!-- Excel Column (Source) -->
                <div class="excel-column">
                  <label class="field-label">Excel Column</label>
                  <Dropdown
                    :modelValue="getMappedExcelColumn(field.name)"
                    @update:modelValue="(value) => onFieldMappingChange(field.name, value)"
                    :options="getExcelColumnOptions()"
                    optionLabel="label"
                    optionValue="value"
                    placeholder="-- Skip this field --"
                    class="w-full"
                  />
                  <p v-if="getMappedExcelColumn(field.name)" class="sample-value">
                    Sample: {{ getSampleValue(getMappedExcelColumn(field.name)!) }}
                  </p>
                </div>

                <!-- Transformation -->
                <div class="transform-column">
                  <label class="field-label">Transformation</label>
                  <Dropdown
                    v-model="fieldTransformations[field.name]"
                    @update:modelValue="() => onTransformationChange(field.name)"
                    :options="getTransformationOptions(field)"
                    optionLabel="label"
                    optionValue="value"
                    :disabled="!getMappedExcelColumn(field.name)"
                    class="w-full"
                  />
                </div>

                <!-- Actions -->
                <div class="actions-column">
                  <Button
                    v-if="fieldTransformations[field.name] && fieldTransformations[field.name] !== 'none' && getMappedExcelColumn(field.name)"
                    @click="showTransformPreviewForField(field.name)"
                    icon="pi pi-eye"
                    text
                    rounded
                    severity="secondary"
                    v-tooltip.top="'Preview transformation'"
                  />
                  <div class="skip-checkbox">
                    <Checkbox
                      :modelValue="!getMappedExcelColumn(field.name)"
                      @update:modelValue="() => toggleSkipField(field.name)"
                      :binary="true"
                      :inputId="`skip-${field.name}`"
                    />
                    <label :for="`skip-${field.name}`" class="skip-label">Skip</label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Validation Errors -->
        <Message v-if="validationErrors.length > 0" severity="warn" class="validation-message">
          <h3>
            <i class="pi pi-exclamation-triangle mr-2"></i>
            Mapping Warnings
          </h3>
          <ul class="error-list">
            <li v-for="(err, index) in validationErrors" :key="index">{{ err }}</li>
          </ul>
        </Message>

        <!-- Transformation Warnings -->
        <Message v-if="transformationWarnings.length > 0" severity="warn" class="validation-message">
          <h3>
            <i class="pi pi-exclamation-triangle mr-2"></i>
            Date Transformation Warning
          </h3>
          <ul class="error-list">
            <li v-for="(warning, index) in transformationWarnings" :key="index">{{ warning }}</li>
          </ul>
        </Message>

        <!-- Server Validation Errors -->
        <Message v-if="serverValidationErrors.length > 0" severity="error" class="validation-message">
          <h3>
            <i class="pi pi-times-circle mr-2"></i>
            Data Validation Errors
          </h3>
          <ul class="error-list scrollable">
            <li v-for="(err, index) in serverValidationErrors" :key="index">{{ err }}</li>
          </ul>
        </Message>

        <!-- Data Preview with Highlighting -->
        <div v-if="showPreview" class="preview-section">
          <div class="preview-header">
            <h3 class="section-title">Data Preview with Validation</h3>
            <Button
              @click="showPreview = !showPreview"
              icon="pi pi-times"
              text
              rounded
              severity="secondary"
            />
          </div>

          <div class="preview-table-wrapper">
            <table class="preview-table">
              <thead>
                <tr>
                  <th class="row-number-header">#</th>
                  <th
                    v-for="(header, idx) in store.excelHeaders"
                    :key="idx"
                    class="column-header"
                  >
                    {{ header }}
                    <div v-if="localMapping[header]" class="mapped-field">
                      → {{ localMapping[header] }}
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, rowIdx) in previewData" :key="rowIdx">
                  <td class="row-number">{{ rowIdx + 1 }}</td>
                  <td
                    v-for="(cell, cellIdx) in row"
                    :key="cellIdx"
                    class="data-cell"
                    :class="getCellValidationClass(rowIdx, cellIdx)"
                    :title="getCellValidationMessage(rowIdx, cellIdx)"
                  >
                    <div class="cell-content">
                      <span>{{ formatCellValue(cell) }}</span>
                      <i
                        v-if="getCellValidationIcon(rowIdx, cellIdx)"
                        :class="`pi ${getCellValidationIcon(rowIdx, cellIdx)}`"
                      ></i>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="bottom-actions">
          <Button
            label="Generate & Download SQL"
            icon="pi pi-download"
            @click="generateSQL"
            :disabled="loading || !canGenerate"
            severity="success"
            size="large"
          />

          <Button
            :label="showPreview ? 'Hide' : 'Show' + ' Preview'"
            icon="pi pi-eye"
            @click="showPreview = !showPreview"
            severity="secondary"
          />
        </div>

        <!-- Loading Indicator -->
        <div v-if="loading" class="loading-container">
          <i class="pi pi-spin pi-spinner loading-spinner"></i>
        </div>

        <!-- Error Display -->
        <Message v-if="error" severity="error">{{ error }}</Message>
      </div>
      </template>
    </Card>

    <!-- Transform Preview Dialog -->
    <Dialog
      v-model:visible="transformPreviewColumn"
      :header="`Transformation Preview: ${transformPreviewColumn}`"
      :style="{ width: '50rem' }"
      :modal="true"
    >
      <div v-if="transformPreviewColumn" class="dialog-content">
        <p><strong>Transformation:</strong> {{ transformations[fieldTransformations[transformPreviewColumn]]?.label }}</p>
        <p class="dialog-description">{{ transformations[fieldTransformations[transformPreviewColumn]]?.description }}</p>
      </div>

      <div class="preview-dialog-table">
        <table class="dialog-table">
          <thead>
            <tr>
              <th>Original</th>
              <th>Transformed</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(preview, idx) in getTransformPreview(transformPreviewColumn)" :key="idx">
              <td>{{ preview.original }}</td>
              <td class="transformed-value">{{ preview.transformed }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <template #footer>
        <Button label="Close" @click="transformPreviewColumn = null" />
      </template>
    </Dialog>

    <!-- Clear Mappings Confirmation Dialog -->
    <Dialog
      v-model:visible="showClearDialog"
      header="Confirm Clear All"
      :modal="true"
      :style="{ width: '30rem' }"
    >
      <div class="confirm-dialog-content">
        <i class="pi pi-exclamation-triangle dialog-warning-icon"></i>
        <div>
          <p>Are you sure you want to clear all column mappings?</p>
          <p class="dialog-subtitle">This will remove all mappings and transformations.</p>
        </div>
      </div>

      <template #footer>
        <Button label="Cancel" text @click="showClearDialog = false" />
        <Button label="Clear All" severity="danger" @click="confirmClearMappings" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import StepperNav from '../components/StepperNav.vue'
import { useMappingStore, Field, type CellValue } from '../store/mappingStore'
import { useAuthStore } from '../store/authStore'
import { useImportStore } from '../store/importStore'
import { transformations, applyTransformation, suggestTransformations, hasYearOnlyValues, type TransformationType } from '../utils/transformations'
import { validateDataset, getCellClass, getValidationIcon, type ValidationResult } from '../utils/dataValidation'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import Checkbox from 'primevue/checkbox'
import Card from 'primevue/card'
import Message from 'primevue/message'

const router = useRouter()
const store = useMappingStore()
const authStore = useAuthStore()
const importStore = useImportStore()

// Mapping state (Excel column → DB field)
const localMapping = ref<Record<string, string>>({})
// Field transformations (DB field → transformation type)
const fieldTransformations = ref<Record<string, TransformationType>>({})
const previousFieldTransformations = ref<Record<string, TransformationType>>({}) // Store previous transformations when skipping

// UI state
const loading = ref(false)
const error = ref('')
const serverValidationErrors = ref<string[]>([])
const showPreview = ref(false)
const showClearDialog = ref(false)
const transformPreviewColumn = ref<string | null>(null)
const autoMappingStats = ref<{
  total: number
  mapped: number
  skipped: number
} | null>(null)

// Validation state
const cellValidations = ref<Map<string, ValidationResult>>(new Map())
const validationStats = ref<{
  validRowCount: number
  errorCount: number
  warningCount: number
} | null>(null)

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

onMounted(() => {
  // Initialize auto-mapping
  autoMap()
  validateData()
})

/**
 * Levenshtein distance algorithm for better string matching
 */
function levenshteinDistance(str1: string, str2: string): number {
  const len1 = str1.length
  const len2 = str2.length
  const matrix: number[][] = []

  for (let i = 0; i <= len1; i++) {
    matrix[i] = [i]
  }

  for (let j = 0; j <= len2; j++) {
    matrix[0][j] = j
  }

  for (let i = 1; i <= len1; i++) {
    for (let j = 1; j <= len2; j++) {
      if (str1[i - 1] === str2[j - 1]) {
        matrix[i][j] = matrix[i - 1][j - 1]
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j] + 1
        )
      }
    }
  }

  return matrix[len1][len2]
}

/**
 * Calculate similarity score
 */
function calculateSimilarity(str1: string, str2: string): number {
  const distance = levenshteinDistance(str1, str2)
  const maxLen = Math.max(str1.length, str2.length)
  return 1 - distance / maxLen
}

/**
 * Check if a field is likely an auto-increment ID field
 */
function isAutoIncrementField(field: Field): boolean {
  const nameLower = field.name.toLowerCase()
  const typeLower = field.type.toLowerCase()

  // Check if it's an integer type
  const isIntType = typeLower.includes('int') || typeLower.includes('serial')

  // Check if name suggests it's an ID
  const isIdName = nameLower === 'id' ||
                   nameLower.endsWith('_id') ||
                   nameLower.endsWith('id') ||
                   nameLower.startsWith('id_')

  // Auto-increment fields are typically NOT NULL integer IDs
  return isIntType && isIdName && !field.nullable
}

/**
 * Get list of auto-increment field names for display
 */
function getAutoIncrementFieldNames(): string[] {
  if (!store.selectedTable) return []
  return store.selectedTable.fields
    .filter(field => isAutoIncrementField(field))
    .map(field => field.name)
}

/**
 * Auto-map columns with Levenshtein
 */
function autoMap() {
  const mapping: Record<string, string> = {}
  const transformsToApply: Record<string, TransformationType> = {}
  let mappedCount = 0

  for (const header of store.excelHeaders) {
    const normalizedHeader = header.toLowerCase().trim().replace(/[_\s-]/g, '')

    let bestMatch: Field | null = null
    let bestScore = 0

    for (const field of store.selectedTable?.fields || []) {
      // Skip auto-increment ID fields - they shouldn't be mapped
      if (isAutoIncrementField(field)) {
        continue
      }

      const normalizedField = field.name.toLowerCase().trim().replace(/[_\s-]/g, '')

      let score = 0

      if (normalizedField === normalizedHeader) {
        score = 1.0
      } else if (normalizedField.includes(normalizedHeader) || normalizedHeader.includes(normalizedField)) {
        score = 0.8
      } else {
        const similarity = calculateSimilarity(normalizedHeader, normalizedField)
        if (similarity > 0.6) {
          score = similarity * 0.7
        }
      }

      if (score > bestScore) {
        bestScore = score
        bestMatch = field
      }
    }

    if (bestMatch && bestScore > 0.6) {
      mapping[header] = bestMatch.name
      mappedCount++

      // Get column data for suggestions
      const columnIndex = store.excelHeaders.indexOf(header)
      const columnData = store.excelData.map(row => row[columnIndex])

      // Suggest transformations (store by field name, not Excel column)
      const suggestions = suggestTransformations(columnData, bestMatch.type)
      if (suggestions.length > 1) {
        transformsToApply[bestMatch.name] = suggestions[1] // First non-'none' suggestion
      } else {
        transformsToApply[bestMatch.name] = 'none'
      }
    }
  }

  localMapping.value = mapping
  fieldTransformations.value = transformsToApply

  // Store auto-mapping statistics for display
  autoMappingStats.value = {
    total: store.excelHeaders.length,
    mapped: mappedCount,
    skipped: store.excelHeaders.length - mappedCount
  }

  updateMapping()
}

/**
 * Update mapping in store
 */
function updateMapping() {
  store.setMapping(localMapping.value)
}

/**
 * Clear all mappings
 */
function confirmClearMappings() {
  localMapping.value = {}
  fieldTransformations.value = {}
  updateMapping()
  showClearDialog.value = false
}

/**
 * Get which Excel column is mapped to a database field
 */
function getMappedExcelColumn(fieldName: string): string | null {
  for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
    if (dbField === fieldName) {
      return excelCol
    }
  }
  return null
}

/**
 * Handle field mapping change
 */
function onFieldMappingChange(fieldName: string, excelColumn: string) {
  // Remove any existing mapping to this field
  for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
    if (dbField === fieldName) {
      delete localMapping.value[excelCol]
    }
  }

  // Add new mapping if Excel column selected
  if (excelColumn) {
    // Remove any existing mapping for this Excel column (prevent duplicate mappings)
    delete localMapping.value[excelColumn]
    localMapping.value[excelColumn] = fieldName

    // Suggest transformation
    const field = store.selectedTable?.fields.find(f => f.name === fieldName)
    if (field) {
      const columnIndex = store.excelHeaders.indexOf(excelColumn)
      const columnData = store.excelData.map(row => row[columnIndex])
      const suggestions = suggestTransformations(columnData, field.type)
      fieldTransformations.value[fieldName] = suggestions[1] || 'none'
    }
  } else {
    fieldTransformations.value[fieldName] = 'none'
  }

  onMappingChange()
}

/**
 * Toggle skip for a field
 */
function toggleSkipField(fieldName: string) {
  const mappedExcelCol = getMappedExcelColumn(fieldName)

  if (mappedExcelCol) {
    // Currently mapped, skip it - save transformation before clearing
    previousFieldTransformations.value[fieldName] = fieldTransformations.value[fieldName] || 'none'
    delete localMapping.value[mappedExcelCol]
    fieldTransformations.value[fieldName] = 'none'
  } else {
    // Currently skipped, try to auto-map it
    const field = store.selectedTable?.fields.find(f => f.name === fieldName)
    if (!field) return

    const normalizedField = fieldName.toLowerCase().trim().replace(/[_\s-]/g, '')
    let bestMatch: string | null = null
    let bestScore = 0

    for (const excelHeader of store.excelHeaders) {
      // Skip if this Excel column is already mapped
      if (localMapping.value[excelHeader]) continue

      const normalizedHeader = excelHeader.toLowerCase().trim().replace(/[_\s-]/g, '')
      const similarity = calculateSimilarity(normalizedHeader, normalizedField)

      if (similarity > bestScore) {
        bestScore = similarity
        bestMatch = excelHeader
      }
    }

    if (bestMatch && bestScore > 0.6) {
      localMapping.value[bestMatch] = fieldName

      // Restore previous transformation if it exists, otherwise suggest one
      if (previousFieldTransformations.value[fieldName] && previousFieldTransformations.value[fieldName] !== 'none') {
        fieldTransformations.value[fieldName] = previousFieldTransformations.value[fieldName]
      } else {
        const columnIndex = store.excelHeaders.indexOf(bestMatch)
        const columnData = store.excelData.map(row => row[columnIndex])
        const suggestions = suggestTransformations(columnData, field.type)
        fieldTransformations.value[fieldName] = suggestions[1] || 'none'
      }
    }
  }

  onMappingChange()
}

/**
 * Get Excel column options for Select component
 */
function getExcelColumnOptions() {
  return [
    { label: '-- Skip this field --', value: '' },
    ...store.excelHeaders.map(header => ({ label: header, value: header }))
  ]
}

/**
 * Get transformation options for a field (for Select component)
 */
function getTransformationOptions(field: Field) {
  const excelCol = getMappedExcelColumn(field.name)
  if (!excelCol) return [{ label: transformations.none.label, value: 'none' }]

  const columnIndex = store.excelHeaders.indexOf(excelCol)
  const columnData = store.excelData.map(row => row[columnIndex])
  const transformationTypes = suggestTransformations(columnData, field.type)

  return transformationTypes.map(type => ({
    label: transformations[type].label,
    value: type
  }))
}

/**
 * Show transformation preview for a field
 */
function showTransformPreviewForField(fieldName: string) {
  transformPreviewColumn.value = fieldName
}

/**
 * Get sample value from first row
 */
function getSampleValue(header: string): string {
  const columnIndex = store.excelHeaders.indexOf(header)
  if (columnIndex === -1 || !store.excelData.length) return 'N/A'

  const sampleValue = store.excelData[0]?.[columnIndex]
  if (sampleValue === null || sampleValue === undefined) return 'N/A'

  const strValue = String(sampleValue)
  return strValue.substring(0, 30) + (strValue.length > 30 ? '...' : '')
}

/**
 * Handle mapping change
 */
function onMappingChange() {
  updateMapping()
  validateData()
}

/**
 * Handle transformation change
 */
function onTransformationChange(_fieldName: string) {
  validateData()
}

/**
 * Validate all data
 */
function validateData() {
  if (!store.selectedTable) return

  const fields: Field[] = []
  const mapping: Record<string, string> = {}

  for (const excelHeader of store.excelHeaders) {
    const dbColumn = localMapping.value[excelHeader]
    if (dbColumn) {
      const field = store.selectedTable.fields.find(f => f.name === dbColumn)
      if (field) {
        fields.push(field)
        mapping[excelHeader] = dbColumn
      }
    }
  }

  // Apply transformations to data
  const transformedData = store.excelData.map(row => {
    const newRow = [...row]
    store.excelHeaders.forEach((header, idx) => {
      const dbField = localMapping.value[header]
      if (dbField) {
        const transform = fieldTransformations.value[dbField]
        if (transform && transform !== 'none') {
          newRow[idx] = applyTransformation(row[idx], transform) as CellValue
        }
      }
    })
    return newRow
  })

  const result = validateDataset(transformedData, fields, mapping, store.excelHeaders)

  validationStats.value = {
    validRowCount: result.validRowCount,
    errorCount: result.errorCount,
    warningCount: result.warningCount
  }

  // Store validations for highlighting
  cellValidations.value.clear()
  result.validations.forEach(v => {
    const key = `${v.rowIndex}-${v.columnIndex}`
    cellValidations.value.set(key, v)
  })
}

/**
 * Get cell validation class
 */
function getCellValidationClass(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = cellValidations.value.get(key)
  return validation ? getCellClass(validation) : ''
}

/**
 * Get cell validation message
 */
function getCellValidationMessage(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = cellValidations.value.get(key)
  return validation?.message || ''
}

/**
 * Get cell validation icon
 */
function getCellValidationIcon(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = cellValidations.value.get(key)
  return validation ? getValidationIcon(validation.severity) : ''
}

/**
 * Preview data (first 20 rows with transformations applied)
 */
const previewData = computed(() => {
  return store.excelData.slice(0, 20).map(row => {
    const newRow = [...row]
    store.excelHeaders.forEach((header, idx) => {
      const dbField = localMapping.value[header]
      if (dbField) {
        const transform = fieldTransformations.value[dbField]
        if (transform && transform !== 'none') {
          newRow[idx] = applyTransformation(row[idx], transform) as CellValue
        }
      }
    })
    return newRow
  })
})

/**
 * Format cell value for display
 */
function formatCellValue(value: unknown): string {
  if (value === null || value === undefined) return '(null)'
  return String(value)
}

/**
 * Validation errors
 */
const validationErrors = computed(() => {
  const errors: string[] = []

  if (!store.selectedTable) return errors

  for (const field of store.selectedTable.fields) {
    // Skip auto-increment ID fields - they don't need to be mapped
    if (isAutoIncrementField(field)) {
      continue
    }

    if (!field.nullable) {
      const isMapped = Object.values(localMapping.value).includes(field.name)
      if (!isMapped) {
        errors.push(`Required field "${field.name}" is not mapped`)
      }
    }
  }

  return errors
})

/**
 * Transformation warnings (informational, not blocking)
 */
const transformationWarnings = computed(() => {
  const warnings: string[] = []

  if (!store.selectedTable) return warnings

  // Check for year-only values in date fields
  for (const field of store.selectedTable.fields) {
    const fieldTypeLower = field.type.toLowerCase()
    const isDateField = fieldTypeLower.includes('date') || fieldTypeLower.includes('time')

    if (isDateField) {
      const excelCol = getMappedExcelColumn(field.name)
      if (excelCol) {
        const columnIndex = store.excelHeaders.indexOf(excelCol)
        const columnData = store.excelData.map(row => row[columnIndex])

        if (hasYearOnlyValues(columnData)) {
          warnings.push(
            `Field "${field.name}": Detected year-only values (e.g., "2023"). ` +
            `Using "Excel Date (or Year)" transformation will convert them to YYYY-01-01.`
          )
        }
      }
    }
  }

  return warnings
})

/**
 * Check if a field has year-only warning
 */
function hasYearWarning(fieldName: string): boolean {
  if (!store.selectedTable) return false

  const field = store.selectedTable.fields.find(f => f.name === fieldName)
  if (!field) return false

  const fieldTypeLower = field.type.toLowerCase()
  const isDateField = fieldTypeLower.includes('date') || fieldTypeLower.includes('time')

  if (isDateField) {
    const excelCol = getMappedExcelColumn(fieldName)
    if (excelCol) {
      const columnIndex = store.excelHeaders.indexOf(excelCol)
      const columnData = store.excelData.map(row => row[columnIndex])
      return hasYearOnlyValues(columnData)
    }
  }

  return false
}

/**
 * Can generate SQL
 */
const canGenerate = computed(() => {
  return Object.values(localMapping.value).some(v => v !== '')
})

/**
 * Get transformation preview data
 */
function getTransformPreview(fieldName: string) {
  const excelCol = getMappedExcelColumn(fieldName)
  if (!excelCol) return []

  const columnIndex = store.excelHeaders.indexOf(excelCol)
  const transform = fieldTransformations.value[fieldName]

  return store.excelData.slice(0, 10).map(row => ({
    original: formatCellValue(row[columnIndex]),
    transformed: formatCellValue(applyTransformation(row[columnIndex], transform))
  }))
}

interface FieldInfo {
  name: string
  type: string
  nullable: boolean
}

/**
 * Generate SQL
 */
async function generateSQL() {
  if (!store.selectedTable) return

  error.value = ''
  serverValidationErrors.value = []
  loading.value = true

  try {
    // Apply transformations to all data
    const transformedData = store.excelData.map(row => {
      const newRow = [...row]
      store.excelHeaders.forEach((header, idx) => {
        const dbField = localMapping.value[header]
        if (dbField) {
          const transform = fieldTransformations.value[dbField]
          if (transform && transform !== 'none') {
            newRow[idx] = applyTransformation(row[idx], transform) as CellValue
          }
        }
      })
      return newRow
    })

    // Build ordered rows based on mapping
    const mappedRows: unknown[][] = []

    for (const row of transformedData) {
      const mappedRow: unknown[] = []

      for (const excelHeader of store.excelHeaders) {
        const dbColumn = localMapping.value[excelHeader]
        if (dbColumn) {
          const index = store.excelHeaders.indexOf(excelHeader)
          mappedRow.push(row[index])
        }
      }

      if (mappedRow.length > 0) {
        mappedRows.push(mappedRow)
      }
    }

    // Build fields array for validation
    const fields: FieldInfo[] = []
    for (const excelHeader of store.excelHeaders) {
      const dbColumn = localMapping.value[excelHeader]
      if (dbColumn) {
        const field = store.selectedTable.fields.find(f => f.name === dbColumn)
        if (field) {
          fields.push({
            name: field.name,
            type: field.type,
            nullable: field.nullable
          })
        }
      }
    }

    const response = await fetch(`${API_URL}/generate-sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        table: store.selectedTable.name,
        mapping: localMapping.value,
        rows: mappedRows,
        fields: fields
      })
    })

    if (!response.ok) {
      if (response.status === 422) {
        const errorData = await response.json()
        serverValidationErrors.value = errorData.errors || []
        error.value = errorData.error || 'Data validation failed'
        loading.value = false
        return
      }

      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.message || errorData.error || 'Failed to generate SQL')
    }

    const sql = await response.text()

    // Download file
    const blob = new Blob([sql], { type: 'text/plain' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    const filename = `import_${store.selectedTable.name}_${Date.now()}.sql`
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)

    // Save to import history if user is authenticated
    if (authStore.isAuthenticated) {
      try {
        console.log('User is authenticated, saving to import history...')

        // Determine status based on validation results
        let status: 'success' | 'warning' | 'failed' = 'success'
        const errorCount = serverValidationErrors.value.length
        const warningCount = validationStats.value?.warningCount || 0

        if (errorCount > 0) {
          status = 'failed'
        } else if (warningCount > 0) {
          status = 'warning'
        }

        // Build transformations list
        const appliedTransformations: string[] = []
        Object.entries(fieldTransformations.value).forEach(([field, transform]) => {
          if (transform && transform !== 'none') {
            appliedTransformations.push(`${field}: ${transform}`)
          }
        })

        const importData = {
          tableName: store.selectedTable.name,
          rowCount: mappedRows.length,
          status,
          generatedSql: sql,
          errorCount,
          warningCount,
          metadata: {
            sourceFileName: filename,
            mappingSummary: localMapping.value,
            transformations: appliedTransformations.length > 0 ? appliedTransformations : undefined,
            databaseType: 'mysql', // Could be detected from schema
            validationErrors: serverValidationErrors.value.length > 0 ? serverValidationErrors.value : undefined,
            validationWarnings: validationStats.value?.warningCount ? ['Some data validation warnings occurred'] : undefined
          }
        }

        console.log('Saving import with data:', importData)
        await importStore.createImport(importData)
        console.log('✅ Import saved to history successfully')
      } catch (historyError) {
        // Don't fail the whole operation if history save fails
        console.error('❌ Failed to save import to history:', historyError)
      }
    } else {
      console.log('User not authenticated, skipping history save')
    }

    loading.value = false
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'An error occurred'
    loading.value = false
  }
}
</script>

<style scoped>
.mapping-page {
  padding: 1.5rem 1rem;
}

.main-card {
  box-shadow: var(--p-shadow-4);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.page-title {
  font-size: 1.875rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
  color: var(--p-text-color);
}

.page-subtitle {
  margin-top: 0.25rem;
  color: var(--p-text-muted-color);
}

.restart-button {
  margin-top: 0.75rem;
  font-weight: 600;
  color: var(--p-primary-color);
  background: none;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.auto-mapping-banner {
  margin-bottom: 1rem;
}

.banner-content {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.banner-icon {
  flex-shrink: 0;
}

.banner-icon-large {
  font-size: 1.5rem;
}

.banner-text {
  flex: 1;
}

.banner-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.banner-description {
  font-size: 0.875rem;
}

.low-match-warning {
  margin-top: 0.75rem;
  background: rgba(255, 235, 156, 0.3);
  border-radius: var(--p-border-radius);
  padding: 0.75rem;
}

.warning-title {
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.warning-text {
  font-size: 0.875rem;
}

.code-example {
  background: white;
  padding: 0.125rem 0.25rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
}

.banner-footer {
  font-size: 0.875rem;
  margin-top: 0.5rem;
}

.info-banner {
  margin-bottom: 1rem;
}

.info-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex: 1;
}

.validation-stats {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
}

.stat-success {
  color: var(--p-green-700);
}

.stat-warning {
  color: var(--p-orange-600);
}

.stat-error {
  color: var(--p-red-700);
}

.mapping-section {
  margin-bottom: 1.5rem;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--p-text-color);
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.mapping-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.mapping-card {
  border: 2px solid var(--p-surface-border);
  border-radius: var(--p-border-radius);
  padding: 1rem;
  background: var(--p-surface-card);
  transition: all 0.2s;
}

.mapping-card.mapped {
  border-color: var(--p-green-300);
  background: rgba(34, 197, 94, 0.05);
}

.mapping-card.warning {
  border-color: var(--p-orange-400);
  background: rgba(251, 146, 60, 0.05);
}

.mapping-card.unmapped {
  border-color: var(--p-surface-border);
}

.mapping-grid {
  display: grid;
  grid-template-columns: 1fr auto 2fr 2fr auto;
  gap: 1rem;
  align-items: center;
}

@media (max-width: 768px) {
  .mapping-grid {
    grid-template-columns: 1fr;
  }
}

.field-column,
.excel-column,
.transform-column {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.field-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
  margin-bottom: 0.25rem;
}

.field-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.field-icon {
  flex-shrink: 0;
  width: 2rem;
  height: 2rem;
  background: rgba(168, 85, 247, 0.1);
  border-radius: var(--p-border-radius);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--p-purple-600);
}

.field-info {
  flex: 1;
  min-width: 0;
}

.field-name-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.field-name {
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--p-text-color);
}

.badge {
  padding: 0.125rem 0.5rem;
  font-size: 0.75rem;
  font-weight: 500;
  border-radius: 9999px;
  white-space: nowrap;
}

.badge-success {
  background: var(--p-green-100);
  color: var(--p-green-700);
}

.badge-warning {
  background: var(--p-orange-100);
  color: var(--p-orange-700);
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.field-type {
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.arrow-column {
  display: flex;
  justify-content: center;
}

.mapping-arrow {
  font-size: 1.5rem;
}

.arrow-mapped {
  color: var(--p-green-600);
}

.arrow-warning {
  color: var(--p-orange-500);
}

.arrow-unmapped {
  color: var(--p-surface-300);
}

.sample-value {
  font-size: 0.75rem;
  margin-top: 0.25rem;
  color: var(--p-text-muted-color);
}

.actions-column {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
  align-items: center;
}

.skip-checkbox {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: var(--p-border-radius);
  transition: background-color 0.2s;
}

.skip-checkbox:hover {
  background-color: var(--p-surface-100);
}

.skip-label {
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
  color: var(--p-text-muted-color);
}

.validation-message {
  margin-bottom: 1rem;
}

.error-list {
  list-style: disc;
  list-style-position: inside;
  font-size: 0.875rem;
  margin-top: 0.5rem;
}

.error-list.scrollable {
  max-height: 15rem;
  overflow-y: auto;
}

.preview-section {
  margin-bottom: 1.5rem;
  border-radius: var(--p-border-radius);
  padding: 1rem;
  border: 1px solid var(--p-surface-border);
  background: var(--p-surface-50);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.preview-table-wrapper {
  overflow-x: auto;
  max-height: 24rem;
  overflow-y: auto;
}

.preview-table {
  min-width: 100%;
  border-collapse: collapse;
}

.preview-table thead {
  position: sticky;
  top: 0;
  background: var(--p-surface-100);
  z-index: 10;
}

.row-number-header,
.column-header {
  padding: 0.75rem;
  text-align: left;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--p-text-color);
}

.mapped-field {
  font-size: 0.75rem;
  font-weight: normal;
  color: var(--p-primary-color);
}

.preview-table tbody {
  background: var(--p-surface-0);
}

.preview-table tbody tr {
  border-top: 1px solid var(--p-surface-border);
}

.row-number {
  padding: 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--p-text-muted-color);
  background: var(--p-surface-0);
}

.data-cell {
  padding: 0.75rem;
  font-size: 0.875rem;
  color: var(--p-text-color);
}

.cell-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.bottom-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.loading-spinner {
  font-size: 2.5rem;
  color: var(--p-primary-color);
}

.dialog-content {
  margin-bottom: 1rem;
}

.dialog-description {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.preview-dialog-table {
  overflow-x: auto;
}

.dialog-table {
  min-width: 100%;
  border-collapse: collapse;
  border: 1px solid var(--p-surface-border);
}

.dialog-table thead {
  background: var(--p-surface-100);
}

.dialog-table th {
  padding: 0.75rem;
  text-align: left;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--p-text-color);
}

.dialog-table tbody tr {
  border-top: 1px solid var(--p-surface-border);
}

.dialog-table td {
  padding: 0.75rem;
  font-size: 0.875rem;
}

.transformed-value {
  font-weight: 500;
  color: var(--p-primary-color);
}

.confirm-dialog-content {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.dialog-warning-icon {
  font-size: 1.875rem;
  color: var(--p-orange-500);
}

.dialog-subtitle {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}
</style>
