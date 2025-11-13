<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-200px)]">
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
          color="warning"
          variant="soft"
          title="Session Expired"
          :description="sessionExpiredMessage"
          :close-button="{ icon: 'i-heroicons-x-mark-20-solid', color: 'gray', variant: 'ghost', padded: false }"
          @close="sessionExpiredMessage = ''"
        />

        <!-- Error Message -->
        <UAlert
          v-if="authStore.error"
          color="error"
          variant="soft"
          title="Error"
          :description="authStore.error"
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
            class="w-full"
            :ui="{ base: 'w-full' }"
            :error="!!emailError"
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
            class="w-full"
            :ui="{ base: 'w-full' }"
            :error="!!passwordError"
            required
          />
          <p v-if="passwordError" class="text-red-500 text-sm mt-1">{{ passwordError }}</p>
        </div>

        <!-- Remember Me -->
        <div class="flex items-center gap-2">
          <UCheckbox 
            v-model="rememberMe" 
            label="Remember me"
          />
        </div>

        <!-- Submit Button -->
        <UButton
          type="submit"
          color="success"
          variant="solid"
          size="md"
          class="w-full"
          :loading="authStore.loading"
          :disabled="authStore.loading"
        >
          Sign In
        </UButton>

        <!-- Divider -->
        <div class="relative flex items-center my-4">
          <div class="flex-grow border-t border-gray-300 dark:border-gray-700"></div>
          <span class="flex-shrink mx-4 text-sm text-gray-600 dark:text-gray-400">OR</span>
          <div class="flex-grow border-t border-gray-300 dark:border-gray-700"></div>
        </div>

        <!-- Continue as Guest -->
        <UButton
          variant="outline"
          color="neutral"
          size="md"
          class="w-full"
          @click="handleContinueAsGuest"
          :disabled="authStore.loading"
        >
          Continue as Guest
        </UButton>

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

onMounted(() => {
  // Check for session expired message
  if (route.query.sessionExpired === 'true') {
    sessionExpiredMessage.value = 'Your session has expired. Please sign in again.'
  }
})

const validateForm = (): boolean => {
  emailError.value = ''
  passwordError.value = ''
  
  let isValid = true
  
  if (!email.value) {
    emailError.value = 'Email is required'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    emailError.value = 'Please enter a valid email'
    isValid = false
  }
  
  if (!password.value) {
    passwordError.value = 'Password is required'
    isValid = false
  } else if (password.value.length < 8) {
    passwordError.value = 'Password must be at least 8 characters'
    isValid = false
  }
  
  return isValid
}

const handleLogin = async () => {
  if (!validateForm()) return
  
  await authStore.login(email.value, password.value)
  
  if (!authStore.error) {
    const redirectTo = route.query.redirect as string || '/'
    router.push(redirectTo)
  }
}

const handleContinueAsGuest = () => {
  authStore.continueAsGuest()
  const redirectTo = route.query.redirect as string || '/'
  router.push(redirectTo)
}
</script>