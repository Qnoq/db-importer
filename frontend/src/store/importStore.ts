import { defineStore } from 'pinia'

export interface ImportMetadata {
  sourceFileName?: string
  mappingSummary?: Record<string, string>
  transformations?: string[]
  databaseType?: string
  validationErrors?: string[]
  validationWarnings?: string[]
  extra?: Record<string, any>
}

export interface Import {
  id: string
  userId: string
  tableName: string
  rowCount: number
  status: 'success' | 'warning' | 'failed'
  errorCount: number
  warningCount: number
  metadata: ImportMetadata
  createdAt: string
  updatedAt: string
}

export interface ImportWithSQL extends Import {
  generatedSql: string
}

export interface ImportStats {
  totalImports: number
  totalRows: number
  successCount: number
  warningCount: number
  failedCount: number
  successRate: number
  mostUsedTable?: string
  lastImportDate?: string
}

export interface CreateImportRequest {
  tableName: string
  rowCount: number
  status: 'success' | 'warning' | 'failed'
  generatedSql: string
  errorCount: number
  warningCount: number
  metadata: ImportMetadata
}

export interface GetImportsRequest {
  tableName?: string
  status?: 'success' | 'warning' | 'failed'
  page?: number
  pageSize?: number
  sortBy?: 'created_at' | 'table_name' | 'row_count'
  sortOrder?: 'asc' | 'desc'
}

export interface GetImportsResponse {
  imports: Import[]
  total: number
  page: number
  pageSize: number
  totalPages: number
}

export interface ImportState {
  imports: Import[]
  total: number
  page: number
  pageSize: number
  totalPages: number
  stats: ImportStats | null
  loading: boolean
  error: string | null
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const useImportStore = defineStore('import', {
  state: (): ImportState => ({
    imports: [],
    total: 0,
    page: 1,
    pageSize: 20,
    totalPages: 0,
    stats: null,
    loading: false,
    error: null
  }),

  actions: {
    async createImport(req: CreateImportRequest): Promise<Import> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          credentials: 'include',
          body: JSON.stringify(req)
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to create import' }))
          throw new Error(errorData.error || 'Failed to create import')
        }

        const data = await response.json()
        return data.data
      } catch (error: any) {
        this.error = error.message || 'Failed to create import'
        throw error
      } finally {
        this.loading = false
      }
    },

    async listImports(req: GetImportsRequest = {}): Promise<void> {
      this.loading = true
      this.error = null

      try {
        // Build query string
        const params = new URLSearchParams()
        if (req.tableName) params.append('tableName', req.tableName)
        if (req.status) params.append('status', req.status)
        if (req.page) params.append('page', req.page.toString())
        if (req.pageSize) params.append('pageSize', req.pageSize.toString())
        if (req.sortBy) params.append('sortBy', req.sortBy)
        if (req.sortOrder) params.append('sortOrder', req.sortOrder)

        const response = await fetch(`${API_URL}/api/v1/imports/list?${params}`, {
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to list imports' }))
          throw new Error(errorData.error || 'Failed to list imports')
        }

        const data = await response.json()
        const result: GetImportsResponse = data.data

        this.imports = result.imports || []
        this.total = result.total
        this.page = result.page
        this.pageSize = result.pageSize
        this.totalPages = result.totalPages
      } catch (error: any) {
        this.error = error.message || 'Failed to list imports'
        throw error
      } finally {
        this.loading = false
      }
    },

    async getImport(id: string): Promise<Import> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports/get?id=${id}`, {
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Import not found' }))
          throw new Error(errorData.error || 'Import not found')
        }

        const data = await response.json()
        return data.data
      } catch (error: any) {
        this.error = error.message || 'Failed to get import'
        throw error
      } finally {
        this.loading = false
      }
    },

    async getImportWithSQL(id: string): Promise<ImportWithSQL> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports/sql?id=${id}`, {
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Import not found' }))
          throw new Error(errorData.error || 'Import not found')
        }

        const data = await response.json()
        return data.data
      } catch (error: any) {
        this.error = error.message || 'Failed to get import SQL'
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteImport(id: string): Promise<void> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports/delete?id=${id}`, {
          method: 'DELETE',
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to delete import' }))
          throw new Error(errorData.error || 'Failed to delete import')
        }

        // Remove from local state
        this.imports = this.imports.filter(imp => imp.id !== id)
        this.total = Math.max(0, this.total - 1)
      } catch (error: any) {
        this.error = error.message || 'Failed to delete import'
        throw error
      } finally {
        this.loading = false
      }
    },

    async getStats(): Promise<void> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports/stats`, {
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to get stats' }))
          throw new Error(errorData.error || 'Failed to get stats')
        }

        const data = await response.json()
        this.stats = data.data
      } catch (error: any) {
        this.error = error.message || 'Failed to get stats'
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteOldImports(days: number = 30): Promise<number> {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${API_URL}/api/v1/imports/old?days=${days}`, {
          method: 'DELETE',
          credentials: 'include'
        })

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({ error: 'Failed to delete old imports' }))
          throw new Error(errorData.error || 'Failed to delete old imports')
        }

        const data = await response.json()
        return data.data.deletedCount
      } catch (error: any) {
        this.error = error.message || 'Failed to delete old imports'
        throw error
      } finally {
        this.loading = false
      }
    },

    downloadSQL(sql: string, filename: string) {
      const blob = new Blob([sql], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    }
  },

  getters: {
    hasImports: (state): boolean => state.imports.length > 0,

    importsByStatus: (state) => (status: 'success' | 'warning' | 'failed') => {
      return state.imports.filter(imp => imp.status === status)
    }
  }
})
