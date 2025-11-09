/**
 * SQL Validation utilities for security and data integrity
 */

export interface ValidationResult {
  valid: boolean
  warnings: string[]
  errors: string[]
}

/**
 * Validates SQL content for security issues and potential problems
 */
export function validateSQL(sql: string): ValidationResult {
  const result: ValidationResult = {
    valid: true,
    warnings: [],
    errors: []
  }

  if (!sql || sql.trim().length === 0) {
    result.errors.push('SQL content is empty')
    result.valid = false
    return result
  }

  // Dangerous keywords that should NOT be in generated INSERT statements
  const dangerousKeywords = [
    'DROP',
    'DELETE',
    'TRUNCATE',
    'ALTER',
    'CREATE',
    'GRANT',
    'REVOKE',
    'EXEC',
    'EXECUTE',
    'SHUTDOWN',
    'KILL'
  ]

  const upperSQL = sql.toUpperCase()

  // Check for dangerous keywords
  for (const keyword of dangerousKeywords) {
    const regex = new RegExp(`\\b${keyword}\\b`, 'i')
    if (regex.test(sql)) {
      result.errors.push(`Dangerous SQL keyword detected: ${keyword}`)
      result.valid = false
    }
  }

  // Check for SQL injection patterns
  const injectionPatterns: Array<{ pattern: RegExp; description: string }> = [
    {
      pattern: /;\s*DROP/i,
      description: 'SQL injection pattern: DROP statement after semicolon'
    },
    {
      pattern: /;\s*DELETE/i,
      description: 'SQL injection pattern: DELETE statement after semicolon'
    },
    {
      pattern: /--\s*$/gm,
      description: 'SQL comment at end of line (potential injection)'
    },
    {
      pattern: /\/\*.*\*\//,
      description: 'SQL multi-line comment (potential injection)'
    },
    {
      pattern: /\bUNION\b.*\bSELECT\b/i,
      description: 'SQL injection pattern: UNION SELECT'
    },
    {
      pattern: /\bOR\b\s+['"]?\w+['"]?\s*=\s*['"]?\w+['"]?/i,
      description: 'SQL injection pattern: OR condition that always true'
    },
    {
      pattern: /\bAND\b\s+['"]?\w+['"]?\s*=\s*['"]?\w+['"]?/i,
      description: 'Suspicious AND condition'
    }
  ]

  for (const { pattern, description } of injectionPatterns) {
    if (pattern.test(sql)) {
      result.errors.push(description)
      result.valid = false
    }
  }

  // Performance and size warnings
  if (sql.length > 1000000) {
    // > 1MB
    result.warnings.push(
      `SQL file is very large (${(sql.length / 1024 / 1024).toFixed(2)}MB), may cause performance issues`
    )
  }

  const lineCount = sql.split('\n').length
  if (lineCount > 10000) {
    result.warnings.push(
      `SQL contains ${lineCount.toLocaleString()} lines, consider splitting into smaller batches`
    )
  }

  // Check for very long lines (potential issue)
  const lines = sql.split('\n')
  const longLines = lines.filter(line => line.length > 5000)
  if (longLines.length > 0) {
    result.warnings.push(
      `Found ${longLines.length} very long line(s) (>5000 chars), may cause issues`
    )
  }

  // Validate INSERT statement structure
  if (upperSQL.includes('INSERT')) {
    // Check for proper INSERT INTO format
    if (!upperSQL.match(/INSERT\s+INTO\s+\w+/i)) {
      result.warnings.push('INSERT statements should use INSERT INTO format')
    }

    // Check for VALUES keyword
    if (!upperSQL.includes('VALUES')) {
      result.warnings.push('INSERT statements should include VALUES clause')
    }
  } else {
    result.warnings.push('No INSERT statements found in SQL')
  }

  return result
}

/**
 * Validates a single value for a given SQL field type
 */
export function validateValue(
  value: any,
  fieldType: string,
  fieldName: string
): { valid: boolean; error?: string } {
  if (value === null || value === undefined || value === '') {
    return { valid: true } // NULL values are handled separately
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
    if (isNaN(num) || !Number.isInteger(num)) {
      return {
        valid: false,
        error: `Field "${fieldName}" expects an integer, got: ${value}`
      }
    }
  }

  // Numeric types (decimal, float, double)
  else if (
    normalizedType.includes('decimal') ||
    normalizedType.includes('numeric') ||
    normalizedType.includes('float') ||
    normalizedType.includes('double') ||
    normalizedType.includes('real')
  ) {
    const num = Number(value)
    if (isNaN(num)) {
      return {
        valid: false,
        error: `Field "${fieldName}" expects a number, got: ${value}`
      }
    }
  }

  // Boolean types
  else if (
    normalizedType.includes('boolean') ||
    normalizedType.includes('bool') ||
    normalizedType === 'bit'
  ) {
    if (
      typeof value !== 'boolean' &&
      value !== 0 &&
      value !== 1 &&
      value !== '0' &&
      value !== '1' &&
      value !== 'true' &&
      value !== 'false'
    ) {
      return {
        valid: false,
        error: `Field "${fieldName}" expects a boolean, got: ${value}`
      }
    }
  }

  // Date/Time types
  else if (normalizedType.includes('date') || normalizedType.includes('time')) {
    const dateValue = new Date(value)
    if (isNaN(dateValue.getTime())) {
      return {
        valid: false,
        error: `Field "${fieldName}" expects a valid date/time, got: ${value}`
      }
    }
  }

  // String length validation for VARCHAR, CHAR
  else if (normalizedType.includes('varchar') || normalizedType.includes('char')) {
    // Extract length from type like "varchar(255)"
    const lengthMatch = fieldType.match(/\((\d+)\)/)
    if (lengthMatch) {
      const maxLength = parseInt(lengthMatch[1])
      const strValue = String(value)
      if (strValue.length > maxLength) {
        return {
          valid: false,
          error: `Field "${fieldName}" exceeds maximum length of ${maxLength} (got ${strValue.length})`
        }
      }
    }
  }

  return { valid: true }
}

/**
 * Counts the number of INSERT statements in SQL
 */
export function countInserts(sql: string): number {
  const matches = sql.match(/INSERT\s+INTO/gi)
  return matches ? matches.length : 0
}

/**
 * Estimates the number of rows being inserted
 */
export function estimateRowCount(sql: string): number {
  // Count VALUES occurrences
  const valuesMatches = sql.match(/\)\s*,\s*\(/g)
  return valuesMatches ? valuesMatches.length + 1 : 1
}

/**
 * Sanitizes a SQL identifier (table name, column name)
 */
export function sanitizeIdentifier(identifier: string): string {
  // Remove any characters that are not alphanumeric or underscore
  return identifier.replace(/[^a-zA-Z0-9_]/g, '')
}

/**
 * Checks if SQL is likely to be safe generated INSERT statements
 */
export function isSafeInsertSQL(sql: string): boolean {
  const validation = validateSQL(sql)
  return validation.valid && validation.errors.length === 0
}
