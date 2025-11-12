import { describe, it, expect } from 'vitest'
import {
  validateCell,
  validateDataset,
  getCellClass,
  getValidationIcon,
  type ValidationSeverity,
} from './dataValidation'
import type { Field } from '../store/mappingStore'

// Mock field helper
const createField = (
  name: string,
  type: string,
  nullable: boolean = true
): Field => ({
  name,
  type,
  nullable,
})

describe('validateCell - NULL constraints', () => {
  it('should reject NULL in non-nullable field', () => {
    const field = createField('name', 'varchar(255)', false)
    const result = validateCell(null, field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
    expect(result.message).toContain('cannot be NULL')
  })

  it('should reject empty string in non-nullable field', () => {
    const field = createField('name', 'varchar(255)', false)
    const result = validateCell('', field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
  })

  it('should accept NULL in nullable field', () => {
    const field = createField('description', 'text', true)
    const result = validateCell(null, field, 0, 0)
    expect(result.valid).toBe(true)
    expect(result.severity).toBe('info')
    expect(result.message).toBe('NULL value')
  })

  it('should accept empty string in nullable field', () => {
    const field = createField('description', 'text', true)
    const result = validateCell('', field, 0, 0)
    expect(result.valid).toBe(true)
    expect(result.severity).toBe('info')
  })
})

describe('validateCell - Numeric validation', () => {
  it('should accept valid integers', () => {
    const field = createField('age', 'int')
    const result = validateCell(42, field, 0, 0)
    expect(result.valid).toBe(true)
  })

  it('should reject non-numeric values for numeric fields', () => {
    const field = createField('age', 'int')
    const result = validateCell('not a number', field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
    expect(result.message).toContain('Expected number')
  })

  it('should warn about rounding for integer fields', () => {
    const field = createField('count', 'int')
    const result = validateCell(42.7, field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('warning')
    expect(result.message).toContain('rounded to integer')
    expect(result.suggestion).toBe('43')
  })

  it('should validate TINYINT range', () => {
    const field = createField('status', 'tinyint')
    expect(validateCell(100, field, 0, 0).valid).toBe(true)

    const resultTooLow = validateCell(-200, field, 0, 0)
    expect(resultTooLow.valid).toBe(false)
    expect(resultTooLow.severity).toBe('error')
    expect(resultTooLow.message).toContain('TINYINT range')

    const resultTooHigh = validateCell(200, field, 0, 0)
    expect(resultTooHigh.valid).toBe(false)
    expect(resultTooHigh.message).toContain('TINYINT range')
  })

  it('should validate SMALLINT range', () => {
    const field = createField('value', 'smallint')
    expect(validateCell(30000, field, 0, 0).valid).toBe(true)

    const resultTooLow = validateCell(-40000, field, 0, 0)
    expect(resultTooLow.valid).toBe(false)
    expect(resultTooLow.severity).toBe('error')
    expect(resultTooLow.message).toContain('SMALLINT range')
  })

  it('should accept valid decimals', () => {
    const field = createField('price', 'decimal(10,2)')
    const result = validateCell(99.99, field, 0, 0)
    expect(result.valid).toBe(true)
  })

  it('should warn about exceeding decimal precision', () => {
    const field = createField('price', 'decimal(5,2)')
    const result = validateCell(12345.67, field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('warning')
    expect(result.message).toContain('exceeds precision')
  })

  it('should warn about exceeding decimal scale', () => {
    const field = createField('price', 'decimal(10,2)')
    const result = validateCell(99.999, field, 0, 0)
    expect(result.valid).toBe(true)
    expect(result.severity).toBe('warning')
    expect(result.message).toContain('exceed scale')
  })
})

describe('validateCell - Boolean validation', () => {
  it('should accept valid boolean values', () => {
    const field = createField('active', 'boolean')
    expect(validateCell(true, field, 0, 0).valid).toBe(true)
    expect(validateCell(false, field, 0, 0).valid).toBe(true)
    expect(validateCell(1, field, 0, 0).valid).toBe(true)
    expect(validateCell(0, field, 0, 0).valid).toBe(true)
    expect(validateCell('true', field, 0, 0).valid).toBe(true)
    expect(validateCell('false', field, 0, 0).valid).toBe(true)
    expect(validateCell('yes', field, 0, 0).valid).toBe(true)
    expect(validateCell('no', field, 0, 0).valid).toBe(true)
  })

  it('should reject invalid boolean values', () => {
    const field = createField('active', 'bool')
    const result = validateCell('maybe', field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
    expect(result.message).toContain('Expected boolean')
  })
})

describe('validateCell - Date/Time validation', () => {
  it('should accept valid dates', () => {
    const field = createField('birthday', 'date')
    expect(validateCell('2023-12-25', field, 0, 0).valid).toBe(true)
    expect(validateCell('25/12/2023', field, 0, 0).valid).toBe(true)
  })

  it('should reject invalid dates', () => {
    const field = createField('birthday', 'date')
    const result = validateCell('not a date', field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
    expect(result.message).toContain('Invalid date format')
  })

  it('should warn about unusual years', () => {
    const field = createField('event_date', 'date')
    const result = validateCell('1800-01-01', field, 0, 0)
    expect(result.valid).toBe(true)
    expect(result.severity).toBe('warning')
    expect(result.message).toContain('Unusual year')
  })

  it('should accept datetime values', () => {
    const field = createField('created_at', 'datetime')
    expect(validateCell('2023-12-25 15:30:00', field, 0, 0).valid).toBe(true)
  })
})

describe('validateCell - String validation', () => {
  it('should accept strings within length', () => {
    const field = createField('name', 'varchar(50)')
    const result = validateCell('John Doe', field, 0, 0)
    expect(result.valid).toBe(true)
  })

  it('should reject strings exceeding length', () => {
    const field = createField('code', 'varchar(5)')
    const result = validateCell('TOOLONG', field, 0, 0)
    expect(result.valid).toBe(false)
    expect(result.severity).toBe('error')
    expect(result.message).toContain('exceeds maximum')
  })

  it('should warn when close to length limit', () => {
    const field = createField('code', 'varchar(20)')
    const result = validateCell('1234567890123456789', field, 0, 0) // 19 chars, limit 20 (> 90%)
    expect(result.valid).toBe(true)
    expect(result.severity).toBe('warning')
    expect(result.message).toContain('close to maximum')
  })

  it('should validate email format', () => {
    const field = createField('email', 'varchar(255)')
    expect(validateCell('user@example.com', field, 0, 0).valid).toBe(true)

    const invalidResult = validateCell('not-an-email', field, 0, 0)
    expect(invalidResult.valid).toBe(false)
    expect(invalidResult.severity).toBe('warning')
    expect(invalidResult.message).toContain('valid email')
  })

  it('should validate URL format', () => {
    const field = createField('website', 'varchar(255)')
    expect(validateCell('https://example.com', field, 0, 0).valid).toBe(true)

    const invalidResult = validateCell('not a url', field, 0, 0)
    expect(invalidResult.valid).toBe(false)
    expect(invalidResult.severity).toBe('warning')
    expect(invalidResult.message).toContain('valid URL')
  })

  it('should accept TEXT fields without length check', () => {
    const field = createField('description', 'text')
    const longText = 'x'.repeat(10000)
    const result = validateCell(longText, field, 0, 0)
    expect(result.valid).toBe(true)
  })
})

describe('validateDataset', () => {
  it('should validate entire dataset', () => {
    const fields: Field[] = [
      createField('id', 'int', false),
      createField('name', 'varchar(50)', false),
      createField('age', 'int', true),
    ]
    const data = [
      [1, 'John', 30],
      [2, 'Jane', 25],
      [3, 'Bob', null],
    ]
    const mapping = { 'ID': 'id', 'Name': 'name', 'Age': 'age' }
    const headers = ['ID', 'Name', 'Age']

    const result = validateDataset(data, fields, mapping, headers)
    expect(result.errorCount).toBe(0)
    expect(result.warningCount).toBe(0)
    expect(result.validRowCount).toBe(3)
  })

  it('should count errors and warnings', () => {
    const fields: Field[] = [
      createField('id', 'int', false),
      createField('name', 'varchar(5)', false),
    ]
    const data = [
      [1, 'John'],
      [2, 'VeryLongName'], // Exceeds varchar(5)
      [null, 'Bob'], // NULL in non-nullable field
    ]
    const mapping = { 'ID': 'id', 'Name': 'name' }
    const headers = ['ID', 'Name']

    const result = validateDataset(data, fields, mapping, headers)
    expect(result.errorCount).toBeGreaterThan(0)
    expect(result.validRowCount).toBeLessThan(3)
  })

  it('should handle unmapped columns', () => {
    const fields: Field[] = [createField('id', 'int', false)]
    const data = [[1, 'Unmapped']]
    const mapping = { 'ID': 'id' } // 'Extra' column not mapped
    const headers = ['ID', 'Extra']

    const result = validateDataset(data, fields, mapping, headers)
    expect(result.errorCount).toBe(0)
  })

  it('should handle missing fields gracefully', () => {
    const fields: Field[] = [createField('id', 'int', false)]
    const data = [[1]]
    const mapping = { 'ID': 'unknown_field' }
    const headers = ['ID']

    const result = validateDataset(data, fields, mapping, headers)
    // Should not crash
    expect(result).toBeDefined()
  })
})

describe('getCellClass', () => {
  it('should return error class', () => {
    const validation = { valid: false, severity: 'error' as ValidationSeverity }
    expect(getCellClass(validation)).toBe('validation-error')
  })

  it('should return warning class', () => {
    const validation = { valid: true, severity: 'warning' as ValidationSeverity }
    expect(getCellClass(validation)).toBe('validation-warning')
  })

  it('should return info class', () => {
    const validation = { valid: true, severity: 'info' as ValidationSeverity }
    expect(getCellClass(validation)).toBe('validation-info')
  })

  it('should return success class', () => {
    const validation = { valid: true, severity: 'success' as ValidationSeverity }
    expect(getCellClass(validation)).toBe('validation-success')
  })

  it('should return empty string for null', () => {
    expect(getCellClass(null)).toBe('')
  })
})

describe('getValidationIcon', () => {
  it('should return error icon', () => {
    expect(getValidationIcon('error')).toBe('pi-times-circle')
  })

  it('should return warning icon', () => {
    expect(getValidationIcon('warning')).toBe('pi-exclamation-triangle')
  })

  it('should return info icon', () => {
    expect(getValidationIcon('info')).toBe('pi-info-circle')
  })

  it('should return success icon', () => {
    expect(getValidationIcon('success')).toBe('pi-check-circle')
  })
})
