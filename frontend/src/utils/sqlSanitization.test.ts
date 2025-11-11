import { describe, it, expect } from 'vitest'
import {
  sanitizeValue,
  escapeString,
  sanitizeIdentifier,
  sanitizeRow,
  detectSQLInjection,
  safeSanitizeValue,
  removeComments,
  normalizeSQL,
} from './sqlSanitization'

describe('escapeString', () => {
  it('should escape single quotes by doubling them', () => {
    expect(escapeString("O'Reilly")).toBe("'O''Reilly'")
    expect(escapeString("It's a test")).toBe("'It''s a test'")
  })

  it('should escape backslashes', () => {
    expect(escapeString('C:\\Users\\test')).toBe("'C:\\\\Users\\\\test'")
  })

  it('should escape control characters', () => {
    expect(escapeString('Line1\nLine2')).toBe("'Line1\\nLine2'")
    expect(escapeString('Tab\there')).toBe("'Tab\\there'")
    expect(escapeString('Carriage\rReturn')).toBe("'Carriage\\rReturn'")
  })

  it('should remove null bytes', () => {
    expect(escapeString('Test\0value')).toBe("'Testvalue'")
  })

  it('should handle empty strings', () => {
    expect(escapeString('')).toBe("''")
  })

  it('should handle strings with multiple special characters', () => {
    expect(escapeString("It's a \\test\nwith 'quotes'")).toBe(
      "'It''s a \\\\test\\nwith ''quotes'''"
    )
  })
})

describe('sanitizeValue - Integer types', () => {
  it('should sanitize integer values', () => {
    expect(sanitizeValue(42, 'int')).toBe('42')
    expect(sanitizeValue('100', 'INTEGER')).toBe('100')
    expect(sanitizeValue(123.7, 'bigint')).toBe('123')
  })

  it('should floor decimal numbers for integer types', () => {
    expect(sanitizeValue(42.9, 'int')).toBe('42')
    expect(sanitizeValue(99.1, 'smallint')).toBe('99')
  })

  it('should handle negative integers', () => {
    expect(sanitizeValue(-42, 'int')).toBe('-42')
  })

  it('should throw error for invalid integers', () => {
    expect(() => sanitizeValue('not a number', 'int')).toThrow('Invalid integer value')
    expect(() => sanitizeValue('abc', 'INTEGER')).toThrow('Invalid integer value')
  })
})

describe('sanitizeValue - Numeric types', () => {
  it('should sanitize decimal values', () => {
    expect(sanitizeValue(42.5, 'decimal')).toBe('42.5')
    expect(sanitizeValue('123.456', 'numeric')).toBe('123.456')
    expect(sanitizeValue(3.14159, 'float')).toBe('3.14159')
  })

  it('should handle scientific notation', () => {
    expect(sanitizeValue(1e5, 'float')).toBe('100000')
  })

  it('should throw error for invalid numeric values', () => {
    expect(() => sanitizeValue('not a number', 'decimal')).toThrow('Invalid numeric value')
  })
})

describe('sanitizeValue - Boolean types', () => {
  it('should convert true values to 1', () => {
    expect(sanitizeValue(true, 'boolean')).toBe('1')
    expect(sanitizeValue(1, 'bool')).toBe('1')
    expect(sanitizeValue('1', 'boolean')).toBe('1')
    expect(sanitizeValue('true', 'boolean')).toBe('1')
    expect(sanitizeValue('TRUE', 'boolean')).toBe('1')
  })

  it('should convert false values to 0', () => {
    expect(sanitizeValue(false, 'boolean')).toBe('0')
    expect(sanitizeValue(0, 'bool')).toBe('0')
    expect(sanitizeValue('0', 'boolean')).toBe('0')
    expect(sanitizeValue('false', 'boolean')).toBe('0')
    expect(sanitizeValue('FALSE', 'boolean')).toBe('0')
  })

  it('should throw error for invalid boolean values', () => {
    expect(() => sanitizeValue('maybe', 'boolean')).toThrow('Invalid boolean value')
    expect(() => sanitizeValue(2, 'boolean')).toThrow('Invalid boolean value')
  })
})

