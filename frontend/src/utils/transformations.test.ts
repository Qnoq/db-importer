import { describe, it, expect } from 'vitest'
import {
  transformations,
  parseSmartDate,
  formatDateISO,
  formatDateTimeISO,
  parseExcelDate,
  isYearValue,
  hasYearOnlyValues,
  applyTransformation,
  applyColumnTransformation,
  suggestTransformations,
} from './transformations'

describe('transformations.uppercase', () => {
  it('should convert to uppercase', () => {
    expect(transformations.uppercase.apply('hello')).toBe('HELLO')
    expect(transformations.uppercase.apply('Test123')).toBe('TEST123')
  })
})

describe('transformations.lowercase', () => {
  it('should convert to lowercase', () => {
    expect(transformations.lowercase.apply('HELLO')).toBe('hello')
    expect(transformations.lowercase.apply('Test123')).toBe('test123')
  })
})

describe('transformations.trim', () => {
  it('should remove leading and trailing spaces', () => {
    expect(transformations.trim.apply('  hello  ')).toBe('hello')
    expect(transformations.trim.apply('\t test \n')).toBe('test')
  })

  it('should not modify inner spaces', () => {
    expect(transformations.trim.apply('  hello world  ')).toBe('hello world')
  })
})

describe('transformations.capitalize', () => {
  it('should capitalize first letter of each word', () => {
    expect(transformations.capitalize.apply('hello world')).toBe('Hello World')
    expect(transformations.capitalize.apply('JOHN DOE')).toBe('John Doe')
  })

  it('should handle single words', () => {
    expect(transformations.capitalize.apply('test')).toBe('Test')
  })
})

describe('transformations.removeSpaces', () => {
  it('should remove all spaces', () => {
    expect(transformations.removeSpaces.apply('hello world')).toBe('helloworld')
    expect(transformations.removeSpaces.apply('  test  123  ')).toBe('test123')
  })
})

describe('transformations.removeSpecialChars', () => {
  it('should keep only letters, numbers, and spaces', () => {
    expect(transformations.removeSpecialChars.apply('hello@world!')).toBe('helloworld')
    expect(transformations.removeSpecialChars.apply('test-123_abc')).toBe('test123abc')
    expect(transformations.removeSpecialChars.apply('hello world')).toBe('hello world')
  })
})

describe('transformations.formatPhone', () => {
  it('should extract only digits', () => {
    expect(transformations.formatPhone.apply('(555) 123-4567')).toBe('5551234567')
    expect(transformations.formatPhone.apply('+1-555-123-4567')).toBe('15551234567')
    expect(transformations.formatPhone.apply('555.123.4567')).toBe('5551234567')
  })
})

describe('transformations.formatEmail', () => {
  it('should convert to lowercase and trim', () => {
    expect(transformations.formatEmail.apply('  Test@EXAMPLE.COM  ')).toBe('test@example.com')
    expect(transformations.formatEmail.apply('USER@Domain.Com')).toBe('user@domain.com')
  })
})

describe('transformations.extractNumbers', () => {
  it('should extract all numeric characters', () => {
    expect(transformations.extractNumbers.apply('abc123def456')).toBe('123456')
    expect(transformations.extractNumbers.apply('Price: $99.99')).toBe('9999')
  })

  it('should return empty string if no numbers', () => {
    expect(transformations.extractNumbers.apply('no numbers here')).toBe('')
  })
})

describe('transformations.toBoolean', () => {
  it('should convert truthy values to true', () => {
    expect(transformations.toBoolean.apply('true')).toBe(true)
    expect(transformations.toBoolean.apply('yes')).toBe(true)
    expect(transformations.toBoolean.apply('y')).toBe(true)
    expect(transformations.toBoolean.apply('1')).toBe(true)
    expect(transformations.toBoolean.apply('on')).toBe(true)
  })

  it('should be case insensitive', () => {
    expect(transformations.toBoolean.apply('TRUE')).toBe(true)
    expect(transformations.toBoolean.apply('Yes')).toBe(true)
    expect(transformations.toBoolean.apply('ON')).toBe(true)
  })

  it('should convert falsy values to false', () => {
    expect(transformations.toBoolean.apply('false')).toBe(false)
    expect(transformations.toBoolean.apply('no')).toBe(false)
    expect(transformations.toBoolean.apply('0')).toBe(false)
    expect(transformations.toBoolean.apply('off')).toBe(false)
  })

  it('should handle whitespace', () => {
    expect(transformations.toBoolean.apply('  yes  ')).toBe(true)
  })
})

