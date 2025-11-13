<template>
  <div class="px-4 py-6 md:px-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="mx-auto max-w-4xl rounded-lg border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900">
      <div class="border-b border-slate-200 px-6 py-6 dark:border-slate-700">
        <h2 class="text-3xl font-bold text-slate-900 dark:text-white">Upload Data File</h2>
        <p class="mt-2 text-slate-600 dark:text-slate-400">Upload an Excel or CSV file containing your data</p>
      </div>

      <div class="space-y-6 px-6 py-6">
        <UAlert
          v-if="!store.hasSelectedTable"
          color="warning"
          variant="subtle"
          title="No table selected"
          description="Please select a table first before uploading data."
          :closable="false"
        />

        <template v-else>
          <!-- Selected Table Info -->
          <UAlert
            color="info"
            variant="subtle"
            title="Target table selected"
            :closable="false"
          >
            <template #description>
              <p class="text-sm">Importing to <strong>{{ store.selectedTable?.name }}</strong> ({{ store.selectedTable?.fields.length }} columns)</p>
            </template>
          </UAlert>

          <!-- Pro Tip: Column Naming -->
          <UAlert
            color="success"
            variant="subtle"
            :closable="false"
          >
            <template #title>
              <div class="flex items-center gap-2">
                <span>💡</span>
                <span>Pro Tip: Name Your Excel Columns</span>
              </div>
            </template>
            <template #description>
              <div class="space-y-2">
                <p class="text-sm">For <strong>automatic column mapping</strong>, name your Excel headers to match your database field names.</p>
                <div class="bg-green-100 p-2 text-xs dark:bg-green-900">
                  <p><strong>Example:</strong> If your database has <code class="font-mono">sit_name</code>, <code class="font-mono">sit_address</code>, <code class="font-mono">sit_zipCode</code> → Use the same names in your Excel first row!</p>
                </div>
                <p class="text-xs">The system will auto-detect and map matching columns, saving you time!</p>
              </div>
            </template>
          </UAlert>

          <!-- Upload Area -->
          <div class="space-y-3">
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300">
              Data File
            </label>
            <div
              class="flex flex-col items-center gap-4 rounded-lg border-2 border-dashed border-slate-300 p-8 text-center transition-colors hover:border-green-600 dark:border-slate-600"
              @click="fileInput?.click()"
              @dragover.prevent
              @drop.prevent="handleDrop"
            >
              <div class="text-4xl">📊</div>
              <p class="text-lg font-medium text-slate-900 dark:text-white">
                Drop your data file here, or click to browse
              </p>
              <p class="text-sm text-slate-600 dark:text-slate-400">
                Supports Excel (.xlsx, .xls) and CSV files
              </p>
              <p class="text-xs text-slate-500 dark:text-slate-500">
                Maximum file size: 50MB
              </p>
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
          <div v-if="loading" class="flex flex-col items-center justify-center gap-4 py-12">
            <div class="text-4xl animate-spin">⏳</div>
            <p class="font-medium text-slate-900 dark:text-white">Parsing your data file...</p>
            <p class="text-sm text-slate-600 dark:text-slate-400">This may take a few seconds</p>
          </div>

          <!-- Error State -->
          <UAlert
            v-if="error"
            color="error"
            variant="subtle"
            :closable="false"
          >
            <template #title>Upload Failed</template>
            <p class="text-sm">{{ error }}</p>
          </UAlert>

          <!-- Success State with Data Preview -->
          <div v-if="store.hasExcelData && !loading" class="space-y-6">
            <!-- Success Banner -->
            <UAlert
              color="success"
              variant="subtle"
              :closable="false"
            >
              <template #title>Data loaded successfully!</template>
              <p class="text-sm">Found {{ store.excelData.length }} rows with {{ store.excelHeaders.length }} columns</p>
            </UAlert>

            <!-- Data Preview -->
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Data Preview</h3>
                <span class="inline-flex items-center rounded-full bg-green-100 px-3 py-1 text-sm font-medium text-green-900 dark:bg-green-900 dark:text-green-100">
                  {{ store.excelData.length }} rows
                </span>
              </div>

              <div class="overflow-x-auto rounded-lg border border-slate-200 bg-gradient-to-br from-slate-50 to-green-50 dark:border-slate-700 dark:from-slate-800 dark:to-green-950">
                <div class="overflow-y-auto" style="max-height: 400px;">
                  <table class="min-w-full border-collapse">
                    <thead class="sticky top-0 bg-slate-100 dark:bg-slate-700">
                      <tr>
                        <th class="border border-slate-200 px-4 py-3 text-left text-xs font-bold uppercase text-slate-900 dark:border-slate-600 dark:text-white">#</th>
                        <th
                          v-for="header in store.excelHeaders"
                          :key="header"
                          class="border border-slate-200 px-4 py-3 text-left text-xs font-bold uppercase text-slate-900 dark:border-slate-600 dark:text-white"
                        >
                          {{ header }}
                        </th>
                      </tr>
                    </thead>
                    <tbody class="bg-white dark:bg-slate-900">
                      <tr v-for="(row, index) in store.excelData.slice(0, 10)" :key="index" class="border-b border-slate-200 hover:bg-green-50 dark:border-slate-700 dark:hover:bg-green-950">
                        <td class="border border-slate-200 px-4 py-3 text-sm font-medium text-slate-900 dark:border-slate-600 dark:text-slate-300">{{ index + 1 }}</td>
                        <td
                          v-for="(cell, cellIndex) in row"
                          :key="cellIndex"
                          class="border border-slate-200 px-4 py-3 text-sm text-slate-700 dark:border-slate-600 dark:text-slate-400"
                        >
                          {{ cell }}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
              <p v-if="store.excelData.length > 10" class="text-center text-sm italic text-slate-600 dark:text-slate-400">
                Showing first 10 rows of {{ store.excelData.length }} total rows
              </p>
            </div>

            <!-- Continue Button -->
            <div class="flex items-center justify-between border-t border-slate-200 pt-6 dark:border-slate-700">
              <UButton
                @click="fileInput?.click()"
                color="success"
                variant="ghost"
              >
                ↻ Upload a different file
              </UButton>
              <UButton
                @click="goToMapping"
                color="success"
                icon="i-heroicons-arrow-right"
              >
                Continue to Column Mapping
              </UButton>
            </div>
          </div>
        </template>
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
