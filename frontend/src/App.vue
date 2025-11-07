<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 flex flex-col">
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center shadow-md">
              <i class="pi pi-database text-white text-xl"></i>
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">
                SQL Data Importer
              </h1>
              <p class="text-xs text-gray-500">Import data safely & efficiently</p>
            </div>
          </div>

          <!-- Authentication Actions -->
          <div class="flex items-center space-x-4">
            <!-- Guest Mode Info -->
            <div v-if="authStore.isGuest" class="hidden sm:flex items-center space-x-2">
              <Tag severity="secondary" value="Guest Mode" icon="pi pi-user" />
            </div>

            <!-- Authenticated User Menu -->
            <div v-else-if="authStore.isAuthenticated" class="flex items-center space-x-2">
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

            <!-- Login/Register Buttons -->
            <div v-else class="flex items-center space-x-2">
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
import { APP_VERSION } from './version'
import Button from 'primevue/button'
import Avatar from 'primevue/avatar'
import Tag from 'primevue/tag'

const router = useRouter()
const authStore = useAuthStore()
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

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>
