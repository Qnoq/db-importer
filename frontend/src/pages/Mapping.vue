<template>
  <div class="mapping-page px-4 py-6 sm:px-8">
    <!-- Progress Stepper with Navigation -->
    <StepperNav />

    <!-- Scroll to Top/Bottom Button -->
    <UButton
      v-if="showScrollButton"
      @click="scrollToTopOrBottom"
      :icon="isNearBottom ? 'i-heroicons-arrow-up' : 'i-heroicons-arrow-down'"
      color="primary"
      size="lg"
      class="fixed bottom-8 right-8 z-50 shadow-lg"
      :aria-label="isNearBottom ? 'Scroll to top' : 'Scroll to bottom'"
    >
      {{ isNearBottom ? 'Top' : 'Bottom' }}
    </UButton>

    <div class="main-card bg-white dark:bg-gray-950 rounded-lg border border-gray-200 dark:border-gray-800 shadow-md p-6">
      <!-- Header -->
      <div class="page-header mb-6 flex justify-between items-center">
        <div>
          <h2 class="page-title text-3xl font-bold mb-2 text-gray-900 dark:text-white">Map Columns</h2>
          <p class="page-subtitle text-gray-600 dark:text-gray-400">
            Match your Excel/CSV columns to database fields and apply transformations
          </p>
        </div>
      </div>

      <!-- Mapping Header Component (Alerts & Info Banners) -->
      <MappingHeader
        :show-missing-data-alert="!isLoadingData && (!store.hasExcelData || !store.hasSelectedTable)"
        :auto-mapping-stats="autoMappingStats"
        :sample-field-names="store.selectedTable?.fields.slice(0, 2).map(f => f.name) || []"
        :auto-increment-fields="getAutoIncrementFieldNames()"
        :is-restoring="isLoadingData"
        :table-name="store.selectedTable?.name"
        :data-row-count="store.excelData.length"
        :validation-stats="validationStats"
        @start-over="router.push('/')"
      />

      <!-- Column Mapping Section -->
      <div class="mapping-section mb-6">
        <div class="section-header flex justify-between items-center mb-4">
          <h3 class="section-title text-lg font-semibold text-gray-900 dark:text-white">Column Mapping</h3>

          <!-- Mapping Actions Component (Auto-map & Clear All buttons) -->
          <MappingActions
            :is-restoring="isLoadingData"
            :has-mapping="Object.keys(localMapping).length > 0"
            @auto-map="autoMap"
            @clear-all="showClearDialog = true"
          />
        </div>

        <!-- Skeleton Loading State -->
        <div v-if="isLoadingData" class="mapping-list space-y-3">
            <div v-for="i in 5" :key="`skeleton-${i}`" class="mapping-card border-2 border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 rounded-lg p-4">
              <div class="mapping-grid grid grid-cols-1 md:grid-cols-5 gap-4 items-center">
                <div class="field-column flex flex-col gap-2">
                  <USkeleton class="h-3 w-24" />
                  <div class="flex items-center gap-2">
                    <USkeleton class="h-8 w-8 rounded" />
                    <div class="flex-1 space-y-2">
                      <USkeleton class="h-4 w-32" />
                      <USkeleton class="h-3 w-20" />
                    </div>
                  </div>
                </div>
                <div class="arrow-column flex justify-center">
                  <USkeleton class="h-6 w-6" />
                </div>
                <div class="excel-column flex flex-col gap-2">
                  <USkeleton class="h-3 w-24" />
                  <USkeleton class="h-10 w-full" />
                  <USkeleton class="h-3 w-28" />
                </div>
                <div class="transform-column flex flex-col gap-2">
                  <USkeleton class="h-3 w-28" />
                  <USkeleton class="h-10 w-full" />
                  <USkeleton class="h-3 w-full" />
                </div>
                <div class="actions-column flex gap-2 justify-end items-center">
                  <USkeleton class="h-8 w-16 rounded" />
                </div>
              </div>
            </div>
          </div>

          <!-- Actual Mapping Content with MappingCard Components -->
          <div v-else-if="store.hasExcelData && store.hasSelectedTable" class="mapping-list space-y-3">
            <MappingCard
              v-for="(field, index) in store.selectedTable?.fields"
              :key="index"
              :field="field"
              :selected-excel-column="getMappedExcelColumn(field.name)"
              :excel-headers="store.excelHeaders"
              :selected-transformation="fieldTransformations[field.name] || 'none'"
              :available-transformations="getTransformationOptions(field)"
              :has-warning="hasYearWarning(field.name)"
              :is-mapped="!!getMappedExcelColumn(field.name)"
              :sample-value="getMappedExcelColumn(field.name) ? getSampleValue(getMappedExcelColumn(field.name)!) : undefined"
              :is-auto-increment="isAutoIncrementField(field)"
              @update:selected-excel-column="(value) => onFieldMappingChange(field.name, value)"
              @update:selected-transformation="(value) => store.updateTransformation(field.name, value)"
              @preview-transformation="showTransformPreviewForField(field.name)"
              @skip-field="toggleSkipField(field.name)"
            />
          </div>
        </div>

        <!-- ValidationSummary Component (Errors, Warnings, Preview) -->
        <ValidationSummary
          v-if="store.hasExcelData && store.hasSelectedTable"
          :validation-errors="validationErrors"
          :transformation-warnings="transformationWarnings"
          :server-validation-errors="serverValidationErrors"
          :show-preview="showPreview"
          :preview-data="previewData"
          :mapped-headers="mappedHeaders"
          :cell-validations="cellValidations"
          @update:show-preview="showPreview = $event"
        />

        <!-- GenerateSQLPanel Component (Action Buttons) -->
        <GenerateSQLPanel
          v-if="store.hasExcelData && store.hasSelectedTable"
          :validation-errors="validationErrors"
          :is-restoring="isLoadingData"
          :is-loading="loading"
          :error="error"
          :is-authenticated="authStore.isAuthenticated"
          @preview-data="showPreview = !showPreview"
          @generate-sql="generateSQL"
          @generate-and-save="generateAndSave"
        />
    </div>

    <!-- TransformPreviewModal Component -->
    <TransformPreviewModal
      v-model:is-open="showTransformPreview"
      :column-name="transformPreviewColumn"
      :transformation-label="transformPreviewColumn && fieldTransformations[transformPreviewColumn] ? transformations[fieldTransformations[transformPreviewColumn]]?.label : ''"
      :transformation-description="transformPreviewColumn && fieldTransformations[transformPreviewColumn] ? transformations[fieldTransformations[transformPreviewColumn]]?.description : ''"
      :preview-data="getTransformPreview(transformPreviewColumn || '')"
    />

    <!-- Clear Mappings Confirmation Modal -->
    <UModal
      v-model:open="showClearDialog"
      title="Confirm Clear All"
      description="This will remove all mappings and transformations."
      :ui="{ content: 'sm:max-w-md' }"
    >
      <template #body>
        <div class="flex gap-4">
          <span class="text-3xl flex-shrink-0">⚠️</span>
          <p class="text-gray-900 dark:text-white pt-1">Are you sure you want to clear all column mappings?</p>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-2">
          <UButton @click="showClearDialog = false" color="neutral" variant="soft">
            Cancel
          </UButton>
          <UButton @click="confirmClearMappings" color="error">
            Clear All
          </UButton>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import StepperNav from '../components/StepperNav.vue'
