<template>
  <div class="px-4 py-6">
    <div class="bg-white shadow rounded-lg p-6">
      <!-- Header -->
      <div class="flex justify-between items-center mb-4">
        <div>
          <h2 class="text-2xl font-semibold">Step 4: Map Columns</h2>
          <p class="text-gray-600 mt-1">
            Match your Excel/CSV columns to database fields and apply transformations
          </p>
        </div>
        <button
          @click="showTemplateDialog = true"
          class="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-4 rounded-md transition flex items-center gap-2"
        >
          <i class="pi pi-bookmark"></i>
          Templates
        </button>
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
        <div class="space-y-4 mb-6">
          <div
            v-for="(header, index) in store.excelHeaders"
            :key="index"
            class="border rounded-lg p-4"
          >
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <!-- Column Mapping -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  Excel Column: {{ header }}
                </label>
                <select
                  v-model="localMapping[header]"
                  @change="onMappingChange"
                  class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="">-- Skip this column --</option>
                  <option
                    v-for="field in store.selectedTable?.fields"
                    :key="field.name"
                    :value="field.name"
                  >
                    {{ field.name }} ({{ field.type }}){{ field.nullable ? '' : ' - NOT NULL' }}
                  </option>
                </select>
              </div>

              <!-- Transformation -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  Transformation
                </label>
                <select
                  v-model="columnTransformations[header]"
                  @change="onTransformationChange(header)"
                  :disabled="!localMapping[header]"
                  class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
                >
                  <option
                    v-for="transType in getTransformationOptions(header)"
                    :key="transType"
                    :value="transType"
                  >
                    {{ transformations[transType].label }}
                  </option>
                </select>
              </div>

              <!-- Status Indicator -->
              <div class="flex items-center justify-between">
                <div v-if="localMapping[header]" class="flex items-center gap-2">
                  <i class="pi pi-check-circle text-green-600 text-2xl"></i>
                  <span class="text-sm text-gray-600">
                    Mapped to {{ localMapping[header] }}
                  </span>
                </div>
                <button
                  v-if="columnTransformations[header] && columnTransformations[header] !== 'none'"
                  @click="showTransformPreview(header)"
                  class="text-blue-600 hover:text-blue-700 text-sm font-medium"
                >
                  <i class="pi pi-eye mr-1"></i>
                  Preview
                </button>
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
            @click="autoMap"
            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md transition flex items-center gap-2"
          >
            <i class="pi pi-bolt"></i>
            Auto-map
          </button>

          <button
            @click="showPreview = !showPreview"
            class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-md transition flex items-center gap-2"
          >
            <i class="pi pi-eye"></i>
            {{ showPreview ? 'Hide' : 'Show' }} Preview
          </button>

          <button
            @click="validateData"
            class="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-4 rounded-md transition flex items-center gap-2"
          >
            <i class="pi pi-shield"></i>
            Validate Data
          </button>

          <button
            @click="showSaveTemplateDialog = true"
            :disabled="!canGenerate"
            class="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-4 rounded-md transition disabled:opacity-50 flex items-center gap-2"
          >
            <i class="pi pi-save"></i>
            Save as Template
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

    <!-- Template Dialog -->
    <div v-if="showTemplateDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="showTemplateDialog = false">
      <div class="bg-white rounded-lg p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-semibold">Mapping Templates</h3>
          <button @click="showTemplateDialog = false" class="text-gray-600 hover:text-gray-800">
            <i class="pi pi-times text-xl"></i>
          </button>
        </div>

        <div v-if="availableTemplates.length === 0" class="text-center py-8 text-gray-500">
          <i class="pi pi-inbox text-4xl mb-2"></i>
          <p>No templates saved yet</p>
          <p class="text-sm">Create your first template by mapping columns and clicking "Save as Template"</p>
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="template in availableTemplates"
            :key="template.id"
            class="border rounded-lg p-4 hover:bg-gray-50 cursor-pointer transition"
            @click="applyTemplate(template)"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <h4 class="font-semibold">{{ template.name }}</h4>
                <p v-if="template.description" class="text-sm text-gray-600 mt-1">{{ template.description }}</p>
                <div class="flex gap-4 text-xs text-gray-500 mt-2">
                  <span><i class="pi pi-table mr-1"></i>{{ template.tableName }}</span>
                  <span><i class="pi pi-calendar mr-1"></i>{{ formatDate(template.updatedAt) }}</span>
                  <span><i class="pi pi-arrows-h mr-1"></i>{{ Object.keys(template.mapping).length }} mappings</span>
                </div>
              </div>
              <button
                @click.stop="deleteTemplateConfirm(template.id)"
                class="text-red-600 hover:text-red-700 p-2"
              >
                <i class="pi pi-trash"></i>
              </button>
            </div>
          </div>
        </div>

        <div class="mt-6 flex gap-2">
          <button
            @click="exportTemplatesFile"
            class="flex-1 bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-md transition"
          >
            <i class="pi pi-download mr-2"></i>
            Export All
          </button>
          <button
            @click="$refs.importTemplateInput.click()"
            class="flex-1 bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-md transition"
          >
            <i class="pi pi-upload mr-2"></i>
            Import
          </button>
          <input
            ref="importTemplateInput"
            type="file"
            accept=".json"
            @change="importTemplatesFile"
            class="hidden"
          />
        </div>
      </div>
    </div>

    <!-- Save Template Dialog -->
    <div v-if="showSaveTemplateDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click.self="showSaveTemplateDialog = false">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h3 class="text-xl font-semibold mb-4">Save Mapping Template</h3>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Template Name</label>
            <input
              v-model="newTemplateName"
              type="text"
              placeholder="e.g., Customer Import"
              class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Description (optional)</label>
            <textarea
              v-model="newTemplateDescription"
              placeholder="Describe this template..."
              rows="3"
              class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            ></textarea>
          </div>

          <div class="flex gap-2">
            <button
              @click="saveTemplate"
              :disabled="!newTemplateName.trim()"
              class="flex-1 bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md transition disabled:opacity-50"
            >
              Save
            </button>
            <button
              @click="showSaveTemplateDialog = false; newTemplateName = ''; newTemplateDescription = ''"
              class="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-800 py-2 px-4 rounded-md transition"
            >
              Cancel
            </button>
          </div>
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
            Transformation: <strong>{{ transformations[columnTransformations[transformPreviewColumn]]?.label }}</strong>
          </p>
          <p class="text-sm text-gray-600">
            {{ transformations[columnTransformations[transformPreviewColumn]]?.description }}
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore, Field } from '../store/mappingStore'
import { transformations, applyTransformation, suggestTransformations, type TransformationType } from '../utils/transformations'
import { validateDataset, validateCell, getCellClass, getValidationIcon, type ValidationResult } from '../utils/dataValidation'
import {
  loadTemplates,
  createTemplate,
  deleteTemplate,
  getTemplatesForTable,
  exportTemplates,
  importTemplates,
  type MappingTemplate
} from '../utils/mappingTemplates'

