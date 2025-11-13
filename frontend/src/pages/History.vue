<template>
  <div class="p-6 max-w-[112rem] mx-auto">
    <!-- Page Header -->
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Import History</h1>
      <p class="text-gray-600 dark:text-gray-400">View and manage your import history</p>
    </div>

    <!-- Stats Cards -->
    <div v-if="importStore.stats" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <!-- Total Imports -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Total Imports</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ importStore.stats.totalImports }}</p>
          </div>
          <div class="text-3xl">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Total Rows -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Total Rows</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ formatNumber(importStore.stats.totalRows) }}</p>
          </div>
          <div class="text-3xl">
            <svg class="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Success Rate -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Success Rate</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ importStore.stats.successRate.toFixed(1) }}%</p>
          </div>
          <div class="text-3xl">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Most Used Table -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div class="flex-1 min-w-0">
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Most Used Table</p>
            <p class="text-lg font-bold text-gray-900 dark:text-white truncate">{{ importStore.stats.mostUsedTable || 'N/A' }}</p>
          </div>
          <div class="text-3xl ml-4">
            <svg class="w-8 h-8 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700 mb-6">
      <div class="flex flex-wrap gap-4">
        <div class="flex-1 min-w-[200px]">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Table Name</label>
          <UInput
            v-model="filters.tableName"
            placeholder="Filter by table name..."
            size="md"
          />
        </div>

        <div class="min-w-[150px]">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Status</label>
          <USelect
            v-model="filters.status"
            :options="statusOptions"
            placeholder="All statuses"
            size="md"
          />
        </div>
      </div>
    </div>

    <!-- Import List -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
      <UTable
        :rows="importStore.imports"
        :columns="columns"
        :loading="importStore.loading"
      >
        <template #empty-state>
          <div class="flex flex-col items-center justify-center py-8 text-gray-500 dark:text-gray-400">
            <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
            </svg>
            <p>No imports found</p>
          </div>
        </template>

        <template #loading-state>
          <div class="flex items-center justify-center py-8">
            <svg class="animate-spin h-8 w-8 text-green-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
          </div>
        </template>

        <template #tableName-data="{ row }">
          <span class="font-medium text-gray-900 dark:text-white">{{ row.tableName }}</span>
        </template>

        <template #rowCount-data="{ row }">
          <span class="text-gray-700 dark:text-gray-300">{{ formatNumber(row.rowCount) }}</span>
        </template>

        <template #status-data="{ row }">
          <UBadge
            :label="row.status"
            :color="getStatusColor(row.status)"
            variant="subtle"
          />
        </template>

        <template #errorCount-data="{ row }">
          <span v-if="row.errorCount > 0" class="font-medium text-red-600 dark:text-red-400">
            {{ row.errorCount }}
          </span>
          <span v-else class="text-gray-500 dark:text-gray-400">0</span>
        </template>

        <template #warningCount-data="{ row }">
          <span v-if="row.warningCount > 0" class="font-medium text-amber-600 dark:text-amber-400">
            {{ row.warningCount }}
          </span>
          <span v-else class="text-gray-500 dark:text-gray-400">0</span>
        </template>

        <template #createdAt-data="{ row }">
          <span class="text-gray-700 dark:text-gray-300">{{ formatDate(row.createdAt) }}</span>
        </template>

        <template #actions-data="{ row }">
          <div class="flex gap-2">
            <UTooltip text="View Details">
              <UButton
                icon="i-heroicons-eye"
                color="neutral"
                variant="ghost"
                size="sm"
                @click="viewDetails(row)"
              />
            </UTooltip>
            <UTooltip text="Download SQL">
              <UButton
                icon="i-heroicons-arrow-down-tray"
                color="neutral"
                variant="ghost"
                size="sm"
                :loading="downloadingId === row.id"
                @click="downloadSQL(row)"
              />
            </UTooltip>
            <UTooltip text="Delete">
              <UButton
                icon="i-heroicons-trash"
                color="error"
                variant="ghost"
                size="sm"
                @click="confirmDelete(row)"
              />
            </UTooltip>
          </div>
        </template>
      </UTable>

      <!-- Custom Pagination -->
      <div v-if="importStore.total > 0" class="flex items-center justify-between px-6 py-4 border-t border-gray-200 dark:border-gray-700">
        <div class="text-sm text-gray-700 dark:text-gray-300">
          Showing {{ ((currentPage - 1) * importStore.pageSize) + 1 }} to {{ Math.min(currentPage * importStore.pageSize, importStore.total) }} of {{ importStore.total }} results
        </div>
        <div class="flex gap-2">
          <UButton
            icon="i-heroicons-chevron-left"
            color="neutral"
            variant="outline"
            size="sm"
            :disabled="currentPage === 1"
            @click="goToPage(currentPage - 1)"
          />
          <div class="flex gap-1">
            <UButton
              v-for="page in visiblePages"
              :key="page"
              :label="page.toString()"
              :color="currentPage === page ? 'success' : 'neutral'"
              :variant="currentPage === page ? 'solid' : 'outline'"
              size="sm"
              @click="goToPage(page)"
            />
          </div>
          <UButton
            icon="i-heroicons-chevron-right"
            color="neutral"
            variant="outline"
            size="sm"
            :disabled="currentPage === totalPages"
            @click="goToPage(currentPage + 1)"
          />
        </div>
      </div>
    </div>

    <!-- Details Modal -->
    <UModal
      v-model:open="detailsVisible"
      :title="`Import Details - ${selectedImport?.tableName || ''}`"
      description="View detailed information about this import"
      :ui="{ content: 'sm:max-w-4xl' }"
    >
      <template #body>

        <div v-if="selectedImport" class="space-y-6">
          <!-- Basic Info -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Table Name</p>
              <p class="font-medium text-gray-900 dark:text-white">{{ selectedImport.tableName }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Status</p>
              <UBadge
                :label="selectedImport.status"
                :color="getStatusColor(selectedImport.status)"
                variant="subtle"
              />
            </div>
            <div>
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Row Count</p>
              <p class="font-medium text-gray-900 dark:text-white">{{ formatNumber(selectedImport.rowCount) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Errors / Warnings</p>
              <p class="font-medium text-gray-900 dark:text-white">{{ selectedImport.errorCount }} / {{ selectedImport.warningCount }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Created At</p>
              <p class="font-medium text-gray-900 dark:text-white">{{ formatDate(selectedImport.createdAt) }}</p>
            </div>
            <div v-if="selectedImport.metadata.sourceFileName">
              <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">Source File</p>
              <p class="font-medium text-gray-900 dark:text-white truncate" :title="selectedImport.metadata.sourceFileName">
                {{ selectedImport.metadata.sourceFileName }}
              </p>
            </div>
          </div>

          <!-- Column Mapping -->
          <div v-if="selectedImport.metadata.mappingSummary && Object.keys(selectedImport.metadata.mappingSummary).length > 0" class="mt-6">
            <p class="text-sm font-semibold text-gray-900 dark:text-white mb-2">Column Mapping:</p>
            <div class="bg-gray-50 dark:bg-gray-900 rounded-lg p-3 max-h-40 overflow-y-auto border border-gray-200 dark:border-gray-700">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
                <div v-for="(dbCol, excelCol) in selectedImport.metadata.mappingSummary" :key="excelCol" class="flex items-center gap-2">
                  <span class="text-gray-600 dark:text-gray-400">{{ excelCol }}</span>
                  <svg class="w-3 h-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                  <span class="font-medium text-gray-900 dark:text-white">{{ dbCol }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Transformations -->
          <div v-if="selectedImport.metadata.transformations && selectedImport.metadata.transformations.length > 0" class="mt-6">
            <p class="text-sm font-semibold text-gray-900 dark:text-white mb-2">Transformations Applied:</p>
            <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-3 border border-blue-200 dark:border-blue-800">
              <ul class="list-disc list-inside text-sm text-gray-700 dark:text-gray-300 space-y-1">
                <li v-for="(transformation, idx) in selectedImport.metadata.transformations" :key="idx">
                  {{ transformation }}
                </li>
              </ul>
            </div>
          </div>

          <!-- SQL Preview -->
          <div v-if="selectedImportSQL" class="mt-6">
            <div class="flex items-center justify-between mb-2">
              <p class="text-sm font-semibold text-gray-900 dark:text-white">SQL Preview:</p>
              <UButton
                label="Download Full SQL"
                icon="i-heroicons-arrow-down-tray"
                size="xs"
                color="neutral"
                variant="outline"
                @click="downloadFullSQL"
              />
            </div>
            <div class="bg-gray-900 dark:bg-black rounded-lg p-4 max-h-60 overflow-y-auto border border-gray-700">
              <pre class="text-sm text-green-400 font-mono whitespace-pre-wrap">{{ getSQLPreview(selectedImportSQL) }}</pre>
            </div>
          </div>

          <!-- Errors -->
          <div v-if="selectedImport.metadata.validationErrors?.length" class="mt-6">
            <p class="text-sm font-semibold text-red-600 dark:text-red-400 mb-2">Errors:</p>
            <div class="bg-red-50 dark:bg-red-900/20 rounded-lg p-3 max-h-32 overflow-y-auto border border-red-200 dark:border-red-800">
              <ul class="list-disc list-inside text-sm text-gray-700 dark:text-gray-300 space-y-1">
                <li v-for="(error, idx) in selectedImport.metadata.validationErrors" :key="idx">
                  {{ error }}
                </li>
              </ul>
            </div>
          </div>

          <!-- Warnings -->
          <div v-if="selectedImport.metadata.validationWarnings?.length" class="mt-6">
            <p class="text-sm font-semibold text-amber-600 dark:text-amber-400 mb-2">Warnings:</p>
            <div class="bg-amber-50 dark:bg-amber-900/20 rounded-lg p-3 max-h-32 overflow-y-auto border border-amber-200 dark:border-amber-800">
              <ul class="list-disc list-inside text-sm text-gray-700 dark:text-gray-300 space-y-1">
                <li v-for="(warning, idx) in selectedImport.metadata.validationWarnings" :key="idx">
                  {{ warning }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </template>
    </UModal>

    <!-- Delete Confirmation Modal -->
    <UModal
      v-model:open="deleteVisible"
      title="Confirm Delete"
      description="Are you sure you want to delete this import?"
      :ui="{ content: 'sm:max-w-md' }"
    >
      <template #body>
        <div class="flex items-start gap-4">
          <div class="flex-shrink-0">
            <svg class="w-10 h-10 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <p class="text-gray-600 dark:text-gray-400 pt-2">This action cannot be undone.</p>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-3">
          <UButton
            label="Cancel"
            color="neutral"
            variant="ghost"
            @click="deleteVisible = false"
          />
          <UButton
            label="Delete"
            color="error"
            :loading="importStore.loading"
            @click="deleteImport"
          />
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useImportStore, type Import } from '../store/importStore'

const importStore = useImportStore()
const toast = useToast()

// Table columns configuration
const columns = [
  {
    id: 'tableName',
    key: 'tableName',
    label: 'Table'
  },
  {
    id: 'rowCount',
    key: 'rowCount',
    label: 'Rows'
  },
  {
    id: 'status',
    key: 'status',
    label: 'Status'
  },
  {
    id: 'errorCount',
    key: 'errorCount',
    label: 'Errors'
  },
  {
    id: 'warningCount',
    key: 'warningCount',
    label: 'Warnings'
  },
  {
    id: 'createdAt',
    key: 'createdAt',
    label: 'Date'
  },
  {
    id: 'actions',
    key: 'actions',
    label: 'Actions'
  }
]

const filters = ref({
  tableName: '',
  status: null as 'success' | 'warning' | 'failed' | null
})

const statusOptions = [
  { label: 'All statuses', value: null },
  { label: 'Success', value: 'success' },
  { label: 'Warning', value: 'warning' },
  { label: 'Failed', value: 'failed' }
]

const selectedImport = ref<Import | null>(null)
const selectedImportSQL = ref<string | null>(null)
const detailsVisible = ref(false)
const deleteVisible = ref(false)
const downloadingId = ref<string | null>(null)
const currentPage = ref(1)

// Debounce timer for auto-filtering
let filterDebounceTimer: ReturnType<typeof setTimeout> | null = null

// Pagination computed properties
const totalPages = computed(() => {
  return Math.ceil(importStore.total / importStore.pageSize)
})

const visiblePages = computed(() => {
  const total = totalPages.value
  const current = currentPage.value
  const pages: number[] = []

  if (total <= 7) {
    // Show all pages if 7 or fewer
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Always show first page
    pages.push(1)

    if (current > 3) {
      pages.push(-1) // Ellipsis placeholder
    }

    // Show current page and neighbors
    const start = Math.max(2, current - 1)
    const end = Math.min(total - 1, current + 1)

    for (let i = start; i <= end; i++) {
      pages.push(i)
    }

    if (current < total - 2) {
      pages.push(-2) // Ellipsis placeholder
    }

    // Always show last page
    pages.push(total)
  }

  return pages.filter(p => p > 0) // Remove ellipsis for now
})

const goToPage = async (page: number) => {
  if (page < 1 || page > totalPages.value) return

  currentPage.value = page
  await importStore.listImports({
    page,
    pageSize: importStore.pageSize,
    tableName: filters.value.tableName || undefined,
    status: filters.value.status || undefined
  })
}

onMounted(async () => {
  await importStore.getStats()
  await importStore.listImports({ page: 1, pageSize: 20 })
})

// Auto-filter with debounce when filters change
watch(filters, () => {
  if (filterDebounceTimer) {
    clearTimeout(filterDebounceTimer)
  }

  filterDebounceTimer = setTimeout(async () => {
    currentPage.value = 1
    await importStore.listImports({
      page: 1,
      pageSize: importStore.pageSize,
      tableName: filters.value.tableName || undefined,
      status: filters.value.status || undefined
    })
  }, 500)
}, { deep: true })

const viewDetails = async (imp: Import) => {
  selectedImport.value = imp
  selectedImportSQL.value = null
  detailsVisible.value = true

  // Fetch SQL in the background
  try {
    const importWithSQL = await importStore.getImportWithSQL(imp.id)
    selectedImportSQL.value = importWithSQL.generatedSql
  } catch (error) {
    console.error('Failed to load SQL:', error)
    toast.add({
      title: 'Warning',
      description: 'Failed to load SQL preview',
      color: 'warning'
    })
  }
}

const getSQLPreview = (sql: string): string => {
  const maxLength = 500
  if (sql.length <= maxLength) {
    return sql
  }
  return sql.substring(0, maxLength) + '\n...\n(SQL truncated for preview. Download to see full SQL)'
}

const downloadFullSQL = () => {
  if (!selectedImport.value || !selectedImportSQL.value) return

  const filename = `${selectedImport.value.tableName}_${selectedImport.value.createdAt.replace(/[:.]/g, '-')}.sql`
  importStore.downloadSQL(selectedImportSQL.value, filename)
  toast.add({
    title: 'Success',
    description: 'SQL downloaded successfully',
    color: 'success'
  })
}

const downloadSQL = async (imp: Import) => {
  downloadingId.value = imp.id
  try {
    const importWithSQL = await importStore.getImportWithSQL(imp.id)
    const filename = `${imp.tableName}_${imp.createdAt.replace(/[:.]/g, '-')}.sql`
    importStore.downloadSQL(importWithSQL.generatedSql, filename)
    toast.add({
      title: 'Success',
      description: 'SQL downloaded successfully',
      color: 'green'
    })
  } catch (error) {
    toast.add({
      title: 'Error',
      description: 'Failed to download SQL',
      color: 'error'
    })
  } finally {
    downloadingId.value = null
  }
}

const confirmDelete = (imp: Import) => {
  selectedImport.value = imp
  deleteVisible.value = true
}

const deleteImport = async () => {
  if (!selectedImport.value) return

  try {
    await importStore.deleteImport(selectedImport.value.id)
    await importStore.getStats() // Refresh stats
    toast.add({
      title: 'Success',
      description: 'Import deleted successfully',
      color: 'success'
    })
    deleteVisible.value = false
  } catch (error) {
    toast.add({
      title: 'Error',
      description: 'Failed to delete import',
      color: 'error'
    })
  }
}

const formatDate = (dateString: string): string => {
  const date = new Date(dateString)
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
}

const formatNumber = (num: number): string => {
  return num.toLocaleString()
}

const getStatusColor = (status: string): string => {
  switch (status) {
    case 'success': return 'success'
    case 'warning': return 'warning'
    case 'failed': return 'error'
    default: return 'neutral'
  }
}
</script>