describe('transformations.toNumber', () => {
  it('should convert strings to numbers', () => {
    expect(transformations.toNumber.apply('123')).toBe(123)
    expect(transformations.toNumber.apply('45.67')).toBe(45.67)
    expect(transformations.toNumber.apply('-99.9')).toBe(-99.9)
  })

  it('should extract numbers from strings with text', () => {
    expect(transformations.toNumber.apply('Price: $99.99')).toBe(99.99)
    expect(transformations.toNumber.apply('Total: 1234.56 USD')).toBe(1234.56)
  })

  it('should return 0 for invalid numbers', () => {
    expect(transformations.toNumber.apply('no numbers')).toBe(0)
  })
})

describe('transformations.formatDate', () => {
  it('should format valid dates', () => {
    const result = transformations.formatDate.apply('2023-12-25')
    expect(result).toMatch(/^\d{4}-\d{2}-\d{2}$/)
  })

  it('should handle different date formats', () => {
    expect(transformations.formatDate.apply('25/12/2023')).toBeDefined()
    expect(transformations.formatDate.apply('2023-12-25')).toBeDefined()
  })

  it('should return original value for invalid dates', () => {
    expect(transformations.formatDate.apply('not a date')).toBe('not a date')
  })
})

describe('transformations.excelDate', () => {
  it('should convert Excel serial dates', () => {
    const result = transformations.excelDate.apply('44927') // 2023-01-01
    expect(result).toMatch(/^2023-01-01/)
  })

  it('should convert years to YYYY-01-01', () => {
    const result = transformations.excelDate.apply('2023')
    expect(result).toMatch(/^2023-01-01/)
  })

  it('should handle Excel serial dates with time', () => {
    const result = transformations.excelDate.apply('44927.5') // 2023-01-01 12:00:00
    expect(result).toContain('2023-01-01')
    expect(result).toContain('12:00:00')
  })

  it('should return original value for invalid dates', () => {
    expect(transformations.excelDate.apply('not a date')).toBe('not a date')
  })
})

describe('parseSmartDate', () => {
  it('should parse ISO format (YYYY-MM-DD)', () => {
    const date = parseSmartDate('2023-12-25')
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
    expect(date?.getMonth()).toBe(11) // December = 11
    expect(date?.getDate()).toBe(25)
  })

  it('should parse DD/MM/YYYY format', () => {
    const date = parseSmartDate('25/12/2023')
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
  })

  it('should parse DD-MM-YYYY format', () => {
    const date = parseSmartDate('25-12-2023')
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
  })

  it('should handle natural date parsing', () => {
    const date = parseSmartDate('December 25, 2023')
    expect(date).toBeInstanceOf(Date)
  })

  it('should return null for invalid dates', () => {
    expect(parseSmartDate('not a date')).toBeNull()
    expect(parseSmartDate('99/99/9999')).toBeNull()
  })

  it('should return null for non-string values', () => {
    expect(parseSmartDate(null as any)).toBeNull()
    expect(parseSmartDate(undefined as any)).toBeNull()
  })
})

describe('formatDateISO', () => {
  it('should format date as YYYY-MM-DD', () => {
    const date = new Date(2023, 11, 25) // December 25, 2023
    expect(formatDateISO(date)).toBe('2023-12-25')
  })

  it('should pad single-digit months and days', () => {
    const date = new Date(2023, 0, 5) // January 5, 2023
    expect(formatDateISO(date)).toBe('2023-01-05')
  })
})

