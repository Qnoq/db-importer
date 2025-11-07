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
        <!-- Auto-mapping Success Banner -->
        <div v-if="autoMappingStats" class="mb-4 bg-green-50 border border-green-200 rounded-md p-4">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0">
              <i class="pi pi-check-circle text-green-600 text-2xl"></i>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-green-900 mb-1">
                Auto-mapping successful!
              </h3>
              <p class="text-sm text-green-800">
                The system automatically mapped <strong>{{ autoMappingStats.mapped }} of {{ autoMappingStats.total }} columns</strong>
                by comparing your Excel column names with database field names.
              </p>
              <p class="text-sm text-green-700 mt-2">
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
                @click="clearAllMappings"
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
              :class="getMappedExcelColumn(field.name) ? 'border-green-300 bg-green-50' : 'border-gray-200'"
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
                      </div>
                      <p class="text-xs text-gray-500">
                        {{ field.type }}
                      </p>
                    </div>
                  </div>
                </div>

                <!-- Arrow -->
                <div class="md:col-span-1 flex justify-center">
                  <i class="pi pi-arrow-left text-2xl" :class="getMappedExcelColumn(field.name) ? 'text-green-600' : 'text-gray-300'"></i>
                </div>

                <!-- Excel Column (Source) -->
                <div class="md:col-span-4">
                  <label class="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
                    Excel Column
                  </label>
                  <select
                    :value="getMappedExcelColumn(field.name)"
                    @change="onFieldMappingChange(field.name, ($event.target as HTMLSelectElement).value)"
                    class="block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
                  >
                    <option value="">-- Skip this field --</option>
                    <option
                      v-for="excelHeader in store.excelHeaders"
                      :key="excelHeader"
                      :value="excelHeader"
                    >
                      {{ excelHeader }}
                    </option>
                  </select>
                  <p v-if="getMappedExcelColumn(field.name)" class="text-xs text-gray-500 mt-1">
                    Sample: {{ getSampleValue(getMappedExcelColumn(field.name)!) }}
                  </p>
                </div>

                <!-- Transformation -->
                <div class="md:col-span-3">
                  <label class="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
                    Transformation
                  </label>
                  <select
                    v-model="fieldTransformations[field.name]"
                    @change="onTransformationChange(field.name)"
                    :disabled="!getMappedExcelColumn(field.name)"
                    class="block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:text-gray-400"
                  >
                    <option
                      v-for="transType in getTransformationOptionsForField(field)"
                      :key="transType"
                      :value="transType"
                    >
                      {{ transformations[transType].label }}
                    </option>
                  </select>
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
                    <input
                      type="checkbox"
                      :checked="!getMappedExcelColumn(field.name)"
                      @change="toggleSkipField(field.name)"
                      class="w-4 h-4 text-orange-600 border-gray-300 rounded focus:ring-orange-500 cursor-pointer"
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
        <div v-if="transformationWarnings.length > 0" class="bg-blue-50 border border-blue-200 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-blue-800 mb-2">
            <i class="pi pi-info-circle mr-2"></i>
            Transformation Info
          </h3>
          <ul class="list-disc list-inside text-sm text-blue-700 space-y-1">
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import StepperNav from '../components/StepperNav.vue'
import { useMappingStore, Field } from '../store/mappingStore'
import { transformations, applyTransformation, suggestTransformations, hasYearOnlyValues, type TransformationType } from '../utils/transformations'
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
const showTemplateDialog = ref(false)
const showSaveTemplateDialog = ref(false)
const transformPreviewColumn = ref<string | null>(null)
const autoMappingStats = ref<{
  total: number
  mapped: number
  skipped: number
} | null>(null)

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
function clearAllMappings() {
  if (confirm('Are you sure you want to clear all column mappings?')) {
    localMapping.value = {}
    columnTransformations.value = {}
    updateMapping()
  }
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
 * Get transformation options for a field
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
    fieldTransformations.value,
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
    fieldTransformations.value = { ...template.transformations }
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
