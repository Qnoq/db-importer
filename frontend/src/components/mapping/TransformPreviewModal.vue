<template>
  <UModal
    :open="isOpen"
    @update:open="$emit('update:isOpen', $event)"
    :title="`Transformation Preview: ${columnName || ''}`"
    :description="transformationDescription"
    :ui="{ content: 'sm:max-w-2xl' }"
  >
    <template #body>
      <div v-if="columnName" class="mb-6">
        <p class="text-gray-900 dark:text-white">
          <strong>Transformation:</strong> {{ transformationLabel }}
        </p>
      </div>

      <div class="preview-dialog-table overflow-x-auto">
        <table class="min-w-full border-collapse border border-gray-200 dark:border-gray-700">
          <thead class="bg-gray-100 dark:bg-gray-800">
            <tr>
              <th class="px-4 py-2 text-left font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">
                Original
              </th>
              <th class="px-4 py-2 text-left font-semibold text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">
                Transformed
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(preview, idx) in previewData"
              :key="idx"
              class="border-t border-gray-200 dark:border-gray-700"
            >
              <td class="px-4 py-2 text-gray-900 dark:text-white border border-gray-200 dark:border-gray-700">
                {{ formatValue(preview.original) }}
              </td>
              <td class="px-4 py-2 text-gray-900 dark:text-white font-semibold text-green-600 dark:text-green-400 border border-gray-200 dark:border-gray-700">
                {{ formatValue(preview.transformed) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>

    <template #footer>
      <div class="flex justify-end">
        <UButton @click="$emit('update:isOpen', false)" color="neutral">
          Close
        </UButton>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
interface PreviewItem {
  original: any
  transformed: any
}

interface Props {
  isOpen: boolean
  columnName: string | null
  transformationLabel: string
  transformationDescription: string
  previewData: PreviewItem[]
}

withDefaults(defineProps<Props>(), {
  isOpen: false,
  columnName: null,
  transformationLabel: '',
  transformationDescription: '',
  previewData: () => []
})

defineEmits<{
  'update:isOpen': [value: boolean]
}>()

function formatValue(value: any): string {
  if (value === null || value === undefined) return '(null)'
  return String(value)
}
</script>
