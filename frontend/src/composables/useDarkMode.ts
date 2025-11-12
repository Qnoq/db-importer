import { ref, watch } from 'vue'

// Global state - shared across all components
const isDark = ref(false)
const isInitialized = ref(false)

const updateDOM = () => {
  if (isDark.value) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

const initDarkMode = () => {
  if (isInitialized.value) return // Already initialized

  // Check localStorage first
  const stored = localStorage.getItem('darkMode')
  if (stored !== null) {
    isDark.value = stored === 'true'
  } else {
    // Check system preference
    isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
  }
  updateDOM()
  isInitialized.value = true
}

const toggleDark = () => {
  isDark.value = !isDark.value
  updateDOM()
  localStorage.setItem('darkMode', isDark.value ? 'true' : 'false')
}

// Watch for changes
watch(isDark, () => {
  updateDOM()
})

// Initialize immediately when module loads
if (typeof window !== 'undefined') {
  initDarkMode()
}

export function useDarkMode() {
  return {
    isDark,
    toggleDark,
    initDarkMode
  }
}
