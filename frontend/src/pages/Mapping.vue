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
        @scroll-to-validation="scrollToValidationSummary"
      />

      <!-- Column Mapping Section -->
      <div class="mapping-section mb-6">
        <div class="section-header flex justify-between items-center mb-4">
          <h3 class="section-title text-lg font-semibold text-gray-900 dark:text-white">Column Mapping</h3>

          <!-- Action Buttons (Preview, Auto-map & Clear All) -->
          <div class="flex gap-2">
            <UButton
              v-if="!isLoadingData"
              @click="showPreviewModal = true"
              variant="soft"
              color="info"
              icon="i-heroicons-eye"
              :disabled="validationErrors.length > 0 || Object.keys(localMapping).length === 0"
            >
              Preview Data
            </UButton>

            <!-- Mapping Actions Component (Auto-map & Clear All buttons) -->
            <MappingActions
              :is-restoring="isLoadingData"
              :has-mapping="Object.keys(localMapping).length > 0"
              @auto-map="autoMap"
              @clear-all="showClearDialog = true"
            />
          </div>
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

          <!-- Actual Mapping Content with MappingCard Components (Virtual Scrolling) -->
          <div v-else-if="store.hasExcelData && store.hasSelectedTable" class="mapping-list">
            <div
              ref="scrollParentRef"
              :style="{ height: virtualScrollHeight, overflow: 'auto' }"
              class="space-y-3"
            >
              <div
                :style="{
                  height: `${virtualizer.getTotalSize()}px`,
                  width: '100%',
                  position: 'relative'
                }"
              >
                <div
                  v-for="virtualRow in virtualizer.getVirtualItems()"
                  :key="virtualRow.index"
                  :style="{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    width: '100%',
                    transform: `translateY(${virtualRow.start}px)`,
                    marginBottom: '12px'
                  }"
                >
                  <MappingCard
                    :field="store.selectedTable!.fields[virtualRow.index]"
                    :selected-excel-column="getMappedExcelColumn(store.selectedTable!.fields[virtualRow.index].name)"
                    :excel-headers="store.excelHeaders"
                    :selected-transformation="fieldTransformations[store.selectedTable!.fields[virtualRow.index].name] || 'none'"
                    :available-transformations="getTransformationOptions(store.selectedTable!.fields[virtualRow.index])"
                    :has-warning="hasYearWarning(store.selectedTable!.fields[virtualRow.index].name)"
                    :is-mapped="!!getMappedExcelColumn(store.selectedTable!.fields[virtualRow.index].name)"
                    :sample-value="getMappedExcelColumn(store.selectedTable!.fields[virtualRow.index].name) ? getSampleValue(getMappedExcelColumn(store.selectedTable!.fields[virtualRow.index].name)!) : undefined"
                    :is-auto-increment="isAutoIncrementField(store.selectedTable!.fields[virtualRow.index])"
                    @update:selected-excel-column="(value) => onFieldMappingChange(store.selectedTable!.fields[virtualRow.index].name, value)"
                    @update:selected-transformation="(value) => store.updateTransformation(store.selectedTable!.fields[virtualRow.index].name, value)"
                    @preview-transformation="showTransformPreviewForField(store.selectedTable!.fields[virtualRow.index].name)"
                    @skip-field="toggleSkipField(store.selectedTable!.fields[virtualRow.index].name)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ValidationSummary Component (Errors, Warnings) -->
        <ValidationSummary
          ref="validationSummaryRef"
          v-if="store.hasExcelData && store.hasSelectedTable"
          :validation-errors="validationErrors"
          :transformation-warnings="transformationWarnings"
          :server-validation-errors="serverValidationErrors"
          :cell-validations="cellValidations"
        />

        <!-- GenerateSQLPanel Component (Action Buttons) -->
        <GenerateSQLPanel
          v-if="store.hasExcelData && store.hasSelectedTable"
          :validation-errors="validationErrors"
          :is-restoring="isLoadingData"
          :is-loading="loading"
          :error="error"
          :is-authenticated="authStore.isAuthenticated"
          :has-mapping-errors="validationErrors.length > 0 || Object.keys(localMapping).length === 0"
          @generate-sql="generateSQL"
          @generate-and-save="generateAndSave"
          @preview-data="showPreviewModal = true"
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

    <!-- PreviewDataModal Component -->
    <PreviewDataModal
      v-model:is-open="showPreviewModal"
      :preview-data="previewData"
      :mapped-headers="mappedHeaders"
      :cell-validations="previewCellValidations"
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
          <UButton @click="confirmClearMappings(); showClearDialog = false" color="error">
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
import { useVirtualizer } from '@tanstack/vue-virtual'
import StepperNav from '../components/StepperNav.vue'
import MappingHeader from '../components/mapping/MappingHeader.vue'
import MappingActions from '../components/mapping/MappingActions.vue'
import MappingCard from '../components/mapping/MappingCard.vue'
import ValidationSummary from '../components/mapping/ValidationSummary.vue'
import GenerateSQLPanel from '../components/mapping/GenerateSQLPanel.vue'
import TransformPreviewModal from '../components/mapping/TransformPreviewModal.vue'
import PreviewDataModal from '../components/mapping/PreviewDataModal.vue'
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
  previewCellValidations,
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
const showPreviewModal = ref(false)

