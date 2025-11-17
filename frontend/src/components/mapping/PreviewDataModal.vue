<template>
  <UModal
    v-model:open="isOpen"
    :ui="{ content: 'sm:max-w-7xl' }"
  >
    <template #header>
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Data Preview with Validation (Editable)</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Showing {{ paginatedData.length }} of {{ displayData.length }} rows with transformations applied - Double-click any cell to edit
          </p>
        </div>
        <div class="flex items-center gap-2">
          <UBadge v-if="displayData.length > maxRowsPerPage" color="amber" variant="soft">
            Limited to {{ maxRowsPerPage }} rows for performance
          </UBadge>
          <UBadge color="blue" variant="soft">
            Double-click to edit
          </UBadge>
        </div>
      </div>
    </template>

    <template #body>
      <div class="preview-table-wrapper overflow-x-auto max-h-[70vh] overflow-y-auto">
        <table class="min-w-full border-collapse">
          <thead class="bg-gray-100 dark:bg-gray-800 sticky top-0 z-10">
            <tr>
              <th class="px-3 py-2 text-left text-xs font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">Row</th>
              <th v-for="(header, idx) in mappedHeaders" :key="idx" class="px-3 py-2 text-left text-xs font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">
                {{ header }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, rowIndex) in paginatedData" :key="rowIndex" class="border-t border-gray-200 dark:border-gray-700">
              <td class="px-3 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 border border-gray-200 dark:border-gray-700">{{ rowIndex + currentPage * maxRowsPerPage + 1 }}</td>
              <td
                v-for="(cell, colIndex) in row"
                :key="colIndex"
                class="px-3 py-2 text-xs border border-gray-200 dark:border-gray-700 relative group"
                :class="getCellClass(getActualRowIndex(rowIndex), colIndex)"
              >
                <!-- Editing Mode -->
                <div v-if="isEditing(getActualRowIndex(rowIndex), colIndex)" class="flex items-center gap-1">
                  <UInput
                    v-model="editingValue"
                    @keyup.enter="saveEdit(getActualRowIndex(rowIndex), colIndex)"
                    @keyup.escape="cancelEdit"
                    @blur="saveEdit(getActualRowIndex(rowIndex), colIndex)"
                    size="xs"
                    class="w-full"
                    autofocus
                  />
                </div>

                <!-- Display Mode -->
                <div
                  v-else
                  @dblclick="startEdit(getActualRowIndex(rowIndex), colIndex, cell)"
                  class="flex items-center gap-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 px-1 py-0.5 rounded transition-colors"
                  :title="'Double-click to edit: ' + formatCellValue(cell)"
                >
                  <span v-if="getCellIcon(getActualRowIndex(rowIndex), colIndex)" class="flex-shrink-0">{{ getCellIcon(getActualRowIndex(rowIndex), colIndex) }}</span>
                  <span class="truncate">{{ formatCellValue(cell) }}</span>
                </div>

                <!-- Validation Tooltip -->
                <div v-if="getCellMessage(getActualRowIndex(rowIndex), colIndex)" class="absolute hidden group-hover:block z-10 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-xs rounded px-2 py-1 -top-8 left-0 whitespace-nowrap shadow-lg">
                  {{ getCellMessage(getActualRowIndex(rowIndex), colIndex) }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination Info & Controls -->
      <div v-if="displayData.length > maxRowsPerPage" class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-600 dark:text-gray-400">
            Rows {{ currentPage * maxRowsPerPage + 1 }} - {{ Math.min((currentPage + 1) * maxRowsPerPage, displayData.length) }} of {{ displayData.length }}
          </div>
          <div class="flex gap-2">
            <UButton
              @click="previousPage"
              :disabled="currentPage === 0"
              icon="i-heroicons-chevron-left"
              size="xs"
              variant="soft"
            >
              Previous
            </UButton>
            <UButton
              @click="nextPage"
              :disabled="(currentPage + 1) * maxRowsPerPage >= displayData.length"
              icon="i-heroicons-chevron-right"
              size="xs"
              variant="soft"
            >
              Next
            </UButton>
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
import { ref, computed } from 'vue'
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

// Pagination state
const maxRowsPerPage = 100 // Show 100 rows at a time for performance
const currentPage = ref(0)

const isOpen = computed({
  get: () => props.isOpen,
  set: (value) => {
    emit('update:isOpen', value)
    // Reset to first page when modal is closed
    if (!value) {
      currentPage.value = 0
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

// Paginated data - only show a subset of rows at a time for performance
const paginatedData = computed(() => {
  const start = currentPage.value * maxRowsPerPage
  const end = start + maxRowsPerPage
  return displayData.value.slice(start, end)
})

// Get the actual row index in the full dataset (accounting for pagination)
function getActualRowIndex(paginatedRowIndex: number): number {
  return currentPage.value * maxRowsPerPage + paginatedRowIndex
}

// Pagination navigation
function previousPage() {
  if (currentPage.value > 0) {
    currentPage.value--
  }
}

function nextPage() {
  if ((currentPage.value + 1) * maxRowsPerPage < displayData.value.length) {
    currentPage.value++
  }
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
      container: 'z-[9999]'
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
      container: 'z-[9999]'
    }
  })
}
</script>
