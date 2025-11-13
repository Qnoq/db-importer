import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHistory } from 'vue-router'
import ui from '@nuxt/ui/vue-plugin'
import router from './router'
import App from './App.vue'

// Import des styles de l'application
import './style.css'

// Initialiser le thème AVANT le montage pour éviter le flash
const initTheme = () => {
  // Vérifier localStorage pour la préférence sauvegardée
  const savedTheme = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches

  // Appliquer le thème sauvegardé ou la préférence système
  const isDark = savedTheme ? savedTheme === 'dark' : prefersDark

  if (isDark) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

// Initialiser le thème immédiatement
initTheme()

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(ui)

app.mount('#app')