// Scroll button state
const showScrollButton = ref(false)
const isNearBottom = ref(false)

// Validation summary reference
const validationSummaryRef = ref<HTMLElement | null>(null)

// Virtual scrolling setup
const scrollParentRef = ref<HTMLElement | null>(null)
const virtualScrollHeight = computed(() => {
  const fieldCount = store.selectedTable?.fields.length || 0
  // Limite la hauteur: max 800px ou hauteur de viewport - 400px
  const maxHeight = Math.min(800, window.innerHeight - 400)
  return fieldCount > 10 ? `${maxHeight}px` : 'auto'
})

const virtualizer = useVirtualizer({
  get count() {
    return store.selectedTable?.fields.length || 0
  },
  getScrollElement: () => scrollParentRef.value,
  estimateSize: () => 180, // Hauteur estimée d'une MappingCard en pixels
  overscan: 5, // Nombre d'éléments à rendre avant/après la zone visible
})

// Lifecycle hooks
onMounted(() => {
  console.timeEnd('⏱️ [STEP 3→4] Navigation time')
  console.time('⏱️ [STEP 4] Total Page Load')
  console.log(`🔍 [STEP 4] Starting with ${store.excelData.length} rows and ${store.excelHeaders.length} columns`)

  // Initialize localMapping from store first (for session restoration)
  console.time('⏱️ [STEP 4] Initialize mapping from store')
  if (Object.keys(store.mapping).length > 0) {
    localMapping.value = { ...store.mapping }
  }
  console.timeEnd('⏱️ [STEP 4] Initialize mapping from store')

  // Initialize auto-mapping (only if no mapping exists yet and not restoring)
  if (!sessionStore.isRestoring && Object.keys(localMapping.value).length === 0) {
    console.time('⏱️ [STEP 4] Auto-mapping')
    autoMap()
    console.timeEnd('⏱️ [STEP 4] Auto-mapping')
  } else {
    // If we have mapping, just sync it
    console.time('⏱️ [STEP 4] Sync field-to-excel mapping')
    syncFieldToExcelMapping()
    console.timeEnd('⏱️ [STEP 4] Sync field-to-excel mapping')
  }

  console.time('⏱️ [STEP 4] Initial validation')
  validateData()
  console.timeEnd('⏱️ [STEP 4] Initial validation')

  // Add scroll listener for scroll button
  window.addEventListener('scroll', handleScroll)

  console.timeEnd('⏱️ [STEP 4] Total Page Load')
  console.log('✅ [STEP 4] Page fully loaded and ready')

  // Log virtual scrolling info
  if (store.selectedTable && store.selectedTable.fields.length > 10) {
    console.log(`📜 [STEP 4] Virtual scrolling enabled for ${store.selectedTable.fields.length} fields`)
  }
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

/**
 * Scroll to validation summary section
 */
function scrollToValidationSummary() {
  if (validationSummaryRef.value) {
    // Access the root HTML element of the component
    const el = (validationSummaryRef.value as { $el: HTMLElement }).$el
    if (el) {
      el.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      })
    }
  }
}
</script>
