<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-200px)]">
    <div class="w-full max-w-sm bg-white dark:bg-gray-900 rounded-xl shadow-lg border border-gray-200 dark:border-gray-800 p-8">
      <!-- Card Title -->
      <div class="text-center mb-6">
        <div class="text-4xl mb-3">👤</div>
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Create Account</h2>
        <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
          Sign up to save your history, templates, and unlimited imports
        </p>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleRegister" class="space-y-4">
        <!-- Error Message -->
        <UAlert
          v-if="authStore.error"
          color="error"
          variant="soft"
          title="Error"
          :description="authStore.error"
        />

        <!-- First Name Field -->
        <div>
          <label for="firstName" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            First Name <span class="text-gray-600 dark:text-gray-400">(Optional)</span>
          </label>
          <UInput
            id="firstName"
            v-model="firstName"
            type="text"
            placeholder="John"
            class="w-full"
            :ui="{ base: 'w-full' }"
          />
        </div>

        <!-- Last Name Field -->
        <div>
          <label for="lastName" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            Last Name <span class="text-gray-600 dark:text-gray-400">(Optional)</span>
          </label>
          <UInput
            id="lastName"
            v-model="lastName"
            type="text"
            placeholder="Doe"
            class="w-full"
            :ui="{ base: 'w-full' }"
          />
        </div>

        <!-- Email Field -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            Email *
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
            Password *
          </label>
          <UInput
            id="password"
            v-model="password"
            type="password"
            placeholder="At least 8 characters"
            class="w-full"
            :ui="{ base: 'w-full' }"
            :error="!!passwordError"
            required
          />
          <p v-if="passwordError" class="text-red-500 text-sm mt-1">{{ passwordError }}</p>

          <!-- Password Hints -->
          <div class="bg-gray-50 dark:bg-gray-800 rounded p-3 mt-2">
            <p class="text-xs font-semibold text-gray-700 dark:text-gray-300 mb-2">Suggestions</p>
            <ul class="text-xs text-gray-600 dark:text-gray-400 space-y-1 ml-3">
              <li>• At least 8 characters</li>
              <li>• Mix of letters, numbers, and symbols</li>
            </ul>
          </div>
        </div>

        <!-- Confirm Password Field -->
        <div>
          <label for="confirmPassword" class="block text-sm font-medium text-gray-900 dark:text-gray-100 mb-2">
            Confirm Password *
          </label>
          <UInput
            id="confirmPassword"
            v-model="confirmPassword"
            type="password"
            placeholder="Confirm your password"
            class="w-full"
            :ui="{ base: 'w-full' }"
            :error="!!confirmPasswordError"
            required
          />
          <p v-if="confirmPasswordError" class="text-red-500 text-sm mt-1">{{ confirmPasswordError }}</p>
        </div>

        <!-- Terms and Conditions -->
        <div class="flex items-start gap-2 pt-2">
          <UCheckbox 
            v-model="acceptedTerms"
            :ui="{ base: 'mt-1' }"
          />
          <label for="terms" class="text-sm text-gray-700 dark:text-gray-300 cursor-pointer">
            I agree to the
            <a href="#" class="text-green-600 hover:text-green-700 dark:text-green-500 dark:hover:text-green-400 hover:underline">Terms of Service</a>
            and
            <a href="#" class="text-green-600 hover:text-green-700 dark:text-green-500 dark:hover:text-green-400 hover:underline">Privacy Policy</a>
          </label>
        </div>
        <p v-if="termsError" class="text-red-500 text-sm">{{ termsError }}</p>

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
          Create Account
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

        <!-- Login Link -->
        <div class="text-center pt-2">
          <span class="text-sm text-gray-600 dark:text-gray-400">
            Already have an account?
          </span>
          <router-link
            to="/login"
            class="text-sm font-medium text-green-600 hover:text-green-700 dark:text-green-500 dark:hover:text-green-400 hover:underline ml-1"
          >
            Sign In
          </router-link>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../store/authStore'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const firstName = ref('')
const lastName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const acceptedTerms = ref(false)

const emailError = ref('')
const passwordError = ref('')
const confirmPasswordError = ref('')
const termsError = ref('')

const validateForm = (): boolean => {
  emailError.value = ''
  passwordError.value = ''
  confirmPasswordError.value = ''
  termsError.value = ''

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

  if (confirmPassword.value !== password.value) {
    confirmPasswordError.value = 'Passwords do not match'
    isValid = false
  }

  if (!acceptedTerms.value) {
    termsError.value = 'You must accept the terms and conditions'
    isValid = false
  }

  return isValid
}

const handleRegister = async () => {
  if (!validateForm()) return

  await authStore.register(
    email.value,
    password.value,
    firstName.value,
    lastName.value
  )

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