/**
 * Data transformations for cell values
 * Inspired by Dromo's transformation capabilities
 */

export type TransformationType =
  | 'none'
  | 'uppercase'
  | 'lowercase'
  | 'trim'
  | 'capitalize'
  | 'removeSpaces'
  | 'removeSpecialChars'
  | 'formatPhone'
  | 'formatEmail'
  | 'extractNumbers'
  | 'toBoolean'
  | 'toNumber'
  | 'formatDate'
  | 'excelDate'

export interface Transformation {
  type: TransformationType
  label: string
  description: string
  apply: (value: string) => string | number | boolean
  preview: (value: string) => string
}

export const transformations: Record<TransformationType, Transformation> = {
  none: {
    type: 'none',
    label: 'No transformation',
    description: 'Use value as-is',
    apply: (val) => val,
    preview: (val) => val
  },

  uppercase: {
    type: 'uppercase',
    label: 'UPPERCASE',
    description: 'Convert to uppercase',
    apply: (val) => String(val).toUpperCase(),
    preview: (val) => `"${val}" → "${String(val).toUpperCase()}"`
  },

  lowercase: {
    type: 'lowercase',
    label: 'lowercase',
    description: 'Convert to lowercase',
    apply: (val) => String(val).toLowerCase(),
    preview: (val) => `"${val}" → "${String(val).toLowerCase()}"`
  },

  trim: {
    type: 'trim',
    label: 'Trim spaces',
    description: 'Remove leading and trailing spaces',
    apply: (val) => String(val).trim(),
    preview: (val) => `"${val}" → "${String(val).trim()}"`
  },

  capitalize: {
    type: 'capitalize',
    label: 'Capitalize',
    description: 'Capitalize first letter of each word',
    apply: (val) => {
      return String(val)
        .toLowerCase()
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ')
    },
    preview: (val) => {
      const result = String(val)
        .toLowerCase()
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ')
      return `"${val}" → "${result}"`
    }
  },

  removeSpaces: {
    type: 'removeSpaces',
    label: 'Remove all spaces',
    description: 'Remove all whitespace characters',
    apply: (val) => String(val).replace(/\s+/g, ''),
    preview: (val) => `"${val}" → "${String(val).replace(/\s+/g, '')}"`
  },

  removeSpecialChars: {
    type: 'removeSpecialChars',
    label: 'Remove special characters',
    description: 'Keep only letters, numbers, and spaces',
    apply: (val) => String(val).replace(/[^a-zA-Z0-9\s]/g, ''),
    preview: (val) => `"${val}" → "${String(val).replace(/[^a-zA-Z0-9\s]/g, '')}"`
  },

  formatPhone: {
    type: 'formatPhone',
    label: 'Format phone',
    description: 'Extract only digits from phone number',
    apply: (val) => String(val).replace(/[^\d]/g, ''),
    preview: (val) => `"${val}" → "${String(val).replace(/[^\d]/g, '')}"`
  },

  formatEmail: {
    type: 'formatEmail',
    label: 'Format email',
    description: 'Convert to lowercase and trim',
    apply: (val) => String(val).toLowerCase().trim(),
    preview: (val) => `"${val}" → "${String(val).toLowerCase().trim()}"`
  },

  extractNumbers: {
    type: 'extractNumbers',
    label: 'Extract numbers',
    description: 'Extract only numeric characters',
    apply: (val) => {
      const numbers = String(val).match(/\d+/g)
      return numbers ? numbers.join('') : ''
    },
    preview: (val) => {
      const numbers = String(val).match(/\d+/g)
      const result = numbers ? numbers.join('') : ''
      return `"${val}" → "${result}"`
    }
  },

  toBoolean: {
    type: 'toBoolean',
    label: 'To boolean',
    description: 'Convert to true/false (yes/no, 1/0, true/false)',
    apply: (val) => {
      const normalized = String(val).toLowerCase().trim()
      return ['true', 'yes', 'y', '1', 'on'].includes(normalized)
    },
    preview: (val) => {
      const normalized = String(val).toLowerCase().trim()
      const result = ['true', 'yes', 'y', '1', 'on'].includes(normalized)
      return `"${val}" → ${result}`
    }
  },

  toNumber: {
    type: 'toNumber',
    label: 'To number',
    description: 'Convert to number (remove non-numeric chars)',
    apply: (val) => {
      const cleaned = String(val).replace(/[^\d.-]/g, '')
      const num = parseFloat(cleaned)
      return isNaN(num) ? 0 : num
    },
    preview: (val) => {
      const cleaned = String(val).replace(/[^\d.-]/g, '')
      const num = parseFloat(cleaned)
      return `"${val}" → ${isNaN(num) ? 0 : num}`
    }
  },

  formatDate: {
    type: 'formatDate',
    label: 'Format date',
    description: 'Attempt to parse and format as YYYY-MM-DD',
    apply: (val) => {
      const date = parseSmartDate(String(val))
      return date ? formatDateISO(date) : val
    },
    preview: (val) => {
      const date = parseSmartDate(String(val))
      const result = date ? formatDateISO(date) : val
      return `"${val}" → "${result}"`
    }
  },

  excelDate: {
    type: 'excelDate',
    label: 'Excel Date (or Year)',
    description: 'Convert Excel serial date to YYYY-MM-DD HH:MM:SS. If value is just a year (e.g., 2023), converts to YYYY-01-01',
    apply: (val) => {
      const date = parseExcelDate(val)
      return date ? formatDateTimeISO(date) : val
    },
    preview: (val) => {
      const date = parseExcelDate(val)
      const result = date ? formatDateTimeISO(date) : val
      return `${val} → "${result}"`
    }
  }
}

