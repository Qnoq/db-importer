import { defineStore } from 'pinia'
import { useAuthStore } from './authStore'
import { useMappingStore } from './mappingStore'
import type { Table } from './mappingStore'

export interface WorkflowSessionState {
  loading: boolean
  error: string | null
  lastSavedAt: Date | null
  sessionId: string | null
  isRestoring: boolean
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const useWorkflowSessionStore = defineStore('workflowSession', {
  state: (): WorkflowSessionState => ({
    loading: false,
    error: null,
    lastSavedAt: null,
    sessionId: null,
    isRestoring: false
  }),

  actions: {
    /**
     * Save schema content and parsed tables (Step 1)
     */
    async saveSchema(schemaContent: string, tables: Table[]): Promise<void> {
      const authStore = useAuthStore()

      // Only save to backend if user is authenticated
      if (!authStore.isAuthenticated) {
        return // Guest users rely on mappingStore's localStorage
      }

      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/workflow/session/schema`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...authStore.getAuthHeader()
          },
          body: JSON.stringify({
            schemaContent,
            tables
          })
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to save schema' }))
          throw new Error(errorData.error || 'Failed to save schema')
        }

        const data = await response.json()
        this.sessionId = data.data.id
        this.lastSavedAt = new Date()
      } catch (error: any) {
        this.error = error.message || 'Failed to save schema'
        console.error('Error saving schema to session:', error)
        // Don't throw - allow the app to continue with localStorage fallback
      } finally {
        this.loading = false
      }
    },

    /**
     * Save selected table name (Step 2)
     */
    async saveTableSelection(tableName: string): Promise<void> {
      const authStore = useAuthStore()

      if (!authStore.isAuthenticated) {
        return
      }

      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/workflow/session/table`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...authStore.getAuthHeader()
          },
          body: JSON.stringify({
            tableName
          })
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to save table selection' }))
          throw new Error(errorData.error || 'Failed to save table selection')
        }

        this.lastSavedAt = new Date()
      } catch (error: any) {
        this.error = error.message || 'Failed to save table selection'
        console.error('Error saving table selection to session:', error)
      } finally {
        this.loading = false
      }
    },

    /**
     * Save data file information (Step 3)
     */
    async saveDataFile(fileName: string, headers: string[], sampleData: any[][]): Promise<void> {
      const authStore = useAuthStore()

      if (!authStore.isAuthenticated) {
        return
      }

      this.loading = true
      this.error = null

      try {
        // Limit sample data to 50 rows
        const limitedSampleData = sampleData.slice(0, 50)

        const response = await fetch(`${API_URL}/api/v1/workflow/session/data`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...authStore.getAuthHeader()
          },
          body: JSON.stringify({
            fileName,
            headers,
            sampleData: limitedSampleData
          })
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to save data file' }))
          throw new Error(errorData.error || 'Failed to save data file')
        }

        this.lastSavedAt = new Date()
      } catch (error: any) {
        this.error = error.message || 'Failed to save data file'
        console.error('Error saving data file to session:', error)
      } finally {
        this.loading = false
      }
    },

    /**
     * Save column mapping and transformations (Step 4)
     */
    async saveMapping(mapping: Record<string, string>, transformations: Record<string, string> = {}): Promise<void> {
      const authStore = useAuthStore()

      if (!authStore.isAuthenticated) {
        return
      }

      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/workflow/session/mapping`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            ...authStore.getAuthHeader()
          },
          body: JSON.stringify({
            mapping,
            transformations
          })
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to save mapping' }))
          throw new Error(errorData.error || 'Failed to save mapping')
        }

        this.lastSavedAt = new Date()
      } catch (error: any) {
        this.error = error.message || 'Failed to save mapping'
        console.error('Error saving mapping to session:', error)
      } finally {
        this.loading = false
      }
    },

    /**
     * Get active workflow session
     */
    async getSession(): Promise<any | null> {
      const authStore = useAuthStore()

      if (!authStore.isAuthenticated) {
        return null
      }

      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/workflow/session`, {
          headers: authStore.getAuthHeader()
        })

        if (!response.ok) {
          if (response.status === 404) {
            return null // No active session
          }
          const errorData = await response.json().catch(() => ({ error: 'Failed to get session' }))
          throw new Error(errorData.error || 'Failed to get session')
        }

        const data = await response.json()

        if (data.data) {
          this.sessionId = data.data.id
          return data.data
        }

        return null
      } catch (error: any) {
        this.error = error.message || 'Failed to get session'
        console.error('Error getting session:', error)
        return null
      } finally {
        this.loading = false
      }
    },

    /**
     * Restore workflow state from session
     */
    async restoreSession(): Promise<boolean> {
      const authStore = useAuthStore()
      const mappingStore = useMappingStore()

      if (!authStore.isAuthenticated) {
        // Guest users rely on mappingStore's localStorage
        return false
      }

      this.isRestoring = true

      try {
        const session = await this.getSession()

        if (!session) {
          this.isRestoring = false
          return false
        }

        // Restore state to mappingStore
        if (session.schemaTables && session.schemaTables.length > 0) {
          mappingStore.setTables(session.schemaTables)
        }

        if (session.selectedTableName) {
          mappingStore.selectTable(session.selectedTableName)
        }

        if (session.dataHeaders && session.dataHeaders.length > 0) {
          // Note: We don't restore full excel data (too large)
          // We only restore headers and sample data for display
          mappingStore.setExcelData(session.dataHeaders, session.sampleData || [])
        }

        if (session.columnMapping && Object.keys(session.columnMapping).length > 0) {
          mappingStore.setMapping(session.columnMapping)
        }

        if (session.fieldTransformations && Object.keys(session.fieldTransformations).length > 0) {
          mappingStore.setTransformations(session.fieldTransformations)
        }

        console.log('Session restored successfully', {
          step: session.currentStep,
          tables: session.schemaTables?.length,
          selectedTable: session.selectedTableName,
          hasData: session.dataHeaders?.length > 0,
          hasTransformations: !!session.fieldTransformations
        })

        this.isRestoring = false
        return true
      } catch (error) {
        console.error('Error restoring session:', error)
        this.isRestoring = false
        return false
      }
    },

    /**
     * Delete workflow session
     */
    async deleteSession(): Promise<void> {
      const authStore = useAuthStore()

      if (!authStore.isAuthenticated) {
        return
      }

      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/workflow/session`, {
          method: 'DELETE',
          headers: authStore.getAuthHeader()
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to delete session' }))
          throw new Error(errorData.error || 'Failed to delete session')
        }

        this.sessionId = null
        this.lastSavedAt = null
      } catch (error: any) {
        this.error = error.message || 'Failed to delete session'
        console.error('Error deleting session:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    /**
     * Clear local state
     */
    clearState() {
      this.sessionId = null
      this.lastSavedAt = null
      this.error = null
      this.isRestoring = false
    }
  },

  getters: {
    hasSavedSession: (state): boolean => state.sessionId !== null,

    timeSinceLastSave: (state): string | null => {
      if (!state.lastSavedAt) return null

      const now = new Date()
      const diff = now.getTime() - state.lastSavedAt.getTime()
      const seconds = Math.floor(diff / 1000)
      const minutes = Math.floor(seconds / 60)

      if (seconds < 60) {
        return 'Just now'
      } else if (minutes < 60) {
        return `${minutes} minute${minutes > 1 ? 's' : ''} ago`
      } else {
        const hours = Math.floor(minutes / 60)
        return `${hours} hour${hours > 1 ? 's' : ''} ago`
      }
    }
  }
})
