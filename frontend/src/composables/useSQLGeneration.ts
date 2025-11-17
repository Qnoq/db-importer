import { ref, type Ref } from 'vue'
import { useMappingStore, type CellValue } from '../store/mappingStore'
import { useAuthStore } from '../store/authStore'
import { useImportStore } from '../store/importStore'
import { applyTransformation } from '../utils/transformations'
import { apiClient } from '../utils/apiClient'

interface FieldInfo {
  name: string
  type: string
  nullable: boolean
}

export function useSQLGeneration(
  localMapping: Ref<Record<string, string>>,
  validationStats: Ref<{ validRowCount: number; errorCount: number; warningCount: number } | null>
) {
  const store = useMappingStore()
  const authStore = useAuthStore()
  const importStore = useImportStore()

  // State
  const loading = ref(false)
  const error = ref('')
  const serverValidationErrors = ref<string[]>([])

  /**
   * Generate SQL
   */
  async function generateSQL() {
    if (!store.selectedTable) return

    error.value = ''
    serverValidationErrors.value = []
    loading.value = true

    try {
      // Apply transformations to all data
      const transformedData = store.excelData.map(row => {
        const newRow = [...row]
        store.excelHeaders.forEach((header, idx) => {
          const dbField = localMapping.value[header]
          if (dbField) {
            const transform = store.transformations[dbField]
            if (transform && transform !== 'none') {
              newRow[idx] = applyTransformation(row[idx], transform) as CellValue
            }
          }
        })
        return newRow
      })

      // Build ordered rows based on mapping
      const mappedRows: unknown[][] = []

      for (const row of transformedData) {
        const mappedRow: unknown[] = []

        for (const excelHeader of store.excelHeaders) {
          const dbColumn = localMapping.value[excelHeader]
          if (dbColumn) {
            const index = store.excelHeaders.indexOf(excelHeader)
            mappedRow.push(row[index])
          }
        }

        if (mappedRow.length > 0) {
          mappedRows.push(mappedRow)
        }
      }

      // Build fields array for validation
      const fields: FieldInfo[] = []
      for (const excelHeader of store.excelHeaders) {
        const dbColumn = localMapping.value[excelHeader]
        if (dbColumn) {
          const field = store.selectedTable.fields.find(f => f.name === dbColumn)
          if (field) {
            fields.push({
              name: field.name,
              type: field.type,
              nullable: field.nullable
            })
          }
        }
      }

      const response = await fetch(`${apiClient.getBaseUrl()}/generate-sql`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          table: store.selectedTable.name,
          mapping: localMapping.value,
          rows: mappedRows,
          fields: fields
        })
      })

      if (!response.ok) {
        if (response.status === 422) {
          const errorData = await response.json()
          serverValidationErrors.value = errorData.errors || []
          error.value = errorData.error || 'Data validation failed'
          loading.value = false
          return
        }

        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.message || errorData.error || 'Failed to generate SQL')
      }

      const sql = await response.text()

      // Download file
      const filename = `import_${store.selectedTable.name}_${Date.now()}.sql`
      downloadSQL(sql, filename)

      loading.value = false
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'An error occurred'
      loading.value = false
    }
  }

  /**
   * Generate and save SQL to import history
   */
  async function generateAndSave() {
    if (!store.selectedTable) return

    error.value = ''
    serverValidationErrors.value = []
    loading.value = true

    try {
      // Apply transformations to all data
      const transformedData = store.excelData.map(row => {
        const newRow = [...row]
        store.excelHeaders.forEach((header, idx) => {
          const dbField = localMapping.value[header]
          if (dbField) {
            const transform = store.transformations[dbField]
            if (transform && transform !== 'none') {
              newRow[idx] = applyTransformation(row[idx], transform) as CellValue
            }
          }
        })
        return newRow
      })

      // Build ordered rows based on mapping
      const mappedRows: unknown[][] = []

      for (const row of transformedData) {
        const mappedRow: unknown[] = []

        for (const excelHeader of store.excelHeaders) {
          const dbColumn = localMapping.value[excelHeader]
          if (dbColumn) {
            const index = store.excelHeaders.indexOf(excelHeader)
            mappedRow.push(row[index])
          }
        }

        if (mappedRow.length > 0) {
          mappedRows.push(mappedRow)
        }
      }

      // Build fields array for validation
      const fields: FieldInfo[] = []
      for (const excelHeader of store.excelHeaders) {
        const dbColumn = localMapping.value[excelHeader]
        if (dbColumn) {
          const field = store.selectedTable.fields.find(f => f.name === dbColumn)
          if (field) {
            fields.push({
              name: field.name,
              type: field.type,
              nullable: field.nullable
            })
          }
        }
      }

      const response = await fetch(`${apiClient.getBaseUrl()}/generate-sql`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          table: store.selectedTable.name,
          mapping: localMapping.value,
          rows: mappedRows,
          fields: fields
        })
      })

      if (!response.ok) {
        if (response.status === 422) {
          const errorData = await response.json()
          serverValidationErrors.value = errorData.errors || []
          error.value = errorData.error || 'Data validation failed'
          loading.value = false
          return
        }

        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.message || errorData.error || 'Failed to generate SQL')
      }

      const sql = await response.text()

      // Download file
      const filename = `import_${store.selectedTable.name}_${Date.now()}.sql`
      downloadSQL(sql, filename)

      // Save to import history if user is authenticated
      if (authStore.isAuthenticated) {
        try {
          console.log('User is authenticated, saving to import history...')

          // Determine status based on validation results
          let status: 'success' | 'warning' | 'failed' = 'success'
          const errorCount = serverValidationErrors.value.length
          const warningCount = validationStats.value?.warningCount || 0

          if (errorCount > 0) {
            status = 'failed'
          } else if (warningCount > 0) {
            status = 'warning'
          }

          // Build transformations list
          const appliedTransformations: string[] = []
          Object.entries(store.transformations).forEach(([field, transform]) => {
            if (transform && transform !== 'none') {
              appliedTransformations.push(`${field}: ${transform}`)
            }
          })

          const importData = {
            tableName: store.selectedTable.name,
            rowCount: mappedRows.length,
            status,
            generatedSql: sql,
            errorCount,
            warningCount,
            metadata: {
              sourceFileName: filename,
              mappingSummary: localMapping.value,
              transformations: appliedTransformations.length > 0 ? appliedTransformations : undefined,
              databaseType: 'mysql', // Could be detected from schema
              validationErrors: serverValidationErrors.value.length > 0 ? serverValidationErrors.value : undefined,
              validationWarnings: validationStats.value?.warningCount ? ['Some data validation warnings occurred'] : undefined
            }
          }

          console.log('Saving import with data:', importData)
          await importStore.createImport(importData)
          console.log('✅ Import saved to history successfully')
        } catch (historyError) {
          // Don't fail the whole operation if history save fails
          console.error('❌ Failed to save import to history:', historyError)
        }
      } else {
        console.log('User not authenticated, skipping history save')
      }

      loading.value = false
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'An error occurred'
      loading.value = false
    }
  }

  /**
   * Download SQL file
   */
  function downloadSQL(sql: string, filename: string) {
    const blob = new Blob([sql], { type: 'text/plain' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  }

  return {
    loading,
    error,
    serverValidationErrors,
    generateSQL,
    generateAndSave,
    downloadSQL
  }
}
