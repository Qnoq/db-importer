import { ref, computed, watch, type Ref } from 'vue'
import { useMappingStore, type Field, type CellValue } from '../store/mappingStore'
import { validateDataset, getCellClass, getValidationIcon, type ValidationResult } from '../utils/dataValidation'
import { applyTransformation, hasYearOnlyValues } from '../utils/transformations'

export function useValidation(
  localMapping: Ref<Record<string, string>>,
  getMappedExcelColumn: (fieldName: string) => string | null,
  isAutoIncrementField: (field: Field) => boolean
) {
  const store = useMappingStore()

  // State
  const cellValidations = ref<Map<string, ValidationResult>>(new Map())
  const validationStats = ref<{
    validRowCount: number
    errorCount: number
    warningCount: number
  } | null>(null)

  /**
   * Validate all data
   */
  function validateData() {
    if (!store.selectedTable) return

    const fields: Field[] = []
    const mapping: Record<string, string> = {}

    for (const excelHeader of store.excelHeaders) {
      const dbColumn = localMapping.value[excelHeader]
      if (dbColumn) {
        const field = store.selectedTable.fields.find(f => f.name === dbColumn)
        if (field) {
          fields.push(field)
          mapping[excelHeader] = dbColumn
        }
      }
    }

    // First apply dataOverrides to get the final data
    const dataWithOverrides = store.excelData.map((row, rowIndex) => {
      return row.map((cell, colIndex) => {
        const key = `${rowIndex}-${colIndex}`
        if (store.dataOverrides[key]) {
          return store.dataOverrides[key].value as CellValue
        }
        return cell
      })
    })

    // Then apply transformations to data
    const transformedData = dataWithOverrides.map(row => {
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

    const result = validateDataset(transformedData, fields, mapping, store.excelHeaders)

    validationStats.value = {
      validRowCount: result.validRowCount,
      errorCount: result.errorCount,
      warningCount: result.warningCount
    }

    // Store validations for highlighting
    cellValidations.value.clear()
    result.validations.forEach(v => {
      const key = `${v.rowIndex}-${v.columnIndex}`
      cellValidations.value.set(key, v)
    })
  }

  /**
   * Get cell validation class
   */
  function getCellValidationClass(rowIndex: number, colIndex: number): string {
    const key = `${rowIndex}-${colIndex}`
    const validation = cellValidations.value.get(key)
    return validation ? getCellClass(validation) : ''
  }

  /**
   * Get cell validation message
   */
  function getCellValidationMessage(rowIndex: number, colIndex: number): string {
    const key = `${rowIndex}-${colIndex}`
    const validation = cellValidations.value.get(key)
    return validation?.message || ''
  }

  /**
   * Get cell validation icon
   */
  function getCellValidationIcon(rowIndex: number, colIndex: number): string {
    const key = `${rowIndex}-${colIndex}`
    const validation = cellValidations.value.get(key)
    return validation ? getValidationIcon(validation.severity) : ''
  }

  /**
   * Preview data (all rows with transformations applied, only mapped columns)
   */
  const previewData = computed(() => {
    return store.excelData.map((row, rowIndex) => {
      const mappedRow: CellValue[] = []
      store.excelHeaders.forEach((header, idx) => {
        const dbField = localMapping.value[header]
        if (dbField) {
          // First check if there's an override for this cell
          const key = `${rowIndex}-${idx}`
          let value = store.dataOverrides[key] ? (store.dataOverrides[key].value as CellValue) : row[idx]

          // Then apply transformation if any
          const transform = store.transformations[dbField]
          if (transform && transform !== 'none') {
            value = applyTransformation(value, transform) as CellValue
          }
          mappedRow.push(value)
        }
      })
      return mappedRow
    })
  })

  /**
   * Mapped headers for preview
   */
  const mappedHeaders = computed(() => {
    const headers: string[] = []
    for (const excelHeader of store.excelHeaders) {
      const dbColumn = localMapping.value[excelHeader]
      if (dbColumn) {
        headers.push(dbColumn)
      }
    }
    return headers
  })

  /**
   * Remap cell validations to match preview column indices
   * Preview only shows mapped columns, so column indices are different
   */
  const previewCellValidations = computed(() => {
    const remappedValidations = new Map<string, ValidationResult>()

    // Create mapping from original column index to preview column index
    const originalToPreviewIndex = new Map<number, number>()
    let previewIndex = 0
    store.excelHeaders.forEach((header, originalIndex) => {
      const dbColumn = localMapping.value[header]
      if (dbColumn) {
        originalToPreviewIndex.set(originalIndex, previewIndex)
        previewIndex++
      }
    })

    // Remap validations with new column indices
    cellValidations.value.forEach((validation, key) => {
      const previewColIndex = originalToPreviewIndex.get(validation.columnIndex)
      if (previewColIndex !== undefined) {
        const newKey = `${validation.rowIndex}-${previewColIndex}`
        remappedValidations.set(newKey, validation)
      }
    })

    return remappedValidations
  })

  /**
   * Format cell value for display
   */
  function formatCellValue(value: unknown): string {
    if (value === null || value === undefined) return '(null)'
    return String(value)
  }

  /**
   * Validation errors
   */
  const validationErrors = computed(() => {
    const errors: string[] = []

    if (!store.selectedTable) return errors

    for (const field of store.selectedTable.fields) {
      // Skip auto-increment ID fields - they don't need to be mapped
      if (isAutoIncrementField(field)) {
        continue
      }

      if (!field.nullable) {
        const isMapped = Object.values(localMapping.value).includes(field.name)
        if (!isMapped) {
          errors.push(`Required field "${field.name}" is not mapped`)
        }
      }
    }

    return errors
  })

  /**
   * Transformation warnings (informational, not blocking)
   */
  const transformationWarnings = computed(() => {
    const warnings: string[] = []

    if (!store.selectedTable) return warnings

    // Check for year-only values in date fields
    for (const field of store.selectedTable.fields) {
      const fieldTypeLower = field.type.toLowerCase()
      const isDateField = fieldTypeLower.includes('date') || fieldTypeLower.includes('time')

      if (isDateField) {
        const excelCol = getMappedExcelColumn(field.name)
        if (excelCol) {
          const columnIndex = store.excelHeaders.indexOf(excelCol)
          const columnData = store.excelData.map(row => row[columnIndex])

          if (hasYearOnlyValues(columnData)) {
            warnings.push(
              `Field "${field.name}": Detected year-only values (e.g., "2023"). ` +
              `Using "Excel Date (or Year)" transformation will convert them to YYYY-01-01.`
            )
          }
        }
      }
    }

    return warnings
  })

  /**
   * Check if a field has year-only warning
   */
  function hasYearWarning(fieldName: string): boolean {
    if (!store.selectedTable) return false

    const field = store.selectedTable.fields.find(f => f.name === fieldName)
    if (!field) return false

    const fieldTypeLower = field.type.toLowerCase()
    const isDateField = fieldTypeLower.includes('date') || fieldTypeLower.includes('time')

    if (isDateField) {
      const excelCol = getMappedExcelColumn(fieldName)
      if (excelCol) {
        const columnIndex = store.excelHeaders.indexOf(excelCol)
        const columnData = store.excelData.map(row => row[columnIndex])
        return hasYearOnlyValues(columnData)
      }
    }

    return false
  }

  /**
   * Get transformation preview data
   */
  function getTransformPreview(fieldName: string) {
    const excelCol = getMappedExcelColumn(fieldName)
    if (!excelCol) return []

    const columnIndex = store.excelHeaders.indexOf(excelCol)
    const transform = store.transformations[fieldName]

    return store.excelData.slice(0, 10).map(row => ({
      original: formatCellValue(row[columnIndex]),
      transformed: formatCellValue(applyTransformation(row[columnIndex], transform))
    }))
  }

  // Watch for field transformations changes and trigger validation
  watch(() => store.transformations, () => {
    validateData()
  }, { deep: true })

  return {
    cellValidations,
    validationStats,
    validationErrors,
    transformationWarnings,
    previewData,
    mappedHeaders,
    previewCellValidations,
    validateData,
    getCellValidationClass,
    getCellValidationMessage,
    getCellValidationIcon,
    formatCellValue,
    hasYearWarning,
    getTransformPreview
  }
}
