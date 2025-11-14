<template>
  <div class="px-4 py-6 md:px-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="mx-auto max-w-6xl rounded-lg border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900">
      <div class="border-b border-slate-200 px-6 py-6 dark:border-slate-700">
        <h2 class="text-3xl font-bold text-slate-900 dark:text-white">Select Target Table</h2>
        <p class="mt-2 text-slate-600 dark:text-slate-400">Choose the table where you want to import data</p>
      </div>

      <div class="space-y-6 px-6 py-6">
        <UAlert
          v-if="!store.hasSchema"
          color="warning"
          variant="subtle"
          title="No schema loaded"
          description="Please upload a SQL file first."
          :closable="false"
        >
          <template #description>
            <div class="space-y-3">
              <p class="text-sm">Please upload a SQL file first.</p>
              <UButton
                @click="router.push('/')"
                color="neutral"
                variant="outline"
                size="sm"
              >
                Go back to upload schema
              </UButton>
            </div>
          </template>
        </UAlert>

        <template v-else>
          <!-- Search and Stats Bar -->
          <div class="space-y-4">
            <!-- Search Input -->
            <div class="relative">
              <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-slate-500">
                🔍
              </div>
              <UInput
                v-model="searchQuery"
                type="text"
                placeholder="Search tables by name..."
                class="pl-10"
              />
              <button
                v-if="searchQuery"
                @click="searchQuery = ''"
                class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-500 transition-colors hover:text-slate-900 dark:hover:text-white"
              >
                ✕
              </button>
            </div>

            <!-- Stats and Sorting -->
            <div class="flex flex-col items-center justify-between gap-4 rounded-lg bg-slate-50 p-4 dark:bg-slate-800 md:flex-row">
              <div class="flex items-center gap-4 text-sm">
                <div class="flex items-center gap-2">
                  <span>📊</span>
                  <span class="font-medium text-slate-700 dark:text-slate-300">
                    {{ filteredTables.length }} of {{ store.tables.length }} tables
                  </span>
                </div>
                <div v-if="selectedTableName" class="flex items-center gap-2 text-green-600 dark:text-green-400">
                  <span>✓</span>
                  <span class="font-medium">1 selected</span>
                </div>
              </div>

              <div class="flex items-center gap-3">
                <label class="text-sm font-medium text-slate-700 dark:text-slate-300">Sort by:</label>
                <select
                  v-model="sortBy"
                  class="rounded border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 transition-colors focus:border-green-600 focus:outline-none dark:border-slate-600 dark:bg-slate-800 dark:text-white"
                >
                  <option value="name">Name A-Z</option>
                  <option value="name-desc">Name Z-A</option>
                  <option value="columns">Columns (Low-High)</option>
                  <option value="columns-desc">Columns (High-Low)</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="filteredTables.length === 0" class="text-center py-12">
            <div class="text-5xl mb-4">📭</div>
            <p class="text-lg font-medium text-slate-900 dark:text-white">No tables found</p>
            <p class="text-sm text-slate-600 dark:text-slate-400">Try adjusting your search query</p>
            <UButton
              @click="searchQuery = ''"
              color="neutral"
              variant="ghost"
              class="mt-4"
            >
              Clear search
            </UButton>
          </div>

          <!-- Table Grid -->
          <div v-else class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            <div
              v-for="table in paginatedTables"
              :key="table.name"
              @click="selectTable(table.name)"
              class="cursor-pointer rounded-lg border-2 border-slate-200 bg-white p-5 transition-all hover:border-green-300 hover:shadow-md dark:border-slate-700 dark:bg-slate-800"
              :class="{ 'border-green-500 bg-green-50 dark:border-green-500 dark:bg-green-950': selectedTableName === table.name }"
            >
              <!-- Table Header -->
              <div class="flex items-start justify-between gap-3 pb-4">
                <div class="flex items-center gap-3 flex-1 min-w-0">
                  <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded bg-green-100 text-lg dark:bg-green-900">
                    📊
                  </div>
                  <div class="min-w-0 flex-1">
                    <h3 class="truncate font-semibold text-slate-900 dark:text-white" :title="table.name">
                      {{ table.name }}
                    </h3>
                    <p class="text-sm text-slate-600 dark:text-slate-400">
                      📋 {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                    </p>
                  </div>
                </div>
                <div v-if="selectedTableName === table.name" class="flex-shrink-0 text-xl text-green-600 dark:text-green-400">
                  ✓
                </div>
              </div>

              <!-- Column Preview -->
              <div class="space-y-3 border-t border-slate-200 pt-4 dark:border-slate-700">
                <p class="text-xs font-bold uppercase text-slate-500 dark:text-slate-400">Columns</p>
                <div class="space-y-1">
                  <div
                    v-for="field in table.fields.slice(0, 4)"
                    :key="field.name"
                    class="flex items-center gap-2 text-sm"
                  >
                    <span class="text-slate-400 dark:text-slate-600">●</span>
                    <span class="truncate text-slate-700 dark:text-slate-300">{{ field.name }}</span>
                    <span class="ml-auto flex-shrink-0 text-xs text-slate-500 dark:text-slate-500">{{ formatType(field.type) }}</span>
                  </div>
                  <div v-if="table.fields.length > 4" class="text-xs italic text-slate-500 dark:text-slate-500 pl-3">
                    + {{ table.fields.length - 4 }} more...
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pagination -->
          <div v-if="filteredTables.length > itemsPerPage" class="flex flex-col items-center justify-between gap-4 border-t border-slate-200 pt-6 dark:border-slate-700 md:flex-row">
            <div class="text-sm text-slate-600 dark:text-slate-400">
              Showing {{ (currentPage - 1) * itemsPerPage + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredTables.length) }} of {{ filteredTables.length }} tables
            </div>
            <div class="flex items-center gap-2">
              <UButton
                @click="currentPage--"
                :disabled="currentPage === 1"
                color="neutral"
                variant="outline"
                size="sm"
                icon="i-heroicons-chevron-left"
              />
              <div class="flex items-center gap-1">
                <UButton
                  v-for="page in visiblePages"
                  :key="page"
                  @click="currentPage = page"
                  :label="String(page)"
                  :color="page === currentPage ? 'success' : 'neutral'"
                  :variant="page === currentPage ? 'soft' : 'outline'"
                  size="sm"
                />
              </div>
              <UButton
                @click="currentPage++"
                :disabled="currentPage === totalPages"
                color="neutral"
                variant="outline"
                size="sm"
                icon="i-heroicons-chevron-right"
              />
            </div>
          </div>

          <!-- Continue Button -->
          <UAlert v-if="selectedTableName" color="success" variant="subtle" :closable="false" class="mt-8">
            <template #title>
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <span>✓</span>
                  <span>Table selected: {{ selectedTableName }}</span>
                </div>
                <UButton
                  @click="goToUploadData"
                  color="success"
                  size="sm"
                  icon="i-heroicons-arrow-right"
                >
                  Continue to Data Upload
                </UButton>
              </div>
            </template>
            <template #description>
              <p class="text-sm">Ready to upload your data file</p>
            </template>
          </UAlert>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import { useWorkflowSessionStore } from '../store/workflowSessionStore'
