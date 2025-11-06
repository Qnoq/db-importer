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

export interface MappingState {
  tables: Table[]
  selectedTable: Table | null
  excelData: any[][]
  excelHeaders: string[]
  mapping: Record<string, string>
}

export const useMappingStore = defineStore('mapping', {
  state: (): MappingState => ({
    tables: [],
    selectedTable: null,
    excelData: [],
    excelHeaders: [],
    mapping: {}
  }),

  actions: {
    setTables(tables: Table[]) {
      this.tables = tables
    },

    selectTable(tableName: string) {
      this.selectedTable = this.tables.find(t => t.name === tableName) || null
    },

    setExcelData(headers: string[], data: any[][]) {
      this.excelHeaders = headers
      this.excelData = data
    },

    setMapping(mapping: Record<string, string>) {
      this.mapping = mapping
    },

    updateMapping(excelColumn: string, dbColumn: string) {
      this.mapping[excelColumn] = dbColumn
    },

    reset() {
      this.tables = []
      this.selectedTable = null
      this.excelData = []
      this.excelHeaders = []
      this.mapping = {}
    }
  },

  getters: {
    hasSchema: (state) => state.tables.length > 0,
    hasSelectedTable: (state) => state.selectedTable !== null,
    hasExcelData: (state) => state.excelData.length > 0
  }
})
