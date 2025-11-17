// types/index.ts

export interface Field {
  name: string
  type: string
  nullable?: boolean
  required: boolean
  primary?: boolean
  unique?: boolean
  default?: string | null
  references?: {
    table: string
    column: string
  }
  length?: number
  precision?: number
  scale?: number
}

export interface TableSchema {
  name: string
  fields: Field[]
  indexes?: Index[]
  constraints?: Constraint[]
  comment?: string
}

export interface Index {
  name: string
  columns: string[]
  unique: boolean
  type?: 'btree' | 'hash' | 'gin' | 'gist'
}

export interface Constraint {
  name: string
  type: 'primary' | 'foreign' | 'unique' | 'check'
  columns: string[]
  references?: {
    table: string
    columns: string[]
  }
  checkExpression?: string
}

export interface MappingResult {
  source: string      // Excel column header
  target: string      // Database field name
  confidence: number  // 0-1 confidence score
  autoMapped: boolean
}

export interface ValidationError {
  row?: number
  field?: string
  message: string
  severity: 'error' | 'warning'
}

export interface SQLGenerationOptions {
  includeTruncate: boolean
  useTransaction: boolean
  ignoreErrors: boolean
  includeComments: boolean
  batchSize?: number
  escapeSpecialChars?: boolean
  dateFormat?: string
}

export interface ImportResult {
  success: boolean
  rowsProcessed: number
  rowsInserted: number
  errors: ValidationError[]
  warnings: ValidationError[]
  sql?: string
}

export interface ExcelParseResult {
  headers: string[]
  data: Record<string, any>[]
  sheetName?: string
  totalRows: number
  parsedRows: number
  errors: string[]
}

export interface DatabaseConnection {
  id: string
  name: string
  type: 'mysql' | 'postgresql' | 'sqlite' | 'mssql'
  host?: string
  port?: number
  database: string
  username?: string
  ssl?: boolean
  createdAt: Date
  updatedAt: Date
}

export interface User {
  id: string
  email: string
  name?: string
  role: 'user' | 'admin'
  subscription?: {
    plan: 'free' | 'pro' | 'enterprise'
    validUntil: Date
    features: string[]
  }
  createdAt: Date
  lastLogin: Date
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
  expiresIn: number
}

export interface ApiError {
  code: string
  message: string
  details?: any
  timestamp: Date
}

// Utility types
export type FieldType = 
  | 'string' 
  | 'text'
  | 'int' 
  | 'integer' 
  | 'bigint' 
  | 'smallint'
  | 'decimal' 
  | 'numeric' 
  | 'float' 
  | 'double'
  | 'boolean' 
  | 'bool'
  | 'date' 
  | 'datetime' 
  | 'timestamp'
  | 'time'
  | 'json' 
  | 'jsonb'
  | 'uuid'
  | 'binary' 
  | 'blob'

export type SortDirection = 'asc' | 'desc'

export interface PaginationParams {
  page: number
  limit: number
  sortBy?: string
  sortDirection?: SortDirection
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  totalPages: number
}
