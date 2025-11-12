<template>
  <div class="page-container">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <div class="main-card">
      <h2 class="page-title">Select Target Table</h2>
      <p class="page-description">
        Choose the table where you want to import data
      </p>

      <Message v-if="!store.hasSchema" severity="warn" :closable="false">
        <p>No schema loaded. Please upload a SQL file first.</p>
        <Button
          @click="router.push('/')"
          label="Go back to upload schema"
          icon="pi pi-arrow-left"
          severity="secondary"
          text
          class="mt-3"
        />
      </Message>

      <div v-else>
        <!-- Search and Stats Bar -->
        <div class="search-section">
          <!-- Search Input -->
          <div class="search-wrapper">
            <div class="search-icon">
              <i class="pi pi-search"></i>
            </div>
            <InputText
              v-model="searchQuery"
              type="text"
              placeholder="Search tables by name..."
              class="search-input"
            />
            <div v-if="searchQuery" class="clear-icon">
              <button @click="searchQuery = ''" class="clear-button">
                <i class="pi pi-times"></i>
              </button>
            </div>
          </div>

          <!-- Stats and Sorting -->
          <div class="stats-bar">
            <div class="stats-info">
              <div class="stat-item">
                <i class="pi pi-database stat-icon"></i>
                <span class="stat-text">
                  {{ filteredTables.length }} of {{ store.tables.length }} tables
                </span>
              </div>
              <div v-if="selectedTableName" class="stat-item selected">
                <i class="pi pi-check-circle"></i>
                <span class="stat-text">1 selected</span>
              </div>
            </div>

            <div class="sort-controls">
              <label class="sort-label">Sort by:</label>
              <select v-model="sortBy" class="sort-select">
                <option value="name">Name A-Z</option>
                <option value="name-desc">Name Z-A</option>
                <option value="columns">Columns (Low-High)</option>
                <option value="columns-desc">Columns (High-Low)</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="filteredTables.length === 0" class="empty-state">
          <i class="pi pi-inbox empty-icon"></i>
          <p class="empty-title">No tables found</p>
          <p class="empty-subtitle">Try adjusting your search query</p>
          <Button
            @click="searchQuery = ''"
            label="Clear search"
            text
            class="mt-4"
          />
        </div>

        <!-- Table Grid -->
        <div v-else class="table-grid">
          <div
            v-for="table in paginatedTables"
            :key="table.name"
            @click="selectTable(table.name)"
            class="table-card"
            :class="{ 'selected': selectedTableName === table.name }"
          >
            <!-- Table Header -->
            <div class="table-header">
              <div class="table-info">
                <div class="table-icon">
                  <i class="pi pi-table"></i>
                </div>
                <div class="table-details">
                  <h3 class="table-name" :title="table.name">
                    {{ table.name }}
                  </h3>
                  <p class="table-columns">
                    <i class="pi pi-list"></i>
                    {{ table.fields.length }} column{{ table.fields.length !== 1 ? 's' : '' }}
                  </p>
                </div>
              </div>
              <div v-if="selectedTableName === table.name" class="check-icon">
                <i class="pi pi-check-circle"></i>
              </div>
            </div>

            <!-- Column Preview -->
            <div class="column-preview">
              <p class="preview-title">Columns</p>
              <div class="column-list">
                <div
                  v-for="field in table.fields.slice(0, 4)"
                  :key="field.name"
                  class="column-item"
                >
                  <i class="pi pi-circle-fill column-bullet"></i>
                  <span class="column-name">{{ field.name }}</span>
                  <span class="column-type">{{ formatType(field.type) }}</span>
                </div>
                <div v-if="table.fields.length > 4" class="column-more">
                  + {{ table.fields.length - 4 }} more...
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="filteredTables.length > itemsPerPage" class="pagination-wrapper">
          <div class="pagination-info">
            Showing {{ (currentPage - 1) * itemsPerPage + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredTables.length) }} of {{ filteredTables.length }} tables
          </div>
          <div class="pagination-controls">
            <Button
              @click="currentPage--"
              :disabled="currentPage === 1"
              icon="pi pi-chevron-left"
              outlined
              size="small"
            />
            <div class="page-numbers">
              <Button
                v-for="page in visiblePages"
                :key="page"
                @click="currentPage = page"
                :label="String(page)"
                :outlined="page !== currentPage"
                :severity="page === currentPage ? 'success' : undefined"
                size="small"
              />
            </div>
            <Button
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              icon="pi pi-chevron-right"
              outlined
              size="small"
            />
          </div>
        </div>

        <!-- Continue Button -->
        <Message v-if="selectedTableName" severity="success" :closable="false" class="mt-8">
          <div class="selection-message">
            <div class="selection-info">
              <i class="pi pi-check-circle selection-icon"></i>
              <div>
                <p class="selection-title">Table selected: {{ selectedTableName }}</p>
                <p class="selection-subtitle">Ready to upload your data file</p>
              </div>
            </div>
            <Button
              @click="goToUploadData"
              label="Continue to Data Upload"
              icon="pi pi-arrow-right"
              iconPos="right"
              severity="success"
            />
          </div>
        </Message>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import StepperNav from '../components/StepperNav.vue'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import Message from 'primevue/message'

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
watch(searchQuery, resetPage)
watch(sortBy, resetPage)
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

