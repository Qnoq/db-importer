/**
 * SQL Sanitization utilities for safe SQL generation
 */

/**
 * Sanitizes a value for use in SQL INSERT statements
 * @param value The value to sanitize
 * @param fieldType The SQL field type (e.g., 'int', 'varchar', 'date')
 * @returns Sanitized SQL-safe string representation
 */
export function sanitizeValue(value: any, fieldType: string): string {
  // Handle NULL values
  if (value === null || value === undefined || value === '') {
    return 'NULL'
  }

  const normalizedType = fieldType.toLowerCase()

  // Integer types
  if (
    normalizedType.includes('int') ||
    normalizedType.includes('integer') ||
    normalizedType.includes('bigint') ||
    normalizedType.includes('smallint') ||
    normalizedType.includes('tinyint')
  ) {
    const num = Number(value)
    if (isNaN(num)) {
      throw new Error(`Invalid integer value: ${value}`)
    }
    return Math.floor(num).toString()
  }

  // Numeric types (decimal, float, double, real)
  if (
    normalizedType.includes('decimal') ||
    normalizedType.includes('numeric') ||
    normalizedType.includes('float') ||
    normalizedType.includes('double') ||
    normalizedType.includes('real')
  ) {
    const num = Number(value)
    if (isNaN(num)) {
      throw new Error(`Invalid numeric value: ${value}`)
    }
    return num.toString()
  }

  // Boolean types
  if (
    normalizedType.includes('boolean') ||
    normalizedType.includes('bool') ||
    normalizedType === 'bit'
  ) {
    // Convert to 1 or 0 for maximum compatibility
    if (
      value === true ||
      value === 1 ||
      value === '1' ||
      value === 'true' ||
      value === 'TRUE'
    ) {
      return '1'
    }
    if (
      value === false ||
      value === 0 ||
      value === '0' ||
      value === 'false' ||
      value === 'FALSE'
    ) {
      return '0'
    }
    throw new Error(`Invalid boolean value: ${value}`)
  }

  // Date types
  if (normalizedType.includes('date') && !normalizedType.includes('time')) {
    const date = new Date(value)
    if (isNaN(date.getTime())) {
      throw new Error(`Invalid date value: ${value}`)
    }
    // Format as YYYY-MM-DD
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `'${year}-${month}-${day}'`
  }

  // DateTime types
  if (
    normalizedType.includes('datetime') ||
    normalizedType.includes('timestamp')
  ) {
    const date = new Date(value)
    if (isNaN(date.getTime())) {
      throw new Error(`Invalid datetime value: ${value}`)
    }
    // Format as YYYY-MM-DD HH:MM:SS
    const iso = date.toISOString()
    const datetime = iso.replace('T', ' ').substring(0, 19)
    return `'${datetime}'`
  }

  // Time types
  if (normalizedType === 'time') {
    // Accept HH:MM:SS format or parse from date
    const timeMatch = String(value).match(/^(\d{1,2}):(\d{2}):(\d{2})$/)
    if (timeMatch) {
      return `'${value}'`
    }
    const date = new Date(value)
    if (!isNaN(date.getTime())) {
      const hours = String(date.getHours()).padStart(2, '0')
      const minutes = String(date.getMinutes()).padStart(2, '0')
      const seconds = String(date.getSeconds()).padStart(2, '0')
      return `'${hours}:${minutes}:${seconds}'`
    }
    throw new Error(`Invalid time value: ${value}`)
  }

  // JSON types
  if (normalizedType === 'json' || normalizedType === 'jsonb') {
    try {
      const jsonString =
        typeof value === 'string' ? value : JSON.stringify(value)
      // Escape single quotes for SQL
      const escaped = jsonString.replace(/'/g, "''")
      return `'${escaped}'`
    } catch (error) {
      throw new Error(`Invalid JSON value: ${value}`)
    }
  }

  // UUID types
  if (normalizedType === 'uuid') {
    const str = String(value)
    // Basic UUID format validation
    if (
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        str
      )
    ) {
      throw new Error(`Invalid UUID format: ${value}`)
    }
    return `'${str}'`
  }

  // Default: String types (varchar, char, text, etc.)
  return escapeString(String(value))
}

