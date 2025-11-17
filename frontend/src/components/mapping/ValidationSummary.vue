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
  </div>
</template>

<script setup lang="ts">
interface Props {
  validationErrors: string[]
  transformationWarnings: string[]
  serverValidationErrors?: string[]
}

withDefaults(defineProps<Props>(), {
  serverValidationErrors: () => []
})
</script>
