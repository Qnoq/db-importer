<template>
  <div class="px-4 py-6 md:px-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <!-- Main Card Container -->
    <div class="mx-auto max-w-4xl rounded-lg border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900">
      <div class="border-b border-slate-200 px-6 py-6 dark:border-slate-700">
        <h2 class="text-3xl font-bold text-slate-900 dark:text-white">Upload SQL Schema</h2>
        <p class="mt-2 text-slate-600 dark:text-slate-400">Upload your MySQL/MariaDB or PostgreSQL dump file to get started</p>
      </div>

      <div class="space-y-6 px-6 py-6">
        <!-- Important: Single Table Note -->
        <UAlert
          color="info"
          variant="subtle"
          title="Pro Tip: Export Only Your Target Table"
          description="You only need the CREATE TABLE statement for the table you want to import data into. No need to upload your entire database dump!"
          :closable="false"
        >
          <template #description>
            <div class="space-y-2">
              <p class="text-sm">You only need the <strong>CREATE TABLE</strong> statement for the table you want to import data into. No need to upload your entire database dump!</p>
              <div class="space-y-1 bg-slate-100 p-2 dark:bg-slate-800">
                <p class="text-xs font-semibold">Example export command:</p>
                <code class="block font-mono text-xs">mysqldump -u user -p --no-data database_name table_name > table.sql</code>
                <code class="block font-mono text-xs">pg_dump -U user --schema-only -t table_name database > table.sql</code>
              </div>
            </div>
          </template>
        </UAlert>

        <!-- Upload Area -->
        <div class="rounded-lg border border-slate-200 dark:border-slate-700">
          <div class="flex items-center justify-between bg-slate-50 px-6 py-4 dark:bg-slate-800">
            <span class="font-semibold text-slate-900 dark:text-white">SQL Schema File</span>
          </div>

          <div class="px-6 py-6">
            <div
              class="flex flex-col items-center gap-4 rounded-lg border-2 border-dashed border-slate-300 p-8 text-center transition-colors hover:border-green-600 dark:border-slate-600 cursor-pointer"
              @click="fileInput?.click()"
              @dragover.prevent
              @drop.prevent="handleDrop"
            >
              <div class="text-4xl">☁️</div>
              <p class="text-lg font-medium text-slate-900 dark:text-white">
                Drop your SQL file here, or click to browse
              </p>
              <p class="text-sm text-slate-600 dark:text-slate-400">
                Supports MySQL, MariaDB, and PostgreSQL dump files
              </p>
              <p class="text-xs text-slate-500 dark:text-slate-500">
                A single table schema is typically &lt; 50KB
              </p>
            </div>
            <input
              type="file"
              accept=".sql"
              @change="handleFileUpload"
              ref="fileInput"
              class="hidden"
            />
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="flex flex-col items-center justify-center gap-4 py-12">
          <div class="text-4xl animate-spin">⏳</div>
          <p class="font-medium text-slate-900 dark:text-white">Parsing your SQL schema...</p>
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

        <!-- Success State -->
        <div v-if="store.hasSchema && !loading && !showSingleTableDialog" class="space-y-6">
          <!-- Success Banner -->
          <UAlert
            color="success"
            variant="subtle"
            :closable="false"
          >
            <template #title>Schema parsed successfully!</template>
            <p class="text-sm">Found {{ store.tables.length }} table{{ store.tables.length !== 1 ? 's' : '' }} in your database dump</p>
          </UAlert>

          <!-- Tables Preview -->
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-slate-900 dark:text-white">Detected Tables</h3>
              <span class="inline-flex items-center rounded-full bg-green-100 px-3 py-1 text-sm font-medium text-green-900 dark:bg-green-900 dark:text-green-100">
                {{ store.tables.length }} tables
              </span>
            </div>

            <div class="max-h-96 overflow-y-auto rounded-lg border border-slate-200 bg-gradient-to-br from-slate-50 to-green-50 p-4 dark:border-slate-700 dark:from-slate-800 dark:to-green-950">
              <div class="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
                <div
                  v-for="table in store.tables"
                  :key="table.name"
                  class="flex items-center gap-3 rounded-lg border border-slate-200 bg-white p-3 dark:border-slate-700 dark:bg-slate-900"
                >
                  <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded bg-green-100 text-lg dark:bg-green-900">
                    📊
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="truncate font-medium text-slate-900 dark:text-white" :title="table.name">
                      {{ table.name }}
                    </p>
                    <p class="text-xs text-slate-600 dark:text-slate-400">
                      {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Continue Button (only show for multiple tables) -->
          <div v-if="store.tables.length > 1" class="flex items-center justify-between border-t border-slate-200 pt-6 dark:border-slate-700">
            <UButton
              @click="fileInput?.click()"
              color="success"
              variant="ghost"
            >
              ↻ Upload a different file
            </UButton>
            <UButton
              @click="goToSelectTable"
              color="success"
              icon="i-heroicons-arrow-right"
            >
              Continue to Table Selection
            </UButton>
          </div>
        </div>
      </div>
    </div>

    <!-- Single Table Auto-Select Modal -->
    <UModal
      v-model:open="showSingleTableDialog"
      title="Single Table Detected"
      description="We'll auto-select it and skip the table selection step."
      :ui="{ content: 'sm:max-w-sm' }"
    >
      <template #body>
        <div class="space-y-4 text-center">
          <!-- Success Icon -->
          <div class="flex justify-center">
            <div class="flex h-20 w-20 items-center justify-center rounded-full bg-green-100 text-4xl dark:bg-green-900">
              ✓
            </div>
          </div>

          <!-- Message -->
          <p class="text-slate-700 dark:text-slate-300">
            We found only <strong class="text-green-600">1 table</strong> in your schema:
          </p>

          <!-- Table Name -->
          <div class="rounded-lg border border-green-200 bg-green-50 p-4 dark:border-green-900 dark:bg-green-950">
            <div class="flex items-center justify-center gap-3">
              <div class="text-2xl">📊</div>
              <div class="text-left">
                <p class="font-bold text-green-900 dark:text-green-100">{{ store.tables[0]?.name }}</p>
                <p class="text-sm text-green-700 dark:text-green-300">
                  {{ store.tables[0]?.fields.length }} column{{ store.tables[0]?.fields.length !== 1 ? 's' : '' }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </template>

      <template #footer>
        <div class="flex flex-col gap-3 w-full">
          <UButton
            @click="continueToProceed"
            color="success"
            block
            icon="i-heroicons-arrow-right"
          >
            Continue to Upload Data
          </UButton>
          <UButton
            @click="cancelSingleTableDialog"
            color="neutral"
            variant="outline"
            block
          >
            Upload a Different File
          </UButton>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import StepperNav from '../components/StepperNav.vue'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')
const showSingleTableDialog = ref(false)

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

async function processFile(file: File) {
  if (!file) return

  error.value = ''
  loading.value = true

  try {
    const formData = new FormData()
    formData.append('file', file)

    const response = await fetch(`${API_URL}/parse-schema`, {
      method: 'POST',
      body: formData
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => null)
      throw new Error(errorData?.error || `Server error: ${response.status}`)
    }

    const data = await response.json()

    if (!data.tables || data.tables.length === 0) {
      throw new Error('No tables found in the SQL file')
    }

    store.setTables(data.tables)

    // If only one table, show dialog
    if (data.tables.length === 1) {
      showSingleTableDialog.value = true
    }
  } catch (err) {
    if (err instanceof TypeError && err.message.includes('fetch')) {
      error.value = 'Cannot connect to backend server. Please ensure the backend is running on ' + API_URL
    } else {
      error.value = err instanceof Error ? err.message : 'An error occurred'
    }
  } finally {
    loading.value = false
  }
}

async function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    await processFile(file)
  }
}

function handleDrop(event: DragEvent) {
  const file = event.dataTransfer?.files?.[0]
  if (file && file.name.endsWith('.sql')) {
    processFile(file)
  } else {
    error.value = 'Please upload a valid .sql file'
  }
}

function continueToProceed() {
  // Auto-select the single table
  if (store.tables.length === 1) {
    store.selectTable(store.tables[0].name)
    showSingleTableDialog.value = false
    router.push('/upload-data')
  }
}

function cancelSingleTableDialog() {
  // Close the modal
  showSingleTableDialog.value = false
  // Reset the store to clear the uploaded schema
  store.reset()
  // Reset the file input to allow selecting a new file
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

function goToSelectTable() {
  router.push('/select-table')
}
</script>
