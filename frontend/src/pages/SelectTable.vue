<template>
  <div class="px-4 py-6">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="bg-white shadow-lg rounded-xl p-8 border border-gray-200">
      <h2 class="text-3xl font-bold text-gray-900 mb-2">Select Target Table</h2>
      <p class="text-gray-600 mb-6">
        Choose the table where you want to import data
      </p>

      <div v-if="!store.hasSchema" class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
        <p class="text-yellow-700">No schema loaded. Please upload a SQL file first.</p>
        <button
          @click="router.push('/')"
          class="mt-3 text-blue-600 hover:text-blue-700 font-semibold"
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
                class="text-gray-400 hover:text-gray-600 transition"
              >
                <i class="pi pi-times"></i>
              </button>
            </div>
          </div>

          <!-- Stats and Sorting -->
          <div class="flex items-center justify-between bg-gray-50 rounded-lg px-4 py-3">
            <div class="flex items-center space-x-4 text-sm">
              <div class="flex items-center">
                <i class="pi pi-database text-blue-600 mr-2"></i>
                <span class="font-medium text-gray-700">
                  {{ filteredTables.length }} of {{ store.tables.length }} tables
                </span>
              </div>
              <div v-if="selectedTableName" class="flex items-center text-green-600">
                <i class="pi pi-check-circle mr-2"></i>
                <span class="font-medium">1 selected</span>
              </div>
            </div>

            <div class="flex items-center space-x-2">
              <label class="text-sm text-gray-600">Sort by:</label>
              <select
                v-model="sortBy"
                class="text-sm border border-gray-300 rounded-md px-3 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
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
          <i class="pi pi-inbox text-6xl text-gray-300 mb-4"></i>
          <p class="text-gray-500 text-lg font-medium mb-2">No tables found</p>
          <p class="text-gray-400 text-sm">Try adjusting your search query</p>
          <button
            @click="searchQuery = ''"
            class="mt-4 text-blue-600 hover:text-blue-700 font-medium"
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
              ? 'border-blue-500 bg-blue-50 shadow-md'
              : 'border-gray-200 hover:border-blue-300 bg-white'"
          >
            <!-- Table Header -->
            <div class="flex items-start justify-between mb-3">
              <div class="flex items-center flex-1 min-w-0">
                <div class="flex-shrink-0 w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center mr-3">
                  <i class="pi pi-table text-blue-600 text-lg"></i>
                </div>
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-lg text-gray-900 truncate" :title="table.name">
                    {{ table.name }}
                  </h3>
                  <p class="text-sm text-gray-500 mt-1">
                    <i class="pi pi-list text-xs mr-1"></i>
                    {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                  </p>
                </div>
              </div>
              <div v-if="selectedTableName === table.name" class="flex-shrink-0 ml-2">
                <i class="pi pi-check-circle text-blue-600 text-xl"></i>
              </div>
            </div>

            <!-- Column Preview -->
            <div class="mt-4 pt-4 border-t border-gray-200">
              <p class="text-xs text-gray-500 uppercase tracking-wide font-semibold mb-2">
                Columns
              </p>
              <div class="space-y-1.5">
                <div
                  v-for="field in table.fields.slice(0, 4)"
                  :key="field.name"
                  class="flex items-center text-sm"
                >
                  <i class="pi pi-circle-fill text-xs text-gray-400 mr-2"></i>
                  <span class="text-gray-700 truncate">{{ field.name }}</span>
                  <span class="ml-auto text-xs text-gray-500 pl-2">{{ formatType(field.type) }}</span>
                </div>
                <div v-if="table.fields.length > 4" class="text-xs text-gray-400 italic pl-4">
                  + {{ table.fields.length - 4 }} more...
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="filteredTables.length > itemsPerPage" class="mt-6 flex items-center justify-between border-t border-gray-200 pt-6">
          <div class="text-sm text-gray-600">
            Showing {{ (currentPage - 1) * itemsPerPage + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredTables.length) }} of {{ filteredTables.length }} tables
          </div>
          <div class="flex items-center space-x-2">
            <button
              @click="currentPage--"
              :disabled="currentPage === 1"
              class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 transition"
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
                  ? 'bg-blue-600 text-white border-blue-600'
                  : 'border-gray-300 hover:bg-gray-50'"
              >
                {{ page }}
              </button>
            </div>
            <button
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50 transition"
            >
              <i class="pi pi-chevron-right"></i>
            </button>
          </div>
        </div>

        <!-- Continue Button -->
        <div v-if="selectedTableName" class="mt-8 flex items-center justify-between bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex items-center">
            <i class="pi pi-check-circle text-blue-600 text-2xl mr-3"></i>
            <div>
              <p class="font-semibold text-blue-900">Table selected: {{ selectedTableName }}</p>
              <p class="text-sm text-blue-700">Ready to upload your data file</p>
            </div>
          </div>
          <button
            @click="goToUploadData"
            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition shadow-sm hover:shadow-md flex items-center"
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