describe('sanitizeValue - Date types', () => {
  it('should format dates as YYYY-MM-DD', () => {
    const result = sanitizeValue('2023-12-25', 'date')
    expect(result).toMatch(/^'\d{4}-\d{2}-\d{2}'$/)
  })

  it('should format datetime values', () => {
    const result = sanitizeValue('2023-12-25T15:30:00', 'datetime')
    expect(result).toMatch(/^'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'$/)
  })

  it('should format timestamp values', () => {
    const result = sanitizeValue(new Date('2023-12-25'), 'timestamp')
    expect(result).toMatch(/^'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'$/)
  })

  it('should throw error for invalid dates', () => {
    expect(() => sanitizeValue('not a date', 'date')).toThrow('Invalid date value')
    expect(() => sanitizeValue('invalid', 'datetime')).toThrow('Invalid datetime value')
  })
})

describe('sanitizeValue - Time type', () => {
  it('should accept valid time format HH:MM:SS', () => {
    expect(sanitizeValue('15:30:45', 'time')).toBe("'15:30:45'")
    expect(sanitizeValue('00:00:00', 'time')).toBe("'00:00:00'")
  })

  it('should throw error for invalid time', () => {
    expect(() => sanitizeValue('invalid', 'time')).toThrow('Invalid time value')
  })
})

describe('sanitizeValue - JSON types', () => {
  it('should sanitize JSON objects', () => {
    const obj = { name: 'John', age: 30 }
    const result = sanitizeValue(obj, 'json')
    expect(result).toBe("'{\"name\":\"John\",\"age\":30}'")
  })

  it('should sanitize JSON strings', () => {
    const json = '{"key":"value"}'
    const result = sanitizeValue(json, 'jsonb')
    expect(result).toBe("'{\"key\":\"value\"}'")
  })

  it('should escape single quotes in JSON', () => {
    const obj = { text: "It's a test" }
    const result = sanitizeValue(obj, 'json')
    expect(result).toContain("''")
  })
})

describe('sanitizeValue - UUID type', () => {
  it('should accept valid UUIDs', () => {
    const uuid = '550e8400-e29b-41d4-a716-446655440000'
    expect(sanitizeValue(uuid, 'uuid')).toBe(`'${uuid}'`)
  })

  it('should throw error for invalid UUIDs', () => {
    expect(() => sanitizeValue('not-a-uuid', 'uuid')).toThrow('Invalid UUID format')
    expect(() => sanitizeValue('123456', 'uuid')).toThrow('Invalid UUID format')
  })
})

describe('sanitizeValue - String types', () => {
  it('should escape string values', () => {
    expect(sanitizeValue('Hello World', 'varchar')).toBe("'Hello World'")
    expect(sanitizeValue('Test', 'text')).toBe("'Test'")
  })

  it('should handle strings with special characters', () => {
    expect(sanitizeValue("O'Reilly", 'varchar')).toBe("'O''Reilly'")
    expect(sanitizeValue('Line1\nLine2', 'text')).toBe("'Line1\\nLine2'")
  })
})

describe('sanitizeValue - NULL values', () => {
  it('should return NULL for null values', () => {
    expect(sanitizeValue(null, 'varchar')).toBe('NULL')
    expect(sanitizeValue(undefined, 'int')).toBe('NULL')
    expect(sanitizeValue('', 'text')).toBe('NULL')
  })
})

describe('sanitizeIdentifier', () => {
  it('should wrap MySQL identifiers in backticks', () => {
    expect(sanitizeIdentifier('users', 'mysql')).toBe('`users`')
    expect(sanitizeIdentifier('table_name', 'mysql')).toBe('`table_name`')
  })

  it('should wrap PostgreSQL identifiers in double quotes', () => {
    expect(sanitizeIdentifier('users', 'postgresql')).toBe('"users"')
    expect(sanitizeIdentifier('table_name', 'postgresql')).toBe('"table_name"')
  })

  it('should remove dangerous characters', () => {
    expect(sanitizeIdentifier('user-table', 'mysql')).toBe('`usertable`')
    expect(sanitizeIdentifier('user@table', 'mysql')).toBe('`usertable`')
  })

  it('should default to MySQL if no dialect specified', () => {
    expect(sanitizeIdentifier('users')).toBe('`users`')
  })
})

