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
          >
            <i v-if="isStepCompleted(step.id)" class="pi pi-check text-sm"></i>
            <span v-else>{{ index + 1 }}</span>
          </div>
          <span
            class="ml-3 text-sm font-medium transition-colors"
            :class="currentStep === step.id ? 'text-blue-600' : isStepCompleted(step.id) ? 'text-green-600' : 'text-gray-500'"
          >
            {{ step.label }}
          </span>
        </button>

        <!-- Connector Line -->
        <div
          v-if="index < steps.length - 1"
          class="w-16 h-0.5 mx-4 transition-colors"
          :class="isStepCompleted(step.id) ? 'bg-green-500' : 'bg-gray-300'"
        ></div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="mt-6 flex items-center justify-between">
      <button
        v-if="canGoBack"
        @click="goBack"
        class="text-gray-600 hover:text-gray-800 font-medium flex items-center transition group"
      >
        <i class="pi pi-arrow-left mr-2 group-hover:-translate-x-1 transition-transform"></i>
        Previous Step
      </button>
      <div v-else></div>

      <button
        v-if="canReset"
        @click="handleReset"
        class="text-red-600 hover:text-red-700 font-medium flex items-center transition"
      >
        <i class="pi pi-refresh mr-2"></i>
        Start Over
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'

const router = useRouter()
const route = useRoute()
const store = useMappingStore()

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
    return 'bg-blue-600 text-white shadow-lg scale-110'
  } else if (isStepCompleted(stepId)) {
    return 'bg-green-500 text-white shadow-md'
  } else if (canNavigateTo(stepId)) {
    return 'bg-gray-200 text-gray-600 hover:bg-gray-300'
  } else {
    return 'bg-gray-200 text-gray-400 opacity-50'
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

function handleReset() {
  if (confirm('Are you sure you want to start over? This will clear all your current data and mappings.')) {
    store.reset()
    router.push('/')
  }
}
</script>
