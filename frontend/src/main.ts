import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import MyPreset from './theme/my-preset'
import ToastService from 'primevue/toastservice'
import Tooltip from 'primevue/tooltip'
import router from './router'
import App from './App.vue'

// Import des styles PrimeVue et de l'application
import 'primeicons/primeicons.css'
import './style.css'

// Initialiser le thème AVANT le montage pour éviter le flash
const initTheme = () => {
  // Vérifier localStorage pour la préférence sauvegardée
  const savedTheme = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches

  // Appliquer le thème sauvegardé ou la préférence système
  const isDark = savedTheme ? savedTheme === 'dark' : prefersDark

  if (isDark) {
    document.documentElement.classList.add('p-dark')
  } else {
    document.documentElement.classList.remove('p-dark')
  }
}

// Initialiser le thème immédiatement
initTheme()

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: MyPreset,
    options: {
      // PrimeVue 4 utilise 'p-dark' par défaut sur l'élément html
      darkModeSelector: '.p-dark',
      // Utiliser CSS layers pour mieux isoler les styles
      cssLayer: {
        name: 'primevue',
        order: 'primevue'
      }
    }
  }
})
app.use(ToastService)
app.directive('tooltip', Tooltip)

app.mount('#app')
