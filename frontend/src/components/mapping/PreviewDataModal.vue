<template>
  <UModal
    v-model:open="isOpen"
    :ui="{
      content: 'sm:max-w-7xl',
      body: '!overflow-hidden'
    }"
  >
    <template #header>
      <div class="flex flex-col gap-2">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Data Preview with Validation (Editable)</h3>
          <div class="absolute left-1/2 -translate-x-1/2 flex items-center gap-2">
            <UBadge v-if="hasMoreRows" color="green" variant="soft">
              Scroll down to load more
            </UBadge>
            <UBadge color="blue" variant="soft">
              Double-click on cells to edit
            </UBadge>
          </div>
        </div>
        <p class="text-sm text-gray-600 dark:text-gray-400">
          Showing {{ visibleRowCount }} of {{ displayData.length }} rows with transformations applied
        </p>
      </div>
    </template>

    <template #body>
      <div
        ref="scrollContainer"
        @scroll="handleScroll"
        class="preview-table-wrapper overflow-x-auto max-h-[70vh] overflow-y-auto"
      >
        <table class="min-w-full border-collapse">
          <thead class="bg-gray-100 dark:bg-gray-800 sticky top-0 z-20 shadow-sm">
            <tr>
              <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800">Row</th>
              <th v-for="(header, idx) in mappedHeaders" :key="idx" class="px-3 py-2 text-left text-xs font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800">
                {{ header }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, rowIndex) in lazyLoadedData" :key="rowIndex" class="border-t border-gray-200 dark:border-gray-700">
              <td class="px-3 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 border border-gray-200 dark:border-gray-700">{{ rowIndex + 1 }}</td>
              <td
                v-for="(cell, colIndex) in row"
                :key="colIndex"
                class="px-3 py-2 text-xs border border-gray-200 dark:border-gray-700 relative group"
                :class="getCellClass(rowIndex, colIndex)"
              >
                <!-- Editing Mode -->
                <div v-if="isEditing(rowIndex, colIndex)" class="flex items-center gap-1">
                  <UInput
                    v-model="editingValue"
                    @keyup.enter="saveEdit(rowIndex, colIndex)"
                    @keyup.escape="cancelEdit"
                    @blur="saveEdit(rowIndex, colIndex)"
                    size="xs"
                    class="w-full"
                    autofocus
                  />
                </div>

                <!-- Display Mode -->
                <div
                  v-else
                  @dblclick="startEdit(rowIndex, colIndex, cell)"
                  class="flex items-center gap-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 px-1 py-0.5 rounded transition-colors"
                  :title="'Double-click to edit: ' + formatCellValue(cell)"
                >
                  <span v-if="getCellIcon(rowIndex, colIndex)" class="flex-shrink-0">{{ getCellIcon(rowIndex, colIndex) }}</span>
                  <span class="truncate">{{ formatCellValue(cell) }}</span>
                </div>

                <!-- Validation Tooltip -->
                <div v-if="getCellMessage(rowIndex, colIndex)" class="absolute hidden group-hover:block z-10 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-xs rounded px-2 py-1 -top-8 left-0 whitespace-nowrap shadow-lg">
                  {{ getCellMessage(rowIndex, colIndex) }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Loading indicator when fetching more rows -->
        <div v-if="isLoadingMore" class="flex items-center justify-center py-6">
          <div class="flex items-center gap-3 text-sm text-gray-600 dark:text-gray-400">
            <div class="animate-spin rounded-full h-5 w-5 border-2 border-gray-300 border-t-green-600 dark:border-gray-600 dark:border-t-green-500"></div>
            <span>Loading more rows...</span>
          </div>
        </div>

        <!-- All loaded indicator -->
        <div v-else-if="!hasMoreRows && visibleRowCount > initialLoadCount" class="flex items-center justify-center py-6">
          <div class="text-sm text-gray-600 dark:text-gray-400">
            ✓ All {{ displayData.length }} rows loaded
          </div>
        </div>
      </div>

      <p class="text-xs text-gray-600 dark:text-gray-400 mt-3">
        Hover over highlighted cells for validation messages. Red indicates errors, amber indicates warnings.
      </p>
    </template>

    <template #footer>
      <div class="flex justify-between items-center">
        <UButton
          @click="resetChanges"
          color="red"
          variant="ghost"
          icon="i-heroicons-arrow-path"
          :disabled="!hasChanges"
        >
          Reset Changes
        </UButton>
        <div class="flex gap-2">
          <UBadge v-if="hasChanges" color="orange">
            {{ changeCount }} edit(s) made
          </UBadge>
          <UButton @click="isOpen = false" color="neutral" variant="soft">
            Close
          </UButton>
        </div>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import { useMappingStore } from '../../store/mappingStore'
import type { CellValue, ValidationResult } from '../../store/mappingStore'

interface Props {
  isOpen: boolean
  previewData: CellValue[][]
  mappedHeaders: string[]
  cellValidations: Map<string, ValidationResult>
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:isOpen': [value: boolean]
}>()

const store = useMappingStore()
const toast = useToast()

// Editing state
const editingCell = ref<{ row: number; col: number } | null>(null)
const editingValue = ref<string>('')

// Lazy loading state
const initialLoadCount = 100 // Load 100 rows initially
const loadMoreCount = 50 // Load 50 more rows each time
const visibleRowCount = ref(initialLoadCount)
const isLoadingMore = ref(false)
const scrollContainer = ref<HTMLElement | null>(null)

const isOpen = computed({
  get: () => props.isOpen,
  set: (value) => {
    emit('update:isOpen', value)
    // Reset to initial load count when modal is closed
    if (!value) {
      visibleRowCount.value = initialLoadCount
      isLoadingMore.value = false
    }
  }
})

const hasChanges = computed(() => {
  return Object.keys(store.dataOverrides).length > 0
})

const changeCount = computed(() => {
  return Object.keys(store.dataOverrides).length
})

// Create mapping from preview column index to original column index
// This follows the same logic as previewData creation in useValidation.ts
const previewToOriginalIndex = computed(() => {
  const mapping = new Map<number, number>()
  let previewIndex = 0

  // Iterate through excelHeaders to find which columns are mapped
  store.excelHeaders.forEach((header, originalIndex) => {
    const dbField = store.mapping[header]
    if (dbField) {
      // This column is mapped, so it appears in the preview
      mapping.set(previewIndex, originalIndex)
      previewIndex++
    }
  })

  return mapping
})

// Reactive preview data that updates when overrides change
const displayData = computed(() => {
  return props.previewData.map((row, rowIndex) => {
    return row.map((cell, colIndex) => {
      // Get the original column index for this preview column
      const originalColIndex = previewToOriginalIndex.value.get(colIndex) ?? colIndex
      const key = `${rowIndex}-${originalColIndex}`

      if (store.dataOverrides[key]) {
        return store.dataOverrides[key].value as CellValue
      }
      return cell
    })
  })
})

// Lazy loaded data - only show rows up to visibleRowCount
const lazyLoadedData = computed(() => {
  return displayData.value.slice(0, visibleRowCount.value)
})

// Check if there are more rows to load
const hasMoreRows = computed(() => {
  return visibleRowCount.value < displayData.value.length
})

// Handle scroll event to trigger lazy loading
function handleScroll() {
  if (!scrollContainer.value || isLoadingMore.value || !hasMoreRows.value) {
    return
  }

  const { scrollTop, scrollHeight, clientHeight } = scrollContainer.value

  // Load more when user is within 200px of the bottom
  if (scrollHeight - scrollTop - clientHeight < 200) {
    loadMoreRows()
  }
}

// Load more rows with a slight delay for smooth UX
function loadMoreRows() {
  if (isLoadingMore.value || !hasMoreRows.value) return

  isLoadingMore.value = true

  // Save current scroll position before loading more rows
  const savedScrollTop = scrollContainer.value?.scrollTop || 0

  // Use requestAnimationFrame for smooth loading without setTimeout
  requestAnimationFrame(() => {
    const newCount = Math.min(
      visibleRowCount.value + loadMoreCount,
      displayData.value.length
    )
    visibleRowCount.value = newCount

    console.log(`📊 [Preview Modal] Loaded ${newCount} / ${displayData.value.length} rows`)

    // Restore scroll position after DOM updates to prevent jump
    nextTick(() => {
      if (scrollContainer.value) {
        // Maintain the exact scroll position to prevent jumping
        scrollContainer.value.scrollTop = savedScrollTop
      }
      isLoadingMore.value = false
    })
  })
}

// Helper functions for cell validation display
function getCellClass(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = props.cellValidations?.get(key)
  if (!validation) return ''

  switch (validation.severity) {
    case 'error':
      return 'bg-red-50 dark:bg-red-950 text-red-900 dark:text-red-100'
    case 'warning':
      return 'bg-amber-50 dark:bg-amber-950 text-amber-900 dark:text-amber-100'
    default:
      return ''
  }
}

function getCellMessage(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = props.cellValidations?.get(key)
  return validation?.message || ''
}

function getCellIcon(rowIndex: number, colIndex: number): string {
  const key = `${rowIndex}-${colIndex}`
  const validation = props.cellValidations?.get(key)
  if (!validation) return ''

  return validation.severity === 'error' ? '✕' : validation.severity === 'warning' ? '⚠' : ''
}

function formatCellValue(value: unknown): string {
  if (value === null || value === undefined) return '(null)'
  return String(value)
}

// Editing functions
function isEditing(row: number, col: number): boolean {
  return editingCell.value?.row === row && editingCell.value?.col === col
}

function startEdit(row: number, col: number, currentValue: CellValue) {
  editingCell.value = { row, col }
  editingValue.value = currentValue !== null && currentValue !== undefined ? String(currentValue) : ''
}

function saveEdit(row: number, col: number) {
  if (!editingCell.value) return

  const newValue = editingValue.value

  // Get the original column index for this preview column
  const originalColIndex = previewToOriginalIndex.value.get(col) ?? col

  // Update the store with the new value using the original column index
  store.updateCellValue(row, originalColIndex, newValue)

  toast.add({
    title: 'Cell updated',
    description: `Row ${row + 1}, Column ${col + 1} updated`,
    color: 'green',
    ui: {
      container: 'z-[99999]'
    }
  })

  cancelEdit()
}

function cancelEdit() {
  editingCell.value = null
  editingValue.value = ''
}

function resetChanges() {
  store.resetDataOverrides()
  toast.add({
    title: 'Changes reset',
    description: 'All edits have been reverted',
    color: 'blue',
    ui: {
      container: 'z-[99999]'
    }
  })
}
</script>