describe('formatDateTimeISO', () => {
  it('should format datetime as YYYY-MM-DD HH:MM:SS', () => {
    const date = new Date(2023, 11, 25, 15, 30, 45)
    expect(formatDateTimeISO(date)).toBe('2023-12-25 15:30:45')
  })

  it('should pad single-digit values', () => {
    const date = new Date(2023, 0, 5, 9, 5, 3)
    expect(formatDateTimeISO(date)).toBe('2023-01-05 09:05:03')
  })
})

describe('parseExcelDate', () => {
  it('should convert Excel serial date 1 to January 1, 1900', () => {
    const date = parseExcelDate(1)
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(1900)
    expect(date?.getMonth()).toBe(0)
    expect(date?.getDate()).toBe(1)
  })

  it('should convert Excel serial date 44927 to January 1, 2023', () => {
    const date = parseExcelDate(44927)
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
    expect(date?.getMonth()).toBe(0)
    expect(date?.getDate()).toBe(1)
  })

  it('should handle dates after fake Feb 29, 1900', () => {
    // Excel has a bug where it thinks 1900 was a leap year
    // Serial 61 should be March 1, 1900
    const date = parseExcelDate(61)
    expect(date).toBeInstanceOf(Date)
  })

  it('should convert year values to YYYY-01-01', () => {
    const date = parseExcelDate(2023)
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
    expect(date?.getMonth()).toBe(0)
    expect(date?.getDate()).toBe(1)
  })

  it('should handle year range 1900-2100', () => {
    expect(parseExcelDate(1900)).toBeInstanceOf(Date)
    expect(parseExcelDate(2000)).toBeInstanceOf(Date)
    expect(parseExcelDate(2100)).toBeInstanceOf(Date)
  })

  it('should handle decimal values (dates with time)', () => {
    const date = parseExcelDate(44927.5) // 2023-01-01 12:00:00
    expect(date).toBeInstanceOf(Date)
    expect(date?.getHours()).toBe(12)
  })

  it('should return null for invalid values', () => {
    expect(parseExcelDate(null)).toBeNull()
    expect(parseExcelDate(undefined)).toBeNull()
    expect(parseExcelDate('not a number')).toBeNull()
  })

  it('should return null for out of range values', () => {
    expect(parseExcelDate(0)).toBeNull()
    expect(parseExcelDate(-1)).toBeNull()
    expect(parseExcelDate(200000)).toBeNull()
  })

  it('should handle string numbers', () => {
    const date = parseExcelDate('44927')
    expect(date).toBeInstanceOf(Date)
    expect(date?.getFullYear()).toBe(2023)
  })
})

describe('isYearValue', () => {
  it('should identify year values', () => {
    expect(isYearValue(2023)).toBe(true)
    expect(isYearValue(1900)).toBe(true)
    expect(isYearValue(2100)).toBe(true)
  })

  it('should reject non-year values', () => {
    expect(isYearValue(123)).toBe(false)
    expect(isYearValue(44927)).toBe(false)
    expect(isYearValue(2101)).toBe(false)
    expect(isYearValue(1899)).toBe(false)
  })

  it('should handle string numbers', () => {
    expect(isYearValue('2023')).toBe(true)
    expect(isYearValue('123')).toBe(false)
  })

  it('should reject non-integers', () => {
    expect(isYearValue(2023.5)).toBe(false)
  })

  it('should handle null/undefined', () => {
    expect(isYearValue(null)).toBe(false)
    expect(isYearValue(undefined)).toBe(false)
  })
})

