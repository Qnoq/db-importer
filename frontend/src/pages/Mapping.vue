<template>
  <div class="mapping-page px-4 py-6 sm:px-8">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="main-card bg-white dark:bg-gray-950 rounded-lg border border-gray-200 dark:border-gray-800 shadow-md p-6">
      <!-- Header -->
      <div class="page-header mb-6 flex justify-between items-center">
        <div>
          <h2 class="page-title text-3xl font-bold mb-2 text-gray-900 dark:text-white">Map Columns</h2>
          <p class="page-subtitle text-gray-600 dark:text-gray-400">
            Match your Excel/CSV columns to database fields and apply transformations
          </p>
        </div>
      </div>

      <!-- Loading State During Session Restoration -->
      <UAlert v-if="sessionStore.isRestoring" icon="i-heroicons-arrow-path" color="info" variant="soft" class="mb-4">
        <template #title>Restoring your session...</template>
        <template #description>
          <p>Please wait while we load your previous work.</p>
        </template>
      </UAlert>

      <!-- Missing Data Alert (only if not restoring) -->
      <UAlert v-else-if="!store.hasExcelData || !store.hasSelectedTable" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
        <template #title>Missing data</template>
        <template #description>
          <div class="flex flex-col gap-2">
            <p>Please complete previous steps.</p>
            <UButton @click="router.push('/')" variant="soft" color="warning" size="sm">
              ← Start over
            </UButton>
          </div>
        </template>
      </UAlert>

      <div v-else>
        <!-- Auto-mapping Success Banner -->
        <UAlert
          v-if="autoMappingStats"
          :icon="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'i-heroicons-check-circle' : 'i-heroicons-exclamation-triangle'"
          :color="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'success' : 'warning'"
          variant="soft"
          class="mb-4"
        >
          <template #title>
            {{ autoMappingStats.mapped > autoMappingStats.total / 2 ? 'Auto-mapping successful!' : 'Limited auto-mapping' }}
          </template>
          <template #description>
            <div class="space-y-3">
              <p class="text-sm">
                The system automatically mapped <strong>{{ autoMappingStats.mapped }} of {{ autoMappingStats.total }} columns</strong>
                by comparing your Excel column names with database field names.
              </p>

              <!-- Low match warning -->
              <div v-if="autoMappingStats.mapped < autoMappingStats.total / 2" class="bg-yellow-50 dark:bg-yellow-950 border border-yellow-200 dark:border-yellow-800 rounded-md p-3">
                <p class="font-semibold text-sm mb-1">💡 Tip: Improve auto-mapping</p>
                <p class="text-sm">
                  Only <strong>{{ Math.round((autoMappingStats.mapped / autoMappingStats.total) * 100) }}%</strong> of columns were auto-mapped.
                  For better results, <strong>rename your Excel headers to match database field names</strong>
                  (e.g., <code class="bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded text-xs">{{ store.selectedTable?.fields[0]?.name }}</code>,
                  <code class="bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded text-xs">{{ store.selectedTable?.fields[1]?.name }}</code>).
                </p>
              </div>

              <p class="text-sm">
                Review the mappings below and adjust if needed.
                <template v-if="getAutoIncrementFieldNames().length > 0">
                  ID fields (<strong>{{ getAutoIncrementFieldNames().join(', ') }}</strong>)
                  were automatically skipped as they are auto-incremented.
                </template>
              </p>
            </div>
          </template>
        </UAlert>

        <!-- Info Banner -->
        <UAlert icon="i-heroicons-information-circle" color="blue" variant="soft" class="mb-4">
          <template #title>Mapping Information</template>
          <template #description>
            <div class="space-y-2">
              <p class="text-sm">
                Target table: <strong>{{ store.selectedTable?.name }}</strong> |
                Data rows: <strong>{{ store.excelData.length }}</strong>
              </p>
              <div v-if="validationStats" class="flex gap-4 text-sm">
                <span class="text-green-600 dark:text-green-400 font-medium">
                  ✓ {{ validationStats.validRowCount }} valid
                </span>
                <span v-if="validationStats.warningCount > 0" class="text-amber-600 dark:text-amber-400 font-medium">
                  ⚠ {{ validationStats.warningCount }} warnings
                </span>
                <span v-if="validationStats.errorCount > 0" class="text-red-600 dark:text-red-400 font-medium">
                  ✕ {{ validationStats.errorCount }} errors
                </span>
              </div>
            </div>
          </template>
        </UAlert>

        <!-- Column Mapping -->
        <div class="mapping-section mb-6">
          <div class="section-header flex justify-between items-center mb-4">
            <h3 class="section-title text-lg font-semibold text-gray-900 dark:text-white">Column Mapping</h3>
            <div class="action-buttons flex gap-2">
              <UButton
                @click="autoMap"
                color="info"
                variant="soft"
                size="sm"
              >
                ⚡ Auto-map Columns
              </UButton>
              <UButton
                @click="showClearDialog = true"
                color="neutral"
                variant="soft"
                size="sm"
              >
                ✕ Clear All
              </UButton>
            </div>
          </div>

          <div class="mapping-list space-y-3">
            <div
              v-for="(field, index) in store.selectedTable?.fields"
              :key="index"
              class="mapping-card border-2 rounded-lg p-4 transition-all"
              :class="{
                'border-green-300 bg-green-50 dark:bg-green-950 dark:border-green-800': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                'border-amber-400 bg-amber-50 dark:bg-amber-950 dark:border-amber-800': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                'border-gray-200 bg-white dark:bg-gray-900 dark:border-gray-700': !getMappedExcelColumn(field.name)
              }"
            >
              <div class="mapping-grid grid grid-cols-1 md:grid-cols-5 gap-4 items-center">
                <!-- DB Field (Target) -->
                <div class="field-column flex flex-col gap-2">
                  <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">Database Field</label>
                  <div class="field-content flex items-center gap-2">
                    <div class="field-icon flex-shrink-0 w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded flex items-center justify-center text-purple-600 dark:text-purple-300">
                      🗄️
                    </div>
                    <div class="field-info flex-1 min-w-0">
                      <div class="field-name-row flex items-center gap-2">
                        <p class="field-name font-semibold truncate text-gray-900 dark:text-white" :title="field.name">
                          {{ field.name }}{{ field.nullable ? '' : ' *' }}
                        </p>
                        <span v-if="isAutoIncrementField(field)" class="badge badge-success text-xs font-medium rounded-full px-2 py-0.5 bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300 whitespace-nowrap">AUTO</span>
                        <span v-if="hasYearWarning(field.name)" class="badge badge-warning text-xs font-medium rounded-full px-2 py-0.5 bg-amber-100 dark:bg-amber-900 text-amber-700 dark:text-amber-300 whitespace-nowrap flex items-center gap-1">
                          ⚠️ YEAR
                        </span>
                      </div>
                      <p class="field-type text-xs text-gray-600 dark:text-gray-400">{{ field.type }}</p>
                    </div>
                  </div>
                </div>

                <!-- Arrow -->
                <div class="arrow-column flex justify-center">
                  <span
                    class="text-2xl"
                    :class="{
                      'text-green-600': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                      'text-amber-500': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                      'text-gray-300': !getMappedExcelColumn(field.name)
                    }"
                  >
                    ←
                  </span>
                </div>

                <!-- Excel Column (Source) -->
                <div class="excel-column flex flex-col gap-2">
                  <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">Excel Column</label>
                  <USelect
                    v-model="fieldToExcelMapping[field.name]"
                    @update:modelValue="(value) => onFieldMappingChange(field.name, value)"
                    :items="getExcelColumnOptions()"
                    placeholder="-- Skip this field --"
                    class="w-full"
                  />
                  <p class="sample-value text-xs text-gray-600 dark:text-gray-400 mt-1 min-h-[1.25rem]">
                    <span v-if="getMappedExcelColumn(field.name)">Sample: {{ getSampleValue(getMappedExcelColumn(field.name)!) }}</span>
                  </p>
                </div>

                <!-- Transformation -->
                <div class="transform-column flex flex-col gap-2">
                  <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">Transformation</label>
                  <USelect
                    v-model="fieldTransformations[field.name]"
                    :items="getTransformationOptions(field)"
                    :disabled="!getMappedExcelColumn(field.name)"
                    placeholder="None"
                    class="w-full"
                  />
                  <p class="text-xs text-gray-600 dark:text-gray-400 mt-1 min-h-[1.25rem]">
                    <!-- Empty placeholder for alignment -->
                  </p>
                </div>

                <!-- Actions -->
                <div class="actions-column flex gap-2 justify-end items-center">
                  <UTooltip v-if="fieldTransformations[field.name] && fieldTransformations[field.name] !== 'none' && getMappedExcelColumn(field.name)" text="Preview transformation">
                    <UButton
                      @click="showTransformPreviewForField(field.name)"
                      color="neutral"
                      variant="ghost"
                      size="sm"
                      icon="i-heroicons-eye"
                    />
                  </UTooltip>
                  <div class="skip-checkbox flex items-center gap-2 cursor-pointer p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                    <UCheckbox
                      :model-value="!getMappedExcelColumn(field.name)"
                      @update:model-value="() => toggleSkipField(field.name)"
                      :input-id="`skip-${field.name}`"
                    />
                    <label :for="`skip-${field.name}`" class="skip-label text-xs font-medium whitespace-nowrap text-gray-600 dark:text-gray-400">Skip</label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Validation Errors -->
        <UAlert v-if="validationErrors.length > 0" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
          <template #title>Mapping Warnings</template>
          <template #description>
            <ul class="list-disc list-inside text-sm space-y-1">
              <li v-for="(err, index) in validationErrors" :key="index">{{ err }}</li>
            </ul>
          </template>
        </UAlert>

        <!-- Transformation Warnings -->
        <UAlert v-if="transformationWarnings.length > 0" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
          <template #title>Date Transformation Warning</template>
          <template #description>
            <ul class="list-disc list-inside text-sm space-y-1">
              <li v-for="(warning, index) in transformationWarnings" :key="index">{{ warning }}</li>
            </ul>
          </template>
        </UAlert>

        <!-- Server Validation Errors -->
        <UAlert v-if="serverValidationErrors.length > 0" icon="i-heroicons-x-circle" color="error" variant="soft" class="mb-4">
          <template #title>Data Validation Errors</template>
          <template #description>
            <ul class="list-disc list-inside text-sm space-y-1 max-h-60 overflow-y-auto">
              <li v-for="(err, index) in serverValidationErrors" :key="index">{{ err }}</li>
            </ul>
          </template>
        </UAlert>

        <!-- Data Preview with Highlighting -->
        <div v-if="showPreview" class="preview-section mb-6 border border-gray-200 dark:border-gray-700 rounded-lg p-4 bg-gray-50 dark:bg-gray-900">
          <div class="preview-header flex justify-between items-center mb-4">
            <h3 class="section-title text-lg font-semibold text-gray-900 dark:text-white">Data Preview with Validation</h3>
            <UButton
              @click="showPreview = !showPreview"
              color="neutral"
              variant="ghost"
              size="sm"
              icon="i-heroicons-x-mark"
            />
          </div>

          <div class="preview-table-wrapper overflow-x-auto max-h-96 overflow-y-auto">
            <table class="min-w-full border-collapse">
              <thead class="sticky top-0 bg-gray-100 dark:bg-gray-800 z-10">
                <tr>
                  <th class="row-number-header px-3 py-2 text-left text-xs font-semibold uppercase text-gray-900 dark:text-white">#</th>
                  <th
                    v-for="(header, idx) in store.excelHeaders"
                    :key="idx"
                    class="column-header px-3 py-2 text-left text-xs font-semibold uppercase text-gray-900 dark:text-white"
                  >
                    {{ header }}
                    <div v-if="localMapping[header]" class="mapped-field text-xs font-normal text-green-600 dark:text-green-400">
                      → {{ localMapping[header] }}
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white dark:bg-gray-950">
                <tr v-for="(row, rowIdx) in previewData" :key="rowIdx" class="border-t border-gray-200 dark:border-gray-700">
                  <td class="row-number px-3 py-2 text-sm font-medium text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-900">{{ rowIdx + 1 }}</td>
                  <td
                    v-for="(cell, cellIdx) in row"
                    :key="cellIdx"
                    class="data-cell px-3 py-2 text-sm text-gray-900 dark:text-white"
                    :class="getCellValidationClass(rowIdx, cellIdx)"
                    :title="getCellValidationMessage(rowIdx, cellIdx)"
                  >
                    <div class="cell-content flex items-center gap-2">
                      <span>{{ formatCellValue(cell) }}</span>
                      <span
                        v-if="getCellValidationIcon(rowIdx, cellIdx)"
                        class="text-lg"
                      >
                        {{ getCellValidationIcon(rowIdx, cellIdx) === 'pi-check-circle' ? '✓' : getCellValidationIcon(rowIdx, cellIdx) === 'pi-exclamation-triangle' ? '⚠' : '✕' }}
                      </span>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="bottom-actions flex flex-wrap gap-4 mb-6">
          <UButton
            @click="generateSQL"
            :disabled="loading || !canGenerate"
            color="success"
            size="lg"
            icon="i-heroicons-arrow-down-tray"
          >
            Generate & Download SQL
          </UButton>

          <UButton
            @click="showPreview = !showPreview"
            color="neutral"
            size="lg"
            icon="i-heroicons-eye"
          >
            {{ showPreview ? 'Hide' : 'Show' }} Preview
          </UButton>
        </div>

        <!-- Loading Indicator -->
        <div v-if="loading" class="loading-container flex items-center justify-center p-8">
          <div class="flex flex-col items-center gap-4">
            <div class="animate-spin text-4xl">⏳</div>
            <p class="text-gray-600 dark:text-gray-400">Generating SQL...</p>
          </div>
        </div>

        <!-- Error Display -->
        <UAlert v-if="error" icon="i-heroicons-x-circle" color="error" variant="soft" class="mb-4">
          <template #title>Error</template>
          <template #description>
            {{ error }}
          </template>
        </UAlert>
      </div>
    </div>

    <!-- Transform Preview Modal -->
    <UModal
      v-model:open="showTransformPreview"
      :title="`Transformation Preview: ${transformPreviewColumn || ''}`"
      :description="transformPreviewColumn ? transformations[fieldTransformations[transformPreviewColumn]]?.description : ''"
      :ui="{ content: 'sm:max-w-2xl' }"
    >
      <template #body>
        <div v-if="transformPreviewColumn" class="mb-6">
          <p class="text-gray-900 dark:text-white"><strong>Transformation:</strong> {{ transformations[fieldTransformations[transformPreviewColumn]]?.label }}</p>
        </div>

        <div class="preview-dialog-table overflow-x-auto">
          <table class="min-w-full border-collapse border border-gray-200 dark:border-gray-700">
            <thead class="bg-gray-100 dark:bg-gray-800">
              <tr>
                <th class="px-4 py-2 text-left font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">Original</th>
                <th class="px-4 py-2 text-left font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">Transformed</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(preview, idx) in getTransformPreview(transformPreviewColumn!)" :key="idx" class="border-t border-gray-200 dark:border-gray-700">
                <td class="px-4 py-2 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">{{ preview.original }}</td>
                <td class="px-4 py-2 text-gray-900 dark:text-white font-semibold text-green-600 dark:text-green-400 border border-gray-200 dark:border-gray-700">{{ preview.transformed }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end">
          <UButton @click="showTransformPreview = false; transformPreviewColumn = null" color="neutral">
            Close
          </UButton>
        </div>
      </template>
    </UModal>

    <!-- Clear Mappings Confirmation Modal -->
    <UModal
      v-model:open="showClearDialog"
      title="Confirm Clear All"
      description="This will remove all mappings and transformations."
      :ui="{ content: 'sm:max-w-md' }"
    >
      <template #body>
        <div class="flex gap-4">
          <span class="text-3xl flex-shrink-0">⚠️</span>
          <p class="text-gray-900 dark:text-white pt-1">Are you sure you want to clear all column mappings?</p>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-2">
          <UButton @click="showClearDialog = false" color="neutral" variant="soft">
            Cancel
          </UButton>
          <UButton @click="confirmClearMappings" color="error">
            Clear All
          </UButton>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import StepperNav from '../components/StepperNav.vue'
import { useMappingStore, Field, type CellValue } from '../store/mappingStore'
import { useAuthStore } from '../store/authStore'
import { useImportStore } from '../store/importStore'
import { useWorkflowSessionStore } from '../store/workflowSessionStore'
import { transformations, applyTransformation, suggestTransformations, hasYearOnlyValues, type TransformationType } from '../utils/transformations'
import { validateDataset, getCellClass, getValidationIcon, type ValidationResult } from '../utils/dataValidation'

const router = useRouter()
const store = useMappingStore()
const authStore = useAuthStore()
const importStore = useImportStore()
const sessionStore = useWorkflowSessionStore()

// Mapping state (Excel column → DB field)
const localMapping = ref<Record<string, string>>({})
// Field to Excel column mapping (DB field → Excel column) - for v-model binding
const fieldToExcelMapping = ref<Record<string, string | null>>({})
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
const showTransformPreview = ref(false)
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
  // Initialize auto-mapping (only if no mapping exists yet)
  if (Object.keys(localMapping.value).length === 0) {
    autoMap()
  } else {
    // If we have mapping, just sync it
    syncFieldToExcelMapping()
  }

  validateData()
})

