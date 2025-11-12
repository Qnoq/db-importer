<template>
  <div class="login-page">
    <Card class="login-card">
      <template #title>
        <div class="card-title">
          <i class="pi pi-sign-in title-icon"></i>
          <h2>Sign In</h2>
          <p class="subtitle">
            Sign in to access your history, templates, and more
          </p>
        </div>
      </template>

      <template #content>
        <form @submit.prevent="handleLogin" class="login-form">
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
            <label for="email" class="field-label">
              Email
            </label>
            <InputText
              id="email"
              v-model="email"
              type="email"
              placeholder="your@email.com"
              :class="{ 'p-invalid': emailError }"
              required
              autofocus
            />
            <small v-if="emailError" class="p-error">{{ emailError }}</small>
          </div>

          <!-- Password Field -->
          <div class="field">
            <label for="password" class="field-label">
              Password
            </label>
            <Password
              id="password"
              v-model="password"
              placeholder="Enter your password"
              :feedback="false"
              toggleMask
              :class="{ 'p-invalid': passwordError }"
              inputClass="password-input"
              required
            />
            <small v-if="passwordError" class="p-error">{{ passwordError }}</small>
          </div>

          <!-- Remember Me -->
          <div class="remember-section">
            <div class="remember-checkbox">
              <Checkbox v-model="rememberMe" inputId="remember" :binary="true" />
              <label for="remember" class="remember-label">
                Remember me (7 days)
              </label>
            </div>
          </div>

          <!-- Submit Button -->
          <Button
            type="submit"
            label="Sign In"
            icon="pi pi-sign-in"
            class="submit-button"
            :loading="authStore.loading"
            :disabled="authStore.loading"
          />

          <!-- Divider -->
          <Divider align="center">
            <span class="divider-text">OR</span>
          </Divider>

          <!-- Continue as Guest -->
          <Button
            label="Continue as Guest"
            icon="pi pi-user"
            class="guest-button"
            severity="secondary"
            outlined
            @click="handleContinueAsGuest"
            :disabled="authStore.loading"
          />

          <!-- Register Link -->
          <div class="register-link">
            <span class="register-text">
              Don't have an account?
            </span>
            <router-link
              to="/register"
              class="register-link-text"
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
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 200px);
}

.login-card {
  width: 100%;
  max-width: 28rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.card-title {
  text-align: center;
}

.title-icon {
  font-size: 2.25rem;
  margin-bottom: 0.75rem;
  color: var(--p-primary-color);
}

.card-title h2 {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
}

.subtitle {
  font-size: 0.875rem;
  margin: 0.5rem 0 0 0;
  color: var(--p-text-muted-color);
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field {
  display: flex;
  flex-direction: column;
}

.field-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.remember-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.remember-checkbox {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.remember-label {
  font-size: 0.875rem;
  user-select: none;
  color: var(--p-text-muted-color);
}

.divider-text {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.register-link {
  text-align: center;
  margin-top: 1rem;
}

.register-text {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.register-link-text {
  font-size: 0.875rem;
  font-weight: 500;
  margin-left: 0.25rem;
  color: var(--p-primary-color);
  text-decoration: none;
}

.register-link-text:hover {
  text-decoration: underline;
}

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
  width: 100%;
  border-radius: 8px;
  padding: 0.75rem;
}

:deep(.p-password) {
  width: 100%;
}

:deep(.password-input) {
  width: 100%;
}

:deep(.p-button) {
  border-radius: 8px;
  padding: 0.75rem 1rem;
}

:deep(.submit-button),
:deep(.guest-button) {
  width: 100%;
}
</style>