describe('hasYearOnlyValues', () => {
  it('should detect arrays with mostly year values', () => {
    expect(hasYearOnlyValues([2020, 2021, 2022, 2023])).toBe(true)
    expect(hasYearOnlyValues([2020, 2021, 2022, null, 2023])).toBe(true)
  })

  it('should reject arrays without year values', () => {
    expect(hasYearOnlyValues([44927, 44928, 44929])).toBe(false)
    expect(hasYearOnlyValues([1, 2, 3, 4, 5])).toBe(false)
  })

  it('should handle mixed values', () => {
    const mixed = [2020, 44927, 2021, 44928] // 50% years
    expect(hasYearOnlyValues(mixed)).toBe(true)
  })

  it('should handle empty arrays', () => {
    expect(hasYearOnlyValues([])).toBe(false)
  })

  it('should handle arrays with only nulls', () => {
    expect(hasYearOnlyValues([null, null, null])).toBe(false)
  })
})

describe('applyTransformation', () => {
  it('should apply uppercase transformation', () => {
    expect(applyTransformation('hello', 'uppercase')).toBe('HELLO')
  })

  it('should apply lowercase transformation', () => {
    expect(applyTransformation('HELLO', 'lowercase')).toBe('hello')
  })

  it('should apply trim transformation', () => {
    expect(applyTransformation('  test  ', 'trim')).toBe('test')
  })

  it('should handle null values', () => {
    expect(applyTransformation(null, 'uppercase')).toBeNull()
    expect(applyTransformation(undefined, 'lowercase')).toBeUndefined()
  })

  it('should return value for unknown transformation', () => {
    expect(applyTransformation('test', 'unknown' as any)).toBe('test')
  })

  it('should return value for none transformation', () => {
    expect(applyTransformation('test', 'none')).toBe('test')
  })
})

describe('applyColumnTransformation', () => {
  it('should apply transformation to entire column', () => {
    const data = [
      ['hello', 'world'],
      ['foo', 'bar'],
    ]
    const result = applyColumnTransformation(data, 0, 'uppercase')
    expect(result[0][0]).toBe('HELLO')
    expect(result[1][0]).toBe('FOO')
    expect(result[0][1]).toBe('world') // Other column unchanged
  })

  it('should handle empty data', () => {
    const result = applyColumnTransformation([], 0, 'uppercase')
    expect(result).toEqual([])
  })

  it('should not modify original data', () => {
    const data = [['test']]
    const result = applyColumnTransformation(data, 0, 'uppercase')
    expect(data[0][0]).toBe('test') // Original unchanged
    expect(result[0][0]).toBe('TEST') // Result transformed
  })
})

describe('suggestTransformations', () => {
  it('should suggest numeric transformations for numeric fields', () => {
    const data = ['123', '456', '789']
    const suggestions = suggestTransformations(data, 'int')
    expect(suggestions).toContain('toNumber')
  })

  it('should suggest boolean transformations for boolean fields', () => {
    const data = ['true', 'false', 'yes']
    const suggestions = suggestTransformations(data, 'boolean')
    expect(suggestions).toContain('toBoolean')
  })

  it('should suggest date transformations for date fields', () => {
    const data = ['2023-01-01', '2023-02-01']
    const suggestions = suggestTransformations(data, 'date')
    expect(suggestions).toContain('formatDate')
  })

  it('should suggest Excel date transformation for Excel serial dates', () => {
    const data = [44927, 44928, 44929]
    const suggestions = suggestTransformations(data, 'datetime')
    expect(suggestions).toContain('excelDate')
  })

  it('should suggest email transformations for email-like data', () => {
    const data = ['test@example.com', 'user@domain.com']
    const suggestions = suggestTransformations(data, 'varchar')
    expect(suggestions).toContain('formatEmail')
    expect(suggestions).toContain('lowercase')
  })

  it('should suggest phone transformations for phone-like data', () => {
    const data = ['555-123-4567', '(555) 123-4567']
    const suggestions = suggestTransformations(data, 'varchar')
    expect(suggestions).toContain('formatPhone')
  })

  it('should always include none as first option', () => {
    const suggestions = suggestTransformations(['test'], 'varchar')
    expect(suggestions[0]).toBe('none')
  })

  it('should handle empty data', () => {
    const suggestions = suggestTransformations([], 'varchar')
    expect(suggestions).toEqual(['none'])
  })
})
