/**
 * Data validation and error highlighting
 * Provides real-time validation feedback like Dromo
 */

import type { Field, CellValue } from '../store/mappingStore'
import { parseSmartDate } from './transformations'

export type ValidationSeverity = 'error' | 'warning' | 'info' | 'success'

export interface ValidationResult {
  valid: boolean
  severity: ValidationSeverity
  message?: string
  suggestion?: string
}

export interface CellValidation extends ValidationResult {
  rowIndex: number
  columnIndex: number
  fieldName: string
  value: CellValue
}

/**
 * Validate a single cell value against its field definition
 */
export function validateCell(
  value: CellValue,
  field: Field,
  rowIndex: number,
  columnIndex: number
): CellValidation {
  const fieldType = field.type.toLowerCase()
  const baseValidation: CellValidation = {
    rowIndex,
    columnIndex,
    fieldName: field.name,
    value,
    valid: true,
    severity: 'success'
  }

  // Check NULL constraint
  if (!field.nullable && (value === null || value === undefined || String(value).trim() === '')) {
    return {
      ...baseValidation,
      valid: false,
      severity: 'error',
      message: `Field "${field.name}" cannot be NULL`,
      suggestion: 'Provide a value for this required field'
    }
  }

  // Empty values in nullable fields are OK
  if (value === null || value === undefined || String(value).trim() === '') {
    return {
      ...baseValidation,
      valid: true,
      severity: 'info',
      message: 'NULL value'
    }
  }

  // Type-specific validation
  if (isNumericType(fieldType)) {
    return validateNumeric(value, field, baseValidation)
  }

  if (isBooleanType(fieldType)) {
    return validateBoolean(value, baseValidation)
  }

  if (isDateTimeType(fieldType)) {
    return validateDateTime(value, baseValidation)
  }

  if (isStringType(fieldType)) {
    return validateString(value, field, baseValidation)
  }

  return baseValidation
}

/**
 * Validate numeric value
 */
function validateNumeric(
  value: CellValue,
  field: Field,
  base: CellValidation
): CellValidation {
  const strValue = String(value).trim()
  const numValue = Number(strValue)

  if (isNaN(numValue)) {
    return {
      ...base,
      valid: false,
      severity: 'error',
      message: `Expected number, got "${strValue}"`,
      suggestion: 'Provide a valid numeric value'
    }
  }

  const fieldType = field.type.toLowerCase()

  // Integer types
  if (fieldType.includes('int')) {
    if (!Number.isInteger(numValue)) {
      return {
        ...base,
        valid: false,
        severity: 'warning',
        message: 'Value will be rounded to integer',
        suggestion: `${Math.round(numValue)}`
      }
    }

    // Range checks
    if (fieldType.includes('tinyint')) {
      if (numValue < -128 || numValue > 127) {
        return {
          ...base,
          valid: false,
          severity: 'error',
          message: `TINYINT range is -128 to 127, got ${numValue}`,
          suggestion: 'Use a value within the valid range'
        }
      }
    }

    if (fieldType.includes('smallint')) {
      if (numValue < -32768 || numValue > 32767) {
        return {
          ...base,
          valid: false,
          severity: 'error',
          message: `SMALLINT range is -32768 to 32767, got ${numValue}`,
          suggestion: 'Use a value within the valid range'
        }
      }
    }
  }

  // Decimal precision warnings
  if (fieldType.includes('decimal') || fieldType.includes('numeric')) {
    const match = field.type.match(/\((\d+),(\d+)\)/)
    if (match) {
      const [, precision, scale] = match
      const strNum = String(numValue)
      const parts = strNum.split('.')
      const intPart = parts[0].replace('-', '')
      const decPart = parts[1] || ''

      if (intPart.length + decPart.length > parseInt(precision)) {
        return {
          ...base,
          valid: false,
          severity: 'warning',
          message: `Value exceeds precision ${precision}`,
          suggestion: 'Value will be truncated'
        }
      }

      if (decPart.length > parseInt(scale)) {
        return {
          ...base,
          valid: true,
          severity: 'warning',
          message: `Decimal places exceed scale ${scale}`,
          suggestion: 'Value will be rounded'
        }
      }
    }
  }

  return base
}

/**
 * Validate boolean value
 */
function validateBoolean(value: CellValue, base: CellValidation): CellValidation {
  const strValue = String(value).toLowerCase().trim()
  const validBooleans = ['true', 'false', '1', '0', 'yes', 'no', 'y', 'n', 't', 'f', 'on', 'off']

  if (!validBooleans.includes(strValue)) {
    return {
      ...base,
      valid: false,
      severity: 'error',
      message: `Expected boolean value, got "${value}"`,
      suggestion: 'Use: true/false, 1/0, yes/no'
    }
  }

  return base
}

