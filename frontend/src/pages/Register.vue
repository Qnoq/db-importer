<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-200px)]">
    <Card class="w-full max-w-md shadow-lg">
      <template #title>
        <div class="text-center">
          <i class="pi pi-user-plus text-4xl text-blue-600 mb-3"></i>
          <h2 class="text-2xl font-bold text-gray-900">Create Account</h2>
          <p class="text-sm text-gray-500 mt-2">
            Sign up to save your history, templates, and unlimited imports
          </p>
        </div>
      </template>

      <template #content>
        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- Error Message -->
          <Message v-if="authStore.error" severity="error" :closable="false">
            {{ authStore.error }}
          </Message>

          <!-- First Name Field -->
          <div class="field">
            <label for="firstName" class="block text-sm font-medium text-gray-700 mb-2">
              First Name <span class="text-gray-400">(Optional)</span>
            </label>
            <InputText
              id="firstName"
              v-model="firstName"
              type="text"
              placeholder="John"
              class="w-full"
            />
          </div>

          <!-- Last Name Field -->
          <div class="field">
            <label for="lastName" class="block text-sm font-medium text-gray-700 mb-2">
              Last Name <span class="text-gray-400">(Optional)</span>
            </label>
            <InputText
              id="lastName"
              v-model="lastName"
              type="text"
              placeholder="Doe"
              class="w-full"
            />
          </div>

          <!-- Email Field -->
          <div class="field">
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
              Email *
            </label>
            <InputText
              id="email"
              v-model="email"
              type="email"
              placeholder="your@email.com"
              class="w-full"
              :class="{ 'p-invalid': emailError }"
              required
              autofocus
            />
            <small v-if="emailError" class="p-error">{{ emailError }}</small>
          </div>

          <!-- Password Field -->
          <div class="field">
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
              Password *
            </label>
            <Password
              id="password"
              v-model="password"
              placeholder="At least 8 characters"
              :feedback="true"
              toggleMask
              class="w-full"
              :class="{ 'p-invalid': passwordError }"
              inputClass="w-full"
              required
            >
              <template #footer>
                <Divider />
                <p class="text-xs text-gray-600 mt-2">Suggestions</p>
                <ul class="text-xs text-gray-600 ml-4 mt-1">
                  <li>At least 8 characters</li>
                  <li>Mix of letters, numbers, and symbols</li>
                </ul>
              </template>
            </Password>
            <small v-if="passwordError" class="p-error">{{ passwordError }}</small>
          </div>

          <!-- Confirm Password Field -->
          <div class="field">
            <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
              Confirm Password *
            </label>
            <Password
              id="confirmPassword"
              v-model="confirmPassword"
              placeholder="Confirm your password"
              :feedback="false"
              toggleMask
              class="w-full"
              :class="{ 'p-invalid': confirmPasswordError }"
              inputClass="w-full"
              required
            />
            <small v-if="confirmPasswordError" class="p-error">{{ confirmPasswordError }}</small>
          </div>

          <!-- Terms and Conditions -->
          <div class="flex items-start">
            <Checkbox v-model="acceptedTerms" inputId="terms" :binary="true" class="mt-1" />
            <label for="terms" class="ml-2 text-sm text-gray-600">
              I agree to the
              <a href="#" class="text-blue-600 hover:text-blue-700">Terms of Service</a>
              and
              <a href="#" class="text-blue-600 hover:text-blue-700">Privacy Policy</a>
            </label>
          </div>
          <small v-if="termsError" class="p-error block">{{ termsError }}</small>

          <!-- Submit Button -->
          <Button
            type="submit"
            label="Create Account"
            icon="pi pi-user-plus"
            class="w-full mt-4"
            :loading="authStore.loading"
            :disabled="authStore.loading"
          />

          <!-- Divider -->
          <Divider align="center">
            <span class="text-sm text-gray-500">OR</span>
          </Divider>

          <!-- Continue as Guest -->
          <Button
            label="Continue as Guest"
            icon="pi pi-user"
            class="w-full"
            severity="secondary"
            outlined
            @click="handleContinueAsGuest"
            :disabled="authStore.loading"
          />

          <!-- Login Link -->
          <div class="text-center mt-4">
            <span class="text-sm text-gray-600">
              Already have an account?
            </span>
            <router-link
              to="/login"
              class="text-sm text-blue-600 hover:text-blue-700 font-medium ml-1"
            >
              Sign In
            </router-link>
          </div>
        </form>
      </template>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../store/authStore'
import Card from 'primevue/card'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'
import Checkbox from 'primevue/checkbox'
import Message from 'primevue/message'
import Divider from 'primevue/divider'

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
    emailError.value = 'Invalid email format'
    isValid = false
  }

  if (!password.value) {
    passwordError.value = 'Password is required'
    isValid = false
  } else if (password.value.length < 8) {
    passwordError.value = 'Password must be at least 8 characters'
    isValid = false
  }

  if (!confirmPassword.value) {
    confirmPasswordError.value = 'Please confirm your password'
    isValid = false
  } else if (password.value !== confirmPassword.value) {
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
  if (!validateForm()) {
    return
  }

  try {
    await authStore.register(
      email.value,
      password.value,
      firstName.value || undefined,
      lastName.value || undefined
    )

    // Redirect to the page they were trying to access, or home
    const redirect = route.query.redirect as string || '/'
    router.push(redirect)
  } catch (error: any) {
    console.error('Registration failed:', error)
    // Error is already stored in authStore.error
  }
}

const handleContinueAsGuest = () => {
  authStore.continueAsGuest()
  const redirect = route.query.redirect as string || '/'
  router.push(redirect)
}
</script>

<style scoped>
:deep(.p-card) {
  border-radius: 12px;
  overflow: hidden;
}

:deep(.p-card-title) {
  padding: 2rem 2rem 0;
}

:deep(.p-card-content) {
  padding: 1.5rem 2rem 2rem;
}

:deep(.p-inputtext),
:deep(.p-password input) {
  border-radius: 8px;
  border: 1px solid #d1d5db;
  padding: 0.75rem;
  transition: border-color 0.2s;
}

:deep(.p-inputtext:hover),
:deep(.p-password input:hover) {
  border-color: #9ca3af;
}

:deep(.p-inputtext:focus),
:deep(.p-password input:focus) {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

:deep(.p-invalid .p-inputtext),
:deep(.p-invalid input) {
  border-color: #ef4444;
}

:deep(.p-button) {
  border-radius: 8px;
  padding: 0.75rem 1rem;
}
</style>
