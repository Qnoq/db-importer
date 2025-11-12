<template>
  <div class="register-page">
    <Card class="register-card">
      <template #title>
        <div class="card-title">
          <i class="pi pi-user-plus title-icon"></i>
          <h2>Create Account</h2>
          <p class="subtitle">
            Sign up to save your history, templates, and unlimited imports
          </p>
        </div>
      </template>

      <template #content>
        <form @submit.prevent="handleRegister" class="register-form">
          <!-- Error Message -->
          <Message v-if="authStore.error" severity="error" :closable="false">
            {{ authStore.error }}
          </Message>

          <!-- First Name Field -->
          <div class="field">
            <label for="firstName" class="field-label">
              First Name <span class="optional-text">(Optional)</span>
            </label>
            <InputText
              id="firstName"
              v-model="firstName"
              type="text"
              placeholder="John"
            />
          </div>

          <!-- Last Name Field -->
          <div class="field">
            <label for="lastName" class="field-label">
              Last Name <span class="optional-text">(Optional)</span>
            </label>
            <InputText
              id="lastName"
              v-model="lastName"
              type="text"
              placeholder="Doe"
            />
          </div>

          <!-- Email Field -->
          <div class="field">
            <label for="email" class="field-label">
              Email *
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
              Password *
            </label>
            <Password
              id="password"
              v-model="password"
              placeholder="At least 8 characters"
              :feedback="true"
              toggleMask
              :class="{ 'p-invalid': passwordError }"
              inputClass="password-input"
              required
            >
              <template #footer>
                <Divider />
                <p class="password-hint-title">Suggestions</p>
                <ul class="password-hints">
                  <li>At least 8 characters</li>
                  <li>Mix of letters, numbers, and symbols</li>
                </ul>
              </template>
            </Password>
            <small v-if="passwordError" class="p-error">{{ passwordError }}</small>
          </div>

          <!-- Confirm Password Field -->
          <div class="field">
            <label for="confirmPassword" class="field-label">
              Confirm Password *
            </label>
            <Password
              id="confirmPassword"
              v-model="confirmPassword"
              placeholder="Confirm your password"
              :feedback="false"
              toggleMask
              :class="{ 'p-invalid': confirmPasswordError }"
              inputClass="password-input"
              required
            />
            <small v-if="confirmPasswordError" class="p-error">{{ confirmPasswordError }}</small>
          </div>

          <!-- Terms and Conditions -->
          <div class="terms-section">
            <Checkbox v-model="acceptedTerms" inputId="terms" :binary="true" class="terms-checkbox" />
            <label for="terms" class="terms-label">
              I agree to the
              <a href="#" class="terms-link">Terms of Service</a>
              and
              <a href="#" class="terms-link">Privacy Policy</a>
            </label>
          </div>
          <small v-if="termsError" class="p-error terms-error">{{ termsError }}</small>

          <!-- Submit Button -->
          <Button
            type="submit"
            label="Create Account"
            icon="pi pi-user-plus"
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

          <!-- Login Link -->
          <div class="login-link">
            <span class="login-text">
              Already have an account?
            </span>
            <router-link
              to="/login"
              class="login-link-text"
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
.register-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 200px);
}

.register-card {
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

.register-form {
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

.optional-text {
  color: var(--p-text-muted-color);
}

.password-hint-title {
  font-size: 0.75rem;
  margin-top: 0.5rem;
  color: var(--p-text-muted-color);
}

.password-hints {
  font-size: 0.75rem;
  margin: 0.25rem 0 0 1rem;
  color: var(--p-text-muted-color);
}

.terms-section {
  display: flex;
  align-items: flex-start;
}

.terms-checkbox {
  margin-top: 0.25rem;
}

.terms-label {
  margin-left: 0.5rem;
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.terms-link {
  color: var(--p-primary-color);
  text-decoration: none;
}

.terms-link:hover {
  text-decoration: underline;
}

.terms-error {
  display: block;
}

.divider-text {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.login-link {
  text-align: center;
  margin-top: 1rem;
}

.login-text {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.login-link-text {
  font-size: 0.875rem;
  font-weight: 500;
  margin-left: 0.25rem;
  color: var(--p-primary-color);
  text-decoration: none;
}

.login-link-text:hover {
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
