import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config';
import ToastService from 'primevue/toastservice'
import Tooltip from 'primevue/tooltip'
import router from './router'
import App from './App.vue'

import './style.css'
// PrimeVue theme is now loaded dynamically by useDarkMode composable
import 'primeicons/primeicons.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(PrimeVue)
app.use(ToastService)
app.directive('tooltip', Tooltip)

app.mount('#app')
