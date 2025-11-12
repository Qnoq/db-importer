import { ref, watch, onMounted } from 'vue'

const isDark = ref(false)

export function useDarkMode() {
  const toggleDark = () => {
    isDark.value = !isDark.value
    updateDOM()
    localStorage.setItem('darkMode', isDark.value ? 'true' : 'false')
  }

  const updateDOM = () => {
    if (isDark.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  const initDarkMode = () => {
    // Check localStorage first
    const stored = localStorage.getItem('darkMode')
    if (stored !== null) {
      isDark.value = stored === 'true'
    } else {
      // Check system preference
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    updateDOM()
  }

  onMounted(() => {
    initDarkMode()
  })

  // Watch for changes
  watch(isDark, () => {
    updateDOM()
  })

  return {
    isDark,
    toggleDark,
    initDarkMode
  }
}