.page-title {
  font-size: 1.875rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: var(--p-text-color);
}

.page-description {
  margin-bottom: 1.5rem;
  color: var(--p-text-muted-color);
}

.search-section {
  margin-bottom: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.search-wrapper {
  position: relative;
}

.search-icon {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  padding-left: 0.75rem;
  display: flex;
  align-items: center;
  pointer-events: none;
  z-index: 10;
  color: var(--p-text-muted-color);
}

.search-input {
  width: 100%;
  padding-left: 2.5rem;
  padding-right: 2.5rem;
}

.clear-icon {
  position: absolute;
  top: 0;
  bottom: 0;
  right: 0;
  padding-right: 0.75rem;
  display: flex;
  align-items: center;
  z-index: 10;
}

.clear-button {
  background: none;
  border: none;
  color: var(--p-text-muted-color);
  cursor: pointer;
  transition: color 0.2s;
  padding: 0.25rem;
}

.clear-button:hover {
  color: var(--p-text-color);
}

.stats-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--p-surface-50);
  border-radius: 0.5rem;
  padding: 0.75rem 1rem;
}

.stats-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 0.875rem;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.stat-icon {
  color: var(--p-green-500);
}

.stat-item.selected {
  color: var(--p-green-500);
}

.stat-text {
  font-weight: 500;
  color: var(--p-text-color);
}

.stat-item.selected .stat-text {
  color: var(--p-green-500);
}

.sort-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.sort-label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.sort-select {
  font-size: 0.875rem;
  border: 1px solid var(--p-surface-border);
  border-radius: 0.375rem;
  padding: 0.25rem 0.75rem;
  background: var(--p-surface-0);
  color: var(--p-text-color);
  outline: none;
  transition: all 0.2s;
}

.sort-select:focus {
  outline: 2px solid var(--p-green-500);
  outline-offset: 2px;
}

.empty-state {
  text-align: center;
  padding: 3rem 0;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  color: var(--p-surface-300);
}

.empty-title {
  font-size: 1.125rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
  color: var(--p-text-muted-color);
}

.empty-subtitle {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.table-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

@media (min-width: 768px) {
  .table-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1024px) {
  .table-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.table-card {
  border: 2px solid var(--p-surface-border);
  border-radius: 0.5rem;
  padding: 1.25rem;
  cursor: pointer;
  transition: all 0.2s;
  background: var(--p-surface-0);
}

.table-card:hover {
  border-color: var(--p-green-300);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.table-card.selected {
  border-color: var(--p-green-500);
  background: var(--p-green-50);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.table-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.table-info {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
  gap: 0.75rem;
}

.table-icon {
  flex-shrink: 0;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 0.5rem;
  background: var(--p-green-100);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--p-green-600);
  font-size: 1.125rem;
}

.table-details {
  flex: 1;
  min-width: 0;
}

.table-name {
  font-weight: 600;
  font-size: 1.125rem;
  color: var(--p-text-color);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.table-columns {
  font-size: 0.875rem;
  margin-top: 0.25rem;
  color: var(--p-text-muted-color);
}

.table-columns i {
  font-size: 0.75rem;
  margin-right: 0.25rem;
}

.check-icon {
  flex-shrink: 0;
  margin-left: 0.5rem;
  color: var(--p-green-600);
  font-size: 1.25rem;
}

.column-preview {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--p-surface-border);
}

.preview-title {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: var(--p-text-muted-color);
}

.column-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.column-item {
  display: flex;
  align-items: center;
  font-size: 0.875rem;
}

.column-bullet {
  font-size: 0.5rem;
  margin-right: 0.5rem;
  color: var(--p-surface-400);
}

.column-name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: var(--p-text-color);
}

.column-type {
  margin-left: auto;
  padding-left: 0.5rem;
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.column-more {
  font-size: 0.75rem;
  font-style: italic;
  padding-left: 1rem;
  color: var(--p-text-muted-color);
}

.pagination-wrapper {
  margin-top: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid var(--p-surface-border);
  padding-top: 1.5rem;
}

.pagination-info {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.page-numbers {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.selection-message {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.selection-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.selection-icon {
  font-size: 1.5rem;
}

.selection-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.selection-subtitle {
  font-size: 0.875rem;
}

.mt-3 {
  margin-top: 0.75rem;
}

.mt-4 {
  margin-top: 1rem;
}

.mt-8 {
  margin-top: 2rem;
}
</style>
