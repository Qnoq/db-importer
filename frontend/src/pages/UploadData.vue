<template>
  <div class="page-container">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="main-card">
      <div class="page-header">
        <h2 class="page-title">Upload Data File</h2>
        <p class="page-description">
          Upload an Excel or CSV file containing your data
        </p>
      </div>

      <Message v-if="!store.hasSelectedTable" severity="warn" :closable="false">
        <div class="message-content">
          <p class="message-title">No table selected</p>
          <p class="message-text">Please select a table first before uploading data.</p>
        </div>
      </Message>

      <div v-else>
        <!-- Selected Table Info -->
        <Message severity="info" :closable="false" class="table-info">
          <div class="info-content">
            <p class="info-title">Target table selected</p>
            <p class="info-text">
              Importing to <strong>{{ store.selectedTable?.name }}</strong> ({{ store.selectedTable?.fields.length }} columns)
            </p>
          </div>
        </Message>

        <!-- Pro Tip: Column Naming -->
        <Message severity="success" :closable="false" class="pro-tip">
          <div class="tip-content">
            <div class="tip-icon">
              <i class="pi pi-lightbulb"></i>
            </div>
            <div class="tip-text">
              <h3 class="tip-title">Pro Tip: Name Your Excel Columns</h3>
              <p class="tip-description">
                For <strong>automatic column mapping</strong>, name your Excel headers to match your database field names.
              </p>
              <div class="tip-example">
                <strong>Example:</strong> If your database has <code class="code-snippet">sit_name</code>,
                <code class="code-snippet">sit_address</code>,
                <code class="code-snippet">sit_zipCode</code>
                → Use the same names in your Excel first row!
              </div>
              <p class="tip-footer">
                The system will auto-detect and map matching columns, saving you time!
              </p>
            </div>
          </div>
        </Message>

        <!-- Upload Area -->
        <div class="upload-section">
          <label class="upload-label">
            Data File
          </label>
          <div
            class="upload-area"
            @click="fileInput?.click()"
            @dragover.prevent
            @drop.prevent="handleDrop"
          >
            <div class="upload-content">
              <div class="upload-icon">
                <i class="pi pi-file-excel"></i>
              </div>
              <p class="upload-title">
                Drop your data file here, or click to browse
              </p>
              <p class="upload-subtitle">
                Supports Excel (.xlsx, .xls) and CSV files
              </p>
              <p class="upload-limit">
                Maximum file size: 50MB
              </p>
            </div>
          </div>
          <input
            type="file"
            accept=".xlsx,.xls,.csv"
            @change="handleFileUpload"
            ref="fileInput"
            class="hidden-input"
          />
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="loading-state">
          <i class="pi pi-spin pi-spinner loading-icon"></i>
          <p class="loading-title">Parsing your data file...</p>
          <p class="loading-subtitle">This may take a few seconds</p>
        </div>

        <!-- Error State -->
        <Message v-if="error" severity="error" :closable="false" class="error-message">
          <div class="message-content">
            <p class="message-title">Upload Failed</p>
            <p class="message-text">{{ error }}</p>
          </div>
        </Message>

        <!-- Success State with Data Preview -->
        <div v-if="store.hasExcelData && !loading" class="success-section">
          <!-- Success Banner -->
          <Message severity="success" :closable="false">
            <div class="info-content">
              <p class="info-title">Data loaded successfully!</p>
              <p class="info-text">
                Found {{ store.excelData.length }} rows with {{ store.excelHeaders.length }} columns
              </p>
            </div>
          </Message>

          <!-- Data Preview -->
          <div class="preview-section">
            <div class="preview-header">
              <h3 class="preview-title">Data Preview</h3>
              <span class="preview-badge">
                {{ store.excelData.length }} rows
              </span>
            </div>

            <div class="table-wrapper">
              <table class="data-table">
                <thead>
                  <tr>
                    <th class="table-header sticky-col">
                      #
                    </th>
                    <th
                      v-for="header in store.excelHeaders"
                      :key="header"
                      class="table-header"
                    >
                      {{ header }}
                    </th>
                  </tr>
                </thead>
                <tbody class="table-body">
                  <tr v-for="(row, index) in store.excelData.slice(0, 10)" :key="index" class="table-row">
                    <td class="table-cell sticky-col">{{ index + 1 }}</td>
                    <td
                      v-for="(cell, cellIndex) in row"
                      :key="cellIndex"
                      class="table-cell"
                    >
                      {{ cell }}
                    </td>
                  </tr>
                </tbody>
              </table>
              <p v-if="store.excelData.length > 10" class="table-footer">
                Showing first 10 rows of {{ store.excelData.length }} total rows
              </p>
            </div>
          </div>

          <!-- Continue Button -->
          <div class="action-buttons">
            <Button
              @click="fileInput?.click()"
              label="Upload a different file"
              icon="pi pi-refresh"
              text
              severity="success"
            />
            <Button
              @click="goToMapping"
              label="Continue to Column Mapping"
              icon="pi pi-arrow-right"
              iconPos="right"
              severity="success"
            />
          </div>
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
import Button from 'primevue/button'
import Message from 'primevue/message'
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