/**
 * Smart date parsing - tries multiple formats
 * Returns dates in UTC to avoid timezone ambiguities
 */
export function parseSmartDate(value: string): Date | null {
  if (!value || typeof value !== 'string') return null

  const cleaned = value.trim()

  // Try ISO format first (YYYY-MM-DD)
  const isoMatch = cleaned.match(/^(\d{4})-(\d{2})-(\d{2})/)
  if (isoMatch) {
    const [, year, month, day] = isoMatch
    // Parse as UTC to avoid timezone shifts
    return new Date(Date.UTC(parseInt(year), parseInt(month) - 1, parseInt(day)))
  }

  // Try DD/MM/YYYY or MM/DD/YYYY
  const slashMatch = cleaned.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})/)
  if (slashMatch) {
    const [, first, second, year] = slashMatch
    const firstNum = parseInt(first)
    const secondNum = parseInt(second)
    const yearNum = parseInt(year)

    // Validate ranges
    if (firstNum < 1 || firstNum > 31 || secondNum < 1 || secondNum > 12) {
      return null
    }

    // Try EU format (DD/MM/YYYY) first
    const euDate = new Date(Date.UTC(yearNum, secondNum - 1, firstNum))
    if (!isNaN(euDate.getTime()) && euDate.getUTCDate() === firstNum && euDate.getUTCMonth() === secondNum - 1) {
      return euDate
    }

    // Try US format (MM/DD/YYYY) if first/second could be swapped
    if (firstNum <= 12 && secondNum <= 31) {
      const usDate = new Date(Date.UTC(yearNum, firstNum - 1, secondNum))
      if (!isNaN(usDate.getTime()) && usDate.getUTCDate() === secondNum && usDate.getUTCMonth() === firstNum - 1) {
        return usDate
      }
    }

    return null
  }

  // Try DD-MM-YYYY
  const dashMatch = cleaned.match(/^(\d{1,2})-(\d{1,2})-(\d{4})/)
  if (dashMatch) {
    const [, day, month, year] = dashMatch
    return new Date(Date.UTC(parseInt(year), parseInt(month) - 1, parseInt(day)))
  }

  // Try natural Date.parse
  const parsed = Date.parse(cleaned)
  if (!isNaN(parsed)) {
    // Convert to UTC date at midnight
    const date = new Date(parsed)
    return new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
  }

  return null
}

/**
 * Format date as ISO (YYYY-MM-DD)
 * Uses UTC to avoid timezone issues
 */
