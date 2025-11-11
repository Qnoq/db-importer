import { describe, it, expect } from 'vitest'
import {
  validateSQL,
  validateValue,
  countInserts,
  estimateRowCount,
  sanitizeIdentifier,
  isSafeInsertSQL,
} from './sqlValidation'

describe('validateSQL', () => {
  it('should validate correct INSERT statements', () => {
    const sql = "INSERT INTO users (id, name) VALUES (1, 'John')"
    const result = validateSQL(sql)
    expect(result.valid).toBe(true)
    expect(result.errors).toHaveLength(0)
  })

  it('should reject empty SQL', () => {
    const result = validateSQL('')
    expect(result.valid).toBe(false)
    expect(result.errors).toContain('SQL content is empty')
  })

  it('should detect DROP keyword', () => {
    const sql = 'DROP TABLE users'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('DROP'))).toBe(true)
  })

  it('should detect DELETE keyword', () => {
    const sql = 'DELETE FROM users WHERE id = 1'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('DELETE'))).toBe(true)
  })

  it('should detect TRUNCATE keyword', () => {
    const sql = 'TRUNCATE TABLE users'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('TRUNCATE'))).toBe(true)
  })

  it('should detect ALTER keyword', () => {
    const sql = 'ALTER TABLE users ADD COLUMN email VARCHAR(255)'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('ALTER'))).toBe(true)
  })

  it('should detect CREATE keyword', () => {
    const sql = 'CREATE TABLE users (id INT)'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('CREATE'))).toBe(true)
  })

  it('should detect UNION SELECT injection pattern', () => {
    const sql = "INSERT INTO users (id) VALUES (1) UNION SELECT * FROM passwords"
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('UNION SELECT'))).toBe(true)
  })

  it('should detect SQL comments', () => {
    const sql = "INSERT INTO users (id) VALUES (1) --"
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('comment'))).toBe(true)
  })

  it('should detect multi-line comments', () => {
    const sql = 'INSERT INTO users (id) VALUES (1) /* malicious */'
    const result = validateSQL(sql)
    expect(result.valid).toBe(false)
    expect(result.errors.some(e => e.includes('comment'))).toBe(true)
  })

  it('should warn about very large SQL files', () => {
    const sql = 'INSERT INTO users (id) VALUES (1)'.repeat(50000)
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('very large'))).toBe(true)
  })

  it('should warn about many lines', () => {
    const sql = Array(11000).fill('INSERT INTO users (id) VALUES (1);').join('\n')
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('lines'))).toBe(true)
  })

  it('should warn about very long lines', () => {
    const longValue = 'x'.repeat(6000)
    const sql = `INSERT INTO users (data) VALUES ('${longValue}')`
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('very long line'))).toBe(true)
  })

  it('should warn if no INSERT statements found', () => {
    const sql = 'SELECT * FROM users'
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('No INSERT statements'))).toBe(true)
  })

  it('should warn about improper INSERT format', () => {
    const sql = 'INSERT users VALUES (1)' // Missing INTO
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('INSERT INTO'))).toBe(true)
  })

  it('should warn if VALUES clause is missing', () => {
    const sql = 'INSERT INTO users (id)' // Missing VALUES
    const result = validateSQL(sql)
    expect(result.warnings.some(w => w.includes('VALUES'))).toBe(true)
  })
})

