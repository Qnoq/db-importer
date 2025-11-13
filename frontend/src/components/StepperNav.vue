<template>
  <div class="mb-8">
    <!-- Progress Stepper -->
    <div class="flex items-center justify-center gap-4">
      <div
        v-for="(step, index) in steps"
        :key="step.id"
        class="flex items-center"
      >
        <!-- Step Circle -->
        <button
          @click="goToStep(step.id)"
          :disabled="!canNavigateTo(step.id)"
          class="flex items-center bg-transparent border-0 p-0 outline-none transition-opacity duration-200"
          :class="canNavigateTo(step.id) ? 'cursor-pointer' : 'cursor-not-allowed'"
        >
          <div
            class="w-10 h-10 rounded-full flex items-center justify-center font-semibold transition-all duration-200"
            :class="getStepCircleClass(step.id)"
          >
            <span v-if="isStepCompleted(step.id)" class="i-heroicons-check w-4 h-4" />
            <span v-else>{{ index + 1 }}</span>
          </div>
          <span
            class="ml-3 text-sm font-medium transition-colors duration-200"
            :class="getStepLabelClass(step.id)"
          >
            {{ step.label }}
          </span>
        </button>

        <!-- Connector Line -->
        <div
          v-if="index < steps.length - 1"
          class="w-16 h-0.5 mx-4 transition-colors duration-200"
          :class="isStepCompleted(step.id) ? 'bg-green-600' : 'bg-gray-300 dark:bg-gray-600'"
        ></div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="mt-6 flex items-center justify-between">
      <button
        v-if="canGoBack"
        @click="goBack"
        class="font-medium flex items-center bg-transparent border-0 px-4 py-2 text-gray-500 dark:text-gray-400 cursor-pointer transition-colors duration-200 hover:text-gray-900 dark:hover:text-white group"
      >
        <span class="i-heroicons-arrow-left w-4 h-4 mr-2 transition-transform duration-200 group-hover:-translate-x-1" />
        Previous Step
      </button>
      <div v-else></div>

      <button
        v-if="canReset"
        @click="showResetDialog = true"
        class="font-medium flex items-center bg-transparent border-0 px-4 py-2 text-red-500 dark:text-red-400 cursor-pointer transition-colors duration-200 hover:text-red-600 dark:hover:text-red-500"
      >
        <span class="i-heroicons-arrow-path w-4 h-4 mr-2" />
        Start Over
      </button>
    </div>

    <!-- Reset Confirmation Dialog -->
    <UModal
      v-model:open="showResetDialog"
      title="Confirm Reset"
      description="This will clear all your current data and mappings."
    >
      <template #body>
        <div class="flex items-start gap-3">
          <span class="i-heroicons-exclamation-triangle w-8 h-8 text-orange-500 dark:text-orange-400 flex-shrink-0" />
          <p class="text-gray-900 dark:text-white">Are you sure you want to start over?</p>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-2">
          <UButton
            label="Cancel"
            variant="ghost"
            color="gray"
            @click="showResetDialog = false"
          />
          <UButton
            label="Start Over"
            color="red"
            @click="confirmReset"
          />
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'

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

function getStepCircleClass(stepId: string) {
  if (currentStep.value === stepId) {
    return 'bg-green-600 text-white shadow-lg scale-110'
  } else if (isStepCompleted(stepId)) {
    return 'bg-green-600 text-white shadow-md'
  } else if (canNavigateTo(stepId)) {
    return 'bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400 hover:opacity-80'
  } else {
    return 'bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400 opacity-50'
  }
}

function getStepLabelClass(stepId: string) {
  if (currentStep.value === stepId) {
    return 'text-green-600 dark:text-green-400'
  } else if (isStepCompleted(stepId)) {
    return 'text-green-600 dark:text-green-400'
  } else {
    return 'text-gray-500 dark:text-gray-400'
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
