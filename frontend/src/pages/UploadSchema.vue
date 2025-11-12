<template>
  <div class="page-container">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <Card>
      <template #title>
        <h2 class="card-title">Upload SQL Schema</h2>
      </template>

      <template #subtitle>
        Upload your MySQL/MariaDB or PostgreSQL dump file to get started
      </template>

      <template #content>
      <!-- Important: Single Table Note -->
      <Message severity="info" :closable="false" class="pro-tip-message">
        <div class="tip-content">
          <strong>Pro Tip: Export Only Your Target Table</strong>
          <p class="tip-text">
            You only need the <strong>CREATE TABLE</strong> statement for the table you want to import data into.
            No need to upload your entire database dump!
          </p>
          <div class="code-example">
            <strong>Example export command:</strong><br/>
            <code class="code-block">mysqldump -u user -p --no-data database_name table_name &gt; table.sql</code>
            <code class="code-block">pg_dump -U user --schema-only -t table_name database &gt; table.sql</code>
          </div>
        </div>
      </Message>

      <!-- Upload Area -->
      <Panel header="SQL Schema File" class="upload-panel">
        <div
          class="upload-area"
          @click="fileInput?.click()"
          @dragover.prevent
          @drop.prevent="handleDrop"
        >
          <div class="upload-content">
            <i class="pi pi-cloud-upload upload-icon"></i>
            <p class="upload-title">
              Drop your SQL file here, or click to browse
            </p>
            <p class="upload-subtitle">
              Supports MySQL, MariaDB, and PostgreSQL dump files
            </p>
            <p class="upload-limit">
              A single table schema is typically &lt; 50KB
            </p>
          </div>
        </div>
        <input
          type="file"
          accept=".sql"
          @change="handleFileUpload"
          ref="fileInput"
          class="hidden-input"
        />
      </Panel>

      <!-- Loading State -->
      <div v-if="loading" class="loading-state">
        <i class="pi pi-spin pi-spinner loading-icon"></i>
        <p class="loading-title">Parsing your SQL schema...</p>
        <p class="loading-subtitle">This may take a few seconds</p>
      </div>

      <!-- Error State -->
      <Message v-if="error" severity="error" :closable="false" class="error-message">
        <strong>Upload Failed</strong>
        <p class="error-text">{{ error }}</p>
      </Message>

      <!-- Single Table Auto-Select Modal -->
      <div v-if="showSingleTableDialog" class="modal-overlay" @click="cancelSingleTableDialog">
        <div class="modal-content" @click.stop>
          <!-- Close button -->
          <button
            @click="cancelSingleTableDialog"
            class="modal-close"
            aria-label="Close"
          >
            <i class="pi pi-times"></i>
          </button>

          <div class="modal-body">
            <!-- Success Icon -->
            <div class="success-icon">
              <i class="pi pi-check-circle"></i>
            </div>

            <!-- Title -->
            <h3 class="modal-title">
              Single Table Detected
            </h3>

            <!-- Message -->
            <p class="modal-message">
              We found only <strong class="highlight-text">1 table</strong> in your schema:
            </p>

            <!-- Table Name -->
            <div class="table-info-box">
              <div class="table-info-content">
                <i class="pi pi-table table-info-icon"></i>
                <div class="table-info-details">
                  <p class="table-info-name">{{ store.tables[0]?.name }}</p>
                  <p class="table-info-columns">
                    {{ store.tables[0]?.fields.length }} column{{ store.tables[0]?.fields.length !== 1 ? 's' : '' }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Explanation -->
            <p class="modal-explanation">
              Since there's only one table, we'll auto-select it and skip the table selection step.
            </p>

            <!-- Action Buttons -->
            <div class="modal-actions">
              <Button
                @click="continueToProceed"
                label="Continue to Upload Data"
                icon="pi pi-arrow-right"
                iconPos="right"
                severity="success"
                class="modal-button-primary"
              />
              <Button
                @click="cancelSingleTableDialog"
                label="Upload a Different File"
                icon="pi pi-upload"
                outlined
                class="modal-button-secondary"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Success State -->
      <div v-if="store.hasSchema && !loading && !showSingleTableDialog" class="success-section">
        <!-- Success Banner -->
        <Message severity="success" :closable="false">
          <div class="success-content">
            <p class="success-title">Schema parsed successfully!</p>
            <p class="success-text">
              Found {{ store.tables.length }} table{{ store.tables.length !== 1 ? 's' : '' }} in your database dump
            </p>
          </div>
        </Message>

        <!-- Tables Preview -->
        <div class="tables-preview">
          <div class="preview-header">
            <h3 class="preview-title">Detected Tables</h3>
            <span class="preview-badge">
              {{ store.tables.length }} tables
            </span>
          </div>

          <div class="tables-grid-wrapper">
            <div class="tables-grid">
              <div
                v-for="table in store.tables"
                :key="table.name"
                class="table-card"
              >
                <div class="table-card-content">
                  <div class="table-card-icon">
                    <i class="pi pi-table"></i>
                  </div>
                  <div class="table-card-info">
                    <p class="table-card-name" :title="table.name">
                      {{ table.name }}
                    </p>
                    <p class="table-card-columns">
                      {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Continue Button (only show for multiple tables) -->
        <div v-if="store.tables.length > 1" class="action-buttons">
          <Button
            @click="fileInput?.click()"
            label="Upload a different file"
            icon="pi pi-refresh"
            text
            severity="success"
          />
          <Button
            @click="goToSelectTable"
            label="Continue to Table Selection"
            icon="pi pi-arrow-right"
            iconPos="right"
            severity="success"
          />
        </div>
      </div>
      </template>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import StepperNav from '../components/StepperNav.vue'
import Card from 'primevue/card'
import Panel from 'primevue/panel'
import Button from 'primevue/button'
import Message from 'primevue/message'

const router = useRouter()
const store = useMappingStore()
const fileInput = ref<HTMLInputElement>()
const loading = ref(false)
const error = ref('')
const showSingleTableDialog = ref(false)

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

<style scoped>
.page-container {
  padding: 1.5rem 1rem;
}

.card-title {
  font-size: 1.875rem;
  font-weight: 700;
}

.pro-tip-message {
  margin-bottom: 1.5rem;
  width: 100%;
}

.tip-content {
  flex: 1;
}

.tip-text {
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.code-example {
  font-size: 0.75rem;
  padding: 0.5rem;
  font-family: monospace;
  background: var(--p-surface-50);
}

.code-block {
  display: block;
  margin-top: 0.25rem;
}

.upload-panel {
  margin-bottom: 1.5rem;
}

.upload-area {
  border: 2px dashed var(--p-surface-border);
  border-radius: 0.75rem;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: border-color 0.2s;
}

.upload-area:hover {
  border-color: var(--p-primary-color);
}

.upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.upload-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: var(--p-primary-color);
}

.upload-title {
  font-size: 1.125rem;
  font-weight: 500;
  margin-bottom: 0.25rem;
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
  color: var(--p-primary-color);
  margin-bottom: 1rem;
}

.loading-title {
  font-weight: 500;
}

.loading-subtitle {
  font-size: 0.875rem;
  margin-top: 0.5rem;
  color: var(--p-text-muted-color);
}

.error-message {
  margin-bottom: 1rem;
  width: 100%;
}

.error-text {
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.modal-content {
  border-radius: 0.75rem;
  box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  padding: 2rem;
  max-width: 28rem;
  margin: 0 1rem;
  transform: scale(1);
  transition: transform 0.2s;
  position: relative;
  border: 1px solid var(--p-surface-border);
  background: var(--p-surface-0);
}

.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: none;
  border: none;
  color: var(--p-text-muted-color);
  cursor: pointer;
  font-size: 1.25rem;
  padding: 0.25rem;
  transition: color 0.2s;
}

.modal-close:hover {
  color: var(--p-text-color);
}

.modal-body {
  text-align: center;
}

.success-icon {
  width: 5rem;
  height: 5rem;
  background: var(--p-green-100);
  border-radius: 9999px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
  color: var(--p-green-600);
  font-size: 3rem;
}

.modal-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.75rem;
  color: var(--p-text-color);
}

.modal-message {
  margin-bottom: 0.5rem;
  color: var(--p-text-color);
}

.highlight-text {
  color: var(--p-green-600);
}

.table-info-box {
  background: var(--p-green-50);
  border: 1px solid var(--p-green-200);
  border-radius: 0.5rem;
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.table-info-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
}

.table-info-icon {
  color: var(--p-green-600);
  font-size: 1.5rem;
}

.table-info-details {
  text-align: left;
}

.table-info-name {
  font-weight: 700;
  color: var(--p-green-900);
  font-size: 1.125rem;
}

.table-info-columns {
  font-size: 0.875rem;
  color: var(--p-green-700);
}

.modal-explanation {
  font-size: 0.875rem;
  margin-bottom: 1.5rem;
  color: var(--p-text-muted-color);
}

.modal-actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.modal-button-primary {
  width: 100%;
}

.modal-button-secondary {
  width: 100%;
}

.success-section {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.success-content {
  flex: 1;
}

.success-title {
  font-weight: 500;
}

.success-text {
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.tables-preview {
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

.tables-grid-wrapper {
  background: linear-gradient(to bottom right, var(--p-surface-50), var(--p-green-50));
  border-radius: 0.5rem;
  padding: 1rem;
  max-height: 24rem;
  overflow-y: auto;
  border: 1px solid var(--p-surface-border);
}

.tables-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 0.75rem;
}

@media (min-width: 768px) {
  .tables-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1024px) {
  .tables-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.table-card {
  background: var(--p-surface-0);
  border: 1px solid var(--p-surface-border);
  border-radius: 0.5rem;
  padding: 0.75rem;
  transition: all 0.2s;
}

.table-card:hover {
  border-color: var(--p-green-300);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.table-card-content {
  display: flex;
  align-items: center;
}

.table-card-icon {
  width: 2rem;
  height: 2rem;
  background: var(--p-green-100);
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 0.5rem;
  color: var(--p-green-600);
  font-size: 0.875rem;
}

.table-card-info {
  flex: 1;
  min-width: 0;
}

.table-card-name {
  font-weight: 500;
  color: var(--p-text-color);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.table-card-columns {
  font-size: 0.75rem;
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
