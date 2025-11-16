<template>
  <div
    class="mapping-card border-2 rounded-lg p-4 transition-all"
    :class="{
      'border-green-300 bg-green-50 dark:bg-green-950 dark:border-green-800': isMapped && !hasWarning,
      'border-amber-400 bg-amber-50 dark:bg-amber-950 dark:border-amber-800': isMapped && hasWarning,
      'border-gray-200 bg-white dark:bg-gray-900 dark:border-gray-700': !isMapped
    }"
  >
    <div class="mapping-grid grid grid-cols-1 md:grid-cols-5 gap-4 items-center">
      <!-- DB Field (Target) -->
      <div class="field-column flex flex-col gap-2">
        <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">
          Database Field
        </label>
        <div class="field-content flex items-center gap-2">
          <div class="field-icon flex-shrink-0 w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded flex items-center justify-center text-purple-600 dark:text-purple-300">
            🗄️
          </div>
          <div class="field-info flex-1 min-w-0">
            <div class="field-name-row flex items-center gap-2">
              <p class="field-name font-semibold truncate text-gray-900 dark:text-white" :title="field.name">
                {{ field.name }}{{ field.nullable ? '' : ' *' }}
              </p>
              <span v-if="isAutoIncrement" class="badge text-xs font-medium rounded-full px-2 py-0.5 bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300 whitespace-nowrap">
                AUTO
              </span>
              <span v-if="hasWarning" class="badge text-xs font-medium rounded-full px-2 py-0.5 bg-amber-100 dark:bg-amber-900 text-amber-700 dark:text-amber-300 whitespace-nowrap flex items-center gap-1">
                ⚠️ YEAR
              </span>
            </div>
            <p class="field-type text-xs text-gray-600 dark:text-gray-400">{{ field.type }}</p>
          </div>
        </div>
      </div>

      <!-- Arrow -->
      <div class="arrow-column flex justify-center">
        <span
          class="text-2xl"
          :class="{
            'text-green-600': isMapped && !hasWarning,
            'text-amber-500': isMapped && hasWarning,
            'text-gray-300': !isMapped
          }"
        >
          ←
        </span>
      </div>

      <!-- Excel Column (Source) -->
      <div class="excel-column flex flex-col gap-2">
        <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">
          Excel Column
        </label>
        <USelect
          :model-value="selectedExcelColumn"
          @update:model-value="(value) => $emit('update:selectedExcelColumn', value)"
          :items="excelColumnOptions"
          placeholder="-- Skip this field --"
          class="w-full"
        />
        <p class="sample-value text-xs text-gray-600 dark:text-gray-400 mt-1 min-h-[1.25rem]">
          <span v-if="selectedExcelColumn && sampleValue">Sample: {{ sampleValue }}</span>
        </p>
      </div>

      <!-- Transformation -->
      <div class="transform-column flex flex-col gap-2">
        <label class="field-label text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-400">
          Transformation
        </label>
        <USelect
          :model-value="selectedTransformation"
          @update:model-value="(value) => $emit('update:selectedTransformation', value)"
          :items="availableTransformations"
          :disabled="!selectedExcelColumn"
          placeholder="None"
          class="w-full"
        />
        <p class="text-xs text-gray-600 dark:text-gray-400 mt-1 min-h-[1.25rem]">
          <!-- Empty placeholder for alignment -->
        </p>
      </div>

      <!-- Actions -->
      <div class="actions-column flex gap-2 justify-end items-center">
        <UTooltip v-if="selectedTransformation && selectedTransformation !== 'none' && selectedExcelColumn" text="Preview transformation">
          <UButton
            @click="$emit('preview-transformation')"
            color="neutral"
            variant="ghost"
            size="sm"
            icon="i-heroicons-eye"
          />
        </UTooltip>
        <div class="skip-checkbox flex items-center gap-2 cursor-pointer p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
          <UCheckbox
            :model-value="!isMapped"
            @update:model-value="$emit('skip-field')"
            :input-id="`skip-${field.name}`"
          />
          <label :for="`skip-${field.name}`" class="skip-label text-xs font-medium whitespace-nowrap text-gray-600 dark:text-gray-400">
            Skip
          </label>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Field } from '../../store/mappingStore'

interface TransformationOption {
  label: string
  value: string
}

interface Props {
  field: Field
  selectedExcelColumn: string | null
  excelHeaders: string[]
  selectedTransformation: string
  availableTransformations: TransformationOption[]
  hasWarning?: boolean
  isMapped?: boolean
  sampleValue?: string
  isAutoIncrement?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  hasWarning: false,
  isMapped: false,
  sampleValue: '',
  isAutoIncrement: false
})

defineEmits<{
  'update:selectedExcelColumn': [value: string | null]
  'update:selectedTransformation': [value: string]
  'preview-transformation': []
  'skip-field': []
}>()

// Convert headers to options format
const excelColumnOptions = computed(() => {
  return props.excelHeaders.map(header => ({
    label: header,
    value: header
  }))
})
</script>
