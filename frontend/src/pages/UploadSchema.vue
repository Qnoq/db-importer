<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="bg-white shadow-lg rounded-xl p-8 border border-gray-200">
      <div class="mb-8">
        <h2 class="text-3xl font-bold text-gray-900 mb-2">Upload SQL Schema</h2>
        <p class="text-gray-600">
          Upload your MySQL/MariaDB or PostgreSQL dump file to get started
        </p>
      </div>

      <!-- Upload Area -->
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-3">
          SQL Schema File
        </label>
        <div
          class="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-blue-400 transition cursor-pointer bg-gray-50"
          @click="$refs.fileInput?.click()"
          @dragover.prevent
          @drop.prevent="handleDrop"
        >
          <div class="flex flex-col items-center">
            <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mb-4">
              <i class="pi pi-cloud-upload text-blue-600 text-3xl"></i>
            </div>
            <p class="text-lg font-medium text-gray-700 mb-1">
              Drop your SQL file here, or click to browse
            </p>
            <p class="text-sm text-gray-500">
              Supports MySQL, MariaDB, and PostgreSQL dump files
            </p>
            <p class="text-xs text-gray-400 mt-2">
              Maximum file size: 50MB
            </p>
          </div>
        </div>
        <input
          type="file"
          accept=".sql"
          @change="handleFileUpload"
          ref="fileInput"
          class="hidden"
        />
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-12">
        <i class="pi pi-spin pi-spinner text-5xl text-blue-600 mb-4"></i>
        <p class="text-gray-600 font-medium">Parsing your SQL schema...</p>
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

      <!-- Success State -->
      <div v-if="store.hasSchema && !loading" class="space-y-6">
        <!-- Success Banner -->
        <div class="bg-green-50 border-l-4 border-green-500 rounded-lg p-4 flex items-start">
          <i class="pi pi-check-circle text-green-500 text-xl mr-3 mt-0.5"></i>
          <div class="flex-1">
            <p class="font-medium text-green-800">Schema parsed successfully!</p>
            <p class="text-green-700 text-sm mt-1">
              Found {{ store.tables.length }} table{{ store.tables.length !== 1 ? 's' : '' }} in your database dump
            </p>
          </div>
        </div>

        <!-- Tables Preview -->
        <div>
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">Detected Tables</h3>
            <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
              {{ store.tables.length }} tables
            </span>
          </div>

          <div class="bg-gradient-to-br from-gray-50 to-blue-50 rounded-lg p-4 max-h-96 overflow-y-auto border border-gray-200">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              <div
                v-for="table in store.tables"
                :key="table.name"
                class="bg-white rounded-lg p-3 border border-gray-200 hover:border-blue-300 hover:shadow-md transition"
              >
                <div class="flex items-center">
                  <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center mr-2">
                    <i class="pi pi-table text-blue-600 text-sm"></i>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="font-medium text-gray-900 truncate" :title="table.name">
                      {{ table.name }}
                    </p>
                    <p class="text-xs text-gray-500">
                      {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
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
            @click="goToSelectTable"
            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg transition shadow-md hover:shadow-lg flex items-center"
          >
            Continue to Table Selection
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
import StepperNav from '../components/StepperNav.vue'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

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
      throw new Error('Failed to parse schema')
    }

    const data = await response.json()

    if (!data.tables || data.tables.length === 0) {
      throw new Error('No tables found in the SQL file')
    }

    store.setTables(data.tables)
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'An error occurred'
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

function goToSelectTable() {
  router.push('/select-table')
}
</script>
