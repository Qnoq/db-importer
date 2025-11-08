<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-200px)]">
    <Card class="w-full max-w-md shadow-lg">
      <template #title>
        <div class="text-center">
          <i class="pi pi-sign-in text-4xl text-blue-600 mb-3"></i>
          <h2 class="text-2xl font-bold text-gray-900">Sign In</h2>
          <p class="text-sm text-gray-500 mt-2">
            Sign in to access your history, templates, and more
          </p>
        </div>
      </template>

      <template #content>
        <form @submit.prevent="handleLogin" class="space-y-4">
          <!-- Session Expired Message -->
          <Message v-if="sessionExpiredMessage" severity="warn" :closable="true" @close="sessionExpiredMessage = ''">
            {{ sessionExpiredMessage }}
          </Message>

          <!-- Error Message -->
          <Message v-if="authStore.error" severity="error" :closable="false">
            {{ authStore.error }}
          </Message>

          <!-- Email Field -->
          <div class="field">
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
              Email
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
              Password
            </label>
            <Password
              id="password"
              v-model="password"
              placeholder="Enter your password"
              :feedback="false"
              toggleMask
              class="w-full"
              :class="{ 'p-invalid': passwordError }"
              inputClass="w-full"
              required
            />
            <small v-if="passwordError" class="p-error">{{ passwordError }}</small>
          </div>

          <!-- Remember Me -->
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <Checkbox v-model="rememberMe" inputId="remember" :binary="true" />
              <label for="remember" class="text-sm text-gray-600 select-none">
                Remember me (7 days)
              </label>
            </div>
          </div>

          <!-- Submit Button -->
          <Button
            type="submit"
            label="Sign In"
            icon="pi pi-sign-in"
            class="w-full"
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

          <!-- Register Link -->
          <div class="text-center mt-4">
            <span class="text-sm text-gray-600">
              Don't have an account?
            </span>
            <router-link
              to="/register"
              class="text-sm text-blue-600 hover:text-blue-700 font-medium ml-1"
            >
              Sign Up
            </router-link>
          </div>
        </form>
      </template>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
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
