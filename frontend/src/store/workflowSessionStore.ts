import { defineStore } from 'pinia'
import { nextTick } from 'vue'
import { useAuthStore } from './authStore'
import { useMappingStore } from './mappingStore'
import type { Table } from './mappingStore'
import { apiClient, ApiError } from '../utils/apiClient'

export interface WorkflowSessionState {
  loading: boolean
  error: string | null
  lastSavedAt: Date | null
  sessionId: string | null
  isRestoring: boolean
}

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
        const data = await apiClient.post('/api/v1/workflow/session/schema', {
          schemaContent,
          tables
        })
        this.sessionId = data.data.id
        this.lastSavedAt = new Date()
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to save schema'
        this.error = errorMessage
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
        await apiClient.post('/api/v1/workflow/session/table', { tableName })
        this.lastSavedAt = new Date()
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to save table selection'
        this.error = errorMessage
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

        await apiClient.post('/api/v1/workflow/session/data', {
          fileName,
          headers,
          sampleData: limitedSampleData
        })
        this.lastSavedAt = new Date()
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to save data file'
        this.error = errorMessage
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
        await apiClient.post('/api/v1/workflow/session/mapping', {
          mapping,
          transformations
        })
        this.lastSavedAt = new Date()
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to save mapping'
        this.error = errorMessage
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
        const data = await apiClient.get('/api/v1/workflow/session')

        if (data.data) {
          this.sessionId = data.data.id
          return data.data
        }

        return null
      } catch (error) {
        // 404 means no active session - not an error
        if (error instanceof ApiError && error.status === 404) {
          return null
        }

        const errorMessage = error instanceof ApiError ? error.message : 'Failed to get session'
        this.error = errorMessage
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

        // Wait for Vue to update the DOM before hiding the skeleton
        await nextTick()
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
        await apiClient.delete('/api/v1/workflow/session')
        this.sessionId = null
        this.lastSavedAt = null
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to delete session'
        this.error = errorMessage
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
