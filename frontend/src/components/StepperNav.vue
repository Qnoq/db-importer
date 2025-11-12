<template>
  <div class="stepper-nav">
    <!-- Progress Stepper -->
    <div class="stepper-container">
      <div
        v-for="(step, index) in steps"
        :key="step.id"
        class="step-wrapper"
      >
        <!-- Step Circle -->
        <button
          @click="goToStep(step.id)"
          :disabled="!canNavigateTo(step.id)"
          class="step-button"
          :class="getStepButtonClass(step.id)"
        >
          <div
            class="step-circle"
            :class="getStepClasses(step.id)"
            :style="getStepCircleStyle(step.id)"
          >
            <i v-if="isStepCompleted(step.id)" class="pi pi-check"></i>
            <span v-else>{{ index + 1 }}</span>
          </div>
          <span
            class="step-label"
            :style="getStepTextColor(step.id)"
          >
            {{ step.label }}
          </span>
        </button>

        <!-- Connector Line -->
        <div
          v-if="index < steps.length - 1"
          class="step-connector"
          :style="{ backgroundColor: isStepCompleted(step.id) ? 'var(--p-green-500)' : 'var(--p-surface-300)' }"
        ></div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="action-buttons">
      <button
        v-if="canGoBack"
        @click="goBack"
        class="back-button"
      >
        <i class="pi pi-arrow-left back-icon"></i>
        Previous Step
      </button>
      <div v-else></div>

      <button
        v-if="canReset"
        @click="showResetDialog = true"
        class="reset-button"
      >
        <i class="pi pi-refresh reset-icon"></i>
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
      <div class="dialog-content">
        <i class="pi pi-exclamation-triangle warning-icon"></i>
        <div>
          <p class="dialog-message">Are you sure you want to start over?</p>
          <p class="dialog-submessage">This will clear all your current data and mappings.</p>
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

function getStepButtonClass(stepId: string) {
  return canNavigateTo(stepId) ? 'step-button-enabled' : 'step-button-disabled'
}

function getStepClasses(stepId: string) {
  if (currentStep.value === stepId) {
    return 'step-circle-active'
  } else if (isStepCompleted(stepId)) {
    return 'step-circle-completed'
  } else if (canNavigateTo(stepId)) {
    return 'step-circle-available'
  } else {
    return 'step-circle-disabled'
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

<style scoped>
.stepper-nav {
  margin-bottom: 2rem;
}

.stepper-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.step-wrapper {
  display: flex;
  align-items: center;
}

.step-button {
  display: flex;
  align-items: center;
  background: none;
  border: none;
  padding: 0;
  outline: none;
  transition: opacity 0.2s;
}

.step-button:focus {
  outline: none;
}

.step-button-enabled {
  cursor: pointer;
}

.step-button-disabled {
  cursor: not-allowed;
}

.step-button-available:hover .step-circle {
  opacity: 0.8;
}

.step-circle {
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 9999px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  transition: all 0.2s;
}

.step-circle-active {
  color: white;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  transform: scale(1.1);
}

.step-circle-completed {
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.step-circle-available:hover {
  opacity: 0.8;
}

.step-circle-disabled {
  opacity: 0.5;
}

.step-circle i {
  font-size: 0.875rem;
}

.step-label {
  margin-left: 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  transition: color 0.2s;
}

.step-connector {
  width: 4rem;
  height: 0.125rem;
  margin: 0 1rem;
  transition: background-color 0.2s;
}

.action-buttons {
  margin-top: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.back-button {
  font-weight: 500;
  display: flex;
  align-items: center;
  background: none;
  border: none;
  padding: 0.5rem 1rem;
  color: var(--p-text-muted-color);
  cursor: pointer;
  transition: color 0.2s;
}

.back-button:hover {
  color: var(--p-text-color);
}

.back-icon {
  margin-right: 0.5rem;
  transition: transform 0.2s;
}

.back-button:hover .back-icon {
  transform: translateX(-0.25rem);
}

.reset-button {
  font-weight: 500;
  display: flex;
  align-items: center;
  background: none;
  border: none;
  padding: 0.5rem 1rem;
  color: var(--p-red-500);
  cursor: pointer;
  transition: color 0.2s;
}

.reset-button:hover {
  color: var(--p-red-600);
}

.reset-icon {
  margin-right: 0.5rem;
}

.dialog-content {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.warning-icon {
  font-size: 1.875rem;
  color: var(--p-orange-500);
}

.dialog-message {
  margin: 0 0 0.5rem 0;
}

.dialog-submessage {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
  margin: 0;
}
</style>
