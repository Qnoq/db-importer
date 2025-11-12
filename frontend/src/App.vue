<template>
  <div class="min-h-screen flex flex-col" style="background: var(--p-surface-ground)">
    <Toast />
    <header class="sticky top-0 z-50 shadow-sm" style="background: var(--p-surface-0); border-bottom: 1px solid var(--p-surface-border)">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-28">
          <!-- Left: Logo + Navigation -->
          <div class="flex items-center space-x-8">
            <!-- Compact Logo -->
            <a @click="handleNewImport" class="flex items-center space-x-3 hover:opacity-80 transition-opacity cursor-pointer group">
              <img
                src="/logo.png"
                alt="SQL Importer Logo"
                class="h-28 w-auto transition-transform group-hover:scale-105"
              />
            </a>

            <!-- Navigation Menu for Authenticated Users -->
            <nav v-if="authStore.isAuthenticated" class="hidden md:flex items-center space-x-1">
              <a
                @click="handleNewImport"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all cursor-pointer"
                :class="router.currentRoute.value.path === '/'
                  ? 'bg-neon-green-50 text-neon-green-700 dark:bg-neon-green-500/20 dark:text-neon-green-400'
                  : ''"
                :style="router.currentRoute.value.path !== '/' ? { color: 'var(--p-text-muted-color)' } : {}"
              >
                <i class="pi pi-plus-circle mr-2"></i>
                New Import
              </a>
              <router-link
                to="/history"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all"
                :class="router.currentRoute.value.path === '/history'
                  ? 'bg-neon-green-50 text-neon-green-700 dark:bg-neon-green-500/20 dark:text-neon-green-400'
                  : ''"
                :style="router.currentRoute.value.path !== '/history' ? { color: 'var(--p-text-muted-color)' } : {}"
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
              class=""
            />
            <!-- Authenticated User Menu -->
            <div v-if="authStore.isAuthenticated" class="flex items-center space-x-3">
              <div class="hidden md:flex items-center space-x-3 px-3 py-1.5 rounded-lg" style="background: var(--p-surface-100)">
                <Avatar
                  :label="userInitials"
                  class="bg-neon-green-600 dark:bg-neon-green-500 text-white"
                  shape="circle"
                  size="normal"
                />
                <div>
                  <p class="text-sm font-medium">
                    {{ authStore.userDisplayName }}
                  </p>
                  <p class="text-xs" style="color: var(--p-text-muted-color)">{{ authStore.user?.email }}</p>
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
                class=""
              />
            </div>

            <!-- Guest: Login/Register Buttons -->
            <div v-else class="flex items-center space-x-2">
              <Button
                label="Sign In"
                icon="pi pi-sign-in"
                text
                @click="router.push('/login')"
                class="hidden sm:inline-flex"
                style="color: var(--p-text-color)"
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

    <footer class="py-6 transition-colors duration-200" style="border-top: 1px solid var(--p-surface-border); background: var(--p-surface-0)">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col items-center space-y-3">
          <div class="flex items-center space-x-4 text-sm">
            <router-link
              to="/terms-of-service"
              class="transition-colors"
              style="color: var(--p-text-muted-color)"
            >
              Terms of Service
            </router-link>
            <span style="color: var(--p-surface-400)">•</span>
            <router-link
              to="/privacy-policy"
              class="transition-colors"
              style="color: var(--p-text-muted-color)"
            >
              Privacy Policy
            </router-link>
            <span style="color: var(--p-surface-400)">•</span>
            <router-link
              to="/legal-notice"
              class="transition-colors"
              style="color: var(--p-text-muted-color)"
            >
              Legal Notice
            </router-link>
          </div>
          <div class="text-sm" style="color: var(--p-text-muted-color)">
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
