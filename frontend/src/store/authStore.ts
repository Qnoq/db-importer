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

export interface AuthTokens {
  accessToken: string
  refreshToken: string
  expiresAt: number
}

export interface AuthState {
  user: User | null
  tokens: AuthTokens | null
  isAuthenticated: boolean
  isGuest: boolean
  loading: boolean
  error: string | null
}

const STORAGE_KEY = 'db-importer-auth'
const STORAGE_VERSION = '1.0'

// Load auth state from localStorage
function loadFromStorage(): Partial<AuthState> | null {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return null

    const parsed = JSON.parse(stored)

    // Check version compatibility
    if (parsed.version !== STORAGE_VERSION) {
      console.warn('Auth storage version mismatch, clearing old data')
      localStorage.removeItem(STORAGE_KEY)
      return null
    }

    // Don't check access token expiration here - we'll handle refresh in the router
    // The refresh token is valid for 7 days, so we should still load the state
    // and let the router handle refreshing the access token if needed

    return parsed.state
  } catch (error) {
    console.error('Failed to load auth state from storage:', error)
    return null
  }
}

// Save auth state to localStorage
function saveToStorage(state: AuthState): void {
  try {
    const toStore = {
      version: STORAGE_VERSION,
      timestamp: new Date().toISOString(),
      state: {
        user: state.user,
        tokens: state.tokens,
        isAuthenticated: state.isAuthenticated,
        isGuest: state.isGuest
      }
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(toStore))
  } catch (error) {
    console.error('Failed to save auth state to storage:', error)
  }
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => {
    const stored = loadFromStorage()

    if (stored && stored.user && stored.tokens) {
      return {
        user: stored.user,
        tokens: stored.tokens,
        isAuthenticated: true,
        isGuest: false,
        loading: false,
        error: null
      }
    }

    // Default: guest mode
    return {
      user: null,
      tokens: null,
      isAuthenticated: false,
      isGuest: true,
      loading: false,
      error: null
    }
  },

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
          body: JSON.stringify({
            email,
            password,
            first_name: firstName,
            last_name: lastName
          })
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || 'Registration failed')
        }

        const data = await response.json()

        // After successful registration, log in automatically
        await this.login(email, password)

        return data
      } catch (error: any) {
        this.error = error.message || 'Registration failed'
        throw error
      } finally {
        this.loading = false
      }
    },

    async login(email: string, password: string) {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/auth/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ email, password })
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.error || 'Login failed')
        }

        const data = await response.json()

        // Calculate token expiration (15 minutes from now)
        const expiresAt = Date.now() + 15 * 60 * 1000

        this.user = data.user
        this.tokens = {
          accessToken: data.access_token,
          refreshToken: data.refresh_token,
          expiresAt
        }
        this.isAuthenticated = true
        this.isGuest = false

        this.persist()

        return data
      } catch (error: any) {
        this.error = error.message || 'Login failed'
        throw error
      } finally {
        this.loading = false
      }
    },

    async refreshAccessToken() {
      if (!this.tokens?.refreshToken) {
        throw new Error('No refresh token available')
      }

      try {
        const response = await fetch(`${API_URL}/auth/refresh`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            refresh_token: this.tokens.refreshToken
          })
        })

        if (!response.ok) {
          // If refresh fails, log out
          this.logout()
          throw new Error('Token refresh failed')
        }

        const data = await response.json()

        // Update tokens
        const expiresAt = Date.now() + 15 * 60 * 1000
        this.tokens = {
          accessToken: data.access_token,
          refreshToken: data.refresh_token,
          expiresAt
        }

        this.persist()

        return data
      } catch (error: any) {
        this.logout()
        throw error
      }
    },

    async logout() {
      // Call backend logout endpoint if authenticated
      if (this.tokens?.refreshToken) {
        try {
          await fetch(`${API_URL}/auth/logout`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${this.tokens.accessToken}`
            },
            body: JSON.stringify({
              refresh_token: this.tokens.refreshToken
            })
          })
        } catch (error) {
          console.error('Logout request failed:', error)
        }
      }

      // Clear state
      this.user = null
      this.tokens = null
      this.isAuthenticated = false
      this.isGuest = true
      this.error = null

      this.clearStorage()
    },

    // Check if token needs refresh (5 minutes before expiration)
    shouldRefreshToken(): boolean {
      if (!this.tokens) return false
      const fiveMinutes = 5 * 60 * 1000
      return Date.now() > this.tokens.expiresAt - fiveMinutes
    },

    // Get authorization header
    getAuthHeader(): Record<string, string> {
      if (!this.tokens?.accessToken) {
        return {}
      }
      return {
        Authorization: `Bearer ${this.tokens.accessToken}`
      }
    },

    persist() {
      saveToStorage(this.$state)
    },

    clearStorage() {
      try {
        localStorage.removeItem(STORAGE_KEY)
      } catch (error) {
        console.error('Failed to clear auth storage:', error)
      }
    },

    // Continue as guest
    continueAsGuest() {
      this.isGuest = true
      this.isAuthenticated = false
      this.user = null
      this.tokens = null
      this.clearStorage()
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
    },

    isTokenExpired: (state): boolean => {
      if (!state.tokens) return true
      return Date.now() > state.tokens.expiresAt
    }
  }
})
