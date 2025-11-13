<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-200px)] bg-gray-50 dark:bg-gray-950">
    <div class="w-full max-w-sm bg-white dark:bg-gray-900 rounded-xl shadow-lg border border-gray-200 dark:border-gray-800 p-8">
      <!-- Card Title -->
      <div class="text-center mb-6">
        <div class="text-4xl mb-3">🔐</div>
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Sign In</h2>
        <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
          Sign in to access your history, templates, and more
        </p>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleLogin" class="space-y-4">
        <!-- Session Expired Message -->
        <UAlert
          v-if="sessionExpiredMessage"
          color="yellow"
          variant="soft"
          :title="sessionExpiredMessage"
          :close-button="{ icon: 'i-heroicons-x-mark-20-solid', color: 'gray', variant: 'ghost', padded: false }"
          @close="sessionExpiredMessage = ''"
        />

        <!-- Error Message -->
        <UAlert
          v-if="authStore.error"
          color="red"
          variant="soft"
          :title="authStore.error"
          :close-button="null"
        />

        <!-- Email Field -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            Email
          </label>
          <UInput
            id="email"
            v-model="email"
            type="email"
            placeholder="your@email.com"
            :class="{ 'border-red-500': emailError }"
            required
            autofocus
          />
          <p v-if="emailError" class="text-red-500 text-sm mt-1">{{ emailError }}</p>
        </div>

        <!-- Password Field -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            Password
          </label>
          <UInput
            id="password"
            v-model="password"
            type="password"
            placeholder="Enter your password"
            :class="{ 'border-red-500': passwordError }"
            required
          />
          <p v-if="passwordError" class="text-red-500 text-sm mt-1">{{ passwordError }}</p>
        </div>

        <!-- Remember Me -->
        <div class="flex items-center gap-2">
          <UCheckbox v-model="rememberMe" />
          <label for="remember" class="text-sm text-gray-700 dark:text-gray-300 cursor-pointer">
            Remember me (7 days)
          </label>
        </div>

        <!-- Submit Button -->
        <UButton
          type="submit"
          label="Sign In"
          class="w-full"
          color="green"
          :loading="authStore.loading"
          :disabled="authStore.loading"
        />

        <!-- Divider -->
        <div class="relative flex items-center my-4">
          <div class="flex-grow border-t border-gray-300 dark:border-gray-700"></div>
          <span class="flex-shrink mx-4 text-sm text-gray-600 dark:text-gray-400">OR</span>
          <div class="flex-grow border-t border-gray-300 dark:border-gray-700"></div>
        </div>

        <!-- Continue as Guest -->
        <UButton
          label="Continue as Guest"
          variant="outline"
          color="gray"
          class="w-full"
          @click="handleContinueAsGuest"
          :disabled="authStore.loading"
        />

        <!-- Register Link -->
        <div class="text-center pt-2">
          <span class="text-sm text-gray-600 dark:text-gray-400">
            Don't have an account?
          </span>
          <router-link
            to="/register"
            class="text-sm font-medium text-green-600 hover:text-green-700 dark:text-green-500 dark:hover:text-green-400 hover:underline ml-1"
          >
            Sign Up
          </router-link>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../store/authStore'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const emailError = ref('')
const passwordError = ref('')
const sessionExpiredMessage = ref('')

// Check if redirected due to session expiration
onMounted(() => {
  if (route.query.reason === 'session_expired') {
    sessionExpiredMessage.value = 'Your session has expired. Please sign in again.'
  }
})

const validateForm = (): boolean => {
  emailError.value = ''
  passwordError.value = ''

  if (!email.value) {
    emailError.value = 'Email is required'
    return false
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    emailError.value = 'Invalid email format'
    return false
  }

  if (!password.value) {
    passwordError.value = 'Password is required'
    return false
  }

  if (password.value.length < 8) {
    passwordError.value = 'Password must be at least 8 characters'
    return false
  }

  return true
}

const handleLogin = async () => {
  if (!validateForm()) {
    return
  }

  try {
    await authStore.login(email.value, password.value, rememberMe.value)

    // Redirect to the page they were trying to access, or home
    const redirect = route.query.redirect as string || '/'
    router.push(redirect)
  } catch (error: any) {
    console.error('Login failed:', error)
    // Error is already stored in authStore.error
  }
}

const handleContinueAsGuest = () => {
  authStore.continueAsGuest()
  const redirect = route.query.redirect as string || '/'
  router.push(redirect)
}
</script>
