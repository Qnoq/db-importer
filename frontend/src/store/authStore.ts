import { defineStore } from 'pinia'
import { apiClient, ApiError } from '../utils/apiClient'

export interface User {
  id: string
  email: string
  firstName?: string
  lastName?: string
  isActive: boolean
  emailVerified: boolean
  createdAt: string
}

export interface AuthState {
  user: User | null
  isAuthenticated: boolean
  isGuest: boolean
  loading: boolean
  error: string | null
  initialized: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    isAuthenticated: false,
    isGuest: false,
    loading: false,
    error: null,
    initialized: false
  }),

  actions: {
    async register(email: string, password: string, firstName?: string, lastName?: string) {
      this.loading = true
      this.error = null

      try {
        const data = await apiClient.post('/auth/register', {
          email,
          password,
          firstName,
          lastName
        })

        // After successful registration, log in automatically (with remember me enabled by default)
        await this.login(email, password, true)

        return data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Registration failed'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async login(email: string, password: string, rememberMe: boolean = false) {
      this.loading = true
      this.error = null

      try {
        const data = await apiClient.post('/auth/login', {
          email,
          password,
          rememberMe
        })

        // Tokens are now in HTTP-only cookies, just store user data
        this.user = data.data.user
        this.isAuthenticated = true
        this.isGuest = false

        return data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Login failed'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async refreshAccessToken() {
      try {
        await apiClient.post('/auth/refresh')
        // New tokens are set in cookies by the backend
        return true
      } catch (error) {
        console.error('Token refresh error:', error)
        throw error
      }
    },

    async logout() {
      try {
        await apiClient.post('/auth/logout')
      } catch (error) {
        console.error('Logout request failed:', error)
      }

      // Clear state
      this.user = null
      this.isAuthenticated = false
      this.isGuest = true
      this.error = null
    },

    // Check authentication status by calling /auth/me
    async checkAuth() {
      try {
        const data = await apiClient.get('/auth/me')
        this.user = data.data
        this.isAuthenticated = true
        this.isGuest = false
        this.initialized = true
        return true
      } catch (error) {
        console.error('Auth check failed:', error)
        this.user = null
        this.isAuthenticated = false
        this.isGuest = false
        this.initialized = true
        return false
      }
    },

    // Continue as guest
    continueAsGuest() {
      this.isGuest = true
      this.isAuthenticated = false
      this.user = null
    }
  },

  getters: {
    userDisplayName: (state): string => {
      if (!state.user) return 'Guest'
      if (state.user.firstName && state.user.lastName) {
        return `${state.user.firstName} ${state.user.lastName}`
      }
      if (state.user.firstName) {
        return state.user.firstName
      }
      return state.user.email
    }
  }
})
