import { defineStore } from 'pinia'
import { apiClient, ApiError } from '../utils/apiClient'
import type {
  CreateImportResponse,
  GetImportsResponse,
  GetImportResponse,
  GetImportWithSQLResponse,
  DeleteOldImportsResponse,
  JsonValue
} from '../types/api'

export interface ImportMetadata {
  sourceFileName?: string
  mappingSummary?: Record<string, string>
  transformations?: string[]
  databaseType?: string
  validationErrors?: string[]
  validationWarnings?: string[]
  extra?: Record<string, JsonValue>
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
        const response = await apiClient.post<{ data: CreateImportResponse }>('/api/v1/imports', req)
        return response.data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to create import'
        this.error = errorMessage
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

        const response = await apiClient.get<{ data: GetImportsResponse }>(`/api/v1/imports/list?${params}`)
        const result = response.data

        this.imports = result.imports || []
        this.total = result.total
        this.page = result.page
        this.pageSize = result.pageSize
        this.totalPages = result.totalPages
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to list imports'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async getImport(id: string): Promise<Import> {
      this.loading = true
      this.error = null

      try {
        const response = await apiClient.get<{ data: GetImportResponse }>(`/api/v1/imports/get?id=${id}`)
        return response.data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to get import'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async getImportWithSQL(id: string): Promise<ImportWithSQL> {
      this.loading = true
      this.error = null

      try {
        const response = await apiClient.get<{ data: GetImportWithSQLResponse }>(`/api/v1/imports/sql?id=${id}`)
        return response.data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to get import SQL'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteImport(id: string): Promise<void> {
      this.loading = true
      this.error = null

      try {
        await apiClient.delete(`/api/v1/imports/delete?id=${id}`)

        // Remove from local state
        this.imports = this.imports.filter(imp => imp.id !== id)
        this.total = Math.max(0, this.total - 1)
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to delete import'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async getStats(): Promise<void> {
      this.loading = true
      this.error = null

      try {
        const response = await apiClient.get<{ data: ImportStats }>('/api/v1/imports/stats')
        this.stats = response.data
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to get stats'
        this.error = errorMessage
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteOldImports(days: number = 30): Promise<number> {
      this.loading = true
      this.error = null

      try {
        const response = await apiClient.delete<{ data: DeleteOldImportsResponse }>(`/api/v1/imports/old?days=${days}`)
        return response.data.deletedCount
      } catch (error) {
        const errorMessage = error instanceof ApiError ? error.message : 'Failed to delete old imports'
        this.error = errorMessage
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
