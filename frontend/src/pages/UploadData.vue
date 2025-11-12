<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="shadow-lg rounded-xl p-8 border transition-colors duration-200" style="background: var(--p-surface-0); border-color: var(--p-surface-border)">
      <div class="mb-8">
        <h2 class="text-3xl font-bold mb-2" style="color: var(--p-text-color)">Upload Data File</h2>
        <p style="color: var(--p-text-muted-color)">
          Upload an Excel or CSV file containing your data
        </p>
      </div>

      <div v-if="!store.hasSelectedTable" class="bg-yellow-50 dark:bg-yellow-950/20 border-l-4 border-yellow-500 dark:border-yellow-400 rounded-lg p-4 flex items-start">
        <i class="pi pi-exclamation-triangle text-yellow-500 dark:text-yellow-400 text-xl mr-3 mt-0.5"></i>
        <div>
          <p class="font-medium text-yellow-800 dark:text-yellow-300">No table selected</p>
          <p class="text-yellow-700 dark:text-yellow-400 text-sm mt-1">Please select a table first before uploading data.</p>
        </div>
      </div>

      <div v-else>
        <!-- Selected Table Info -->
        <div class="mb-6 bg-neon-green-50 dark:bg-neon-green-950/20 border-l-4 border-neon-green-500 dark:border-neon-green-400 rounded-lg p-4 flex items-start">
          <i class="pi pi-info-circle text-neon-green-500 dark:text-neon-green-400 text-xl mr-3 mt-0.5"></i>
          <div class="flex-1">
            <p class="font-medium text-neon-green-800 dark:text-neon-green-300">Target table selected</p>
            <p class="text-neon-green-700 dark:text-neon-green-400 text-sm mt-1">
              Importing to <strong>{{ store.selectedTable?.name }}</strong> ({{ store.selectedTable?.fields.length }} columns)
            </p>
          </div>
        </div>

        <!-- Pro Tip: Column Naming -->
        <div class="mb-6 bg-neon-green-50 dark:bg-neon-green-950/20 border-l-4 border-neon-green-500 dark:border-neon-green-400 rounded-lg p-4">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0">
              <i class="pi pi-lightbulb text-neon-green-600 dark:text-neon-green-400 text-xl"></i>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-neon-green-900 dark:text-neon-green-300 mb-1">💡 Pro Tip: Name Your Excel Columns</h3>
              <p class="text-sm text-neon-green-800 dark:text-neon-green-300 mb-2">
                For <strong>automatic column mapping</strong>, name your Excel headers to match your database field names.
              </p>
              <div class="text-sm text-neon-green-700 dark:text-neon-green-300 bg-neon-green-100 dark:bg-neon-green-900/30 rounded px-3 py-2">
                <strong>Example:</strong> If your database has <code class="bg-white dark:bg-gray-800 px-1.5 py-0.5 rounded text-xs">sit_name</code>,
                <code class="bg-white dark:bg-gray-800 px-1.5 py-0.5 rounded text-xs">sit_address</code>,
                <code class="bg-white dark:bg-gray-800 px-1.5 py-0.5 rounded text-xs">sit_zipCode</code>
                → Use the same names in your Excel first row!
              </div>
              <p class="text-sm text-neon-green-700 dark:text-neon-green-400 mt-2">
                ✅ The system will auto-detect and map matching columns, saving you time!
              </p>
            </div>
          </div>
        </div>

        <!-- Upload Area -->
        <div class="mb-6">
          <label class="block text-sm font-medium mb-3" style="color: var(--p-text-color)">
            Data File
          </label>
          <div
            class="border-2 border-dashed rounded-xl p-8 text-center hover:border-neon-green-400 dark:hover:border-neon-green-500 transition cursor-pointer"
            style="border-color: var(--p-surface-border); background: var(--p-surface-50)"
            @click="fileInput?.click()"
            @dragover.prevent
            @drop.prevent="handleDrop"
          >
            <div class="flex flex-col items-center">
              <div class="w-16 h-16 bg-neon-green-100 dark:bg-neon-green-900/30 rounded-full flex items-center justify-center mb-4">
                <i class="pi pi-file-excel text-neon-green-600 dark:text-neon-green-400 text-3xl"></i>
              </div>
              <p class="text-lg font-medium mb-1" style="color: var(--p-text-color)">
                Drop your data file here, or click to browse
              </p>
              <p class="text-sm" style="color: var(--p-text-muted-color)">
                Supports Excel (.xlsx, .xls) and CSV files
              </p>
              <p class="text-xs mt-2" style="color: var(--p-text-muted-color)">
                Maximum file size: 50MB
              </p>
            </div>
          </div>
          <input
            type="file"
            accept=".xlsx,.xls,.csv"
            @change="handleFileUpload"
            ref="fileInput"
            class="hidden"
          />
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="flex flex-col items-center justify-center py-12">
          <i class="pi pi-spin pi-spinner text-5xl text-neon-green-600 dark:text-neon-green-400 mb-4"></i>
          <p class="font-medium" style="color: var(--p-text-color)">Parsing your data file...</p>
          <p class="text-sm mt-2" style="color: var(--p-text-muted-color)">This may take a few seconds</p>
        </div>

        <!-- Error State -->
        <div v-if="error" class="bg-red-50 dark:bg-red-950/20 border-l-4 border-red-500 dark:border-red-400 rounded-lg p-4 mb-4 flex items-start">
          <i class="pi pi-exclamation-circle text-red-500 dark:text-red-400 text-xl mr-3 mt-0.5"></i>
          <div>
            <p class="font-medium text-red-800 dark:text-red-300">Upload Failed</p>
            <p class="text-red-700 dark:text-red-400 text-sm mt-1">{{ error }}</p>
          </div>
        </div>

        <!-- Success State with Data Preview -->
        <div v-if="store.hasExcelData && !loading" class="space-y-6">
          <!-- Success Banner -->
          <div class="bg-neon-green-50 dark:bg-neon-green-950/20 border-l-4 border-neon-green-500 dark:border-neon-green-400 rounded-lg p-4 flex items-start">
            <i class="pi pi-check-circle text-neon-green-500 dark:text-neon-green-400 text-xl mr-3 mt-0.5"></i>
            <div class="flex-1">
              <p class="font-medium text-neon-green-800 dark:text-neon-green-300">Data loaded successfully!</p>
              <p class="text-neon-green-700 dark:text-neon-green-400 text-sm mt-1">
                Found {{ store.excelData.length }} rows with {{ store.excelHeaders.length }} columns
              </p>
            </div>
          </div>

          <!-- Data Preview -->
          <div>
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold" style="color: var(--p-text-color)">Data Preview</h3>
              <span class="px-3 py-1 bg-neon-green-100 dark:bg-neon-green-900/30 text-neon-green-800 dark:text-neon-green-300 rounded-full text-sm font-medium">
                {{ store.excelData.length }} rows
              </span>
            </div>

            <div class="overflow-x-auto bg-gradient-to-br from-gray-50 to-neon-green-50 dark:from-gray-800 dark:to-gray-900 rounded-lg p-4 border" style="border-color: var(--p-surface-border)">
              <table class="min-w-full divide-y" style="border-color: var(--p-surface-border)">
                <thead>
                  <tr>
                    <th class="sticky left-0 px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider z-10" style="color: var(--p-text-color); background: var(--p-surface-100)">
                      #
                    </th>
                    <th
                      v-for="header in store.excelHeaders"
                      :key="header"
                      class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider"
                      style="color: var(--p-text-color); background: var(--p-surface-100)"
                    >
                      {{ header }}
                    </th>
                  </tr>
                </thead>
                <tbody class="divide-y" style="background: var(--p-surface-0); border-color: var(--p-surface-border)">
                  <tr v-for="(row, index) in store.excelData.slice(0, 10)" :key="index" class="hover:bg-neon-green-50 dark:hover:bg-neon-green-950/20 transition">
                    <td class="sticky left-0 px-4 py-3 text-sm font-medium" style="color: var(--p-text-muted-color); background: var(--p-surface-0)">{{ index + 1 }}</td>
                    <td
                      v-for="(cell, cellIndex) in row"
                      :key="cellIndex"
                      class="px-4 py-3 text-sm whitespace-nowrap"
                      style="color: var(--p-text-color)"
                    >
                      {{ cell }}
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-if="store.excelData.length > 10" class="text-sm mt-4 text-center italic" style="color: var(--p-text-muted-color)">
                Showing first 10 rows of {{ store.excelData.length }} total rows
              </p>
            </div>
          </div>

          <!-- Continue Button -->
          <div class="flex items-center justify-between pt-6 border-t" style="border-color: var(--p-surface-border)">
            <button
              @click="fileInput?.click()"
              class="text-neon-green-600 dark:text-neon-green-400 hover:text-neon-green-700 dark:hover:text-neon-green-300 font-medium flex items-center transition"
            >
              <i class="pi pi-refresh mr-2"></i>
              Upload a different file
            </button>
            <button
              @click="goToMapping"
              class="bg-neon-green-600 hover:bg-neon-green-700 dark:bg-neon-green-500 dark:hover:bg-neon-green-600 text-white font-semibold py-3 px-8 rounded-lg transition shadow-md hover:shadow-lg flex items-center"
            >
              Continue to Column Mapping
              <i class="pi pi-arrow-right ml-2"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import StepperNav from '../components/StepperNav.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')

