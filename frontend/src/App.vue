<template>
  <Toast />
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 flex flex-col">
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-6">
            <a @click="handleNewImport" class="flex items-center space-x-3 hover:opacity-80 transition-opacity cursor-pointer">
              <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center shadow-md">
                <i class="pi pi-database text-white text-xl"></i>
              </div>
              <div>
                <h1 class="text-xl font-bold text-gray-900">
                  SQL Data Importer
                </h1>
                <p class="text-xs text-gray-500">Import data safely & efficiently</p>
              </div>
            </a>

            <!-- Navigation Menu for Authenticated Users -->
            <nav v-if="authStore.isAuthenticated" class="hidden md:flex items-center space-x-4">
              <a
                @click="handleNewImport"
                class="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors cursor-pointer"
                :class="{ 'text-blue-600': router.currentRoute.value.path === '/' }"
              >
                New Import
              </a>
              <router-link
                to="/history"
                class="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors"
                active-class="text-blue-600"
              >
                History
              </router-link>
            </nav>
          </div>

          <!-- Authentication Actions -->
          <div class="flex items-center space-x-4">
            <!-- Authenticated User Menu -->
            <div v-if="authStore.isAuthenticated" class="flex items-center space-x-2">
              <Avatar
                :label="userInitials"
                class="bg-blue-600 text-white"
                shape="circle"
                size="normal"
              />
              <div class="hidden md:block">
                <p class="text-sm font-medium text-gray-900">
                  {{ authStore.userDisplayName }}
                </p>
                <p class="text-xs text-gray-500">{{ authStore.user?.email }}</p>
              </div>
              <Button
                icon="pi pi-sign-out"
                text
                rounded
                severity="secondary"
                @click="handleLogout"
                v-tooltip.bottom="'Sign Out'"
              />
            </div>

            <!-- Guest Mode: Badge + Login/Register Buttons -->
            <div v-else class="flex items-center space-x-3">
              <!-- Guest Mode Badge -->
              <Tag severity="secondary" value="Guest Mode" icon="pi pi-user" class="hidden sm:flex" />

              <!-- Login/Register Buttons -->
              <div class="flex items-center space-x-2">
                <Button
                  label="Sign In"
                  icon="pi pi-sign-in"
                  text
                  @click="router.push('/login')"
                  class="hidden sm:inline-flex"
                />
                <Button
                  label="Sign Up"
                  icon="pi pi-user-plus"
                  @click="router.push('/register')"
                  size="small"
                />
              </div>
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
        <div class="flex items-center justify-center text-sm text-gray-500">
          <span>v{{ appVersion }}</span>
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
import Tag from 'primevue/tag'
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
