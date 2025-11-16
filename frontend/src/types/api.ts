/**
 * Centralized API Type Definitions
 *
 * This file contains all TypeScript interfaces for API requests and responses,
 * eliminating the use of 'any' types throughout the application.
 */

import type { User } from '../store/authStore'
import type { Import, ImportMetadata, ImportStats } from '../store/importStore'
import type { Table } from '../store/mappingStore'
import type { CellValue } from '../store/mappingStore'

// ============================================================================
// Authentication API Types
// ============================================================================

export interface RegisterRequest {
  email: string
  password: string
  firstName?: string
  lastName?: string
}

export interface RegisterResponse {
  message: string
  user: User
}

export interface LoginRequest {
  email: string
  password: string
  rememberMe?: boolean
}

export interface LoginResponse {
  user: User
  message: string
}

export interface RefreshTokenResponse {
  message: string
}

export interface LogoutResponse {
  message: string
}

export interface MeResponse {
  id: string
  email: string
  firstName?: string
  lastName?: string
  isActive: boolean
  emailVerified: boolean
  createdAt: string
}

// ============================================================================
// Import API Types
// ============================================================================

export interface CreateImportRequest {
  tableName: string
  rowCount: number
  status: 'success' | 'warning' | 'failed'
  generatedSql: string
  errorCount: number
  warningCount: number
  metadata: ImportMetadata
}

export interface CreateImportResponse {
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

export interface GetImportResponse {
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

export interface GetImportWithSQLResponse {
  id: string
  userId: string
  tableName: string
  rowCount: number
  status: 'success' | 'warning' | 'failed'
  errorCount: number
  warningCount: number
  metadata: ImportMetadata
  generatedSql: string
  createdAt: string
  updatedAt: string
}

export interface DeleteImportResponse {
  message: string
}

export interface GetImportStatsResponse {
  totalImports: number
  totalRows: number
  successCount: number
  warningCount: number
  failedCount: number
  successRate: number
  mostUsedTable?: string
  lastImportDate?: string
}

export interface DeleteOldImportsResponse {
  deletedCount: number
  message: string
}

// ============================================================================
// Workflow Session API Types
// ============================================================================

export interface SaveSchemaRequest {
  schemaContent: string
  tables: Table[]
}

export interface SaveSchemaResponse {
  id: string
  message: string
}

export interface SaveTableSelectionRequest {
  tableName: string
}

export interface SaveTableSelectionResponse {
  message: string
}

export interface SaveDataFileRequest {
  fileName: string
  headers: string[]
  sampleData: CellValue[][]
}

export interface SaveDataFileResponse {
  message: string
}

export interface SaveMappingRequest {
  mapping: Record<string, string>
  transformations?: Record<string, string>
}

export interface SaveMappingResponse {
  message: string
}

export interface WorkflowSession {
  id: string
  userId: string
  currentStep: number
  schemaContent?: string
  schemaTables?: Table[]
  selectedTableName?: string
  dataFileName?: string
  dataHeaders?: string[]
  sampleData?: CellValue[][]
  columnMapping?: Record<string, string>
  fieldTransformations?: Record<string, string>
  createdAt: string
  updatedAt: string
}

export interface GetSessionResponse {
  id: string
  userId: string
  currentStep: number
  schemaContent?: string
  schemaTables?: Table[]
  selectedTableName?: string
  dataFileName?: string
  dataHeaders?: string[]
  sampleData?: CellValue[][]
  columnMapping?: Record<string, string>
  fieldTransformations?: Record<string, string>
  createdAt: string
  updatedAt: string
}

export interface DeleteSessionResponse {
  message: string
}

// ============================================================================
// SQL Generation API Types
// ============================================================================

export interface ValidationError {
  row: number
  column: string
  value: CellValue
  field: string
  message: string
  level: 'error' | 'warning' | 'server_error'
}

export interface ValidationResult {
  isValid: boolean
  errors: ValidationError[]
  warnings: ValidationError[]
  serverErrors: ValidationError[]
  totalErrors: number
  totalWarnings: number
  totalServerErrors: number
}

export interface GenerateSQLRequest {
  tableName: string
  fields: Array<{
    name: string
    type: string
    nullable: boolean
  }>
  excelHeaders: string[]
  excelData: CellValue[][]
  mapping: Record<string, string>
  transformations: Record<string, string>
  databaseType: 'mysql' | 'postgres'
}

export interface GenerateSQLResponse {
  sql: string
  rowCount: number
  validation: ValidationResult
}

// ============================================================================
// Generic API Response Types
// ============================================================================

export interface ApiSuccessResponse<T = unknown> {
  data: T
  message?: string
  status: 'success'
}

export interface ApiErrorResponse {
  error: string
  message: string
  status: 'error'
  details?: string[]
}

export type ApiResponse<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse

// ============================================================================
// Utility Types
// ============================================================================

/**
 * Type-safe JSON value
 */
export type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonValue[]
  | { [key: string]: JsonValue }

/**
 * Type for API request body
 */
export type RequestBody = Record<string, JsonValue> | FormData

/**
 * Type for unknown error responses
 */
export interface UnknownErrorResponse {
  message: string
  error?: string
}
