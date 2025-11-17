<template>
  <div class="mapping-header">
    <!-- Missing Data Alert -->
    <UAlert
      v-if="showMissingDataAlert"
      icon="i-heroicons-exclamation-triangle"
      color="warning"
      variant="soft"
      class="mb-4"
    >
      <template #title>Missing data</template>
      <template #description>
        <div class="flex flex-col gap-2">
          <p>Please complete previous steps.</p>
          <UButton @click="$emit('start-over')" variant="soft" color="warning" size="sm">
            ← Start over
          </UButton>
        </div>
      </template>
    </UAlert>

    <!-- Auto-mapping Success Banner -->
    <UAlert
      v-if="autoMappingStats"
      :icon="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'i-heroicons-check-circle' : 'i-heroicons-exclamation-triangle'"
      :color="autoMappingStats.mapped > autoMappingStats.total / 2 ? 'success' : 'warning'"
      variant="soft"
      class="mb-4"
    >
      <template #title>
        {{ autoMappingStats.mapped > autoMappingStats.total / 2 ? 'Auto-mapping successful!' : 'Limited auto-mapping' }}
      </template>
      <template #description>
        <div class="space-y-3">
          <p class="text-sm">
            The system automatically mapped <strong>{{ autoMappingStats.mapped }} of {{ autoMappingStats.total }} columns</strong>
            by comparing your Excel column names with database field names.
          </p>

          <!-- Low match warning -->
          <div v-if="autoMappingStats.mapped < autoMappingStats.total / 2" class="bg-yellow-50 dark:bg-yellow-950 border border-yellow-200 dark:border-yellow-800 rounded-md p-3">
            <p class="font-semibold text-sm mb-1">💡 Tip: Improve auto-mapping</p>
            <p class="text-sm">
              Only <strong>{{ Math.round((autoMappingStats.mapped / autoMappingStats.total) * 100) }}%</strong> of columns were auto-mapped.
              For better results, <strong>rename your Excel headers to match database field names</strong>
              <template v-if="sampleFieldNames.length >= 2">
                (e.g., <code class="bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded text-xs">{{ sampleFieldNames[0] }}</code>,
                <code class="bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded text-xs">{{ sampleFieldNames[1] }}</code>).
              </template>
            </p>
          </div>

          <p class="text-sm">
            Review the mappings below and adjust if needed.
            <template v-if="autoIncrementFields.length > 0">
              ID fields (<strong>{{ autoIncrementFields.join(', ') }}</strong>)
              were automatically skipped as they are auto-incremented.
            </template>
          </p>
        </div>
      </template>
    </UAlert>

    <!-- Info Banner -->
    <UAlert
      v-if="!isRestoring && tableName"
      icon="i-heroicons-information-circle"
      color="blue"
      variant="soft"
      class="mb-4"
    >
      <template #title>Mapping Information</template>
      <template #description>
        <div class="space-y-2">
          <p class="text-sm">
            Target table: <strong>{{ tableName }}</strong> |
            Data rows: <strong>{{ dataRowCount }}</strong>
          </p>
          <div v-if="validationStats" class="flex gap-4 text-sm">
            <span class="text-green-600 dark:text-green-400 font-medium">
              ✓ {{ validationStats.validRowCount }} valid
            </span>
            <button
              v-if="validationStats.warningCount > 0"
              @click="$emit('scroll-to-validation')"
              class="text-amber-600 dark:text-amber-400 font-medium hover:text-amber-700 dark:hover:text-amber-300 underline decoration-dotted cursor-pointer transition-colors"
              title="Click to view warning details"
            >
              ⚠ {{ validationStats.warningCount }} warnings
            </button>
            <button
              v-if="validationStats.errorCount > 0"
              @click="$emit('scroll-to-validation')"
              class="text-red-600 dark:text-red-400 font-medium hover:text-red-700 dark:hover:text-red-300 underline decoration-dotted cursor-pointer transition-colors"
              title="Click to view error details"
            >
              ✕ {{ validationStats.errorCount }} errors
            </button>
          </div>
        </div>
      </template>
    </UAlert>

    <!-- Info Banner Skeleton -->
    <div v-else-if="isRestoring" class="mb-4 border border-gray-200 dark:border-gray-700 bg-blue-50 dark:bg-blue-950 rounded-lg p-4">
      <div class="space-y-2">
        <USkeleton class="h-5 w-40" />
        <USkeleton class="h-4 w-64" />
        <div class="flex gap-4">
          <USkeleton class="h-4 w-20" />
          <USkeleton class="h-4 w-24" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface AutoMappingStats {
  total: number
  mapped: number
  skipped: number
}

interface ValidationStats {
  validRowCount: number
  errorCount: number
  warningCount: number
}

interface Props {
  showMissingDataAlert?: boolean
  autoMappingStats?: AutoMappingStats | null
  sampleFieldNames?: string[]
  autoIncrementFields?: string[]
  isRestoring?: boolean
  tableName?: string
  dataRowCount?: number
  validationStats?: ValidationStats | null
}

withDefaults(defineProps<Props>(), {
  showMissingDataAlert: false,
  autoMappingStats: null,
  sampleFieldNames: () => [],
  autoIncrementFields: () => [],
  isRestoring: false,
  tableName: '',
  dataRowCount: 0,
  validationStats: null
})

defineEmits<{
  'start-over': []
  'scroll-to-validation': []
}>()
</script>
