<template>
  <div class="app-wrapper">
    <Toast />

    <!-- Header -->
    <header class="app-header">
      <div class="app-container">
        <div class="app-header-content">
          <!-- Logo et Navigation -->
          <div class="app-header-left">
            <a @click="handleNewImport" class="app-logo">
              <img src="/logo.png" alt="SQL Importer" />
            </a>

            <nav v-if="authStore.isAuthenticated" class="app-nav">
              <Button
                label="New Import"
                icon="pi pi-plus-circle"
                :text="currentRoute !== '/'"
                :severity="currentRoute === '/' ? 'success' : 'secondary'"
                @click="handleNewImport"
                size="small"
              />
              <Button
                label="History"
                icon="pi pi-history"
                :text="currentRoute !== '/history'"
                :severity="currentRoute === '/history' ? 'success' : 'secondary'"
                @click="() => router.push('/history')"
                size="small"
              />
            </nav>
          </div>

          <!-- Actions à droite -->
          <div class="app-header-right">
            <!-- Toggle Thème -->
            <Button
              :icon="isDark ? 'pi pi-sun' : 'pi pi-moon'"
              text
              rounded
              severity="secondary"
              @click="toggleTheme"
              v-tooltip.bottom="isDark ? 'Light Mode' : 'Dark Mode'"
            />

            <!-- Menu utilisateur -->
            <div v-if="authStore.isAuthenticated" class="app-user">
              <Chip class="app-chip">
                <template #icon>
                  <Avatar
                    :label="userInitials"
                    shape="circle"
                    class="app-avatar"
                  />
                </template>
                <div class="app-user-info">
                  <span class="app-user-name">{{ authStore.userDisplayName }}</span>
                  <span class="app-user-email">{{ authStore.user?.email }}</span>
                </div>
              </Chip>

              <Button
                icon="pi pi-sign-out"
                text
                rounded
                severity="danger"
                @click="handleLogout"
                v-tooltip.bottom="'Sign Out'"
              />
            </div>

            <!-- Boutons invité -->
            <div v-else class="app-guest">
              <Button
                label="Sign In"
                icon="pi pi-sign-in"
                text
                @click="() => router.push('/login')"
                class="app-signin-btn"
              />
              <Button
                label="Sign Up"
                icon="pi pi-user-plus"
                severity="success"
                @click="() => router.push('/register')"
              />
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Contenu principal -->
    <main class="app-main">
      <div class="app-container">
        <router-view />
      </div>
    </main>

    <!-- Footer -->
    <footer class="app-footer">
      <div class="app-container">
        <div class="app-footer-content">
          <div class="app-footer-links">
            <router-link to="/terms-of-service">Terms of Service</router-link>
            <span class="app-footer-separator">•</span>
            <router-link to="/privacy-policy">Privacy Policy</router-link>
            <span class="app-footer-separator">•</span>
            <router-link to="/legal-notice">Legal Notice</router-link>
          </div>
          <div class="app-footer-version">v{{ appVersion }}</div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from './store/authStore'
import { useMappingStore } from './store/mappingStore'
import { useTheme } from './composables/useTheme'
import { APP_VERSION } from './version'

// Composants PrimeVue
import Button from 'primevue/button'
import Avatar from 'primevue/avatar'
import Chip from 'primevue/chip'
import Toast from 'primevue/toast'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const mappingStore = useMappingStore()
const { isDark, toggleTheme } = useTheme()
const appVersion = APP_VERSION

const currentRoute = computed(() => route.path)

const userInitials = computed(() => {
  if (!authStore.user) return 'G'
  const { firstName, lastName, email } = authStore.user
  if (firstName && lastName) return firstName[0] + lastName[0]
  if (firstName) return firstName[0]
  if (email) return email[0].toUpperCase()
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

<style scoped>
.app-wrapper {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--p-surface-ground);
}

/* Header */
.app-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--p-surface-0);
  border-bottom: 1px solid var(--p-surface-border);
  box-shadow: var(--p-shadow-2);
}

.app-header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: var(--app-header-height);
  gap: 2rem;
}

.app-header-left {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.app-logo {
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: transform 0.3s;
}

.app-logo:hover {
  transform: scale(1.05);
}

.app-logo img {
  height: 4rem;
  width: auto;
}

.app-nav {
  display: flex;
  gap: 0.5rem;
}

.app-header-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.app-user,
.app-guest {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.app-chip {
  display: none;
}

.app-avatar {
  background-color: var(--p-primary-color);
  color: var(--p-primary-contrast-color);
}

.app-user-info {
  display: flex;
  flex-direction: column;
}

.app-user-name {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--p-text-color);
}

.app-user-email {
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.app-signin-btn {
  display: none;
}

/* Main */
.app-main {
  flex: 1;
  padding: 2rem 0;
}

/* Footer */
.app-footer {
  background: var(--p-surface-0);
  border-top: 1px solid var(--p-surface-border);
  padding: 1.5rem 0;
  margin-top: auto;
}

.app-footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.app-footer-links {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.app-footer-links a {
  color: var(--p-text-muted-color);
  text-decoration: none;
  transition: color 0.3s;
  font-size: 0.875rem;
}

.app-footer-links a:hover {
  color: var(--p-primary-color);
}

.app-footer-separator {
  color: var(--p-text-muted-color);
}

.app-footer-version {
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}

/* Responsive */
@media (min-width: 768px) {
  .app-chip {
    display: flex;
  }

  .app-signin-btn {
    display: inline-flex;
  }
}

@media (max-width: 768px) {
  .app-nav {
    display: none;
  }

  .app-header-content {
    gap: 1rem;
  }

  .app-footer-content {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>
