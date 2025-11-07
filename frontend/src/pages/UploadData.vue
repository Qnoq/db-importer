<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="bg-white shadow-lg rounded-xl p-8 border border-gray-200">
      <div class="mb-8">
        <h2 class="text-3xl font-bold text-gray-900 mb-2">Upload Data File</h2>
        <p class="text-gray-600">
          Upload an Excel or CSV file containing your data
        </p>
      </div>

      <div v-if="!store.hasSelectedTable" class="bg-yellow-50 border-l-4 border-yellow-500 rounded-lg p-4 flex items-start">
        <i class="pi pi-exclamation-triangle text-yellow-500 text-xl mr-3 mt-0.5"></i>
        <div>
          <p class="font-medium text-yellow-800">No table selected</p>
          <p class="text-yellow-700 text-sm mt-1">Please select a table first before uploading data.</p>
        </div>
      </div>

      <div v-else>
        <!-- Selected Table Info -->
        <div class="mb-6 bg-blue-50 border-l-4 border-blue-500 rounded-lg p-4 flex items-start">
          <i class="pi pi-info-circle text-blue-500 text-xl mr-3 mt-0.5"></i>
          <div class="flex-1">
            <p class="font-medium text-blue-800">Target table selected</p>
            <p class="text-blue-700 text-sm mt-1">
              Importing to <strong>{{ store.selectedTable?.name }}</strong> ({{ store.selectedTable?.fields.length }} columns)
            </p>
          </div>
        </div>

        <!-- Pro Tip: Column Naming -->
        <div class="mb-6 bg-green-50 border-l-4 border-green-500 rounded-lg p-4">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0">
              <i class="pi pi-lightbulb text-green-600 text-xl"></i>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-green-900 mb-1">💡 Pro Tip: Name Your Excel Columns</h3>
              <p class="text-sm text-green-800 mb-2">
                For <strong>automatic column mapping</strong>, name your Excel headers to match your database field names.
              </p>
              <div class="text-sm text-green-700 bg-green-100 rounded px-3 py-2">
                <strong>Example:</strong> If your database has <code class="bg-white px-1.5 py-0.5 rounded text-xs">sit_name</code>,
                <code class="bg-white px-1.5 py-0.5 rounded text-xs">sit_address</code>,
                <code class="bg-white px-1.5 py-0.5 rounded text-xs">sit_zipCode</code>
                → Use the same names in your Excel first row!
              </div>
              <p class="text-sm text-green-700 mt-2">
                ✅ The system will auto-detect and map matching columns, saving you time!
              </p>
            </div>
          </div>
        </div>

        <!-- Upload Area -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-3">
            Data File
          </label>
          <div
            class="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-blue-400 transition cursor-pointer bg-gray-50"
            @click="$refs.fileInput?.click()"
            @dragover.prevent
            @drop.prevent="handleDrop"
          >
            <div class="flex flex-col items-center">
              <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4">
                <i class="pi pi-file-excel text-green-600 text-3xl"></i>
              </div>
              <p class="text-lg font-medium text-gray-700 mb-1">
                Drop your data file here, or click to browse
              </p>
              <p class="text-sm text-gray-500">
                Supports Excel (.xlsx, .xls) and CSV files
              </p>
              <p class="text-xs text-gray-400 mt-2">
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
          <i class="pi pi-spin pi-spinner text-5xl text-blue-600 mb-4"></i>
          <p class="text-gray-600 font-medium">Parsing your data file...</p>
          <p class="text-sm text-gray-500 mt-2">This may take a few seconds</p>
        </div>

        <!-- Error State -->
        <div v-if="error" class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 mb-4 flex items-start">
          <i class="pi pi-exclamation-circle text-red-500 text-xl mr-3 mt-0.5"></i>
          <div>
            <p class="font-medium text-red-800">Upload Failed</p>
            <p class="text-red-700 text-sm mt-1">{{ error }}</p>
          </div>
        </div>

        <!-- Success State with Data Preview -->
        <div v-if="store.hasExcelData && !loading" class="space-y-6">
          <!-- Success Banner -->
          <div class="bg-green-50 border-l-4 border-green-500 rounded-lg p-4 flex items-start">
            <i class="pi pi-check-circle text-green-500 text-xl mr-3 mt-0.5"></i>
            <div class="flex-1">
              <p class="font-medium text-green-800">Data loaded successfully!</p>
              <p class="text-green-700 text-sm mt-1">
                Found {{ store.excelData.length }} rows with {{ store.excelHeaders.length }} columns
              </p>
            </div>
          </div>

          <!-- Data Preview -->
          <div>
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Data Preview</h3>
              <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
                {{ store.excelData.length }} rows
              </span>
            </div>

            <div class="overflow-x-auto bg-gradient-to-br from-gray-50 to-blue-50 rounded-lg p-4 border border-gray-200">
              <table class="min-w-full divide-y divide-gray-300">
                <thead>
                  <tr>
                    <th class="sticky left-0 px-4 py-3 text-left text-xs font-semibold text-gray-900 uppercase tracking-wider bg-gray-200 z-10">
                      #
                    </th>
                    <th
                      v-for="header in store.excelHeaders"
                      :key="header"
                      class="px-4 py-3 text-left text-xs font-semibold text-gray-900 uppercase tracking-wider bg-gray-200"
                    >
                      {{ header }}
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="(row, index) in store.excelData.slice(0, 10)" :key="index" class="hover:bg-blue-50 transition">
                    <td class="sticky left-0 px-4 py-3 text-sm font-medium text-gray-500 bg-white">{{ index + 1 }}</td>
                    <td
                      v-for="(cell, cellIndex) in row"
                      :key="cellIndex"
                      class="px-4 py-3 text-sm text-gray-900 whitespace-nowrap"
                    >
                      {{ cell }}
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-if="store.excelData.length > 10" class="text-sm text-gray-500 mt-4 text-center italic">
                Showing first 10 rows of {{ store.excelData.length }} total rows
              </p>
            </div>
          </div>

          <!-- Continue Button -->
          <div class="flex items-center justify-between pt-6 border-t border-gray-200">
            <button
              @click="$refs.fileInput?.click()"
              class="text-blue-600 hover:text-blue-700 font-medium flex items-center transition"
            >
              <i class="pi pi-refresh mr-2"></i>
              Upload a different file
            </button>
            <button
              @click="goToMapping"
              class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg transition shadow-md hover:shadow-lg flex items-center"
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
