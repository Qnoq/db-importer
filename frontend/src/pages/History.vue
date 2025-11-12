<template>
  <div class="history-page">
    <Toast />

    <!-- Page Header -->
    <div class="page-header">
      <h1>Import History</h1>
      <p class="header-subtitle">View and manage your import history</p>
    </div>

    <!-- Stats Cards -->
    <div v-if="importStore.stats" class="stats-grid">
      <Card>
        <template #content>
          <div class="stat-card-content">
            <div>
              <p class="stat-label">Total Imports</p>
              <p class="stat-value">{{ importStore.stats.totalImports }}</p>
            </div>
            <i class="pi pi-database stat-icon" style="color: var(--p-primary-color)"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="stat-card-content">
            <div>
              <p class="stat-label">Total Rows</p>
              <p class="stat-value">{{ formatNumber(importStore.stats.totalRows) }}</p>
            </div>
            <i class="pi pi-chart-line stat-icon" style="color: var(--p-green-500)"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="stat-card-content">
            <div>
              <p class="stat-label">Success Rate</p>
              <p class="stat-value">{{ importStore.stats.successRate.toFixed(1) }}%</p>
            </div>
            <i class="pi pi-check-circle stat-icon" style="color: var(--p-green-600)"></i>
          </div>
        </template>
      </Card>

      <Card>
        <template #content>
          <div class="stat-card-content">
            <div>
              <p class="stat-label">Most Used Table</p>
              <p class="stat-value-text">{{ importStore.stats.mostUsedTable || 'N/A' }}</p>
            </div>
            <i class="pi pi-table stat-icon" style="color: var(--p-purple-500)"></i>
          </div>
        </template>
      </Card>
    </div>

    <!-- Filters -->
    <Card class="filters-card">
      <template #content>
        <div class="filters-wrapper">
          <div class="filter-field">
            <label class="filter-label">Table Name</label>
            <InputText
              v-model="filters.tableName"
              placeholder="Filter by table name..."
            />
          </div>

          <div class="filter-field-narrow">
            <label class="filter-label">Status</label>
            <Dropdown
              v-model="filters.status"
              :options="statusOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="All statuses"
              showClear
            />
          </div>
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
            <div class="empty-state">
              <i class="pi pi-inbox empty-icon"></i>
              <p>No imports found</p>
            </div>
          </template>

          <Column field="tableName" header="Table" sortable>
            <template #body="{ data }">
              <span class="table-name">{{ data.tableName }}</span>
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
              <span v-if="data.errorCount > 0" class="error-count">
                {{ data.errorCount }}
              </span>
              <span v-else style="color: var(--p-text-muted-color)">0</span>
            </template>
          </Column>

          <Column field="warningCount" header="Warnings">
            <template #body="{ data }">
              <span v-if="data.warningCount > 0" class="warning-count">
                {{ data.warningCount }}
              </span>
              <span v-else style="color: var(--p-text-muted-color)">0</span>
            </template>
          </Column>

          <Column field="createdAt" header="Date" sortable>
            <template #body="{ data }">
              {{ formatDate(data.createdAt) }}
            </template>
          </Column>

          <Column header="Actions" style="width: 200px">
            <template #body="{ data }">
              <div class="action-buttons">
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
      :style="{ width: '60rem' }"
      :modal="true"
    >
      <div v-if="selectedImport" class="details-content">
        <!-- Basic Info -->
        <div class="details-grid">
          <div class="detail-item">
            <p class="detail-label">Table Name</p>
            <p class="detail-value">{{ selectedImport.tableName }}</p>
          </div>
          <div class="detail-item">
            <p class="detail-label">Status</p>
            <Tag :value="selectedImport.status" :severity="getStatusSeverity(selectedImport.status)" />
          </div>
          <div class="detail-item">
            <p class="detail-label">Row Count</p>
            <p class="detail-value">{{ formatNumber(selectedImport.rowCount) }}</p>
          </div>
          <div class="detail-item">
            <p class="detail-label">Errors / Warnings</p>
            <p class="detail-value">{{ selectedImport.errorCount }} / {{ selectedImport.warningCount }}</p>
          </div>
          <div class="detail-item">
            <p class="detail-label">Created At</p>
            <p class="detail-value">{{ formatDate(selectedImport.createdAt) }}</p>
          </div>
          <div v-if="selectedImport.metadata.sourceFileName" class="detail-item">
            <p class="detail-label">Source File</p>
            <p class="detail-value-truncate" :title="selectedImport.metadata.sourceFileName">{{ selectedImport.metadata.sourceFileName }}</p>
          </div>
        </div>

        <!-- Column Mapping -->
        <div v-if="selectedImport.metadata.mappingSummary && Object.keys(selectedImport.metadata.mappingSummary).length > 0" class="detail-section">
          <p class="section-title">Column Mapping:</p>
          <div class="mapping-box">
            <div class="mapping-grid">
              <div v-for="(dbCol, excelCol) in selectedImport.metadata.mappingSummary" :key="excelCol" class="mapping-item">
                <span class="mapping-source">{{ excelCol }}</span>
                <i class="pi pi-arrow-right mapping-arrow"></i>
                <span class="mapping-target">{{ dbCol }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Transformations -->
        <div v-if="selectedImport.metadata.transformations && selectedImport.metadata.transformations.length > 0" class="detail-section">
          <p class="section-title">Transformations Applied:</p>
          <div class="transformations-box">
            <ul class="list-disc">
              <li v-for="(transformation, idx) in selectedImport.metadata.transformations" :key="idx">
                {{ transformation }}
              </li>
            </ul>
          </div>
        </div>

        <!-- SQL Preview -->
        <div v-if="selectedImportSQL" class="detail-section">
          <div class="sql-header">
            <p class="section-title">SQL Preview:</p>
            <Button
              label="Download Full SQL"
              icon="pi pi-download"
              size="small"
              severity="secondary"
              outlined
              @click="downloadFullSQL"
            />
          </div>
          <div class="sql-preview">
            <pre class="sql-code">{{ getSQLPreview(selectedImportSQL) }}</pre>
          </div>
        </div>

        <!-- Errors -->
        <div v-if="selectedImport.metadata.validationErrors?.length" class="detail-section">
          <p class="section-title error-title">Errors:</p>
          <div class="errors-box">
            <ul class="list-disc">
              <li v-for="(error, idx) in selectedImport.metadata.validationErrors" :key="idx">
                {{ error }}
              </li>
            </ul>
          </div>
        </div>

        <!-- Warnings -->
        <div v-if="selectedImport.metadata.validationWarnings?.length" class="detail-section">
          <p class="section-title warning-title">Warnings:</p>
          <div class="warnings-box">
            <ul class="list-disc">
              <li v-for="(warning, idx) in selectedImport.metadata.validationWarnings" :key="idx">
                {{ warning }}
              </li>
            </ul>
          </div>
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
      <div class="delete-content">
        <i class="pi pi-exclamation-triangle delete-icon"></i>
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
import { ref, onMounted, watch } from 'vue'
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
import Toast from 'primevue/toast'

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
const selectedImportSQL = ref<string | null>(null)
const detailsVisible = ref(false)
const deleteVisible = ref(false)
const downloadingId = ref<string | null>(null)

// Debounce timer for auto-filtering
let filterDebounceTimer: ReturnType<typeof setTimeout> | null = null

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
    await importStore.listImports({
      page: 1,
      pageSize: importStore.pageSize,
      tableName: filters.value.tableName || undefined,
      status: filters.value.status || undefined
    })
  }, 500)
}, { deep: true })

