<template>
  <div class="p-6 max-w-7xl mx-auto">
    <!-- Page Header -->
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Import History</h1>
      <p class="text-gray-600">View and manage your import history</p>
    </div>

    <!-- Stats Cards -->
    <div v-if="importStore.stats" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <Card>
        <template #content>
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Total Imports</p>
              <p class="text-2xl font-bold">{{ importStore.stats.totalImports }}</p>
            </div>
            <i class="pi pi-database text-3xl text-blue-500"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Total Rows</p>
              <p class="text-2xl font-bold">{{ formatNumber(importStore.stats.totalRows) }}</p>
            </div>
            <i class="pi pi-chart-line text-3xl text-green-500"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Success Rate</p>
              <p class="text-2xl font-bold">{{ importStore.stats.successRate.toFixed(1) }}%</p>
            </div>
            <i class="pi pi-check-circle text-3xl text-emerald-500"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm text-gray-500">Most Used Table</p>
              <p class="text-lg font-bold truncate">{{ importStore.stats.mostUsedTable || 'N/A' }}</p>
            </div>
            <i class="pi pi-table text-3xl text-purple-500"></i>
          </div>
        </template>
      </Card>
    </div>

    <!-- Filters -->
    <Card class="mb-6">
      <template #content>
        <div class="flex flex-wrap gap-4 items-end">
          <div class="flex-1 min-w-[200px]">
            <label class="block text-sm font-medium text-gray-700 mb-2">Table Name</label>
            <InputText
              v-model="filters.tableName"
              placeholder="Filter by table name..."
              class="w-full"
            />
          </div>

          <div class="min-w-[150px]">
            <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <Dropdown
              v-model="filters.status"
              :options="statusOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="All statuses"
              class="w-full"
              showClear
            />
          </div>

          <Button
            label="Apply Filters"
            icon="pi pi-filter"
            @click="applyFilters"
            :loading="importStore.loading"
          />

          <Button
            label="Reset"
            icon="pi pi-refresh"
            severity="secondary"
            outlined
            @click="resetFilters"
          />
        </div>
      </template>
    </Card>

    <!-- Import List -->
    <Card>
      <template #content>
        <DataTable
          :value="importStore.imports"
          :loading="importStore.loading"
          paginator
          :rows="importStore.pageSize"
          :totalRecords="importStore.total"
          :lazy="true"
          @page="onPage"
          dataKey="id"
          responsiveLayout="scroll"
        >
          <template #empty>
            <div class="text-center py-8 text-gray-500">
              <i class="pi pi-inbox text-4xl mb-3"></i>
              <p>No imports found</p>
            </div>
          </template>

          <Column field="tableName" header="Table" sortable>
            <template #body="{ data }">
              <span class="font-medium">{{ data.tableName }}</span>
            </template>
          </Column>

          <Column field="rowCount" header="Rows" sortable>
            <template #body="{ data }">
              {{ formatNumber(data.rowCount) }}
            </template>
          </Column>

          <Column field="status" header="Status" sortable>
            <template #body="{ data }">
              <Tag
                :value="data.status"
                :severity="getStatusSeverity(data.status)"
              />
            </template>
          </Column>

          <Column field="errorCount" header="Errors">
            <template #body="{ data }">
              <span v-if="data.errorCount > 0" class="text-red-600 font-medium">
                {{ data.errorCount }}
              </span>
              <span v-else class="text-gray-400">0</span>
            </template>
          </Column>

          <Column field="warningCount" header="Warnings">
            <template #body="{ data }">
              <span v-if="data.warningCount > 0" class="text-orange-600 font-medium">
                {{ data.warningCount }}
              </span>
              <span v-else class="text-gray-400">0</span>
            </template>
          </Column>

          <Column field="createdAt" header="Date" sortable>
            <template #body="{ data }">
              {{ formatDate(data.createdAt) }}
            </template>
          </Column>

          <Column header="Actions" style="width: 200px">
            <template #body="{ data }">
              <div class="flex gap-2">
                <Button
                  icon="pi pi-eye"
                  text
                  rounded
                  severity="secondary"
                  v-tooltip.top="'View Details'"
                  @click="viewDetails(data)"
                />
                <Button
                  icon="pi pi-download"
                  text
                  rounded
                  severity="info"
                  v-tooltip.top="'Download SQL'"
                  @click="downloadSQL(data)"
                  :loading="downloadingId === data.id"
                />
                <Button
                  icon="pi pi-trash"
                  text
                  rounded
                  severity="danger"
                  v-tooltip.top="'Delete'"
                  @click="confirmDelete(data)"
                />
              </div>
            </template>
          </Column>
        </DataTable>
      </template>
    </Card>

    <!-- Details Dialog -->
    <Dialog
      v-model:visible="detailsVisible"
      :header="`Import Details - ${selectedImport?.tableName}`"
      :style="{ width: '50rem' }"
      :modal="true"
    >
      <div v-if="selectedImport" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-sm text-gray-500">Table Name</p>
            <p class="font-medium">{{ selectedImport.tableName }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Status</p>
            <Tag :value="selectedImport.status" :severity="getStatusSeverity(selectedImport.status)" />
          </div>
          <div>
            <p class="text-sm text-gray-500">Row Count</p>
            <p class="font-medium">{{ formatNumber(selectedImport.rowCount) }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Errors / Warnings</p>
            <p class="font-medium">{{ selectedImport.errorCount }} / {{ selectedImport.warningCount }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Created At</p>
            <p class="font-medium">{{ formatDate(selectedImport.createdAt) }}</p>
          </div>
          <div v-if="selectedImport.metadata.sourceFileName">
            <p class="text-sm text-gray-500">Source File</p>
            <p class="font-medium">{{ selectedImport.metadata.sourceFileName }}</p>
          </div>
        </div>

        <div v-if="selectedImport.metadata.validationErrors?.length">
          <p class="text-sm font-medium text-red-600 mb-2">Errors:</p>
          <ul class="list-disc list-inside text-sm text-gray-700 space-y-1">
            <li v-for="(error, idx) in selectedImport.metadata.validationErrors" :key="idx">
              {{ error }}
            </li>
          </ul>
        </div>

        <div v-if="selectedImport.metadata.validationWarnings?.length">
          <p class="text-sm font-medium text-orange-600 mb-2">Warnings:</p>
          <ul class="list-disc list-inside text-sm text-gray-700 space-y-1">
            <li v-for="(warning, idx) in selectedImport.metadata.validationWarnings" :key="idx">
              {{ warning }}
            </li>
          </ul>
        </div>
      </div>
    </Dialog>

    <!-- Delete Confirmation -->
    <Dialog
      v-model:visible="deleteVisible"
      header="Confirm Delete"
      :modal="true"
      :style="{ width: '30rem' }"
    >
      <div class="flex items-center gap-3">
        <i class="pi pi-exclamation-triangle text-3xl text-orange-500"></i>
        <span>Are you sure you want to delete this import?</span>
      </div>

      <template #footer>
        <Button label="Cancel" text @click="deleteVisible = false" />
        <Button label="Delete" severity="danger" @click="deleteImport" :loading="importStore.loading" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useImportStore, type Import } from '../store/importStore'
import { useToast } from 'primevue/usetoast'
import Card from 'primevue/card'
import Button from 'primevue/button'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Tag from 'primevue/tag'
import InputText from 'primevue/inputtext'
import Dropdown from 'primevue/dropdown'
import Dialog from 'primevue/dialog'

const router = useRouter()
const importStore = useImportStore()
const toast = useToast()

const filters = ref({
  tableName: '',
  status: null as 'success' | 'warning' | 'failed' | null
})

const statusOptions = [
  { label: 'Success', value: 'success' },
  { label: 'Warning', value: 'warning' },
  { label: 'Failed', value: 'failed' }
]

const selectedImport = ref<Import | null>(null)
const detailsVisible = ref(false)
const deleteVisible = ref(false)
const downloadingId = ref<string | null>(null)

onMounted(async () => {
  await importStore.getStats()
  await importStore.listImports({ page: 1, pageSize: 20 })
})

const applyFilters = async () => {
  await importStore.listImports({
    page: 1,
    pageSize: importStore.pageSize,
    tableName: filters.value.tableName || undefined,
    status: filters.value.status || undefined
  })
}

const resetFilters = async () => {
  filters.value.tableName = ''
  filters.value.status = null
  await importStore.listImports({ page: 1, pageSize: 20 })
}

const onPage = async (event: any) => {
  await importStore.listImports({
    page: event.page + 1,
    pageSize: event.rows,
    tableName: filters.value.tableName || undefined,
    status: filters.value.status || undefined
  })
}

const viewDetails = (imp: Import) => {
  selectedImport.value = imp
  detailsVisible.value = true
}

const downloadSQL = async (imp: Import) => {
  downloadingId.value = imp.id
  try {
    const importWithSQL = await importStore.getImportWithSQL(imp.id)
    const filename = `${imp.tableName}_${imp.createdAt.replace(/[:.]/g, '-')}.sql`
    importStore.downloadSQL(importWithSQL.generatedSql, filename)
    toast.add({ severity: 'success', summary: 'Success', detail: 'SQL downloaded successfully', life: 3000 })
  } catch (error) {
    toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to download SQL', life: 3000 })
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
    toast.add({ severity: 'success', summary: 'Success', detail: 'Import deleted successfully', life: 3000 })
    deleteVisible.value = false
  } catch (error) {
    toast.add({ severity: 'error', summary: 'Error', detail: 'Failed to delete import', life: 3000 })
  }
}

const formatDate = (dateString: string): string => {
  const date = new Date(dateString)
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
}

const formatNumber = (num: number): string => {
  return num.toLocaleString()
}

const getStatusSeverity = (status: string): 'success' | 'warning' | 'danger' => {
  switch (status) {
    case 'success': return 'success'
    case 'warning': return 'warning'
    case 'failed': return 'danger'
    default: return 'info'
  }
}
</script>

<style scoped>
:deep(.p-card) {
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

:deep(.p-datatable) {
  border-radius: 8px;
  overflow: hidden;
}
</style>
