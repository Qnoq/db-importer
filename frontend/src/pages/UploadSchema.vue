<template>
  <div class="px-4 py-6">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-2xl font-semibold mb-4">Step 1: Upload SQL Schema</h2>
      <p class="text-gray-600 mb-6">
        Upload your MySQL/MariaDB or PostgreSQL dump file (.sql)
      </p>

      <div class="mb-6">
        <input
          type="file"
          accept=".sql"
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

      <div v-if="store.hasSchema && !loading" class="mt-6">
        <h3 class="text-lg font-semibold mb-3">Detected Tables ({{ store.tables.length }})</h3>
        <div class="bg-gray-50 rounded-md p-4 max-h-96 overflow-y-auto">
          <ul class="space-y-2">
            <li v-for="table in store.tables" :key="table.name" class="flex items-center">
              <i class="pi pi-table text-blue-600 mr-2"></i>
              <span class="font-medium">{{ table.name }}</span>
              <span class="ml-2 text-gray-500 text-sm">({{ table.fields.length }} columns)</span>
            </li>
          </ul>
        </div>

        <button
          @click="goToSelectTable"
          class="mt-6 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-md transition"
        >
          Continue to Table Selection
          <i class="pi pi-arrow-right ml-2"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

async function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

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

function goToSelectTable() {
  router.push('/select-table')
}
</script>
