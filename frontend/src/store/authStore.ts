import { defineStore } from 'pinia'

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
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    isAuthenticated: false,
    isGuest: false,
    loading: false,
    error: null
  }),

  actions: {
    async register(email: string, password: string, firstName?: string, lastName?: string) {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/auth/register`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include',
          body: JSON.stringify({
            email,
            password,
            firstName,
            lastName
          })
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || 'Registration failed')
        }

        const data = await response.json()

        // After successful registration, log in automatically (with remember me enabled by default)
        await this.login(email, password, true)

        return data
      } catch (error: any) {
        this.error = error.message || 'Registration failed'
        throw error
      } finally {
        this.loading = false
      }
    },

    async login(email: string, password: string, rememberMe: boolean = false) {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/auth/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include', // Send and receive cookies
          body: JSON.stringify({
            email,
            password,
            rememberMe
          })
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || 'Login failed')
        }

        const data = await response.json()

        // Tokens are now in HTTP-only cookies, just store user data
        this.user = data.data.user
        this.isAuthenticated = true
        this.isGuest = false

        return data
      } catch (error: any) {
        this.error = error.message || 'Login failed'
        throw error
      } finally {
        this.loading = false
      }
    },

    async refreshAccessToken() {
      try {
        const response = await fetch(`${API_URL}/auth/refresh`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include' // Send cookies with refresh token
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Token refresh failed' }))
          console.error('Token refresh failed:', errorData)
          throw new Error(errorData.error || 'Token refresh failed')
        }

        // New tokens are set in cookies by the backend
        return true
      } catch (error: any) {
        console.error('Token refresh error:', error)
        throw error
      }
    },

    async logout() {
      try {
        await fetch(`${API_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include' // Send cookies for logout
        })
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
        const response = await fetch(`${API_URL}/auth/me`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include' // Send cookies
        })

        if (response.ok) {
          const data = await response.json()
          this.user = data.data
          this.isAuthenticated = true
          this.isGuest = false
          return true
        } else {
          this.user = null
          this.isAuthenticated = false
          this.isGuest = false
          return false
        }
      } catch (error) {
        console.error('Auth check failed:', error)
        this.user = null
        this.isAuthenticated = false
        this.isGuest = false
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