import MappingHeader from '../components/mapping/MappingHeader.vue'
import MappingActions from '../components/mapping/MappingActions.vue'
import MappingCard from '../components/mapping/MappingCard.vue'
import ValidationSummary from '../components/mapping/ValidationSummary.vue'
import GenerateSQLPanel from '../components/mapping/GenerateSQLPanel.vue'
import TransformPreviewModal from '../components/mapping/TransformPreviewModal.vue'
import { useMappingStore, Field } from '../store/mappingStore'
import { useAuthStore } from '../store/authStore'
import { useImportStore } from '../store/importStore'
import { useWorkflowSessionStore } from '../store/workflowSessionStore'
import { transformations } from '../utils/transformations'
import { useMapping } from '../composables/useMapping'
import { useValidation } from '../composables/useValidation'
import { useSQLGeneration } from '../composables/useSQLGeneration'

const router = useRouter()
const store = useMappingStore()
const authStore = useAuthStore()
const importStore = useImportStore()
const sessionStore = useWorkflowSessionStore()

// Use mapping composable
const {
  localMapping,
  fieldToExcelMapping,
  autoMappingStats,
  autoMap,
  updateMapping,
  syncFieldToExcelMapping,
  confirmClearMappings,
  getMappedExcelColumn,
  onFieldMappingChange,
  toggleSkipField,
  getSampleValue,
  isAutoIncrementField,
  getAutoIncrementFieldNames,
  getTransformationOptions
} = useMapping()