import StepperNav from '../components/StepperNav.vue'

const router = useRouter()
const store = useMappingStore()
const sessionStore = useWorkflowSessionStore()
const selectedTableName = ref('')
const searchQuery = ref('')
const sortBy = ref('name')
const currentPage = ref(1)
const itemsPerPage = 12

// Filtered and sorted tables
const filteredTables = computed(() => {
  let tables = store.tables

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    tables = tables.filter(table =>
      table.name.toLowerCase().includes(query)
    )
  }

  // Sort
  const sorted = [...tables]
  switch (sortBy.value) {
    case 'name':
      sorted.sort((a, b) => a.name.localeCompare(b.name))
      break
    case 'name-desc':
      sorted.sort((a, b) => b.name.localeCompare(a.name))
      break
    case 'columns':
      sorted.sort((a, b) => a.fields.length - b.fields.length)
      break
    case 'columns-desc':
      sorted.sort((a, b) => b.fields.length - a.fields.length)
      break
  }

  return sorted
})

// Pagination
const totalPages = computed(() => Math.ceil(filteredTables.value.length / itemsPerPage))

const paginatedTables = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredTables.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value

  // Show max 5 pages
  let start = Math.max(1, current - 2)
  let end = Math.min(total, start + 4)

  // Adjust start if we're near the end
  if (end - start < 4) {
    start = Math.max(1, end - 4)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Reset page when search/sort changes
const resetPage = () => {
  currentPage.value = 1
}

// Format field type for display
function formatType(type: string): string {
  // Extract just the type name, remove size/precision
  const match = type.match(/^(\w+)/)
  return match ? match[1].toUpperCase() : type.toUpperCase()
}

async function selectTable(tableName: string) {
  selectedTableName.value = tableName
  store.selectTable(tableName)

  // Save to session (for authenticated users)
  await sessionStore.saveTableSelection(tableName)
}

function goToUploadData() {
  router.push('/upload-data')
}

// Watch search and sort
watch(searchQuery, resetPage)
watch(sortBy, resetPage)
</script>
