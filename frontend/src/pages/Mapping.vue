<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="bg-white shadow-lg rounded-xl p-8 border border-gray-200">
      <!-- Header -->
      <div class="flex justify-between items-center mb-6">
        <div>
          <h2 class="text-3xl font-bold text-gray-900 mb-2">Map Columns</h2>
          <p class="text-gray-600 mt-1">
            Match your Excel/CSV columns to database fields and apply transformations
          </p>
        </div>
      </div>

      <div v-if="!store.hasExcelData || !store.hasSelectedTable" class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
        <p class="text-yellow-700">Missing data. Please complete previous steps.</p>
        <button
          @click="router.push('/')"
          class="mt-3 text-blue-600 hover:text-blue-700 font-semibold"
        >
          <i class="pi pi-arrow-left mr-2"></i>
          Start over
        </button>
      </div>

      <div v-else>
        <!-- Auto-mapping Success Banner -->
        <div v-if="autoMappingStats" class="mb-4 rounded-md p-4"
             :class="autoMappingStats.mapped > autoMappingStats.total / 2
                     ? 'bg-green-50 border border-green-200'
                     : 'bg-yellow-50 border border-yellow-200'">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0">
              <i class="text-2xl" :class="autoMappingStats.mapped > autoMappingStats.total / 2
                                          ? 'pi pi-check-circle text-green-600'
                                          : 'pi pi-exclamation-triangle text-yellow-600'"></i>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold mb-1" :class="autoMappingStats.mapped > autoMappingStats.total / 2
                                                     ? 'text-green-900'
                                                     : 'text-yellow-900'">
                <template v-if="autoMappingStats.mapped > autoMappingStats.total / 2">
                  Auto-mapping successful!
                </template>
                <template v-else>
                  Limited auto-mapping
                </template>
              </h3>
              <p class="text-sm" :class="autoMappingStats.mapped > autoMappingStats.total / 2
                                         ? 'text-green-800'
                                         : 'text-yellow-800'">
                The system automatically mapped <strong>{{ autoMappingStats.mapped }} of {{ autoMappingStats.total }} columns</strong>
                by comparing your Excel column names with database field names.
              </p>

              <!-- Low match warning -->
              <div v-if="autoMappingStats.mapped < autoMappingStats.total / 2" class="mt-3 bg-yellow-100 rounded-lg p-3">
                <p class="text-sm text-yellow-900 font-medium mb-1">
                  💡 Tip: Improve auto-mapping
                </p>
                <p class="text-sm text-yellow-800">
                  Only <strong>{{ Math.round((autoMappingStats.mapped / autoMappingStats.total) * 100) }}%</strong> of columns were auto-mapped.
                  For better results, <strong>rename your Excel headers to match database field names</strong>
                  (e.g., <code class="bg-white px-1 rounded text-xs">{{ store.selectedTable?.fields[0]?.name }}</code>,
                  <code class="bg-white px-1 rounded text-xs">{{ store.selectedTable?.fields[1]?.name }}</code>).
                </p>
              </div>

              <p class="text-sm mt-2" :class="autoMappingStats.mapped > autoMappingStats.total / 2
                                              ? 'text-green-700'
                                              : 'text-yellow-700'">
                <i class="pi pi-info-circle mr-1"></i>
                Review the mappings below and adjust if needed.
                <template v-if="getAutoIncrementFieldNames().length > 0">
                  ID fields (<strong>{{ getAutoIncrementFieldNames().join(', ') }}</strong>)
                  were automatically skipped as they are auto-incremented.
                </template>
              </p>
            </div>
          </div>
        </div>

        <!-- Info Banner -->
        <div class="mb-4 bg-blue-50 border border-blue-200 rounded-md p-4 flex items-center justify-between">
          <div class="flex-1">
            <p class="text-sm text-blue-800">
              <i class="pi pi-info-circle mr-2"></i>
              Target table: <strong>{{ store.selectedTable?.name }}</strong> |
              Data rows: <strong>{{ store.excelData.length }}</strong>
            </p>
          </div>
          <div v-if="validationStats" class="flex gap-4 text-sm">
            <span class="text-green-700">
              <i class="pi pi-check-circle"></i> {{ validationStats.validRowCount }} valid
            </span>
            <span v-if="validationStats.warningCount > 0" class="text-yellow-700">
              <i class="pi pi-exclamation-triangle"></i> {{ validationStats.warningCount }} warnings
            </span>
            <span v-if="validationStats.errorCount > 0" class="text-red-700">
              <i class="pi pi-times-circle"></i> {{ validationStats.errorCount }} errors
            </span>
          </div>
        </div>

        <!-- Column Mapping -->
        <div class="mb-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">Column Mapping</h3>
            <div class="flex gap-2">
              <button
                @click="autoMap"
                class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition flex items-center gap-2 shadow-sm"
              >
                <i class="pi pi-bolt"></i>
                Auto-map Columns
              </button>
              <button
                @click="showClearDialog = true"
                class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-4 rounded-lg transition flex items-center gap-2 shadow-sm"
              >
                <i class="pi pi-times"></i>
                Clear All
              </button>
            </div>
          </div>

          <div class="space-y-3">
            <div
              v-for="(field, index) in store.selectedTable?.fields"
              :key="index"
              class="bg-white border-2 rounded-lg p-4 hover:border-blue-300 transition-all"
              :class="{
                'border-green-300 bg-green-50': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                'border-orange-400 bg-orange-50': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                'border-gray-200': !getMappedExcelColumn(field.name)
              }"
            >
              <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                <!-- DB Field (Target) -->
                <div class="md:col-span-3">
                  <label class="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
                    Database Field
                  </label>
                  <div class="flex items-center gap-2">
                    <div class="flex-shrink-0 w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center">
                      <i class="pi pi-database text-purple-600"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2">
                        <p class="font-semibold text-gray-900 truncate" :title="field.name">
                          {{ field.name }}{{ field.nullable ? '' : ' *' }}
                        </p>
                        <span v-if="isAutoIncrementField(field)" class="px-2 py-0.5 text-xs font-medium bg-green-100 text-green-700 rounded-full whitespace-nowrap">
                          AUTO
                        </span>
                        <span v-if="hasYearWarning(field.name)" class="px-2 py-0.5 text-xs font-medium bg-orange-100 text-orange-700 rounded-full whitespace-nowrap flex items-center gap-1">
                          <i class="pi pi-exclamation-triangle text-xs"></i>
                          YEAR
                        </span>
                      </div>
                      <p class="text-xs text-gray-500">
                        {{ field.type }}
                      </p>
                    </div>
                  </div>
                </div>

                <!-- Arrow -->
                <div class="md:col-span-1 flex justify-center">
                  <i class="pi pi-arrow-left text-2xl" :class="{
                    'text-green-600': getMappedExcelColumn(field.name) && !hasYearWarning(field.name),
                    'text-orange-500': getMappedExcelColumn(field.name) && hasYearWarning(field.name),
                    'text-gray-300': !getMappedExcelColumn(field.name)
                  }"></i>
                </div>

                <!-- Excel Column (Source) -->
                <div class="md:col-span-4">
                  <label class="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
                    Excel Column
                  </label>
                  <Select
                    :modelValue="getMappedExcelColumn(field.name)"
                    @update:modelValue="(value) => onFieldMappingChange(field.name, value)"
                    :options="getExcelColumnOptions()"
                    optionLabel="label"
                    optionValue="value"
                    placeholder="-- Skip this field --"
                    class="w-full"
                  />
                  <p v-if="getMappedExcelColumn(field.name)" class="text-xs text-gray-500 mt-1">
                    Sample: {{ getSampleValue(getMappedExcelColumn(field.name)!) }}
                  </p>
                </div>

                <!-- Transformation -->
                <div class="md:col-span-3">
                  <label class="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
                    Transformation
                  </label>
                  <Select
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
                <div class="md:col-span-1 flex gap-2 justify-end items-center">
                  <button
                    v-if="fieldTransformations[field.name] && fieldTransformations[field.name] !== 'none' && getMappedExcelColumn(field.name)"
                    @click="showTransformPreviewForField(field.name)"
                    class="flex items-center justify-center w-8 h-8 text-blue-600 hover:bg-blue-50 rounded-lg transition"
                    title="Preview transformation"
                  >
                    <i class="pi pi-eye text-sm"></i>
                  </button>
                  <button
                    v-else
                    class="flex items-center justify-center w-8 h-8 opacity-0 pointer-events-none"
                    disabled
                  >
                    <i class="pi pi-eye text-sm"></i>
                  </button>
                  <label class="flex items-center gap-1.5 cursor-pointer group px-2 py-1.5 hover:bg-gray-100 rounded-lg transition h-8">
                    <Checkbox
                      :modelValue="!getMappedExcelColumn(field.name)"
                      @update:modelValue="() => toggleSkipField(field.name)"
                      :binary="true"
                      inputId="`skip-${field.name}`"
                    />
                    <span class="text-xs text-gray-600 group-hover:text-gray-900 font-medium whitespace-nowrap">Skip</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Validation Errors -->
        <div v-if="validationErrors.length > 0" class="bg-yellow-50 border border-yellow-200 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-yellow-800 mb-2">
            <i class="pi pi-exclamation-triangle mr-2"></i>
            Mapping Warnings
          </h3>
          <ul class="list-disc list-inside text-sm text-yellow-700 space-y-1">
            <li v-for="(err, index) in validationErrors" :key="index">{{ err }}</li>
          </ul>
        </div>

        <!-- Transformation Warnings -->
        <div v-if="transformationWarnings.length > 0" class="bg-orange-50 border border-orange-300 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-orange-900 mb-2">
            <i class="pi pi-exclamation-triangle mr-2"></i>
            Date Transformation Warning
          </h3>
          <ul class="list-disc list-inside text-sm text-orange-800 space-y-1">
            <li v-for="(warning, index) in transformationWarnings" :key="index">{{ warning }}</li>
          </ul>
        </div>

        <!-- Server Validation Errors -->
        <div v-if="serverValidationErrors.length > 0" class="bg-red-50 border border-red-200 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-red-800 mb-2">
            <i class="pi pi-times-circle mr-2"></i>
            Data Validation Errors
          </h3>
          <ul class="list-disc list-inside text-sm text-red-700 space-y-1 max-h-60 overflow-y-auto">
            <li v-for="(err, index) in serverValidationErrors" :key="index">{{ err }}</li>
          </ul>
        </div>

        <!-- Data Preview with Highlighting -->
        <div v-if="showPreview" class="mb-6 bg-gray-50 border border-gray-300 rounded-md p-4">
          <div class="flex justify-between items-center mb-3">
            <h3 class="text-lg font-semibold">Data Preview with Validation</h3>
            <button
              @click="showPreview = !showPreview"
              class="text-gray-600 hover:text-gray-800"
            >
              <i class="pi pi-times"></i>
            </button>
          </div>

          <div class="overflow-x-auto max-h-96 overflow-y-auto">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="sticky top-0 bg-gray-100">
                <tr>
                  <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase">#</th>
                  <th
                    v-for="(header, idx) in store.excelHeaders"
                    :key="idx"
                    class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase"
                  >
                    {{ header }}
                    <div v-if="localMapping[header]" class="text-xs font-normal text-blue-600">
                      → {{ localMapping[header] }}
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="(row, rowIdx) in previewData" :key="rowIdx">
                  <td class="px-3 py-2 text-sm text-gray-500">{{ rowIdx + 1 }}</td>
                  <td
                    v-for="(cell, cellIdx) in row"
                    :key="cellIdx"
                    class="px-3 py-2 text-sm"
                    :class="getCellValidationClass(rowIdx, cellIdx)"
                    :title="getCellValidationMessage(rowIdx, cellIdx)"
                  >
                    <div class="flex items-center gap-2">
                      <span>{{ formatCellValue(cell) }}</span>
                      <i
                        v-if="getCellValidationIcon(rowIdx, cellIdx)"
                        :class="`pi ${getCellValidationIcon(rowIdx, cellIdx)} text-xs`"
                      ></i>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-4 flex-wrap">
          <button
            @click="generateSQL"
            :disabled="loading || !canGenerate"
            class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-md transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <i class="pi pi-download"></i>
            Generate & Download SQL
          </button>

          <button
            @click="showPreview = !showPreview"
            class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-md transition flex items-center gap-2"
          >
            <i class="pi pi-eye"></i>
            {{ showPreview ? 'Hide' : 'Show' }} Preview
          </button>
        </div>

        <!-- Loading Indicator -->
        <div v-if="loading" class="flex items-center justify-center py-8">
          <i class="pi pi-spin pi-spinner text-4xl text-blue-600"></i>
        </div>

        <!-- Error Display -->
        <div v-if="error" class="mt-4 bg-red-50 border border-red-200 rounded-md p-4">
          <p class="text-red-700">{{ error }}</p>
        </div>
      </div>
    </div>

    <!-- Transform Preview Dialog -->
    <div v-if="transformPreviewColumn" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="transformPreviewColumn = null">
      <div class="bg-white rounded-lg p-6 max-w-3xl w-full max-h-[80vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-semibold">Transformation Preview: {{ transformPreviewColumn }}</h3>
          <button @click="transformPreviewColumn = null" class="text-gray-600 hover:text-gray-800">
            <i class="pi pi-times text-xl"></i>
          </button>
        </div>

        <div class="mb-4">
          <p class="text-sm text-gray-600">
            Transformation: <strong>{{ transformations[fieldTransformations[transformPreviewColumn]]?.label }}</strong>
          </p>
          <p class="text-sm text-gray-600">
            {{ transformations[fieldTransformations[transformPreviewColumn]]?.description }}
          </p>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-300">
            <thead>
              <tr>
                <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase">Original</th>
                <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase">Transformed</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="(preview, idx) in getTransformPreview(transformPreviewColumn)" :key="idx">
                <td class="px-3 py-2 text-sm">{{ preview.original }}</td>
                <td class="px-3 py-2 text-sm font-medium text-blue-600">{{ preview.transformed }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Clear Mappings Confirmation Dialog -->
    <Dialog
      v-model:visible="showClearDialog"
      header="Confirm Clear All"
      :modal="true"
      :style="{ width: '30rem' }"
    >
      <div class="flex items-start gap-3">
        <i class="pi pi-exclamation-triangle text-3xl text-orange-500"></i>
        <div>
          <p class="text-gray-700 mb-2">Are you sure you want to clear all column mappings?</p>
          <p class="text-sm text-gray-600">This will remove all mappings and transformations.</p>
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
import { useMappingStore, Field } from '../store/mappingStore'
import { useAuthStore } from '../store/authStore'
import { useImportStore } from '../store/importStore'
import { transformations, applyTransformation, suggestTransformations, hasYearOnlyValues, type TransformationType } from '../utils/transformations'
import { validateDataset, validateCell, getCellClass, getValidationIcon, type ValidationResult } from '../utils/dataValidation'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import Select from 'primevue/select'
import Checkbox from 'primevue/checkbox'

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

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

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
 * Get transformation options for a field (legacy - returns array of types)
 */
function getTransformationOptionsForField(field: Field): TransformationType[] {
  const excelCol = getMappedExcelColumn(field.name)
  if (!excelCol) return ['none']

  const columnIndex = store.excelHeaders.indexOf(excelCol)
  const columnData = store.excelData.map(row => row[columnIndex])

  return suggestTransformations(columnData, field.type)
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
function onTransformationChange(fieldName: string) {
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
          newRow[idx] = applyTransformation(row[idx], transform)
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
          newRow[idx] = applyTransformation(row[idx], transform)
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
            newRow[idx] = applyTransformation(row[idx], transform)
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
