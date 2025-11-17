<template>
  <UModal
    v-model:open="isOpen"
    :ui="{ content: 'sm:max-w-7xl' }"
  >
    <template #header>
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Data Preview with Validation</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Showing {{ previewData.length }} rows with transformations applied
          </p>
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
            <tr v-for="(row, rowIndex) in previewData" :key="rowIndex" class="border-t border-gray-200 dark:border-gray-700">
              <td class="px-3 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 border border-gray-200 dark:border-gray-700">{{ rowIndex + 1 }}</td>
              <td
                v-for="(cell, colIndex) in row"
                :key="colIndex"
                class="px-3 py-2 text-xs border border-gray-200 dark:border-gray-700 relative group"
                :class="getCellClass(rowIndex, colIndex)"
              >
                <div class="flex items-center gap-1">
                  <span v-if="getCellIcon(rowIndex, colIndex)" class="flex-shrink-0">{{ getCellIcon(rowIndex, colIndex) }}</span>
                  <span class="truncate" :title="formatCellValue(cell)">{{ formatCellValue(cell) }}</span>
                </div>
                <div v-if="getCellMessage(rowIndex, colIndex)" class="absolute hidden group-hover:block z-10 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-xs rounded px-2 py-1 -top-8 left-0 whitespace-nowrap shadow-lg">
                  {{ getCellMessage(rowIndex, colIndex) }}
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="text-xs text-gray-600 dark:text-gray-400 mt-3">
        Hover over highlighted cells for validation messages. Red indicates errors, amber indicates warnings.
      </p>
    </template>

    <template #footer>
      <div class="flex justify-end">
        <UButton @click="isOpen = false" color="neutral" variant="soft">
          Close
        </UButton>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
import { computed } from 'vue'
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

const isOpen = computed({
  get: () => props.isOpen,
  set: (value) => emit('update:isOpen', value)
})

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
</script>