function processFile(file: File) {
  if (!file) return

  error.value = ''
  loading.value = true

  const reader = new FileReader()

  reader.onload = (e) => {
    try {
      const data = e.target?.result
      const workbook = XLSX.read(data, { type: 'array' })

      // Get first sheet
      const firstSheetName = workbook.SheetNames[0]
      const worksheet = workbook.Sheets[firstSheetName]

      // Convert to JSON
      const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 }) as any[][]

      if (jsonData.length === 0) {
        throw new Error('File is empty')
      }

      // First row is headers
      const headers = jsonData[0].map(h => String(h))
      const rows = jsonData.slice(1).filter(row => row.some(cell => cell !== null && cell !== undefined && cell !== ''))

      store.setExcelData(headers, rows)
      loading.value = false
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to parse file'
      loading.value = false
    }
  }

  reader.onerror = () => {
    error.value = 'Failed to read file'
    loading.value = false
  }

  reader.readAsArrayBuffer(file)
}

function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    processFile(file)
  }
}

function handleDrop(event: DragEvent) {
  const file = event.dataTransfer?.files?.[0]
  if (file && (file.name.endsWith('.xlsx') || file.name.endsWith('.xls') || file.name.endsWith('.csv'))) {
    processFile(file)
  } else {
    error.value = 'Please upload a valid Excel or CSV file'
  }
}

function goToMapping() {
  router.push('/mapping')
}
</script>
