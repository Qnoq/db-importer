<template>
  <Toast />
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 dark:from-gray-900 dark:to-gray-950 flex flex-col transition-colors duration-200">
    <header class="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 sticky top-0 z-50 shadow-sm transition-colors duration-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <!-- Left: Logo + Navigation -->
          <div class="flex items-center space-x-8">
            <!-- Compact Logo -->
            <a @click="handleNewImport" class="flex items-center space-x-2 hover:opacity-80 transition-opacity cursor-pointer group">
              <div class="w-9 h-9 bg-gradient-to-br from-neon-green-500 to-emerald-600 dark:from-neon-green-400 dark:to-emerald-500 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-all">
                <i class="pi pi-database text-white text-lg"></i>
              </div>
              <h1 class="text-lg font-bold text-gray-900 dark:text-white">
                SQLSheetr
              </h1>
            </a>

            <!-- Navigation Menu for Authenticated Users -->
            <nav v-if="authStore.isAuthenticated" class="hidden md:flex items-center space-x-1">
              <a
                @click="handleNewImport"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all cursor-pointer"
                :class="router.currentRoute.value.path === '/'
                  ? 'bg-neon-green-50 text-neon-green-700 dark:bg-neon-green-500/20 dark:text-neon-green-400'
                  : 'text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white'"
              >
                <i class="pi pi-plus-circle mr-2"></i>
                New Import
              </a>
              <router-link
                to="/history"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all"
                :class="router.currentRoute.value.path === '/history'
                  ? 'bg-neon-green-50 text-neon-green-700 dark:bg-neon-green-500/20 dark:text-neon-green-400'
                  : 'text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white'"
              >
                <i class="pi pi-history mr-2"></i>
                History
              </router-link>
            </nav>
          </div>

          <!-- Right: Dark Mode Toggle + Authentication Actions -->
          <div class="flex items-center space-x-3">
            <!-- Dark Mode Toggle -->
            <Button
              :icon="isDark ? 'pi pi-sun' : 'pi pi-moon'"
              text
              rounded
              severity="secondary"
              @click="toggleDark"
              v-tooltip.bottom="isDark ? 'Light Mode' : 'Dark Mode'"
              class="hover:bg-gray-100 dark:hover:bg-gray-800"
            />
            <!-- Authenticated User Menu -->
            <div v-if="authStore.isAuthenticated" class="flex items-center space-x-3">
              <div class="hidden md:flex items-center space-x-3 px-3 py-1.5 rounded-lg bg-gray-50 dark:bg-gray-800">
                <Avatar
                  :label="userInitials"
                  class="bg-neon-green-600 dark:bg-neon-green-500 text-white"
                  shape="circle"
                  size="normal"
                />
                <div>
                  <p class="text-sm font-medium text-gray-900 dark:text-white">
                    {{ authStore.userDisplayName }}
                  </p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ authStore.user?.email }}</p>
                </div>
              </div>
              <Avatar
                :label="userInitials"
                class="md:hidden bg-neon-green-600 dark:bg-neon-green-500 text-white"
                shape="circle"
                size="normal"
              />
              <Button
                icon="pi pi-sign-out"
                text
                rounded
                severity="secondary"
                @click="handleLogout"
                v-tooltip.bottom="'Sign Out'"
                class="hover:bg-gray-100 dark:hover:bg-gray-800"
              />
            </div>

            <!-- Guest: Login/Register Buttons -->
            <div v-else class="flex items-center space-x-2">
              <Button
                label="Sign In"
                icon="pi pi-sign-in"
                text
                @click="router.push('/login')"
                class="hidden sm:inline-flex text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
              />
              <Button
                label="Sign Up"
                icon="pi pi-user-plus"
                @click="router.push('/register')"
                class="bg-neon-green-600 hover:bg-neon-green-700 dark:bg-neon-green-500 dark:hover:bg-neon-green-600 border-neon-green-600 dark:border-neon-green-500"
                size="small"
              />
            </div>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto py-8 sm:px-6 lg:px-8 flex-1">
      <router-view />
    </main>

    <footer class="py-6 border-t border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 transition-colors duration-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col items-center space-y-3">
          <div class="flex items-center space-x-4 text-sm">
            <router-link
              to="/terms-of-service"
              class="text-gray-600 dark:text-gray-400 hover:text-neon-green-600 dark:hover:text-neon-green-400 transition-colors"
            >
              Terms of Service
            </router-link>
            <span class="text-gray-300 dark:text-gray-700">•</span>
            <router-link
              to="/privacy-policy"
              class="text-gray-600 dark:text-gray-400 hover:text-neon-green-600 dark:hover:text-neon-green-400 transition-colors"
            >
              Privacy Policy
            </router-link>
            <span class="text-gray-300 dark:text-gray-700">•</span>
            <router-link
              to="/legal-notice"
              class="text-gray-600 dark:text-gray-400 hover:text-neon-green-600 dark:hover:text-neon-green-400 transition-colors"
            >
              Legal Notice
            </router-link>
          </div>
          <div class="text-sm text-gray-500 dark:text-gray-400">
            <span>v{{ appVersion }}</span>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from './store/authStore'
import { useMappingStore } from './store/mappingStore'
import { useDarkMode } from './composables/useDarkMode'
import { APP_VERSION } from './version'
import Button from 'primevue/button'
import Avatar from 'primevue/avatar'
import Tag from 'primevue/tag'
import Toast from 'primevue/toast'

const router = useRouter()
const authStore = useAuthStore()
const mappingStore = useMappingStore()
const { isDark, toggleDark } = useDarkMode()
const appVersion = APP_VERSION

const userInitials = computed(() => {
  if (!authStore.user) return 'G'
  if (authStore.user.firstName && authStore.user.lastName) {
    return authStore.user.firstName[0] + authStore.user.lastName[0]
  }
  if (authStore.user.firstName) {
    return authStore.user.firstName[0]
  }
  if (authStore.user.email) {
    return authStore.user.email[0].toUpperCase()
  }
  return 'U'
})

const handleNewImport = () => {
  mappingStore.reset()
  router.push('/')
}

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>