const router = useRouter()
const store = useMappingStore()

// Mapping state
const localMapping = ref<Record<string, string>>({})
const columnTransformations = ref<Record<string, TransformationType>>({})

// UI state
const loading = ref(false)
const error = ref('')
const serverValidationErrors = ref<string[]>([])
const showPreview = ref(false)
const showTemplateDialog = ref(false)
const showSaveTemplateDialog = ref(false)
const transformPreviewColumn = ref<string | null>(null)

// Template state
const newTemplateName = ref('')
const newTemplateDescription = ref('')
const availableTemplates = ref<MappingTemplate[]>([])

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
  loadAvailableTemplates()
  validateData()
})

/**
 * Load templates for current table
 */
function loadAvailableTemplates() {
  if (!store.selectedTable) return
  availableTemplates.value = getTemplatesForTable(store.selectedTable.name)
}

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
 * Auto-map columns with Levenshtein
 */
function autoMap() {
  const mapping: Record<string, string> = {}
  const transformsToApply: Record<string, TransformationType> = {}

  for (const header of store.excelHeaders) {
    const normalizedHeader = header.toLowerCase().trim().replace(/[_\s-]/g, '')

    let bestMatch: Field | null = null
    let bestScore = 0

    for (const field of store.selectedTable?.fields || []) {
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

      // Get column data for suggestions
      const columnIndex = store.excelHeaders.indexOf(header)
      const columnData = store.excelData.map(row => row[columnIndex])

      // Suggest transformations
      const suggestions = suggestTransformations(columnData, bestMatch.type)
      if (suggestions.length > 1) {
        transformsToApply[header] = suggestions[1] // First non-'none' suggestion
      } else {
        transformsToApply[header] = 'none'
      }
    } else {
      transformsToApply[header] = 'none'
    }
  }

  localMapping.value = mapping
  columnTransformations.value = transformsToApply
  updateMapping()
}

