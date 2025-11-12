import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import Aura from '@primeuix/themes/aura'
import ToastService from 'primevue/toastservice'
import Tooltip from 'primevue/tooltip'
import router from './router'
import App from './App.vue'

import './style.css'
import 'primeicons/primeicons.css'

// Initialize dark mode BEFORE mounting the app to prevent flash
import { useDarkMode } from './composables/useDarkMode'
const { initDarkMode } = useDarkMode()
initDarkMode()

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
      // PrimeVue 4 expects the selector to match where the class is applied
      // We apply 'dark' class on <html>, so we use '.dark'
      darkModeSelector: '.dark',
      // Use CSS layers for better style isolation (matches style.css layer definition)
      cssLayer: {
        name: 'primevue',
        order: 'tailwind-base, primevue, tailwind-utilities'
      }
    }
  }
})
app.use(ToastService)
app.directive('tooltip', Tooltip)

app.mount('#app')