describe('sanitizeRow', () => {
  it('should sanitize all values in a row', () => {
    const row = [1, 'John', true, null]
    const types = ['int', 'varchar', 'boolean', 'int']
    const result = sanitizeRow(row, types)
    expect(result).toEqual(['1', "'John'", '1', 'NULL'])
  })

  it('should throw error if row length does not match field types length', () => {
    const row = [1, 'John']
    const types = ['int']
    expect(() => sanitizeRow(row, types)).toThrow(
      'Row length (2) does not match field types length (1)'
    )
  })
})

describe('detectSQLInjection', () => {
  it('should detect DROP statements', () => {
    expect(detectSQLInjection("'; DROP TABLE users--")).toBe(true)
    expect(detectSQLInjection('value; DROP DATABASE test')).toBe(true)
  })

  it('should detect DELETE statements', () => {
    expect(detectSQLInjection("'; DELETE FROM users--")).toBe(true)
  })

  it('should detect TRUNCATE statements', () => {
    expect(detectSQLInjection("'; TRUNCATE TABLE users--")).toBe(true)
  })

  it('should detect UNION SELECT', () => {
    expect(detectSQLInjection('1 UNION SELECT * FROM users')).toBe(true)
  })

  it('should detect SQL comments', () => {
    expect(detectSQLInjection("admin'--")).toBe(true)
    expect(detectSQLInjection('/* comment */ value')).toBe(true)
  })

  it('should detect OR condition injections', () => {
    expect(detectSQLInjection("' OR '1'='1")).toBe(true)
    expect(detectSQLInjection("' OR 'a'='a")).toBe(true)
  })

  it('should detect xp_cmdshell', () => {
    expect(detectSQLInjection('exec xp_cmdshell')).toBe(true)
  })

  it('should not flag safe values', () => {
    expect(detectSQLInjection('John Doe')).toBe(false)
    expect(detectSQLInjection('test@example.com')).toBe(false)
    expect(detectSQLInjection('123 Main Street')).toBe(false)
  })

  it('should return false for non-string values', () => {
    expect(detectSQLInjection(123 as any)).toBe(false)
    expect(detectSQLInjection(null as any)).toBe(false)
  })
})

describe('safeSanitizeValue', () => {
  it('should sanitize safe values', () => {
    const result = safeSanitizeValue('John', 'varchar')
    expect(result.safe).toBe(true)
    expect(result.sanitized).toBe("'John'")
    expect(result.warning).toBeUndefined()
  })

  it('should detect and block SQL injection', () => {
    const result = safeSanitizeValue("'; DROP TABLE users--", 'varchar')
    expect(result.safe).toBe(false)
    expect(result.sanitized).toBe('NULL')
    expect(result.warning).toBe('Potential SQL injection detected in value')
  })

  it('should handle sanitization errors', () => {
    const result = safeSanitizeValue('not a number', 'int')
    expect(result.safe).toBe(false)
    expect(result.sanitized).toBe('NULL')
    expect(result.warning).toContain('Invalid integer value')
  })
})

describe('removeComments', () => {
  it('should remove single-line comments', () => {
    const sql = 'SELECT * FROM users -- this is a comment'
    expect(removeComments(sql)).toBe('SELECT * FROM users ')
  })

  it('should remove multi-line comments', () => {
    const sql = 'SELECT * /* comment */ FROM users'
    expect(removeComments(sql)).toBe('SELECT *  FROM users')
  })

  it('should remove multiple comments', () => {
    const sql = `
      SELECT * -- comment 1
      FROM users /* comment 2 */
      WHERE active = 1 -- comment 3
    `
    const cleaned = removeComments(sql)
    expect(cleaned).not.toContain('comment')
  })
})

describe('normalizeSQL', () => {
  it('should normalize whitespace', () => {
    const sql = 'SELECT  *   FROM    users'
    expect(normalizeSQL(sql)).toBe('SELECT * FROM users')
  })

  it('should normalize comma spacing', () => {
    const sql = 'SELECT id,name , email,age'
    expect(normalizeSQL(sql)).toBe('SELECT id, name, email, age')
  })

  it('should remove spaces around parentheses', () => {
    const sql = 'INSERT INTO users ( id, name )'
    expect(normalizeSQL(sql)).toBe('INSERT INTO users(id, name)')
  })

  it('should trim the result', () => {
    const sql = '  SELECT * FROM users  '
    expect(normalizeSQL(sql)).toBe('SELECT * FROM users')
  })
})
