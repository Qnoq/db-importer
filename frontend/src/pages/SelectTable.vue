<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="shadow-lg rounded-xl p-8 border transition-colors duration-200" style="background: var(--p-surface-0); border-color: var(--p-surface-border)">
      <h2 class="text-3xl font-bold mb-2" style="color: var(--p-text-color)">Select Target Table</h2>
      <p class="mb-6" style="color: var(--p-text-muted-color)">
        Choose the table where you want to import data
      </p>

      <div v-if="!store.hasSchema" class="bg-yellow-50 dark:bg-yellow-950/20 border border-yellow-200 dark:border-yellow-800 rounded-md p-4">
        <p class="text-yellow-700 dark:text-yellow-400">No schema loaded. Please upload a SQL file first.</p>
        <button
          @click="router.push('/')"
          class="mt-3 text-neon-green-600 dark:text-neon-green-400 hover:text-neon-green-700 dark:hover:text-neon-green-300 font-semibold"
        >
          <i class="pi pi-arrow-left mr-2"></i>
          Go back to upload schema
        </button>
      </div>

      <div v-else>
        <!-- Search and Stats Bar -->
        <div class="mb-6 space-y-4">
          <!-- Search Input -->
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none z-10">
              <i class="pi pi-search text-gray-400"></i>
            </div>
            <InputText
              v-model="searchQuery"
              type="text"
              placeholder="Search tables by name..."
              class="w-full pl-10 pr-10"
            />
            <div v-if="searchQuery" class="absolute inset-y-0 right-0 pr-3 flex items-center z-10">
              <button
                @click="searchQuery = ''"
                class="text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 transition"
              >
                <i class="pi pi-times"></i>
              </button>
            </div>
          </div>

          <!-- Stats and Sorting -->
          <div class="flex items-center justify-between rounded-lg px-4 py-3" style="background: var(--p-surface-50)">
            <div class="flex items-center space-x-4 text-sm">
              <div class="flex items-center">
                <i class="pi pi-database text-neon-green-600 dark:text-neon-green-400 mr-2"></i>
                <span class="font-medium" style="color: var(--p-text-color)">
                  {{ filteredTables.length }} of {{ store.tables.length }} tables
                </span>
              </div>
              <div v-if="selectedTableName" class="flex items-center text-neon-green-600 dark:text-neon-green-400">
                <i class="pi pi-check-circle mr-2"></i>
                <span class="font-medium">1 selected</span>
              </div>
            </div>

            <div class="flex items-center space-x-2">
              <label class="text-sm" style="color: var(--p-text-muted-color)">Sort by:</label>
              <select
                v-model="sortBy"
                class="text-sm border rounded-md px-3 py-1 focus:outline-none focus:ring-2 focus:ring-neon-green-500 dark:focus:ring-neon-green-400"
                style="border-color: var(--p-surface-border); background: var(--p-surface-0); color: var(--p-text-color)"
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
          <i class="pi pi-inbox text-6xl mb-4" style="color: var(--p-surface-300)"></i>
          <p class="text-lg font-medium mb-2" style="color: var(--p-text-muted-color)">No tables found</p>
          <p class="text-sm" style="color: var(--p-text-muted-color)">Try adjusting your search query</p>
          <button
            @click="searchQuery = ''"
            class="mt-4 text-neon-green-600 dark:text-neon-green-400 hover:text-neon-green-700 dark:hover:text-neon-green-300 font-medium"
          >
            Clear search
          </button>
        </div>

        <!-- Table Grid -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="table in paginatedTables"
            :key="table.name"
            @click="selectTable(table.name)"
            class="group border-2 rounded-lg p-5 cursor-pointer transition-all duration-200 hover:shadow-lg"
            :class="selectedTableName === table.name
              ? 'border-neon-green-500 dark:border-neon-green-400 bg-neon-green-50 dark:bg-neon-green-950/20 shadow-md'
              : 'hover:border-neon-green-300 dark:hover:border-neon-green-500'"
            :style="selectedTableName !== table.name ? 'border-color: var(--p-surface-border); background: var(--p-surface-0)' : ''"
          >
            <!-- Table Header -->
            <div class="flex items-start justify-between mb-3">
              <div class="flex items-center flex-1 min-w-0">
                <div class="flex-shrink-0 w-10 h-10 rounded-lg bg-neon-green-100 dark:bg-neon-green-900/30 flex items-center justify-center mr-3">
                  <i class="pi pi-table text-neon-green-600 dark:text-neon-green-400 text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-lg truncate" style="color: var(--p-text-color)" :title="table.name">
                    {{ table.name }}
                  </h3>
                  <p class="text-sm mt-1" style="color: var(--p-text-muted-color)">
                    <i class="pi pi-list text-xs mr-1"></i>
                    {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                  </p>
                </div>
              </div>
              <div v-if="selectedTableName === table.name" class="flex-shrink-0 ml-2">
                <i class="pi pi-check-circle text-neon-green-600 dark:text-neon-green-400 text-xl"></i>
              </div>
            </div>

            <!-- Column Preview -->
            <div class="mt-4 pt-4 border-t" style="border-color: var(--p-surface-border)">
              <p class="text-xs uppercase tracking-wide font-semibold mb-2" style="color: var(--p-text-muted-color)">
                Columns
              </p>
              <div class="space-y-1.5">
                <div
                  v-for="field in table.fields.slice(0, 4)"
                  :key="field.name"
                  class="flex items-center text-sm"
                >
                  <i class="pi pi-circle-fill text-xs mr-2" style="color: var(--p-surface-400)"></i>
                  <span class="truncate" style="color: var(--p-text-color)">{{ field.name }}</span>
                  <span class="ml-auto text-xs pl-2" style="color: var(--p-text-muted-color)">{{ formatType(field.type) }}</span>
                </div>
                <div v-if="table.fields.length > 4" class="text-xs italic pl-4" style="color: var(--p-text-muted-color)">
                  + {{ table.fields.length - 4 }} more...
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="filteredTables.length > itemsPerPage" class="mt-6 flex items-center justify-between border-t pt-6" style="border-color: var(--p-surface-border)">
          <div class="text-sm" style="color: var(--p-text-muted-color)">
            Showing {{ (currentPage - 1) * itemsPerPage + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredTables.length) }} of {{ filteredTables.length }} tables
          </div>
          <div class="flex items-center space-x-2">
            <button
              @click="currentPage--"
              :disabled="currentPage === 1"
              class="px-3 py-1 border rounded-md text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed transition"
              style="border-color: var(--p-surface-border); background: var(--p-surface-0); color: var(--p-text-color)"
            >
              <i class="pi pi-chevron-left"></i>
            </button>
            <div class="flex items-center space-x-1">
              <button
                v-for="page in visiblePages"
                :key="page"
                @click="currentPage = page"
                class="px-3 py-1 border rounded-md text-sm font-medium transition"
                :class="page === currentPage
                  ? 'bg-neon-green-600 dark:bg-neon-green-500 text-white border-neon-green-600 dark:border-neon-green-500'
                  : ''"
                :style="page !== currentPage ? 'border-color: var(--p-surface-border); background: var(--p-surface-0); color: var(--p-text-color)' : ''"
              >
                {{ page }}
              </button>
            </div>
            <button
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              class="px-3 py-1 border rounded-md text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed transition"
              style="border-color: var(--p-surface-border); background: var(--p-surface-0); color: var(--p-text-color)"
            >
              <i class="pi pi-chevron-right"></i>
            </button>
          </div>
        </div>

        <!-- Continue Button -->
        <div v-if="selectedTableName" class="mt-8 flex items-center justify-between bg-neon-green-50 dark:bg-neon-green-950/20 border border-neon-green-200 dark:border-neon-green-800 rounded-lg p-4">
          <div class="flex items-center">
            <i class="pi pi-check-circle text-neon-green-600 dark:text-neon-green-400 text-2xl mr-3"></i>
            <div>
              <p class="font-semibold text-neon-green-900 dark:text-neon-green-300">Table selected: {{ selectedTableName }}</p>
              <p class="text-sm text-neon-green-700 dark:text-neon-green-400">Ready to upload your data file</p>
            </div>
          </div>
          <button
            @click="goToUploadData"
            class="bg-neon-green-600 hover:bg-neon-green-700 dark:bg-neon-green-500 dark:hover:bg-neon-green-600 text-white font-semibold py-3 px-6 rounded-lg transition shadow-sm hover:shadow-md flex items-center"
          >
            Continue to Data Upload
            <i class="pi pi-arrow-right ml-2"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import StepperNav from '../components/StepperNav.vue'
import InputText from 'primevue/inputtext'

const router = useRouter()
const store = useMappingStore()
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

// Watch for changes
const unwatchSearch = () => {
  resetPage()
}

const unwatchSort = () => {
  resetPage()
}

// Format field type for display
function formatType(type: string): string {
  // Extract just the type name, remove size/precision
  const match = type.match(/^(\w+)/)
  return match ? match[1].toUpperCase() : type.toUpperCase()
}

function selectTable(tableName: string) {
  selectedTableName.value = tableName
  store.selectTable(tableName)
}

function goToUploadData() {
  router.push('/upload-data')
}

// Watch search and sort
import { watch } from 'vue'
watch(searchQuery, unwatchSearch)
watch(sortBy, unwatchSort)
</script>
