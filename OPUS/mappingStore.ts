// stores/mapping.ts
import { defineStore } from 'pinia'
import type { Field, TableSchema } from '@/types'

interface MappingState {
  selectedTable: TableSchema | null
  excelData: Record<string, any>[]
  excelHeaders: string[]
  mapping: Record<string, string>
  dataOverrides: Record<string, any>
  sqlOptions: {
    includeTruncate: boolean
    useTransaction: boolean
    ignoreErrors: boolean
    includeComments: boolean
  }
}

export const useMappingStore = defineStore('mapping', {
  state: (): MappingState => ({
    selectedTable: null,
    excelData: [],
    excelHeaders: [],
    mapping: {},
    dataOverrides: {},
    sqlOptions: {
      includeTruncate: false,
      useTransaction: true,
      ignoreErrors: false,
      includeComments: true
    }
  }),

  getters: {
    hasData: (state) => state.excelData.length > 0,
    
    hasMapping: (state) => Object.keys(state.mapping).length > 0,
    
    mappedFields: (state) => {
      if (!state.selectedTable) return []
      return state.selectedTable.fields.filter(field => 
        Object.values(state.mapping).includes(field.name)
      )
    },
    
    unmappedHeaders: (state) => {
      return state.excelHeaders.filter(h => !state.mapping[h])
    },
    
    mappedHeaders: (state) => {
      return state.excelHeaders.filter(h => state.mapping[h])
    },
    
    unmappedRequiredFields: (state) => {
      if (!state.selectedTable) return []
      return state.selectedTable.fields.filter(f => 
        f.required && !Object.values(state.mapping).includes(f.name)
      )
    },
    
    finalData: (state) => {
      return state.excelData.map((row, index) => {
        const key = `${index}`
        if (state.dataOverrides[key]) {
          return { ...row, ...state.dataOverrides[key] }
        }
        return row
      })
    }
  },

  actions: {
    setSelectedTable(table: TableSchema) {
      this.selectedTable = table
      this.clearMapping()
    },
    
    setExcelData(data: Record<string, any>[], headers: string[]) {
      this.excelData = data
      this.excelHeaders = headers
      this.dataOverrides = {}
    },
    
    setMapping(mapping: Record<string, string>) {
      this.mapping = mapping
    },
    
    updateMapping(header: string, field: string) {
      if (field) {
        this.mapping[header] = field
      } else {
        delete this.mapping[header]
      }
    },
    
    clearMapping() {
      this.mapping = {}
      this.dataOverrides = {}
    },
    
    updateCellValue(rowIndex: number, header: string, value: any) {
      const key = `${rowIndex}`
      if (!this.dataOverrides[key]) {
        this.dataOverrides[key] = {}
      }
      this.dataOverrides[key][header] = value
    },
    
    resetDataOverrides() {
      this.dataOverrides = {}
    },
    
    autoMap() {
      if (!this.selectedTable || !this.excelHeaders.length) return 0
      
      const mapping: Record<string, string> = {}
      let mapped = 0
      
      this.excelHeaders.forEach(header => {
        const match = findBestMatch(header, this.selectedTable!.fields)
        if (match && match.score > 0.6) {
          mapping[header] = match.field.name
          mapped++
        }
      })
      
      this.mapping = mapping
      return mapped
    },
    
    isMapped(fieldName: string): boolean {
      return Object.values(this.mapping).includes(fieldName)
    },
    
    getMappedHeader(fieldName: string): string {
      return Object.keys(this.mapping).find(k => this.mapping[k] === fieldName) || ''
    },
    
    setSQLOptions(options: Partial<MappingState['sqlOptions']>) {
      this.sqlOptions = { ...this.sqlOptions, ...options }
    },
    
    reset() {
      this.$reset()
    }
  },
  
  persist: {
    enabled: true,
    strategies: [
      {
        key: 'db-importer-mapping',
        storage: localStorage,
        paths: ['mapping', 'sqlOptions']
      }
    ]
  }
})

// Helper functions
function findBestMatch(header: string, fields: Field[]) {
  let bestMatch = null
  let bestScore = 0
  
  const normalizedHeader = normalizeString(header)
  
  for (const field of fields) {
    const normalizedField = normalizeString(field.name)
    
    // Exact match
    if (normalizedHeader === normalizedField) {
      return { field, score: 1 }
    }
    
    // Calculate similarity
    const score = calculateSimilarity(normalizedHeader, normalizedField)
    if (score > bestScore) {
      bestScore = score
      bestMatch = field
    }
  }
  
  return bestMatch ? { field: bestMatch, score: bestScore } : null
}

function normalizeString(str: string): string {
  return str
    .toLowerCase()
    .replace(/[_-]/g, '')
    .replace(/\s+/g, '')
    .replace(/[^a-z0-9]/g, '')
}

function calculateSimilarity(str1: string, str2: string): number {
  if (str1 === str2) return 1
  if (str1.includes(str2) || str2.includes(str1)) return 0.8
  
  // Levenshtein distance
  const longer = str1.length > str2.length ? str1 : str2
  const shorter = str1.length > str2.length ? str2 : str1
  
  if (longer.length === 0) return 1.0
  
  const editDistance = levenshteinDistance(longer, shorter)
  return (longer.length - editDistance) / longer.length
}

function levenshteinDistance(str1: string, str2: string): number {
  const matrix = []
  
  for (let i = 0; i <= str2.length; i++) {
    matrix[i] = [i]
  }
  
  for (let j = 0; j <= str1.length; j++) {
    matrix[0][j] = j
  }
  
  for (let i = 1; i <= str2.length; i++) {
    for (let j = 1; j <= str1.length; j++) {
      if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1]
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1, // substitution
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j] + 1      // deletion
        )
      }
    }
  }
  
  return matrix[str2.length][str1.length]
}
