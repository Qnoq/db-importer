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

    <!-- Cell Validation Warnings -->
    <UAlert v-if="cellWarnings.length > 0" icon="i-heroicons-exclamation-triangle" color="warning" variant="soft" class="mb-4">
      <template #title>Data Validation Warnings</template>
      <template #description>
        <div class="text-sm space-y-2">
          <p class="font-medium">Found {{ cellWarnings.length }} warning{{ cellWarnings.length > 1 ? 's' : '' }} in your data:</p>
          <ul class="list-disc list-inside space-y-1 max-h-60 overflow-y-auto">
            <li v-for="(warning, index) in cellWarnings.slice(0, 10)" :key="index">
              <strong>Row {{ warning.rowIndex + 1 }}, {{ warning.fieldName }}:</strong> {{ warning.message }}
              <span v-if="warning.suggestion" class="text-gray-600 dark:text-gray-400"> ({{ warning.suggestion }})</span>
            </li>
          </ul>
          <p v-if="cellWarnings.length > 10" class="text-xs text-gray-600 dark:text-gray-400 italic">
            ... and {{ cellWarnings.length - 10 }} more warning{{ cellWarnings.length - 10 > 1 ? 's' : '' }}
          </p>
        </div>
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
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface CellValidation {
  rowIndex: number
  columnIndex: number
  fieldName: string
  value: unknown
  valid: boolean
  severity: 'error' | 'warning' | 'info' | 'success'
  message?: string
  suggestion?: string
}

interface Props {
  validationErrors: string[]
  transformationWarnings: string[]
  serverValidationErrors?: string[]
  cellValidations?: Map<string, CellValidation>
}

const props = withDefaults(defineProps<Props>(), {
  serverValidationErrors: () => [],
  cellValidations: () => new Map()
})

// Extract warnings from cell validations
const cellWarnings = computed(() => {
  const warnings: CellValidation[] = []

  if (props.cellValidations) {
    props.cellValidations.forEach((validation) => {
      if (validation.severity === 'warning') {
        warnings.push(validation)
      }
    })
  }

  return warnings
})
</script>