const onPage = async (event: any) => {
  await importStore.listImports({
    page: event.page + 1,
    pageSize: event.rows,
    tableName: filters.value.tableName || undefined,
    status: filters.value.status || undefined
  })
}

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
    toast.add({ severity: 'warn', summary: 'Warning', detail: 'Failed to load SQL preview', life: 3000 })
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
  toast.add({ severity: 'success', summary: 'Success', detail: 'SQL downloaded successfully', life: 3000 })
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
    default: return 'warning'
  }
}
</script>

<style scoped>
.history-page {
  padding: 1.5rem;
  max-width: 112rem;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 1.5rem;
}

.page-header h1 {
  font-size: 1.875rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
}

.header-subtitle {
  color: var(--p-text-muted-color);
  margin: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
  margin: 0 0 0.25rem 0;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
}

.stat-value-text {
  font-size: 1.125rem;
  font-weight: 700;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.stat-icon {
  font-size: 1.875rem;
}

.filters-card {
  margin-bottom: 1.5rem;
}

.filters-wrapper {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.filter-field {
  flex: 1;
  min-width: 200px;
}

.filter-field-narrow {
  min-width: 150px;
}

.filter-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.empty-state {
  text-align: center;
  padding: 2rem 0;
  color: var(--p-text-muted-color);
}

.empty-icon {
  font-size: 2.25rem;
  margin-bottom: 0.75rem;
}

.table-name {
  font-weight: 500;
}

.error-count {
  font-weight: 500;
  color: var(--p-red-500);
}

.warning-count {
  font-weight: 500;
  color: var(--p-orange-500);
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.details-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
}

.detail-label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
  margin: 0 0 0.25rem 0;
}

.detail-value {
  font-weight: 500;
  margin: 0;
}

.detail-value-truncate {
  font-weight: 500;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.detail-section {
  margin-top: 1rem;
}

.section-title {
  font-size: 0.875rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  color: var(--p-text-color);
}

.error-title {
  color: var(--p-red-600);
}

.warning-title {
  color: var(--p-orange-600);
}

.mapping-box {
  background: var(--p-surface-50);
  border-radius: 0.5rem;
  padding: 0.75rem;
  max-height: 10rem;
  overflow-y: auto;
}

.mapping-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
  font-size: 0.875rem;
}

.mapping-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.mapping-source {
  color: var(--p-text-muted-color);
}

.mapping-arrow {
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.mapping-target {
  font-weight: 500;
  color: var(--p-text-color);
}

.transformations-box {
  background: var(--p-blue-50);
  border-radius: 0.5rem;
  padding: 0.75rem;
}

.list-disc {
  list-style-type: disc;
  list-style-position: inside;
  font-size: 0.875rem;
  margin: 0;
  padding-left: 0;
}

.list-disc li {
  margin-bottom: 0.25rem;
  color: var(--p-text-color);
}

.sql-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.sql-preview {
  background: var(--p-surface-900);
  border-radius: 0.5rem;
  padding: 1rem;
  max-height: 15rem;
  overflow-y: auto;
}

.sql-code {
  font-size: 0.875rem;
  color: var(--p-green-400);
  white-space: pre-wrap;
  font-family: monospace;
  margin: 0;
}

.errors-box {
  background: var(--p-red-50);
  border-radius: 0.5rem;
  padding: 0.75rem;
  max-height: 8rem;
  overflow-y: auto;
}

.warnings-box {
  background: var(--p-orange-50);
  border-radius: 0.5rem;
  padding: 0.75rem;
  max-height: 8rem;
  overflow-y: auto;
}

.delete-content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.delete-icon {
  font-size: 1.875rem;
  color: var(--p-orange-500);
}

:deep(.p-card) {
  border-radius: 12px;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

:deep(.p-datatable) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.p-inputtext) {
  width: 100%;
}

:deep(.p-dropdown) {
  width: 100%;
}
</style>
