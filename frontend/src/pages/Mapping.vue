<template>
  <div class="px-4 py-6">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-2xl font-semibold mb-4">Step 4: Map Columns</h2>
      <p class="text-gray-600 mb-6">
        Match your Excel/CSV columns to database fields
      </p>

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
        <div class="mb-4 bg-blue-50 border border-blue-200 rounded-md p-4">
          <p class="text-sm text-blue-800">
            <i class="pi pi-info-circle mr-2"></i>
            Target table: <strong>{{ store.selectedTable?.name }}</strong> |
            Data rows: <strong>{{ store.excelData.length }}</strong>
          </p>
        </div>

        <div class="space-y-4 mb-6">
          <div
            v-for="(header, index) in store.excelHeaders"
            :key="index"
            class="border rounded-lg p-4"
          >
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  Excel Column: {{ header }}
                </label>
                <select
                  v-model="localMapping[header]"
                  @change="updateMapping"
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
              <div class="ml-4">
                <i
                  v-if="localMapping[header]"
                  class="pi pi-check-circle text-green-600 text-2xl"
                ></i>
              </div>
            </div>
          </div>
        </div>

        <div v-if="validationErrors.length > 0" class="bg-yellow-50 border border-yellow-200 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-yellow-800 mb-2">
            <i class="pi pi-exclamation-triangle mr-2"></i>
            Warnings
          </h3>
          <ul class="list-disc list-inside text-sm text-yellow-700 space-y-1">
            <li v-for="(err, index) in validationErrors" :key="index">{{ err }}</li>
          </ul>
        </div>

        <!-- Server validation errors -->
        <div v-if="serverValidationErrors.length > 0" class="bg-red-50 border border-red-200 rounded-md p-4 mb-4">
          <h3 class="font-semibold text-red-800 mb-2">
            <i class="pi pi-times-circle mr-2"></i>
            Validation Errors
          </h3>
          <ul class="list-disc list-inside text-sm text-red-700 space-y-1 max-h-60 overflow-y-auto">
            <li v-for="(err, index) in serverValidationErrors" :key="index">{{ err }}</li>
          </ul>
        </div>

        <div class="flex gap-4">
          <button
            @click="generateSQL"
            :disabled="loading || !canGenerate"
            class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-md transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i class="pi pi-download mr-2"></i>
            Generate & Download SQL
          </button>

          <button
            @click="autoMap"
            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md transition"
          >
            <i class="pi pi-bolt mr-2"></i>
            Auto-map
          </button>
        </div>

        <div v-if="loading" class="flex items-center justify-center py-8">
          <i class="pi pi-spin pi-spinner text-4xl text-blue-600"></i>
        </div>

        <div v-if="error" class="mt-4 bg-red-50 border border-red-200 rounded-md p-4">
          <p class="text-red-700">{{ error }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore, Field } from '../store/mappingStore'

const router = useRouter()
const store = useMappingStore()
const localMapping = ref<Record<string, string>>({})
const loading = ref(false)
const error = ref('')
const serverValidationErrors = ref<string[]>([])

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

onMounted(() => {
  // Initialize auto-mapping
  autoMap()
})

// Levenshtein distance algorithm for better string matching
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
          matrix[i - 1][j - 1] + 1, // substitution
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j] + 1      // deletion
        )
      }
    }
  }

  return matrix[len1][len2]
}

// Calculate similarity score (0 to 1, higher is better)
function calculateSimilarity(str1: string, str2: string): number {
  const distance = levenshteinDistance(str1, str2)
  const maxLen = Math.max(str1.length, str2.length)
  return 1 - distance / maxLen
}

function autoMap() {
  const mapping: Record<string, string> = {}

  for (const header of store.excelHeaders) {
    const normalizedHeader = header.toLowerCase().trim().replace(/[_\s-]/g, '')

    let bestMatch: Field | null = null
    let bestScore = 0

    // Find best match using multiple strategies
    for (const field of store.selectedTable?.fields || []) {
      const normalizedField = field.name.toLowerCase().trim().replace(/[_\s-]/g, '')

      let score = 0

      // Exact match (highest priority)
      if (normalizedField === normalizedHeader) {
        score = 1.0
      }
      // Contains match
      else if (normalizedField.includes(normalizedHeader) || normalizedHeader.includes(normalizedField)) {
        score = 0.8
      }
      // Levenshtein similarity
      else {
        const similarity = calculateSimilarity(normalizedHeader, normalizedField)
        // Only consider if similarity is above threshold
        if (similarity > 0.6) {
          score = similarity * 0.7 // Lower weight for fuzzy matches
        }
      }

      if (score > bestScore) {
        bestScore = score
        bestMatch = field
      }
    }

    // Only map if we found a reasonably good match
    if (bestMatch && bestScore > 0.6) {
      mapping[header] = bestMatch.name
    }
  }

  localMapping.value = mapping
  updateMapping()
}

function updateMapping() {
  store.setMapping(localMapping.value)
}

const validationErrors = computed(() => {
  const errors: string[] = []

  if (!store.selectedTable) return errors

  // Check for NOT NULL fields that aren't mapped
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

const canGenerate = computed(() => {
  return Object.values(localMapping.value).some(v => v !== '')
})

interface FieldInfo {
  name: string
  type: string
  nullable: boolean
}

async function generateSQL() {
  if (!store.selectedTable) return

  error.value = ''
  serverValidationErrors.value = []
  loading.value = true

  try {
    // Build ordered rows based on mapping
    const mappedRows: unknown[][] = []

    for (const row of store.excelData) {
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
        // Validation errors
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