export function formatDateISO(date: Date): string {
  const year = date.getUTCFullYear()
  const month = String(date.getUTCMonth() + 1).padStart(2, '0')
  const day = String(date.getUTCDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

/**
 * Format date and time as ISO (YYYY-MM-DD HH:MM:SS)
 * Uses UTC to avoid timezone issues
 */
export function formatDateTimeISO(date: Date): string {
  const year = date.getUTCFullYear()
  const month = String(date.getUTCMonth() + 1).padStart(2, '0')
  const day = String(date.getUTCDate()).padStart(2, '0')
  const hours = String(date.getUTCHours()).padStart(2, '0')
  const minutes = String(date.getUTCMinutes()).padStart(2, '0')
  const seconds = String(date.getUTCSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

/**
 * Parse Excel serial date number to JavaScript Date
 * Excel stores dates as numbers where:
 * - Integer part = days since January 1, 1900
 * - Decimal part = fraction of day (time)
 *
 * Special handling:
 * - If the number looks like a year (1900-2100), treat it as YYYY-01-01
 * - Otherwise treat as Excel serial date
 *
 * Note: Excel incorrectly treats 1900 as a leap year, so we need to account for that
 */
export function parseExcelDate(value: unknown): Date | null {
  if (value === null || value === undefined) return null

  // Convert to number
  const num = typeof value === 'number' ? value : parseFloat(String(value))

  if (isNaN(num)) return null

  // SMART DETECTION: If it looks like a year (between 1900 and 2100), treat as year
  // This handles cases where users have just "2023" in their date column
  if (num >= 1900 && num <= 2100 && Number.isInteger(num)) {
    // It's a year! Convert to January 1st of that year (UTC to avoid timezone issues)
    return new Date(Date.UTC(num, 0, 1, 0, 0, 0, 0))
  }

  // Check if it's a valid Excel date number (between 1 and ~50000 for reasonable dates)
  if (num < 1 || num > 100000) return null

  // Excel epoch: January 1, 1900 (serial 1 = Jan 1, 1900)
  // Excel incorrectly treats 1900 as a leap year (serial 60 = fake Feb 29, 1900)
  // For dates after Feb 29, 1900 (serial > 60), we need to subtract an extra day

  // Use UTC to avoid historical timezone issues (timezones weren't standardized in 1900)
  const excelEpochMs = Date.UTC(1900, 0, 1) // January 1, 1900 00:00:00 UTC

  // Calculate days to add from epoch
  // Serial 1 = Jan 1, 1900, so we subtract 1
  // For dates after the fake Feb 29 (serial > 60), subtract an extra day
  const daysToAdd = num > 60 ? num - 2 : num - 1

  // Calculate the date
  const millisecondsPerDay = 24 * 60 * 60 * 1000
  const dateMs = excelEpochMs + daysToAdd * millisecondsPerDay

  const date = new Date(dateMs)

  // Validate the result
  if (isNaN(date.getTime())) return null

  return date
}

/**
 * Check if a value looks like a year (for warning purposes)
 */
export function isYearValue(value: unknown): boolean {
  if (value === null || value === undefined) return false
  const num = typeof value === 'number' ? value : parseFloat(String(value))
  return !isNaN(num) && num >= 1900 && num <= 2100 && Number.isInteger(num)
}

/**
 * Detect if a column contains year-only values
 */
export function hasYearOnlyValues(data: unknown[]): boolean {
  const sample = data.slice(0, 10).filter(v => v !== null && v !== undefined)
  if (sample.length === 0) return false

  // Check if at least 50% of values look like years
  const yearCount = sample.filter(isYearValue).length
  return yearCount >= sample.length / 2
}

/**
 * Apply transformation to a value
 */
export function applyTransformation(
  value: unknown,
  transformationType: TransformationType
): unknown {
  if (value === null || value === undefined) return value

  const transformation = transformations[transformationType]
  if (!transformation) return value

  try {
    return transformation.apply(String(value))
  } catch (error) {
    console.error('Transformation error:', error)
    return value
  }
}

/**
 * Apply transformations to entire column
 */
export function applyColumnTransformation(
  data: unknown[][],
  columnIndex: number,
  transformationType: TransformationType
): unknown[][] {
  return data.map(row => {
    const newRow = [...row]
    if (columnIndex < newRow.length) {
      newRow[columnIndex] = applyTransformation(newRow[columnIndex], transformationType)
    }
    return newRow
  })
}

/**
 * Get transformation suggestions based on column data
 */
export function suggestTransformations(
  data: unknown[],
  fieldType: string
): TransformationType[] {
  const suggestions: TransformationType[] = []

  // Check first few values
  const sample = data.slice(0, 10).filter(v => v !== null && v !== undefined)

  if (sample.length === 0) return ['none']

  const fieldTypeLower = fieldType.toLowerCase()

  // Type-based suggestions
  if (fieldTypeLower.includes('int') || fieldTypeLower.includes('decimal') || fieldTypeLower.includes('float')) {
    suggestions.push('toNumber', 'extractNumbers')
  }

  if (fieldTypeLower.includes('bool')) {
    suggestions.push('toBoolean')
  }

  if (fieldTypeLower.includes('date') || fieldTypeLower.includes('time')) {
    // Check if data looks like Excel serial dates (numbers between 1 and 100000)
    const hasExcelDates = sample.some(v => {
      const num = typeof v === 'number' ? v : parseFloat(String(v))
      return !isNaN(num) && num >= 1 && num < 100000
    })

    if (hasExcelDates) {
      suggestions.push('excelDate')
    }

    suggestions.push('formatDate')
  }

  if (fieldTypeLower.includes('varchar') || fieldTypeLower.includes('text')) {
    // Check for emails
    const hasEmails = sample.some(v =>
      String(v).includes('@') && String(v).includes('.')
    )
    if (hasEmails) {
      suggestions.push('formatEmail', 'lowercase', 'trim')
    }

    // Check for phones
    const hasPhones = sample.some(v =>
      /\d{3}[-\s.]?\d{3}[-\s.]?\d{4}/.test(String(v))
    )
    if (hasPhones) {
      suggestions.push('formatPhone', 'extractNumbers')
    }

    // Check for names
    const hasCapitalization = sample.some(v => {
      const str = String(v)
      return str.length > 0 && str[0] === str[0].toUpperCase()
    })
    if (hasCapitalization) {
      suggestions.push('capitalize', 'trim')
    }

    // Generic text transformations
    suggestions.push('uppercase', 'lowercase', 'trim')
  }

  // Always offer 'none' as first option
  return ['none', ...new Set(suggestions)]
}