// Use validation composable
const {
  cellValidations,
  validationStats,
  validationErrors,
  transformationWarnings,
  previewData,
  mappedHeaders,
  validateData,
  getCellValidationClass,
  getCellValidationMessage,
  getCellValidationIcon,
  formatCellValue,
  hasYearWarning,
  getTransformPreview
} = useValidation(localMapping, getMappedExcelColumn, isAutoIncrementField)

// Use SQL generation composable
const {
  loading,
  error,
  serverValidationErrors,
  showPreview,
  generateSQL,
  generateAndSave,
  downloadSQL
} = useSQLGeneration(localMapping, validationStats)

// Field transformations (from store)
const fieldTransformations = computed(() => store.transformations)

// Loading state - show skeleton if restoring OR if data is not fully loaded yet
const isLoadingData = computed(() => {
  return sessionStore.isRestoring ||
         !store.selectedTable ||
         !store.excelHeaders ||
         store.excelHeaders.length === 0
})

// UI state
const showClearDialog = ref(false)
const transformPreviewColumn = ref<string | null>(null)
const showTransformPreview = ref(false)

// Scroll button state
const showScrollButton = ref(false)
const isNearBottom = ref(false)

// Lifecycle hooks
onMounted(() => {
  // Initialize localMapping from store first (for session restoration)
  if (Object.keys(store.mapping).length > 0) {
    localMapping.value = { ...store.mapping }
  }

  // Initialize auto-mapping (only if no mapping exists yet and not restoring)
  if (!sessionStore.isRestoring && Object.keys(localMapping.value).length === 0) {
    autoMap()
  } else {
    // If we have mapping, just sync it
    syncFieldToExcelMapping()
  }

  validateData()

  // Add scroll listener for scroll button
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

// Watchers
watch(() => store.mapping, (newMapping) => {
  if (newMapping && Object.keys(newMapping).length > 0) {
    console.log('Syncing localMapping from store:', newMapping)
    localMapping.value = { ...newMapping }
    syncFieldToExcelMapping()
    validateData()
  }
}, { deep: true, immediate: true })

watch(fieldTransformations, () => {
  validateData()
}, { deep: true })

/**
 * Show transformation preview for a field
 */
function showTransformPreviewForField(fieldName: string) {
  transformPreviewColumn.value = fieldName
  showTransformPreview.value = true
}

/**
 * Handle scroll event to show/hide and update scroll button
 */
function handleScroll() {
  const scrollTop = window.scrollY || document.documentElement.scrollTop
  const scrollHeight = document.documentElement.scrollHeight
  const clientHeight = document.documentElement.clientHeight

  // Show button after scrolling 200px
  showScrollButton.value = scrollTop > 200

  // Determine if near bottom (within 300px of bottom)
  isNearBottom.value = scrollTop + clientHeight >= scrollHeight - 300
}

/**
 * Scroll to top or bottom based on current position
 */
function scrollToTopOrBottom() {
  if (isNearBottom.value) {
    // Scroll to top
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  } else {
    // Scroll to bottom
    window.scrollTo({
      top: document.documentElement.scrollHeight,
      behavior: 'smooth'
    })
  }
}
</script>
