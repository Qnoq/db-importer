<template>
  <div class="mb-8">
    <!-- Progress Stepper -->
    <div class="flex items-center justify-center space-x-4">
      <div
        v-for="(step, index) in steps"
        :key="step.id"
        class="flex items-center"
      >
        <!-- Step Circle -->
        <button
          @click="goToStep(step.id)"
          :disabled="!canNavigateTo(step.id)"
          class="group flex items-center focus:outline-none"
          :class="canNavigateTo(step.id) ? 'cursor-pointer' : 'cursor-not-allowed'"
        >
          <div
            class="w-10 h-10 rounded-full flex items-center justify-center font-semibold transition-all duration-200"
            :class="getStepClasses(step.id)"
            :style="getStepCircleStyle(step.id)"
          >
            <i v-if="isStepCompleted(step.id)" class="pi pi-check text-sm"></i>
            <span v-else>{{ index + 1 }}</span>
          </div>
          <span
            class="ml-3 text-sm font-medium transition-colors"
            :style="getStepTextColor(step.id)"
          >
            {{ step.label }}
          </span>
        </button>

        <!-- Connector Line -->
        <div
          v-if="index < steps.length - 1"
          class="w-16 h-0.5 mx-4 transition-colors"
          :style="{ backgroundColor: isStepCompleted(step.id) ? 'var(--p-green-500)' : 'var(--p-surface-300)' }"
        ></div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="mt-6 flex items-center justify-between">
      <button
        v-if="canGoBack"
        @click="goBack"
        class="font-medium flex items-center transition group"
        style="color: var(--p-text-muted-color)"
      >
        <i class="pi pi-arrow-left mr-2 group-hover:-translate-x-1 transition-transform"></i>
        Previous Step
      </button>
      <div v-else></div>

      <button
        v-if="canReset"
        @click="showResetDialog = true"
        class="font-medium flex items-center transition"
        style="color: var(--p-red-500)"
      >
        <i class="pi pi-refresh mr-2"></i>
        Start Over
      </button>
    </div>

    <!-- Reset Confirmation Dialog -->
    <Dialog
      v-model:visible="showResetDialog"
      header="Confirm Reset"
      :modal="true"
      :style="{ width: '30rem' }"
    >
      <div class="flex items-start gap-3">
        <i class="pi pi-exclamation-triangle text-3xl" style="color: var(--p-orange-500)"></i>
        <div>
          <p class="mb-2">Are you sure you want to start over?</p>
          <p class="text-sm" style="color: var(--p-text-muted-color)">This will clear all your current data and mappings.</p>
        </div>
      </div>

      <template #footer>
        <Button label="Cancel" text @click="showResetDialog = false" />
        <Button label="Start Over" severity="danger" @click="confirmReset" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'

const router = useRouter()
const route = useRoute()
const store = useMappingStore()
const showResetDialog = ref(false)

const steps = [
  { id: 'upload-schema', label: 'Upload Schema', path: '/' },
  { id: 'select-table', label: 'Select Table', path: '/select-table' },
  { id: 'upload-data', label: 'Upload Data', path: '/upload-data' },
  { id: 'mapping', label: 'Map & Generate', path: '/mapping' },
]

const currentStep = computed(() => {
  const path = route.path
  const step = steps.find(s => s.path === path)
  return step?.id || 'upload-schema'
})

const canGoBack = computed(() => {
  const currentIndex = steps.findIndex(s => s.id === currentStep.value)
  return currentIndex > 0
})

const canReset = computed(() => {
  return store.hasSchema || store.hasData
})

function getStepClasses(stepId: string) {
  if (currentStep.value === stepId) {
    return 'text-white shadow-lg scale-110'
  } else if (isStepCompleted(stepId)) {
    return 'text-white shadow-md'
  } else if (canNavigateTo(stepId)) {
    return 'hover:opacity-80'
  } else {
    return 'opacity-50'
  }
}

function getStepTextColor(stepId: string) {
  if (currentStep.value === stepId) {
    return { color: 'var(--p-primary-color)' }
  } else if (isStepCompleted(stepId)) {
    return { color: 'var(--p-green-500)' }
  } else {
    return { color: 'var(--p-text-muted-color)' }
  }
}

function getStepCircleStyle(stepId: string) {
  if (currentStep.value === stepId) {
    return { backgroundColor: 'var(--p-primary-color)' }
  } else if (isStepCompleted(stepId)) {
    return { backgroundColor: 'var(--p-green-500)' }
  } else if (canNavigateTo(stepId)) {
    return { backgroundColor: 'var(--p-surface-200)', color: 'var(--p-text-muted-color)' }
  } else {
    return { backgroundColor: 'var(--p-surface-200)', color: 'var(--p-text-muted-color)' }
  }
}

function isStepCompleted(stepId: string): boolean {
  const stepIndex = steps.findIndex(s => s.id === stepId)
  const currentIndex = steps.findIndex(s => s.id === currentStep.value)

  // A step is completed if we're past it
  if (stepIndex < currentIndex) {
    // Check if required data exists
    if (stepId === 'upload-schema') return store.hasSchema
    if (stepId === 'select-table') return !!store.selectedTable
    if (stepId === 'upload-data') return store.hasData
    return false
  }
  return false
}

function canNavigateTo(stepId: string): boolean {
  // Can always go to step 1
  if (stepId === 'upload-schema') return true

  // Can only go to step 2 if schema is loaded
  if (stepId === 'select-table') return store.hasSchema

  // Can only go to step 3 if table is selected
  if (stepId === 'upload-data') return store.hasSchema && !!store.selectedTable

  // Can only go to step 4 if data is uploaded
  if (stepId === 'mapping') return store.hasData

  return false
}

function goToStep(stepId: string) {
  if (!canNavigateTo(stepId)) return

  // Don't allow navigating forward, only backward
  const currentIndex = steps.findIndex(s => s.id === currentStep.value)
  const targetIndex = steps.findIndex(s => s.id === stepId)

  // Only allow going to previous steps or current step
  if (targetIndex > currentIndex) {
    return
  }

  const step = steps.find(s => s.id === stepId)
  if (step) {
    router.push(step.path)
  }
}

function goBack() {
  const currentIndex = steps.findIndex(s => s.id === currentStep.value)
  if (currentIndex > 0) {
    const previousStep = steps[currentIndex - 1]
    router.push(previousStep.path)
  }
}

function confirmReset() {
  store.reset()
  router.push('/')
  showResetDialog.value = false
}
</script>
