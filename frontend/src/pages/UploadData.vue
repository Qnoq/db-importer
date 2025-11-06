<template>
  <div class="px-4 py-6">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-2xl font-semibold mb-4">Step 3: Upload Data File</h2>
      <p class="text-gray-600 mb-6">
        Upload an Excel (.xlsx, .xls) or CSV file containing your data
      </p>

      <div v-if="!store.hasSelectedTable" class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
        <p class="text-yellow-700">No table selected. Please select a table first.</p>
        <button
          @click="router.push('/select-table')"
          class="mt-3 text-blue-600 hover:text-blue-700 font-semibold"
        >
          <i class="pi pi-arrow-left mr-2"></i>
          Go back to table selection
        </button>
      </div>

      <div v-else>
        <div class="mb-4 bg-blue-50 border border-blue-200 rounded-md p-4">
          <p class="text-sm text-blue-800">
            <i class="pi pi-info-circle mr-2"></i>
            Selected table: <strong>{{ store.selectedTable?.name }}</strong>
          </p>
        </div>

        <div class="mb-6">
          <input
            type="file"
            accept=".xlsx,.xls,.csv"
            @change="handleFileUpload"
            ref="fileInput"
            class="block w-full text-sm text-gray-500
              file:mr-4 file:py-2 file:px-4
              file:rounded-md file:border-0
              file:text-sm file:font-semibold
              file:bg-blue-50 file:text-blue-700
              hover:file:bg-blue-100"
          />
        </div>

        <div v-if="loading" class="flex items-center justify-center py-8">
          <i class="pi pi-spin pi-spinner text-4xl text-blue-600"></i>
        </div>

        <div v-if="error" class="bg-red-50 border border-red-200 rounded-md p-4 mb-4">
          <p class="text-red-700">{{ error }}</p>
        </div>

        <div v-if="store.hasExcelData && !loading" class="mt-6">
          <h3 class="text-lg font-semibold mb-3">Data Preview ({{ store.excelData.length }} rows)</h3>
          <div class="overflow-x-auto bg-gray-50 rounded-md p-4 max-h-96">
            <table class="min-w-full divide-y divide-gray-300">
              <thead>
                <tr>
                  <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase tracking-wider bg-gray-200">
                    #
                  </th>
                  <th
                    v-for="header in store.excelHeaders"
                    :key="header"
                    class="px-3 py-2 text-left text-xs font-semibold text-gray-900 uppercase tracking-wider bg-gray-200"
                  >
                    {{ header }}
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="(row, index) in store.excelData.slice(0, 10)" :key="index">
                  <td class="px-3 py-2 text-sm text-gray-500">{{ index + 1 }}</td>
                  <td
                    v-for="(cell, cellIndex) in row"
                    :key="cellIndex"
                    class="px-3 py-2 text-sm text-gray-900"
                  >
                    {{ cell }}
                  </td>
                </tr>
              </tbody>
            </table>
            <p v-if="store.excelData.length > 10" class="text-sm text-gray-500 mt-3 italic">
              Showing first 10 rows of {{ store.excelData.length }} total rows
            </p>
          </div>

          <button
            @click="goToMapping"
            class="mt-6 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-md transition"
          >
            Continue to Column Mapping
            <i class="pi pi-arrow-right ml-2"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import * as XLSX from 'xlsx'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')

function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

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

function goToMapping() {
  router.push('/mapping')
}
</script>
