import { defineStore } from 'pinia'

export interface Field {
  name: string
  type: string
  nullable: boolean
}

export interface Table {
  name: string
  fields: Field[]
}

// Type for cell values in Excel/CSV data
export type CellValue = string | number | boolean | null | undefined

export interface MappingState {
  tables: Table[]
  selectedTable: Table | null
  excelData: CellValue[][]
  excelHeaders: string[]
  mapping: Record<string, string>
  transformations: Record<string, string>
}

const STORAGE_KEY = 'db-importer-state'
const STORAGE_VERSION = '1.0'

// Load state from localStorage
function loadFromStorage(): Partial<MappingState> | null {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return null

    const parsed = JSON.parse(stored)

    // Check version compatibility
    if (parsed.version !== STORAGE_VERSION) {
      console.warn('Storage version mismatch, clearing old data')
      localStorage.removeItem(STORAGE_KEY)
      return null
    }

    return parsed.state
  } catch (error) {
    console.error('Failed to load state from storage:', error)
    return null
  }
}

// Save state to localStorage
function saveToStorage(state: MappingState): void {
  try {
    const toStore = {
      version: STORAGE_VERSION,
      timestamp: new Date().toISOString(),
      state: {
        tables: state.tables,
        selectedTable: state.selectedTable,
        excelHeaders: state.excelHeaders,
        // Don't store full excel data to avoid storage limits
        excelDataRowCount: state.excelData.length,
        mapping: state.mapping,
        transformations: state.transformations
      }
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(toStore))
  } catch (error) {
    console.error('Failed to save state to storage:', error)
  }
}

export const useMappingStore = defineStore('mapping', {
  state: (): MappingState => {
    const stored = loadFromStorage()

    if (stored) {
      return {
        tables: stored.tables || [],
        selectedTable: stored.selectedTable || null,
        excelData: [], // Excel data is not persisted due to size
        excelHeaders: stored.excelHeaders || [],
        mapping: stored.mapping || {},
        transformations: stored.transformations || {}
      }
    }

    return {
      tables: [],
      selectedTable: null,
      excelData: [],
      excelHeaders: [],
      mapping: {},
      transformations: {}
    }
  },

  actions: {
    setTables(tables: Table[]) {
      this.tables = tables
      this.persist()
    },

    selectTable(tableName: string) {
      this.selectedTable = this.tables.find(t => t.name === tableName) || null
      this.persist()
    },

    setExcelData(headers: string[], data: CellValue[][]) {
      this.excelHeaders = headers
      this.excelData = data
      this.persist()
    },

    setMapping(mapping: Record<string, string>) {
      this.mapping = mapping
      this.persist()
    },

    updateMapping(excelColumn: string, dbColumn: string) {
      this.mapping[excelColumn] = dbColumn
      this.persist()
    },

    setTransformations(transformations: Record<string, string>) {
      this.transformations = transformations
      this.persist()
    },

    updateTransformation(fieldName: string, transformation: string) {
      this.transformations[fieldName] = transformation
      this.persist()
    },

    reset() {
      this.tables = []
      this.selectedTable = null
      this.excelData = []
      this.excelHeaders = []
      this.mapping = {}
      this.transformations = {}
      this.clearStorage()
    },

    persist() {
      saveToStorage(this.$state)
    },

    clearStorage() {
      try {
        localStorage.removeItem(STORAGE_KEY)
      } catch (error) {
        console.error('Failed to clear storage:', error)
      }
    }
  },

  getters: {
    hasSchema: (state) => state.tables.length > 0,
    hasSelectedTable: (state) => state.selectedTable !== null,
    hasExcelData: (state) => state.excelData.length > 0,
    hasData: (state) => state.excelData.length > 0,

    // Get the number of mapped columns
    mappedColumnsCount: (state) => {
      return Object.values(state.mapping).filter(v => v !== '').length
    },

    // Check if all required (NOT NULL) fields are mapped
    allRequiredFieldsMapped: (state) => {
      if (!state.selectedTable) return false

      for (const field of state.selectedTable.fields) {
        if (!field.nullable) {
          const isMapped = Object.values(state.mapping).includes(field.name)
          if (!isMapped) return false
        }
      }
      return true
    },

    // Get unmapped required fields
    unmappedRequiredFields: (state) => {
      if (!state.selectedTable) return []

      const unmapped: Field[] = []
      for (const field of state.selectedTable.fields) {
        if (!field.nullable) {
          const isMapped = Object.values(state.mapping).includes(field.name)
          if (!isMapped) {
            unmapped.push(field)
          }
        }
      }
      return unmapped
    }
  }
})
