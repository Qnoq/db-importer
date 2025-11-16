<template>
  <div class="mapping-actions flex gap-2">
    <UButton
      @click="$emit('auto-map')"
      color="info"
      variant="soft"
      size="sm"
      :disabled="isRestoring"
    >
      ⚡ Auto-map Columns
    </UButton>
    <UButton
      @click="$emit('clear-all')"
      color="neutral"
      variant="soft"
      size="sm"
      :disabled="isRestoring || !hasMapping"
    >
      ✕ Clear All
    </UButton>
  </div>
</template>

<script setup lang="ts">
interface Props {
  isRestoring?: boolean
  hasMapping?: boolean
}

withDefaults(defineProps<Props>(), {
  isRestoring: false,
  hasMapping: false
})

defineEmits<{
  'auto-map': []
  'clear-all': []
}>()
</script>
