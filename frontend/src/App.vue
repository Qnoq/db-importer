<template>
  <UApp>
    <div class="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
      <!-- Header -->
    <header class="sticky top-0 z-50 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 shadow-sm">
      <div class="app-container">
        <div class="flex justify-between items-center h-[var(--app-header-height)] gap-8">
          <!-- Logo et Navigation -->
          <div class="flex items-center gap-8">
            <a @click="handleNewImport" class="flex items-center cursor-pointer transition-transform hover:scale-105">
              <img src="/logo.png" alt="SQL Importer" class="h-32 w-auto" />
            </a>

            <nav v-if="authStore.isAuthenticated" class="app-nav flex gap-2">
              <UButton
                label="New Import"
                :icon="currentRoute === '/' ? 'i-heroicons-plus-circle' : undefined"
                :variant="currentRoute === '/' ? 'solid' : 'ghost'"
                :color="currentRoute === '/' ? 'success' : 'neutral'"
                @click="handleNewImport"
                size="sm"
              >
                <template v-if="currentRoute !== '/'" #leading>
                  <span class="i-heroicons-plus-circle w-4 h-4" />
                </template>
              </UButton>
              <UButton
                label="History"
                :icon="currentRoute === '/history' ? 'i-heroicons-clock' : undefined"
                :variant="currentRoute === '/history' ? 'solid' : 'ghost'"
                :color="currentRoute === '/history' ? 'success' : 'neutral'"
                @click="() => router.push('/history')"
                size="sm"
              >
                <template v-if="currentRoute !== '/history'" #leading>
                  <span class="i-heroicons-clock w-4 h-4" />
                </template>
              </UButton>
            </nav>
          </div>

          <!-- Actions à droite -->
          <div class="flex items-center gap-3">
            <!-- Toggle Thème -->
            <UTooltip :text="isDark ? 'Light Mode' : 'Dark Mode'">
              <UButton
                :icon="isDark ? 'i-heroicons-sun' : 'i-heroicons-moon'"
                variant="ghost"
                color="neutral"
                @click="toggleTheme"
                square
              />
            </UTooltip>

            <!-- Menu utilisateur -->
            <div v-if="authStore.isAuthenticated" class="flex items-center gap-3">
              <UBadge class="hidden md:flex items-center gap-3 px-3 py-2 bg-gray-100 dark:bg-gray-700">
                <UAvatar
                  :text="userInitials"
                  size="sm"
                  class="bg-green-600 text-white"
                />
                <div class="flex flex-col">
                  <span class="text-sm font-medium text-gray-900 dark:text-white">{{ authStore.userDisplayName }}</span>
                  <span class="text-xs text-gray-500 dark:text-gray-400">{{ authStore.user?.email }}</span>
                </div>
              </UBadge>

              <UTooltip text="Sign Out">
                <UButton
                  icon="i-heroicons-arrow-right-on-rectangle"
                  variant="ghost"
                  color="error"
                  @click="handleLogout"
                  square
                />
              </UTooltip>
            </div>

            <!-- Boutons invité -->
            <div v-else class="flex items-center gap-3">
              <UButton
                label="Sign In"
                icon="i-heroicons-arrow-left-on-rectangle"
                variant="ghost"
                color="neutral"
                @click="() => router.push('/login')"
                class="hidden md:inline-flex"
              />
              <UButton
                label="Sign Up"
                icon="i-heroicons-user-plus"
                color="success"
                @click="() => router.push('/register')"
              />
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Contenu principal -->
    <main class="flex-1 py-8">
      <div class="app-container">
        <router-view />
      </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 py-6 mt-auto">
      <div class="app-container">
        <div class="flex flex-col md:flex-row justify-between items-center gap-4">
          <div class="flex items-center gap-4">
            <router-link
              to="/terms-of-service"
              class="text-sm text-gray-500 dark:text-gray-400 hover:text-green-600 dark:hover:text-green-400 transition-colors no-underline"
            >
              Terms of Service
            </router-link>
            <span class="text-gray-500 dark:text-gray-400">•</span>
            <router-link
              to="/privacy-policy"
              class="text-sm text-gray-500 dark:text-gray-400 hover:text-green-600 dark:hover:text-green-400 transition-colors no-underline"
            >
              Privacy Policy
            </router-link>
            <span class="text-gray-500 dark:text-gray-400">•</span>
            <router-link
              to="/legal-notice"
              class="text-sm text-gray-500 dark:text-gray-400 hover:text-green-600 dark:hover:text-green-400 transition-colors no-underline"
            >
              Legal Notice
            </router-link>
          </div>
          <div class="text-sm text-gray-500 dark:text-gray-400">v{{ appVersion }}</div>
        </div>
      </div>
    </footer>
    </div>
  </UApp>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useColorMode } from '@vueuse/core'
import { useAuthStore } from './store/authStore'
import { useMappingStore } from './store/mappingStore'
import { APP_VERSION } from './version'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const mappingStore = useMappingStore()
const appVersion = APP_VERSION

const colorMode = useColorMode()

const isDark = computed({
  get() {
    return colorMode.value === 'dark'
  },
  set(_isDark: boolean) {
    colorMode.value = _isDark ? 'dark' : 'light'
  }
})

const toggleTheme = () => {
  isDark.value = !isDark.value
}

const currentRoute = computed(() => route.path)

const userInitials = computed(() => {
  if (!authStore.user) return 'G'
  const { firstName, lastName, email } = authStore.user
  if (firstName && lastName) return firstName[0] + lastName[0]
  if (firstName) return firstName[0]
  if (email) return email[0].toUpperCase()
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
