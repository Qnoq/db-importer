import { ref, watch, type Ref } from 'vue'
import { useMappingStore, type Field } from '../store/mappingStore'
import { useWorkflowSessionStore } from '../store/workflowSessionStore'
import { suggestTransformations, type TransformationType } from '../utils/transformations'

export function useMapping() {
  const store = useMappingStore()
  const sessionStore = useWorkflowSessionStore()

  // State
  const localMapping = ref<Record<string, string>>({})
  const fieldToExcelMapping = ref<Record<string, string | null>>({})
  const previousFieldTransformations = ref<Record<string, TransformationType>>({})
  const autoMappingStats = ref<{
    total: number
    mapped: number
    skipped: number
  } | null>(null)

  /**
   * Levenshtein distance algorithm for string matching
   */
  function levenshteinDistance(str1: string, str2: string): number {
    const len1 = str1.length
    const len2 = str2.length
    const matrix: number[][] = []

    for (let i = 0; i <= len1; i++) {
      matrix[i] = [i]
    }

    for (let j = 0; j <= len2; j++) {
      matrix[0][j] = j
    }

    for (let i = 1; i <= len1; i++) {
      for (let j = 1; j <= len2; j++) {
        if (str1[i - 1] === str2[j - 1]) {
          matrix[i][j] = matrix[i - 1][j - 1]
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1
          )
        }
      }
    }

    return matrix[len1][len2]
  }

  /**
   * Calculate similarity score
   */
  function calculateSimilarity(str1: string, str2: string): number {
    const distance = levenshteinDistance(str1, str2)
    const maxLen = Math.max(str1.length, str2.length)
    return 1 - distance / maxLen
  }

  /**
   * Check if a field is likely an auto-increment ID field
   */
  function isAutoIncrementField(field: Field): boolean {
    const nameLower = field.name.toLowerCase()
    const typeLower = field.type.toLowerCase()

    // Check if it's an integer type
    const isIntType = typeLower.includes('int') || typeLower.includes('serial')

    // Check if name suggests it's an ID
    const isIdName = nameLower === 'id' ||
                     nameLower.endsWith('_id') ||
                     nameLower.endsWith('id') ||
                     nameLower.startsWith('id_')

    // Auto-increment fields are typically NOT NULL integer IDs
    return isIntType && isIdName && !field.nullable
  }

  /**
   * Get list of auto-increment field names for display
   */
  function getAutoIncrementFieldNames(): string[] {
    if (!store.selectedTable) return []
    return store.selectedTable.fields
      .filter(field => isAutoIncrementField(field))
      .map(field => field.name)
  }

  /**
   * Auto-map columns with Levenshtein distance
   */
  function autoMap() {
    const mapping: Record<string, string> = {}
    const transformsToApply: Record<string, TransformationType> = {}
    let mappedCount = 0

    for (const header of store.excelHeaders) {
      const normalizedHeader = header.toLowerCase().trim().replace(/[_\s-]/g, '')

      let bestMatch: Field | null = null
      let bestScore = 0

      for (const field of store.selectedTable?.fields || []) {
        // Skip auto-increment ID fields - they shouldn't be mapped
        if (isAutoIncrementField(field)) {
          continue
        }

        const normalizedField = field.name.toLowerCase().trim().replace(/[_\s-]/g, '')
        const score = calculateSimilarity(normalizedHeader, normalizedField)

        if (score > bestScore) {
          bestScore = score
          bestMatch = field
        }
      }

      if (bestMatch && bestScore > 0.6) {
        mapping[header] = bestMatch.name
        mappedCount++

        // Get column data for suggestions
        const columnIndex = store.excelHeaders.indexOf(header)
        const columnData = store.excelData.map(row => row[columnIndex])

        // Suggest transformations (store by field name, not Excel column)
        const suggestions = suggestTransformations(columnData, bestMatch.type)
        if (suggestions.length > 1) {
          transformsToApply[bestMatch.name] = suggestions[1] // First non-'none' suggestion
        } else {
          transformsToApply[bestMatch.name] = 'none'
        }
      }
    }

    localMapping.value = mapping
    store.setTransformations(transformsToApply)

    // Update fieldToExcelMapping for v-model binding
    syncFieldToExcelMapping()

    // Store auto-mapping statistics for display
    autoMappingStats.value = {
      total: store.excelHeaders.length,
      mapped: mappedCount,
      skipped: store.excelHeaders.length - mappedCount
    }

    updateMapping()
  }

  /**
   * Update mapping in store
   */
  function updateMapping() {
    store.setMapping(localMapping.value)

    // Save to session (for authenticated users) with transformations
    sessionStore.saveMapping(localMapping.value, store.transformations)
  }

  /**
   * Sync fieldToExcelMapping from localMapping
   * Converts Excel column → DB field to DB field → Excel column
   */
  function syncFieldToExcelMapping() {
    const newMapping: Record<string, string | null> = {}

    // Convert localMapping (Excel → DB) to fieldToExcelMapping (DB → Excel)
    for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
      if (typeof dbField === 'string') {
        newMapping[dbField] = excelCol
      }
    }

    // Initialize all fields with null if not mapped
    if (store.selectedTable) {
      for (const field of store.selectedTable.fields) {
        if (!newMapping[field.name]) {
          newMapping[field.name] = null
        }
      }
    }

    fieldToExcelMapping.value = newMapping
  }

  /**
   * Clear all mappings
   */
  function confirmClearMappings() {
    localMapping.value = {}
    store.setTransformations({})
    syncFieldToExcelMapping()
    updateMapping()
  }

  /**
   * Get which Excel column is mapped to a database field
   */
  function getMappedExcelColumn(fieldName: string): string | null {
    for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
      if (dbField === fieldName) {
        return excelCol
      }
    }
    return null
  }

  /**
   * Handle field mapping change
   */
  function onFieldMappingChange(fieldName: string, excelColumn: string | null) {
    // Remove any existing mapping to this field
    for (const [excelCol, dbField] of Object.entries(localMapping.value)) {
      if (dbField === fieldName) {
        delete localMapping.value[excelCol]
      }
    }

    // Add new mapping if Excel column selected
    if (excelColumn) {
      // Remove any existing mapping for this Excel column (prevent duplicate mappings)
      delete localMapping.value[excelColumn]
      localMapping.value[excelColumn] = fieldName

      // Suggest transformation
      const field = store.selectedTable?.fields.find(f => f.name === fieldName)
      if (field) {
        const columnIndex = store.excelHeaders.indexOf(excelColumn)
        const columnData = store.excelData.map(row => row[columnIndex])
        const suggestions = suggestTransformations(columnData, field.type)
        store.updateTransformation(fieldName, suggestions[1] || 'none')
      }
    } else {
      store.updateTransformation(fieldName, 'none')
    }

    updateMapping()
  }

  /**
   * Toggle skip for a field
   */
  function toggleSkipField(fieldName: string) {
    const mappedExcelCol = getMappedExcelColumn(fieldName)

    if (mappedExcelCol) {
      // Currently mapped, skip it - save transformation before clearing
      previousFieldTransformations.value[fieldName] = store.transformations[fieldName] || 'none'
      delete localMapping.value[mappedExcelCol]
      store.updateTransformation(fieldName, 'none')
    } else {
      // Currently skipped, try to auto-map it
      const field = store.selectedTable?.fields.find(f => f.name === fieldName)
      if (!field) return

      const normalizedField = fieldName.toLowerCase().trim().replace(/[_\s-]/g, '')
      let bestMatch: string | null = null
      let bestScore = 0

      for (const excelHeader of store.excelHeaders) {
        // Skip if this Excel column is already mapped
        if (localMapping.value[excelHeader]) continue

        const normalizedHeader = excelHeader.toLowerCase().trim().replace(/[_\s-]/g, '')
        const score = calculateSimilarity(normalizedField, normalizedHeader)

        if (score > bestScore) {
          bestScore = score
          bestMatch = excelHeader
        }
      }

      if (bestMatch && bestScore > 0.6) {
        localMapping.value[bestMatch] = fieldName

        // Restore previous transformation if exists
        const previousTransform = previousFieldTransformations.value[fieldName]
        if (previousTransform) {
          store.updateTransformation(fieldName, previousTransform)
        } else {
          // Suggest new transformation
          const columnIndex = store.excelHeaders.indexOf(bestMatch)
          const columnData = store.excelData.map(row => row[columnIndex])
          const suggestions = suggestTransformations(columnData, field.type)
          store.updateTransformation(fieldName, suggestions[1] || 'none')
        }
      }
    }

    syncFieldToExcelMapping()
    updateMapping()
  }

  /**
   * Get Excel column options
   */
  function getExcelColumnOptions() {
    return store.excelHeaders.map(header => ({
      label: header,
      value: header
    }))
  }

  /**
   * Get sample value from first row
   */
  function getSampleValue(header: string): string {
    const columnIndex = store.excelHeaders.indexOf(header)
    if (columnIndex === -1 || !store.excelData.length) return 'N/A'

    const sampleValue = store.excelData[0]?.[columnIndex]
    if (sampleValue === null || sampleValue === undefined) return 'N/A'

    const strValue = String(sampleValue)
    return strValue.substring(0, 30) + (strValue.length > 30 ? '...' : '')
  }

  // Watch for store mapping changes (handles async restoration)
  watch(() => store.mapping, (newMapping) => {
    if (newMapping && Object.keys(newMapping).length > 0) {
      localMapping.value = { ...newMapping }
      syncFieldToExcelMapping()
    }
  }, { deep: true, immediate: true })

  return {
    localMapping,
    fieldToExcelMapping,
    autoMappingStats,
    autoMap,
    updateMapping,
    syncFieldToExcelMapping,
    confirmClearMappings,
    getMappedExcelColumn,
    onFieldMappingChange,
    toggleSkipField,
    getExcelColumnOptions,
    getSampleValue,
    isAutoIncrementField,
    getAutoIncrementFieldNames
  }
}