describe('validateValue', () => {
  it('should validate integer values', () => {
    expect(validateValue(42, 'int', 'age').valid).toBe(true)
    expect(validateValue('123', 'INTEGER', 'id').valid).toBe(true)
  })

  it('should reject non-integer for integer fields', () => {
    const result = validateValue('abc', 'int', 'age')
    expect(result.valid).toBe(false)
    expect(result.error).toContain('expects an integer')
  })

  it('should validate decimal values', () => {
    expect(validateValue(42.5, 'decimal', 'price').valid).toBe(true)
    expect(validateValue('123.45', 'numeric', 'amount').valid).toBe(true)
  })

  it('should reject non-numeric for numeric fields', () => {
    const result = validateValue('not a number', 'decimal', 'price')
    expect(result.valid).toBe(false)
    expect(result.error).toContain('expects a number')
  })

  it('should validate boolean values', () => {
    expect(validateValue(true, 'boolean', 'active').valid).toBe(true)
    expect(validateValue(0, 'bool', 'active').valid).toBe(true)
    expect(validateValue('true', 'boolean', 'active').valid).toBe(true)
    expect(validateValue('false', 'boolean', 'active').valid).toBe(true)
  })

  it('should reject invalid boolean values', () => {
    const result = validateValue('maybe', 'boolean', 'active')
    expect(result.valid).toBe(false)
    expect(result.error).toContain('expects a boolean')
  })

  it('should validate date values', () => {
    expect(validateValue('2023-12-25', 'date', 'birthday').valid).toBe(true)
    expect(validateValue(new Date(), 'datetime', 'created_at').valid).toBe(true)
  })

  it('should reject invalid date values', () => {
    const result = validateValue('not a date', 'date', 'birthday')
    expect(result.valid).toBe(false)
    expect(result.error).toContain('valid date/time')
  })

  it('should validate varchar length', () => {
    const result = validateValue('This is a very long string that exceeds the limit', 'varchar(10)', 'name')
    expect(result.valid).toBe(false)
    expect(result.error).toContain('exceeds maximum length')
  })

  it('should accept varchar within length', () => {
    expect(validateValue('Short', 'varchar(255)', 'name').valid).toBe(true)
  })

  it('should accept NULL values', () => {
    expect(validateValue(null, 'int', 'age').valid).toBe(true)
    expect(validateValue(undefined, 'varchar', 'name').valid).toBe(true)
    expect(validateValue('', 'text', 'description').valid).toBe(true)
  })
})

describe('countInserts', () => {
  it('should count INSERT statements', () => {
    const sql = `
      INSERT INTO users (id) VALUES (1);
      INSERT INTO users (id) VALUES (2);
      INSERT INTO users (id) VALUES (3);
    `
    expect(countInserts(sql)).toBe(3)
  })

  it('should be case insensitive', () => {
    const sql = `
      insert into users (id) VALUES (1);
      INSERT INTO users (id) VALUES (2);
      InSeRt InTo users (id) VALUES (3);
    `
    expect(countInserts(sql)).toBe(3)
  })

  it('should return 0 for no inserts', () => {
    expect(countInserts('SELECT * FROM users')).toBe(0)
    expect(countInserts('')).toBe(0)
  })
})

describe('estimateRowCount', () => {
  it('should estimate rows from VALUES clause', () => {
    const sql = "INSERT INTO users (id) VALUES (1), (2), (3)"
    expect(estimateRowCount(sql)).toBe(3)
  })

  it('should return 1 for single row', () => {
    const sql = "INSERT INTO users (id) VALUES (1)"
    expect(estimateRowCount(sql)).toBe(1)
  })

  it('should handle multi-line VALUES', () => {
    const sql = `
      INSERT INTO users (id, name) VALUES
        (1, 'John'),
        (2, 'Jane'),
        (3, 'Bob')
    `
    expect(estimateRowCount(sql)).toBe(3)
  })
})

describe('sanitizeIdentifier', () => {
  it('should remove non-alphanumeric characters except underscore', () => {
    expect(sanitizeIdentifier('user-name')).toBe('username')
    expect(sanitizeIdentifier('user@table')).toBe('usertable')
    expect(sanitizeIdentifier('table#1')).toBe('table1')
  })

  it('should keep alphanumeric and underscores', () => {
    expect(sanitizeIdentifier('user_table_123')).toBe('user_table_123')
    expect(sanitizeIdentifier('Table1')).toBe('Table1')
  })

  it('should handle empty result', () => {
    expect(sanitizeIdentifier('---')).toBe('')
    expect(sanitizeIdentifier('###')).toBe('')
  })
})

describe('isSafeInsertSQL', () => {
  it('should return true for safe INSERT statements', () => {
    const sql = "INSERT INTO users (id, name) VALUES (1, 'John')"
    expect(isSafeInsertSQL(sql)).toBe(true)
  })

  it('should return false for SQL with dangerous keywords', () => {
    expect(isSafeInsertSQL('DROP TABLE users')).toBe(false)
    expect(isSafeInsertSQL('DELETE FROM users')).toBe(false)
  })

  it('should return false for SQL injection patterns', () => {
    expect(isSafeInsertSQL("1' OR '1'='1")).toBe(false)
    expect(isSafeInsertSQL('UNION SELECT * FROM passwords')).toBe(false)
  })

  it('should return false for empty SQL', () => {
    expect(isSafeInsertSQL('')).toBe(false)
  })
})