// Watch for restored transformations from session (handles async restoration)
watch(() => sessionStore.restoredTransformations, (transformations) => {
  if (transformations && Object.keys(transformations).length > 0) {
    console.log('Applying restored transformations:', transformations)
    fieldTransformations.value = { ...transformations }
    sessionStore.clearRestoredTransformations() // Clear after use
    // Re-validate with new transformations
    validateData()
  }
}, { immediate: true })

// Watch fieldTransformations for changes and trigger validation
watch(fieldTransformations, () => {
  validateData()
}, { deep: true })

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

  // Update fieldToExcelMapping for v-model binding
  syncFieldToExcelMapping()

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

  // Save to session (for authenticated users) with transformations
  sessionStore.saveMapping(localMapping.value, fieldTransformations.value)
}

/**
 * Sync fieldToExcelMapping from localMapping
 * Converts Excel column → DB field to DB field → Excel column
 */
function syncFieldToExcelMapping() {
  const newMapping: Record<string, string | null> = {}

  // Convert localMapping (Excel → DB) to fieldToExcelMapping (DB → Excel)
  for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
    if (typeof dbField === 'string') {
      newMapping[dbField] = excelCol
    }
  }

  // Initialize all fields with null if not mapped
  if (store.selectedTable) {
    for (const field of store.selectedTable.fields) {
      if (!newMapping[field.name]) {
        newMapping[field.name] = null
      }
    }
  }

  fieldToExcelMapping.value = newMapping
}

/**
 * Clear all mappings
 */
function confirmClearMappings() {
  localMapping.value = {}
  fieldTransformations.value = {}
  syncFieldToExcelMapping()
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
    { label: '-- Skip this field --', value: null },
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
  showTransformPreview.value = true
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
  syncFieldToExcelMapping()
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
