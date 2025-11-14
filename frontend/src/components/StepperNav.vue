<template>
  <div class="mb-8">
    <!-- UStepper Component -->
    <UStepper
      :items="stepItems"
      :model-value="currentStepIndex"
      @update:model-value="onStepClick"
      color="success"
      orientation="horizontal"
      linear
      class="mb-6"
    />

    <!-- Action Buttons -->
    <div class="flex items-center justify-between">
      <UButton
        v-if="canGoBack"
        @click="goBack"
        variant="ghost"
        color="neutral"
        icon="i-heroicons-arrow-left"
      >
        Previous Step
      </UButton>
      <div v-else></div>

      <UButton
        v-if="canReset"
        @click="showResetDialog = true"
        variant="ghost"
        color="error"
        icon="i-heroicons-arrow-path"
      >
        Start Over
      </UButton>
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
            color="neutral"
            @click="showResetDialog = false"
          />
          <UButton
            label="Start Over"
            color="error"
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
import { useAuthStore } from '../store/authStore'
import { useWorkflowSessionStore } from '../store/workflowSessionStore'

const router = useRouter()
const route = useRoute()
const store = useMappingStore()
const authStore = useAuthStore()
const sessionStore = useWorkflowSessionStore()
const showResetDialog = ref(false)

interface Step {
  id: string
  label: string
  path: string
  icon?: string
  description?: string
}

const steps: Step[] = [
  {
    id: 'upload-schema',
    label: 'Upload Schema',
    path: '/',
    icon: 'i-heroicons-cloud-arrow-up',
    description: 'Upload your SQL schema file'
  },
  {
    id: 'select-table',
    label: 'Select Table',
    path: '/select-table',
    icon: 'i-heroicons-table-cells',
    description: 'Choose your target table'
  },
  {
    id: 'upload-data',
    label: 'Upload Data',
    path: '/upload-data',
    icon: 'i-heroicons-document-arrow-up',
    description: 'Upload your data file'
  },
  {
    id: 'mapping',
    label: 'Map & Generate',
    path: '/mapping',
    icon: 'i-heroicons-arrows-right-left',
    description: 'Map columns and generate SQL'
  },
]

const currentStepId = computed(() => {
  const path = route.path
  const step = steps.find(s => s.path === path)
  return step?.id || 'upload-schema'
})

const currentStepIndex = computed(() => {
  return steps.findIndex(s => s.id === currentStepId.value)
})

// Transform steps into UStepper items format
const stepItems = computed(() => {
  return steps.map((step, index) => {
    const isCurrent = currentStepId.value === step.id
    const isCompleted = isStepCompleted(step.id)
    const canNavigate = canNavigateTo(step.id)

    return {
      label: step.label,
      description: step.description,
      icon: step.icon,
      disabled: !canNavigate,
      slot: step.id,
      // UStepper will automatically handle the completed state based on model-value
    }
  })
})

const canGoBack = computed(() => {
  return currentStepIndex.value > 0
})

const canReset = computed(() => {
  return store.hasSchema || store.hasData
})

function isStepCompleted(stepId: string): boolean {
  const stepIndex = steps.findIndex(s => s.id === stepId)
  const currentIndex = currentStepIndex.value

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

function goBack() {
  if (currentStepIndex.value > 0) {
    const previousStep = steps[currentStepIndex.value - 1]
    router.push(previousStep.path)
  }
}

function onStepClick(newIndex: number) {
  // Check if the step can be navigated to
  const targetStep = steps[newIndex]
  if (targetStep && canNavigateTo(targetStep.id)) {
    router.push(targetStep.path)
  }
}

async function confirmReset() {
  // Delete backend session for authenticated users
  if (authStore.isAuthenticated) {
    try {
      await sessionStore.deleteSession()
    } catch (error) {
      console.error('Failed to delete session:', error)
    }
  }

  // Reset local state
  store.reset()
  router.push('/')
  showResetDialog.value = false
}
</script>