/**
 * Update mapping in store
 */
function updateMapping() {
  store.setMapping(localMapping.value)
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
function onTransformationChange(header: string) {
  validateData()
}

/**
 * Get transformation options for a column
 */
function getTransformationOptions(header: string): TransformationType[] {
  const dbColumn = localMapping.value[header]
  if (!dbColumn) return ['none']

  const field = store.selectedTable?.fields.find(f => f.name === dbColumn)
  if (!field) return ['none']

  const columnIndex = store.excelHeaders.indexOf(header)
  const columnData = store.excelData.map(row => row[columnIndex])

  return suggestTransformations(columnData, field.type)
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
      const transform = columnTransformations.value[header]
      if (transform && transform !== 'none') {
        newRow[idx] = applyTransformation(row[idx], transform)
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
      const transform = columnTransformations.value[header]
      if (transform && transform !== 'none') {
        newRow[idx] = applyTransformation(row[idx], transform)
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
 * Can generate SQL
 */
const canGenerate = computed(() => {
  return Object.values(localMapping.value).some(v => v !== '')
})

/**
 * Save template
 */
function saveTemplate() {
  if (!store.selectedTable || !newTemplateName.value.trim()) return

  createTemplate(
    newTemplateName.value.trim(),
    store.selectedTable.name,
    localMapping.value,
    columnTransformations.value,
    newTemplateDescription.value.trim() || undefined
  )

  loadAvailableTemplates()
  showSaveTemplateDialog.value = false
  newTemplateName.value = ''
  newTemplateDescription.value = ''
}

/**
 * Apply template
 */
function applyTemplate(template: MappingTemplate) {
  localMapping.value = { ...template.mapping }
  if (template.transformations) {
    columnTransformations.value = { ...template.transformations }
  }
  updateMapping()
  validateData()
  showTemplateDialog.value = false
}

/**
 * Delete template
 */
function deleteTemplateConfirm(id: string) {
  if (confirm('Are you sure you want to delete this template?')) {
    deleteTemplate(id)
    loadAvailableTemplates()
  }
}

/**
 * Export templates
 */
function exportTemplatesFile() {
  const json = exportTemplates()
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `mapping-templates-${Date.now()}.json`
  a.click()
  URL.revokeObjectURL(url)
}

/**
 * Import templates
 */
function importTemplatesFile(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    const json = e.target?.result as string
    const result = importTemplates(json)

    if (result.success) {
      alert(`Successfully imported ${result.imported} template(s)`)
      loadAvailableTemplates()
    } else {
      alert(`Import failed:\n${result.errors.join('\n')}`)
    }
  }
  reader.readAsText(file)

  // Reset input
  target.value = ''
}

/**
 * Show transformation preview
 */
function showTransformPreview(header: string) {
  transformPreviewColumn.value = header
}

/**
 * Get transformation preview data
 */
function getTransformPreview(header: string) {
  const columnIndex = store.excelHeaders.indexOf(header)
  const transform = columnTransformations.value[header]

  return store.excelData.slice(0, 10).map(row => ({
    original: formatCellValue(row[columnIndex]),
    transformed: formatCellValue(applyTransformation(row[columnIndex], transform))
  }))
}

/**
 * Format date for display
 */
function formatDate(isoString: string): string {
  const date = new Date(isoString)
  return date.toLocaleDateString()
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
        const transform = columnTransformations.value[header]
        if (transform && transform !== 'none') {
          newRow[idx] = applyTransformation(row[idx], transform)
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
    a.href = url
    a.download = `import_${store.selectedTable.name}_${Date.now()}.sql`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)

    loading.value = false
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'An error occurred'
    loading.value = false
  }
}
</script>
