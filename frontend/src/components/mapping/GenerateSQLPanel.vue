<template>
  <div class="generate-sql-panel">
    <!-- Action Buttons -->
    <div v-if="!isRestoring" class="bottom-actions flex flex-wrap gap-4 mb-6">
      <UButton
        @click="$emit('preview-data')"
        size="lg"
        variant="soft"
        color="info"
        icon="i-heroicons-eye"
        :disabled="hasValidationErrors"
      >
        Preview Data
      </UButton>
      <UButton
        @click="$emit('generate-sql')"
        size="lg"
        color="primary"
        icon="i-heroicons-code-bracket"
        :disabled="hasValidationErrors || isLoading"
        :loading="isLoading"
      >
        Generate SQL
      </UButton>
      <UButton
        v-if="isAuthenticated"
        @click="$emit('generate-and-save')"
        size="lg"
        variant="solid"
        color="success"
        icon="i-heroicons-cloud-arrow-up"
        :disabled="hasValidationErrors || isLoading"
        :loading="isLoading"
      >
        Generate & Save
      </UButton>
    </div>

    <!-- Action Buttons Skeleton -->
    <div v-else class="bottom-actions flex flex-wrap gap-4 mb-6">
      <USkeleton class="h-12 w-64 rounded-lg" />
      <USkeleton class="h-12 w-40 rounded-lg" />
    </div>

    <!-- Loading Indicator -->
    <div v-if="isLoading" class="loading-container flex items-center justify-center p-8">
      <div class="flex flex-col items-center gap-4">
        <div class="animate-spin text-4xl">⏳</div>
        <p class="text-gray-600 dark:text-gray-400">Generating SQL...</p>
      </div>
    </div>

    <!-- Error Display -->
    <UAlert v-if="error" icon="i-heroicons-x-circle" color="error" variant="soft" class="mb-4">
      <template #title>Error</template>
      <template #description>
        {{ error }}
      </template>
    </UAlert>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  validationErrors: string[]
  isRestoring?: boolean
  isLoading?: boolean
  error?: string
  isAuthenticated?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isRestoring: false,
  isLoading: false,
  error: '',
  isAuthenticated: false
})

defineEmits<{
  'preview-data': []
  'generate-sql': []
  'generate-and-save': []
}>()

const hasValidationErrors = computed(() => props.validationErrors.length > 0)
</script>
