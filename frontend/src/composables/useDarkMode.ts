import { ref, watch } from 'vue'

// Global state - shared across all components
const isDark = ref(false)
const isInitialized = ref(false)

// PrimeVue themes - Vite will resolve these paths correctly
// Using ?url suffix to get the asset URL instead of importing the CSS directly
const LIGHT_THEME = 'https://unpkg.com/primevue@^3/resources/themes/lara-light-teal/theme.css'
const DARK_THEME = 'https://unpkg.com/primevue@^3/resources/themes/lara-dark-teal/theme.css'
const THEME_LINK_ID = 'primevue-theme'

const updatePrimeVueTheme = (useDark: boolean) => {
  // Find or create the theme link element
  let themeLink = document.getElementById(THEME_LINK_ID) as HTMLLinkElement

  if (!themeLink) {
    themeLink = document.createElement('link')
    themeLink.id = THEME_LINK_ID
    themeLink.rel = 'stylesheet'
    document.head.appendChild(themeLink)
  }

  // Update the theme
  themeLink.href = useDark ? DARK_THEME : LIGHT_THEME
}

const updateDOM = () => {
  if (isDark.value) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }

  // Update PrimeVue theme
  updatePrimeVueTheme(isDark.value)
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