<style scoped>
.page-container {
  padding: 1.5rem 1rem;
}

.main-card {
  background: var(--p-surface-0);
  border: 1px solid var(--p-surface-border);
  border-radius: 0.75rem;
  padding: 2rem;
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  transition: colors 0.2s;
}

.page-header {
  margin-bottom: 2rem;
}

.page-title {
  font-size: 1.875rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: var(--p-text-color);
}

.page-description {
  color: var(--p-text-muted-color);
}

.message-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.message-title {
  font-weight: 500;
}

.message-text {
  font-size: 0.875rem;
}

.table-info {
  margin-bottom: 1.5rem;
}

.info-content {
  flex: 1;
}

.info-title {
  font-weight: 500;
}

.info-text {
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.pro-tip {
  margin-bottom: 1.5rem;
}

.tip-content {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.tip-icon {
  flex-shrink: 0;
  font-size: 1.25rem;
}

.tip-text {
  flex: 1;
}

.tip-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
  font-size: 1rem;
}

.tip-description {
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.tip-example {
  font-size: 0.875rem;
  background: var(--p-green-100);
  border-radius: 0.375rem;
  padding: 0.5rem 0.75rem;
}

.code-snippet {
  background: var(--p-surface-0);
  padding: 0.125rem 0.375rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
}

.tip-footer {
  font-size: 0.875rem;
  margin-top: 0.5rem;
}

.upload-section {
  margin-bottom: 1.5rem;
}

.upload-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.75rem;
  color: var(--p-text-color);
}

.upload-area {
  border: 2px dashed var(--p-surface-border);
  border-radius: 0.75rem;
  padding: 2rem;
  text-align: center;
  background: var(--p-surface-50);
  cursor: pointer;
  transition: border-color 0.2s;
}

.upload-area:hover {
  border-color: var(--p-green-400);
}

.upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.upload-icon {
  width: 4rem;
  height: 4rem;
  background: var(--p-green-100);
  border-radius: 9999px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1rem;
  color: var(--p-green-600);
  font-size: 1.875rem;
}

.upload-title {
  font-size: 1.125rem;
  font-weight: 500;
  margin-bottom: 0.25rem;
  color: var(--p-text-color);
}

.upload-subtitle {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.upload-limit {
  font-size: 0.75rem;
  margin-top: 0.5rem;
  color: var(--p-text-muted-color);
}

.hidden-input {
  display: none;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 0;
}

.loading-icon {
  font-size: 3rem;
  color: var(--p-green-600);
  margin-bottom: 1rem;
}

.loading-title {
  font-weight: 500;
  color: var(--p-text-color);
}

.loading-subtitle {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  color: var(--p-text-muted-color);
}

.error-message {
  margin-bottom: 1rem;
}

.success-section {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.preview-section {
  margin-top: 1.5rem;
}

.preview-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.preview-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--p-text-color);
}

.preview-badge {
  padding: 0.25rem 0.75rem;
  background: var(--p-green-100);
  color: var(--p-green-800);
  border-radius: 9999px;
  font-size: 0.875rem;
  font-weight: 500;
}

.table-wrapper {
  overflow-x: auto;
  background: linear-gradient(to bottom right, var(--p-surface-50), var(--p-green-50));
  border-radius: 0.5rem;
  padding: 1rem;
  border: 1px solid var(--p-surface-border);
}

.data-table {
  min-width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

.table-header {
  padding: 0.75rem 1rem;
  text-align: left;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-color);
  background: var(--p-surface-100);
}

.table-header.sticky-col {
  position: sticky;
  left: 0;
  z-index: 10;
}

.table-body {
  background: var(--p-surface-0);
}

.table-row {
  transition: background-color 0.2s;
}

.table-row:hover {
  background: var(--p-green-50);
}

.table-cell {
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  white-space: nowrap;
  color: var(--p-text-color);
  border-top: 1px solid var(--p-surface-border);
}

.table-cell.sticky-col {
  position: sticky;
  left: 0;
  font-weight: 500;
  color: var(--p-text-muted-color);
  background: var(--p-surface-0);
}

.table-row:hover .table-cell.sticky-col {
  background: var(--p-green-50);
}

.table-footer {
  font-size: 0.875rem;
  margin-top: 1rem;
  text-align: center;
  font-style: italic;
  color: var(--p-text-muted-color);
}

.action-buttons {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 1.5rem;
  border-top: 1px solid var(--p-surface-border);
}
</style>
