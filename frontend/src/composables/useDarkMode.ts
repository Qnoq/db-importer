import { ref, watch, onMounted } from 'vue'

// Global state - shared across all components
const isDark = ref(false)
const isInitialized = ref(false)

/**
 * Updates the DOM to reflect the current dark mode state
 * Adds/removes the 'dark' class on <html> element for PrimeVue 4 and Tailwind
 */
const updateDOM = () => {
  if (typeof document === 'undefined') return

  if (isDark.value) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

/**
 * Initialize dark mode by checking localStorage and system preferences
 * This should be called BEFORE mounting the Vue app to prevent flash
 */
const initDarkMode = () => {
  if (isInitialized.value) return // Already initialized

  // Check localStorage first for user preference
  const stored = localStorage.getItem('darkMode')
  if (stored !== null) {
    isDark.value = stored === 'true'
  } else {
    // Fall back to system preference
    if (typeof window !== 'undefined' && window.matchMedia) {
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }
  }

  // Apply the class immediately
  updateDOM()
  isInitialized.value = true
}

/**
 * Toggle between dark and light mode
 * Saves the preference to localStorage
 */
const toggleDark = () => {
  isDark.value = !isDark.value
  localStorage.setItem('darkMode', isDark.value ? 'true' : 'false')
}

// Watch for changes and update DOM
// This handles any programmatic changes to isDark
watch(isDark, () => {
  updateDOM()
}, { immediate: true })

// Initialize immediately when module loads (SSR-safe)
if (typeof window !== 'undefined') {
  initDarkMode()
}

export function useDarkMode() {
  // Ensure initialization on component mount as well
  onMounted(() => {
    if (!isInitialized.value) {
      initDarkMode()
    }
  })

  return {
    isDark,
    toggleDark,
    initDarkMode
  }
}