/**
 * Validate date/time value
 */
function validateDateTime(value: CellValue, base: CellValidation): CellValidation {
  const strValue = String(value).trim()
  const date = parseSmartDate(strValue)

  if (!date) {
    return {
      ...base,
      valid: false,
      severity: 'error',
      message: `Invalid date format: "${strValue}"`,
      suggestion: 'Use format: YYYY-MM-DD or DD/MM/YYYY'
    }
  }

  // Check if date is reasonable
  const year = date.getFullYear()
  if (year < 1900 || year > 2100) {
    return {
      ...base,
      valid: true,
      severity: 'warning',
      message: `Unusual year: ${year}`,
      suggestion: 'Verify this date is correct'
    }
  }

  return base
}

/**
 * Validate string value
 */
function validateString(
  value: CellValue,
  field: Field,
  base: CellValidation
): CellValidation {
  const strValue = String(value)

  // Check length for VARCHAR/CHAR
  const match = field.type.match(/(?:var)?char\((\d+)\)/i)
  if (match) {
    const maxLength = parseInt(match[1])
    if (strValue.length > maxLength) {
      return {
        ...base,
        valid: false,
        severity: 'error',
        message: `Length ${strValue.length} exceeds maximum ${maxLength}`,
        suggestion: `Truncate to ${maxLength} characters`
      }
    }

    // Warning if close to limit
    if (strValue.length > maxLength * 0.9) {
      return {
        ...base,
        valid: true,
        severity: 'warning',
        message: `Length ${strValue.length} is close to maximum ${maxLength}`,
        suggestion: 'Consider using a longer field type'
      }
    }
  }

  // Email validation
  if (field.name.toLowerCase().includes('email')) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(strValue)) {
      return {
        ...base,
        valid: false,
        severity: 'warning',
        message: 'Does not look like a valid email',
        suggestion: 'Check email format'
      }
    }
  }

  // URL validation
  if (field.name.toLowerCase().includes('url') || field.name.toLowerCase().includes('website')) {
    try {
      new URL(strValue)
    } catch {
      return {
        ...base,
        valid: false,
        severity: 'warning',
        message: 'Does not look like a valid URL',
        suggestion: 'Check URL format'
      }
    }
  }

  return base
}

/**
 * Type checking helpers
 */
function isNumericType(type: string): boolean {
  return /int|decimal|numeric|float|double|real|serial/i.test(type)
}

function isBooleanType(type: string): boolean {
  return /bool|bit/i.test(type)
}

function isDateTimeType(type: string): boolean {
  return /date|time|timestamp|datetime|year/i.test(type)
}

function isStringType(type: string): boolean {
  return /char|text|varchar|string/i.test(type)
}

/**
 * Validate entire dataset
 */
export function validateDataset(
  data: CellValue[][],
  fields: Field[],
  mapping: Record<string, string>,
  excelHeaders: string[]
): {
  validations: CellValidation[]
  errorCount: number
  warningCount: number
  validRowCount: number
} {
  const validations: CellValidation[] = []
  let errorCount = 0
  let warningCount = 0
  let validRowCount = 0

  data.forEach((row, rowIndex) => {
    let rowHasError = false

    excelHeaders.forEach((header, colIndex) => {
      const dbColumn = mapping[header]
      if (!dbColumn) return

      const field = fields.find(f => f.name === dbColumn)
      if (!field) return

      const cellValue = row[colIndex]
      const validation = validateCell(cellValue, field, rowIndex, colIndex)

      if (!validation.valid) {
        validations.push(validation)

        if (validation.severity === 'error') {
          errorCount++
          rowHasError = true
        } else if (validation.severity === 'warning') {
          warningCount++
        }
      }
    })

    if (!rowHasError) {
      validRowCount++
    }
  })

  return {
    validations,
    errorCount,
    warningCount,
    validRowCount
  }
}

/**
 * Get CSS class for cell based on validation
 */
export function getCellClass(validation: ValidationResult | null): string {
  if (!validation) return ''

  switch (validation.severity) {
    case 'error':
      return 'bg-red-50 border-red-300 text-red-900'
    case 'warning':
      return 'bg-yellow-50 border-yellow-300 text-yellow-900'
    case 'info':
      return 'bg-blue-50 border-blue-200 text-blue-700'
    case 'success':
      return 'bg-green-50 border-green-200 text-green-700'
    default:
      return ''
  }
}

/**
 * Get icon for validation severity
 */
export function getValidationIcon(severity: ValidationSeverity): string {
  switch (severity) {
    case 'error':
      return 'pi-times-circle'
    case 'warning':
      return 'pi-exclamation-triangle'
    case 'info':
      return 'pi-info-circle'
    case 'success':
      return 'pi-check-circle'
    default:
      return ''
  }
}
