<template>
  <div class="validation-summary">
    <!-- Validation Errors -->
    <UAlert v-if="validationErrors.length > 0" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
      <template #title>Mapping Warnings</template>
      <template #description>
        <ul class="list-disc list-inside text-sm space-y-1">
          <li v-for="(err, index) in validationErrors" :key="index">{{ err }}</li>
        </ul>
      </template>
    </UAlert>

    <!-- Transformation Warnings -->
    <UAlert v-if="transformationWarnings.length > 0" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
      <template #title>Date Transformation Warning</template>
      <template #description>
        <ul class="list-disc list-inside text-sm space-y-1">
          <li v-for="(warning, index) in transformationWarnings" :key="index">{{ warning }}</li>
        </ul>
      </template>
    </UAlert>

    <!-- Server Validation Errors -->
    <UAlert v-if="serverValidationErrors.length > 0" icon="i-heroicons-x-circle" color="error" variant="soft" class="mb-4">
      <template #title>Data Validation Errors</template>
      <template #description>
        <ul class="list-disc list-inside text-sm space-y-1 max-h-60 overflow-y-auto">
          <li v-for="(err, index) in serverValidationErrors" :key="index">{{ err }}</li>
        </ul>
      </template>
    </UAlert>

    <!-- Data Preview with Highlighting -->
    <div v-if="showPreview" class="preview-section mb-6 border border-gray-200 dark:border-gray-700 rounded-lg p-4 bg-gray-50 dark:bg-gray-900">
      <div class="preview-header flex justify-between items-center mb-4">
        <h3 class="section-title text-lg font-semibold text-gray-900 dark:text-white">Data Preview with Validation</h3>
        <UButton
          @click="$emit('close-preview')"
          color="neutral"
          variant="ghost"
          size="sm"
          icon="i-heroicons-x-mark"
        />
      </div>

      <div class="preview-table-wrapper overflow-x-auto max-h-96 overflow-y-auto">
        <table class="min-w-full border-collapse">
          <thead class="bg-gray-100 dark:bg-gray-800 sticky top-0">
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
        Showing first {{ previewData.length }} rows with transformations applied. Hover over cells for validation messages.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { CellValue, ValidationResult } from '../../store/mappingStore'

interface Props {
  validationErrors: string[]
  transformationWarnings: string[]
  serverValidationErrors?: string[]
  showPreview?: boolean
  previewData?: CellValue[][]
  mappedHeaders?: string[]
  cellValidations?: Map<string, ValidationResult>
}

const props = withDefaults(defineProps<Props>(), {
  serverValidationErrors: () => [],
  showPreview: false,
  previewData: () => [],
  mappedHeaders: () => [],
  cellValidations: () => new Map()
})

defineEmits<{
  'close-preview': []
}>()

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
