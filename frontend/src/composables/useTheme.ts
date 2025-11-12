import { ref, watch } from 'vue'

// État global partagé pour le dark mode
const isDark = ref(false)

/**
 * Composable pour gérer le thème PrimeVue 4
 * Utilise la classe 'p-dark' sur l'élément html
 */
export function useTheme() {

  // Initialiser le thème au chargement
  const initTheme = () => {
    // Vérifier localStorage en premier
    const savedTheme = localStorage.getItem('theme')

    if (savedTheme) {
      isDark.value = savedTheme === 'dark'
    } else {
      // Sinon utiliser la préférence système
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }

    updateTheme()
  }

  // Mettre à jour le DOM avec la classe p-dark
  const updateTheme = () => {
    if (isDark.value) {
      document.documentElement.classList.add('p-dark')
    } else {
      document.documentElement.classList.remove('p-dark')
    }
  }

  // Basculer entre light et dark
  const toggleTheme = () => {
    isDark.value = !isDark.value
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
    updateTheme()
  }

  // Définir explicitement le thème
  const setTheme = (dark: boolean) => {
    isDark.value = dark
    localStorage.setItem('theme', dark ? 'dark' : 'light')
    updateTheme()
  }

  // Watcher pour les changements
  watch(isDark, updateTheme)

  // Initialiser au premier appel
  if (typeof window !== 'undefined') {
    initTheme()
  }

  return {
    isDark,
    toggleTheme,
    setTheme,
    initTheme
  }
}
