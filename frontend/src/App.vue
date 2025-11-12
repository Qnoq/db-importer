<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 flex flex-col">
    <Toast />
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
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
                  ? 'bg-blue-50 text-blue-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'"
              >
                <i class="pi pi-plus-circle mr-2"></i>
                New Import
              </a>
              <router-link
                to="/history"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all"
                :class="router.currentRoute.value.path === '/history'
                  ? 'bg-blue-50 text-blue-700'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'"
              >
                <i class="pi pi-history mr-2"></i>
                History
              </router-link>
            </nav>
          </div>

          <!-- Right: Authentication Actions -->
          <div class="flex items-center space-x-3">
            <!-- Authenticated User Menu -->
            <div v-if="authStore.isAuthenticated" class="flex items-center space-x-3">
              <div class="hidden md:flex items-center space-x-3 px-3 py-1.5 rounded-lg bg-gray-50">
                <Avatar
                  :label="userInitials"
                  class="bg-blue-600 text-white"
                  shape="circle"
                  size="normal"
                />
                <div>
                  <p class="text-sm font-medium text-gray-900">
                    {{ authStore.userDisplayName }}
                  </p>
                  <p class="text-xs text-gray-500">{{ authStore.user?.email }}</p>
                </div>
              </div>
              <Avatar
                :label="userInitials"
                class="md:hidden bg-blue-600 text-white"
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
                class="hover:bg-gray-100"
              />
            </div>

            <!-- Guest: Login/Register Buttons -->
            <div v-else class="flex items-center space-x-2">
              <Button
                label="Sign In"
                icon="pi pi-sign-in"
                text
                @click="router.push('/login')"
                class="hidden sm:inline-flex text-gray-700 hover:text-gray-900"
              />
              <Button
                label="Sign Up"
                icon="pi pi-user-plus"
                @click="router.push('/register')"
                severity="info"
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

    <footer class="py-6 border-t border-gray-200 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col items-center space-y-3">
          <div class="flex items-center space-x-4 text-sm">
            <router-link
              to="/terms-of-service"
              class="text-gray-600 hover:text-blue-600 transition-colors"
            >
              Terms of Service
            </router-link>
            <span class="text-gray-300">•</span>
            <router-link
              to="/privacy-policy"
              class="text-gray-600 hover:text-blue-600 transition-colors"
            >
              Privacy Policy
            </router-link>
            <span class="text-gray-300">•</span>
            <router-link
              to="/legal-notice"
              class="text-gray-600 hover:text-blue-600 transition-colors"
            >
              Legal Notice
            </router-link>
          </div>
          <div class="text-sm text-gray-500">
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
import { APP_VERSION } from './version'
import Button from 'primevue/button'
import Avatar from 'primevue/avatar'
import Toast from 'primevue/toast'

const router = useRouter()
const authStore = useAuthStore()
const mappingStore = useMappingStore()
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