/**
 * Escapes a string value for safe use in SQL
 * Handles single quotes, backslashes, and other special characters
 */
export function escapeString(value: string): string {
  if (typeof value !== 'string') {
    value = String(value)
  }

  // Escape single quotes by doubling them (SQL standard)
  let escaped = value.replace(/'/g, "''")

  // Escape backslashes (important for PostgreSQL and some MySQL modes)
  // Note: This might need to be adjusted based on the target database
  escaped = escaped.replace(/\\/g, '\\\\')

  // Escape null bytes
  escaped = escaped.replace(/\0/g, '')

  // Escape control characters
  escaped = escaped.replace(/\r/g, '\\r')
  escaped = escaped.replace(/\n/g, '\\n')
  escaped = escaped.replace(/\t/g, '\\t')

  return `'${escaped}'`
}

/**
 * Sanitizes a SQL identifier (table name, column name)
 * Wraps in backticks for MySQL or double quotes for PostgreSQL
 */
export function sanitizeIdentifier(
  identifier: string,
  dialect: 'mysql' | 'postgresql' = 'mysql'
): string {
  // Remove potentially dangerous characters
  const cleaned = identifier.replace(/[^a-zA-Z0-9_]/g, '')

  if (cleaned !== identifier) {
    console.warn(
      `Identifier "${identifier}" was sanitized to "${cleaned}"`
    )
  }

  // Wrap in appropriate quotes based on dialect
  if (dialect === 'postgresql') {
    return `"${cleaned}"`
  } else {
    // MySQL
    return `\`${cleaned}\``
  }
}

/**
 * Batch sanitizes multiple values for a row
 */
export function sanitizeRow(
  row: any[],
  fieldTypes: string[]
): string[] {
  if (row.length !== fieldTypes.length) {
    throw new Error(
      `Row length (${row.length}) does not match field types length (${fieldTypes.length})`
    )
  }

  return row.map((value, index) =>
    sanitizeValue(value, fieldTypes[index])
  )
}

/**
 * Detects likely SQL injection attempts in a value
 */
export function detectSQLInjection(value: string): boolean {
  if (typeof value !== 'string') {
    return false
  }

  const injectionPatterns = [
    /;\s*(DROP|DELETE|TRUNCATE|ALTER)/i,
    /UNION\s+SELECT/i,
    /--\s*$/,
    /\/\*.*\*\//,
    /'.*OR.*'.*=.*'/i,
    /'.*AND.*'.*=.*'/i,
    /xp_cmdshell/i,
    /exec\s*\(/i
  ]

  return injectionPatterns.some(pattern => pattern.test(value))
}

/**
 * Validates and sanitizes a complete SQL value
 * Returns both the sanitized value and whether it's safe
 */
export function safeSanitizeValue(
  value: any,
  fieldType: string
): { sanitized: string; safe: boolean; warning?: string } {
  try {
    // Check for injection attempts in string values
    if (typeof value === 'string' && detectSQLInjection(value)) {
      return {
        sanitized: 'NULL',
        safe: false,
        warning: 'Potential SQL injection detected in value'
      }
    }

    const sanitized = sanitizeValue(value, fieldType)

    return {
      sanitized,
      safe: true
    }
  } catch (error) {
    return {
      sanitized: 'NULL',
      safe: false,
      warning:
        error instanceof Error ? error.message : 'Sanitization failed'
    }
  }
}

/**
 * Removes comments from SQL (for cleanup/security)
 */
export function removeComments(sql: string): string {
  // Remove single-line comments
  let cleaned = sql.replace(/--.*$/gm, '')

  // Remove multi-line comments
  cleaned = cleaned.replace(/\/\*[\s\S]*?\*\//g, '')

  return cleaned
}

/**
 * Normalizes whitespace in SQL for consistency
 */
export function normalizeSQL(sql: string): string {
  return sql
    .replace(/\s+/g, ' ') // Replace multiple spaces with single space
    .replace(/\s*,\s*/g, ', ') // Normalize comma spacing
    .replace(/\s*\(\s*/g, '(') // Remove spaces after opening parenthesis
    .replace(/\s*\)\s*/g, ')') // Remove spaces before closing parenthesis
    .trim()
}
