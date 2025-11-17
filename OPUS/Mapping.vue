<template>
  <div class="mapping-container">
    <!-- Header avec titre et actions -->
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
        Table Mapping: {{ selectedTable?.name }}
      </h2>
      
      <div class="flex gap-3">
        <UButton
          @click="autoMap"
          color="primary"
          variant="soft"
          icon="i-heroicons-sparkles"
          :disabled="!hasData"
        >
          Auto-Map
        </UButton>
        
        <UButton
          @click="clearMapping"
          color="gray"
          variant="ghost"
          icon="i-heroicons-x-mark"
          :disabled="!hasMapping"
        >
          Clear
        </UButton>
      </div>
    </div>

    <!-- Mapping Configuration -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
      <!-- Excel Headers -->
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold">Excel Columns</h3>
            <UBadge :color="unmappedHeaders.length > 0 ? 'orange' : 'green'">
              {{ mappedHeaders.length }}/{{ excelHeaders.length }} mapped
            </UBadge>
          </div>
        </template>
        
        <div class="space-y-3">
          <div v-for="header in excelHeaders" :key="header" class="mapping-row">
            <div class="flex items-center justify-between">
              <span class="font-medium text-gray-700 dark:text-gray-300">
                {{ header }}
              </span>
              
              <USelectMenu
                v-model="localMapping[header]"
                :options="availableFieldsFor(header)"
                value-attribute="value"
                option-attribute="label"
                placeholder="Select field..."
                class="w-48"
              >
                <template #option="{ option }">
                  <div class="flex items-center justify-between w-full">
                    <span>{{ option.label }}</span>
                    <UBadge v-if="option.required" color="red" size="xs">
                      Required
                    </UBadge>
                  </div>
                </template>
              </USelectMenu>
            </div>
            
            <!-- Sample data preview -->
            <div class="mt-1 text-xs text-gray-500">
              Sample: {{ getSampleData(header) }}
            </div>
          </div>
        </div>
      </UCard>

      <!-- Database Fields -->
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold">Database Fields</h3>
            <UBadge :color="unmappedRequiredFields.length > 0 ? 'red' : 'green'">
              {{ unmappedRequiredFields.length }} required unmapped
            </UBadge>
          </div>
        </template>
        
        <div class="space-y-3">
          <div 
            v-for="field in tableFields" 
            :key="field.name"
            :class="[
              'p-3 rounded-lg border',
              isMapped(field.name) 
                ? 'border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-950'
                : field.required 
                  ? 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-950'
                  : 'border-gray-200 dark:border-gray-700'
            ]"
          >
            <div class="flex items-center justify-between">
              <div>
                <span class="font-medium">{{ field.name }}</span>
                <span class="ml-2 text-sm text-gray-500">({{ field.type }})</span>
              </div>
              
              <div class="flex items-center gap-2">
                <UBadge v-if="field.required" color="red" size="xs">Required</UBadge>
                <UBadge v-if="field.unique" color="blue" size="xs">Unique</UBadge>
                <UBadge v-if="field.primary" color="purple" size="xs">Primary</UBadge>
                <UIcon 
                  v-if="isMapped(field.name)" 
                  name="i-heroicons-check-circle"
                  class="text-green-500"
                />
              </div>
            </div>
            
            <div v-if="isMapped(field.name)" class="mt-1 text-sm text-gray-600">
              Mapped from: {{ getMappedHeader(field.name) }}
            </div>
          </div>
        </div>
      </UCard>
    </div>

    <!-- Data Preview with Editable Cells -->
    <UCard v-if="hasData" class="mb-8">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold">Data Preview (Editable)</h3>
          <div class="flex items-center gap-3">
            <UBadge color="blue">
              Double-click to edit
            </UBadge>
            <UBadge :color="validationErrors.length > 0 ? 'red' : 'green'">
              {{ validationErrors.length }} issues
            </UBadge>
          </div>
        </div>
      </template>

      <!-- Validation Errors -->
      <UAlert 
        v-if="validationErrors.length > 0"
        color="red"
        variant="soft"
        class="mb-4"
      >
        <template #title>Data Validation Issues</template>
        <ul class="mt-2 space-y-1">
          <li v-for="error in validationErrors" :key="error" class="text-sm">
            • {{ error }}
          </li>
        </ul>
      </UAlert>

      <!-- Editable Data Table -->
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-800">
            <tr>
              <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Row
              </th>
              <th 
                v-for="field in mappedFields"
                :key="field.name"
                class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                <div class="flex items-center gap-2">
                  {{ field.name }}
                  <UTooltip v-if="field.required">
                    <template #text>Required field</template>
                    <UIcon name="i-heroicons-exclamation-triangle" class="text-red-400" />
                  </UTooltip>
                </div>
              </th>
            </tr>
          </thead>
          
          <tbody class="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
            <tr 
              v-for="(row, rowIndex) in previewData"
              :key="rowIndex"
              :class="{ 'bg-yellow-50 dark:bg-yellow-950': hasRowWarning(rowIndex) }"
            >
              <td class="px-3 py-2 text-sm text-gray-500">
                {{ rowIndex + 1 }}
              </td>
              
              <td 
                v-for="field in mappedFields"
                :key="field.name"
                class="px-3 py-2 text-sm"
                :class="getCellClass(rowIndex, field)"
              >
                <!-- Editable Cell -->
                <div v-if="isEditing(rowIndex, field.name)" class="flex items-center gap-1">
                  <UInput
                    v-model="editingValue"
                    @keyup.enter="saveEdit(rowIndex, field)"
                    @keyup.escape="cancelEdit"
                    @blur="saveEdit(rowIndex, field)"
                    size="xs"
                    :placeholder="field.type"
                    class="flex-1"
                    autofocus
                  />
                </div>
                
                <!-- Display Cell -->
                <div 
                  v-else
                  @dblclick="startEdit(rowIndex, field, row[getMappedHeader(field.name)])"
                  class="cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 px-2 py-1 rounded transition-colors"
                  :title="'Double-click to edit'"
                >
                  <span v-if="row[getMappedHeader(field.name)] !== null && row[getMappedHeader(field.name)] !== ''">
                    {{ formatCellValue(row[getMappedHeader(field.name)], field.type) }}
                  </span>
                  <span v-else class="text-gray-400 italic">
                    {{ field.default || 'NULL' }}
                  </span>
                  
                  <!-- Cell Validation Icon -->
                  <UIcon 
                    v-if="hasFieldError(rowIndex, field)"
                    name="i-heroicons-exclamation-triangle"
                    class="inline-block ml-1 text-red-400"
                  />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Preview Controls -->
      <div class="mt-4 flex items-center justify-between">
        <div class="text-sm text-gray-500">
          Showing {{ previewData.length }} of {{ totalRows }} rows
        </div>
        
        <div class="flex gap-2">
          <UButton
            @click="previewSize = Math.min(previewSize + 5, totalRows)"
            :disabled="previewSize >= totalRows"
            size="sm"
            variant="ghost"
          >
            Show More
          </UButton>
          
          <UButton
            @click="resetData"
            size="sm"
            variant="ghost"
            color="red"
          >
            Reset Changes
          </UButton>
        </div>
      </div>
    </UCard>

    <!-- SQL Generation -->
    <UCard v-if="hasMapping">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold">SQL Generation</h3>
          <UButton
            @click="generateSQL"
            color="green"
            :loading="generating"
            :disabled="validationErrors.length > 0"
          >
            Generate INSERT Statements
          </UButton>
        </div>
      </template>

      <!-- SQL Options -->
      <div class="grid grid-cols-2 gap-4 mb-4">
        <UCheckbox v-model="sqlOptions.includeTruncate" label="Include TRUNCATE statement" />
        <UCheckbox v-model="sqlOptions.useTransaction" label="Wrap in transaction" />
        <UCheckbox v-model="sqlOptions.ignoreErrors" label="Continue on errors" />
        <UCheckbox v-model="sqlOptions.includeComments" label="Include comments" />
      </div>

      <!-- Generated SQL -->
      <div v-if="generatedSQL" class="mt-4">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium">Generated SQL</span>
          <div class="flex gap-2">
            <UButton
              @click="copySQL"
              size="xs"
              variant="ghost"
              icon="i-heroicons-clipboard-document"
            >
              Copy
            </UButton>
            <UButton
              @click="downloadSQL"
              size="xs"
              variant="ghost"
              icon="i-heroicons-arrow-down-tray"
            >
              Download
            </UButton>
          </div>
        </div>
        
        <div class="relative">
          <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto text-sm">{{ generatedSQL }}</pre>
        </div>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useToast } from '@/composables/useToast'
import { useMappingStore } from '@/stores/mapping'
import type { Field, TableSchema } from '@/types'

const props = defineProps<{
  selectedTable?: TableSchema
  excelData: Record<string, any>[]
  excelHeaders: string[]
}>()

const emit = defineEmits<{
  'update:mapping': [mapping: Record<string, string>]
  'generate': [options: any]
}>()

const toast = useToast()
const mappingStore = useMappingStore()

// State
const localMapping = ref<Record<string, string>>({})
const previewSize = ref(10)
const generating = ref(false)
const generatedSQL = ref('')
const validationErrors = ref<string[]>([])

// Editable cells state
const editingCell = ref<{ row: number; field: string } | null>(null)
const editingValue = ref('')
const dataOverrides = ref<Record<string, any>>({})

// SQL Options
const sqlOptions = ref({
  includeTruncate: false,
  useTransaction: true,
  ignoreErrors: false,
  includeComments: true
})

// Computed
const hasData = computed(() => props.excelData.length > 0)
const hasMapping = computed(() => Object.keys(localMapping.value).length > 0)
const totalRows = computed(() => props.excelData.length)
const tableFields = computed(() => props.selectedTable?.fields || [])

const mappedFields = computed(() => {
  return tableFields.value.filter(field => isMapped(field.name))
})

const unmappedHeaders = computed(() => {
  return props.excelHeaders.filter(h => !localMapping.value[h])
})

const mappedHeaders = computed(() => {
  return props.excelHeaders.filter(h => localMapping.value[h])
})

const unmappedRequiredFields = computed(() => {
  return tableFields.value.filter(f => f.required && !isMapped(f.name))
})

const previewData = computed(() => {
  const data = props.excelData.slice(0, previewSize.value)
  
  // Apply overrides from editing
  return data.map((row, index) => {
    const key = `${index}`
    if (dataOverrides.value[key]) {
      return { ...row, ...dataOverrides.value[key] }
    }
    return row
  })
})

// Methods
function isMapped(fieldName: string): boolean {
  return Object.values(localMapping.value).includes(fieldName)
}

function getMappedHeader(fieldName: string): string {
  return Object.keys(localMapping.value).find(k => localMapping.value[k] === fieldName) || ''
}

function availableFieldsFor(header: string) {
  const mapped = new Set(Object.values(localMapping.value))
  const current = localMapping.value[header]
  
  return [
    { value: '', label: 'Not mapped' },
    ...tableFields.value
      .filter(f => !mapped.has(f.name) || f.name === current)
      .map(f => ({
        value: f.name,
        label: f.name,
        required: f.required,
        type: f.type
      }))
  ]
}

function getSampleData(header: string): string {
  const samples = props.excelData.slice(0, 3)
    .map(row => row[header])
    .filter(v => v !== null && v !== undefined && v !== '')
  
  if (samples.length === 0) return 'No data'
  
  return samples.join(', ')
}

// Editable cells functions
function isEditing(row: number, field: string): boolean {
  return editingCell.value?.row === row && editingCell.value?.field === field
}

function startEdit(row: number, field: Field, currentValue: any) {
  editingCell.value = { row, field: field.name }
  editingValue.value = currentValue || ''
}

function saveEdit(row: number, field: Field) {
  if (!editingCell.value) return
  
  const key = `${row}`
  const header = getMappedHeader(field.name)
  
  if (!dataOverrides.value[key]) {
    dataOverrides.value[key] = {}
  }
  
  // Validate and convert value based on field type
  const convertedValue = convertValue(editingValue.value, field.type)
  
  if (convertedValue !== null || !field.required) {
    dataOverrides.value[key][header] = convertedValue
    
    toast.show({
      title: 'Cell updated',
      description: `Row ${row + 1}, ${field.name} = ${convertedValue}`,
      color: 'green'
    })
  }
  
  cancelEdit()
}

function cancelEdit() {
  editingCell.value = null
  editingValue.value = ''
}

function convertValue(value: string, type: string): any {
  if (!value || value.trim() === '') return null
  
  const cleanValue = value.trim()
  
  switch (type.toLowerCase()) {
    case 'int':
    case 'integer':
    case 'bigint':
    case 'smallint':
      const intVal = parseInt(cleanValue)
      return isNaN(intVal) ? null : intVal
      
    case 'decimal':
    case 'numeric':
    case 'float':
    case 'double':
    case 'real':
      const floatVal = parseFloat(cleanValue)
      return isNaN(floatVal) ? null : floatVal
      
    case 'boolean':
    case 'bool':
      return cleanValue.toLowerCase() === 'true' || cleanValue === '1'
      
    case 'date':
      return cleanValue // Keep as string, backend will handle
      
    default:
      return cleanValue
  }
}

function formatCellValue(value: any, type: string): string {
  if (value === null || value === undefined) return 'NULL'
  
  switch (type.toLowerCase()) {
    case 'boolean':
    case 'bool':
      return value ? '✓' : '✗'
      
    case 'date':
    case 'datetime':
    case 'timestamp':
      try {
        return new Date(value).toLocaleString()
      } catch {
        return value.toString()
      }
      
    default:
      return value.toString()
  }
}

function getCellClass(row: number, field: Field): string {
  const classes = []
  
  if (hasFieldError(row, field)) {
    classes.push('bg-red-50 dark:bg-red-950')
  }
  
  if (isEditing(row, field.name)) {
    classes.push('bg-blue-50 dark:bg-blue-950')
  }
  
  return classes.join(' ')
}

function hasFieldError(row: number, field: Field): boolean {
  const header = getMappedHeader(field.name)
  const value = previewData.value[row]?.[header]
  
  if (field.required && (value === null || value === undefined || value === '')) {
    return true
  }
  
  // Add type validation here if needed
  
  return false
}

function hasRowWarning(row: number): boolean {
  return mappedFields.value.some(field => hasFieldError(row, field))
}

function validateData() {
  const errors: string[] = []
  
  // Check unmapped required fields
  unmappedRequiredFields.value.forEach(field => {
    errors.push(`Required field "${field.name}" is not mapped`)
  })
  
  // Check data integrity
  previewData.value.forEach((row, index) => {
    mappedFields.value.forEach(field => {
      if (hasFieldError(index, field)) {
        errors.push(`Row ${index + 1}: Missing required value for "${field.name}"`)
      }
    })
  })
  
  validationErrors.value = [...new Set(errors)].slice(0, 10) // Show max 10 errors
}

function autoMap() {
  if (!props.selectedTable || !props.excelHeaders.length) {
    toast.show({
      title: 'Cannot auto-map',
      description: 'No table or data available',
      color: 'red'
    })
    return
  }
  
  const mapping: Record<string, string> = {}
  let mapped = 0
  
  props.excelHeaders.forEach(header => {
    const normalizedHeader = header.toLowerCase().replace(/[^a-z0-9]/g, '')
    
    const field = tableFields.value.find(f => {
      const normalizedField = f.name.toLowerCase().replace(/[^a-z0-9]/g, '')
      return normalizedField === normalizedHeader || 
             normalizedField.includes(normalizedHeader) ||
             normalizedHeader.includes(normalizedField)
    })
    
    if (field) {
      mapping[header] = field.name
      mapped++
    }
  })
  
  localMapping.value = mapping
  
  toast.show({
    title: 'Auto-mapping complete',
    description: `Mapped ${mapped} of ${props.excelHeaders.length} columns`,
    color: mapped > 0 ? 'green' : 'orange'
  })
}

function clearMapping() {
  localMapping.value = {}
  dataOverrides.value = {}
  toast.show({
    title: 'Mapping cleared',
    color: 'gray'
  })
}

function resetData() {
  dataOverrides.value = {}
  toast.show({
    title: 'Changes reset',
    description: 'All edits have been reverted',
    color: 'gray'
  })
}

async function generateSQL() {
  if (validationErrors.value.length > 0) {
    toast.show({
      title: 'Cannot generate SQL',
      description: 'Please fix validation errors first',
      color: 'red'
    })
    return
  }
  
  generating.value = true
  
  try {
    // Merge original data with overrides
    const finalData = props.excelData.map((row, index) => {
      const key = `${index}`
      if (dataOverrides.value[key]) {
        return { ...row, ...dataOverrides.value[key] }
      }
      return row
    })
    
    // Generate SQL statements
    const statements: string[] = []
    
    if (sqlOptions.value.includeComments) {
      statements.push(`-- Generated SQL for table: ${props.selectedTable?.name}`)
      statements.push(`-- Date: ${new Date().toISOString()}`)
      statements.push(`-- Rows: ${finalData.length}`)
      statements.push('')
    }
    
    if (sqlOptions.value.useTransaction) {
      statements.push('BEGIN TRANSACTION;')
      statements.push('')
    }
    
    if (sqlOptions.value.includeTruncate) {
      statements.push(`TRUNCATE TABLE ${props.selectedTable?.name};`)
      statements.push('')
    }
    
    // Generate INSERT statements
    finalData.forEach(row => {
      const fields: string[] = []
      const values: string[] = []
      
      mappedFields.value.forEach(field => {
        const header = getMappedHeader(field.name)
        const value = row[header]
        
        fields.push(field.name)
        values.push(formatSQLValue(value, field.type))
      })
      
      const sql = `INSERT INTO ${props.selectedTable?.name} (${fields.join(', ')}) VALUES (${values.join(', ')});`
      statements.push(sql)
    })
    
    if (sqlOptions.value.useTransaction) {
      statements.push('')
      statements.push('COMMIT;')
    }
    
    generatedSQL.value = statements.join('\n')
    
    toast.show({
      title: 'SQL generated',
      description: `Generated ${finalData.length} INSERT statements`,
      color: 'green'
    })
    
    // Emit event
    emit('generate', {
      sql: generatedSQL.value,
      mapping: localMapping.value,
      data: finalData,
      options: sqlOptions.value
    })
    
  } catch (error) {
    console.error('Error generating SQL:', error)
    toast.show({
      title: 'Generation failed',
      description: error.message || 'Unknown error',
      color: 'red'
    })
  } finally {
    generating.value = false
  }
}

function formatSQLValue(value: any, type: string): string {
  if (value === null || value === undefined || value === '') {
    return 'NULL'
  }
  
  switch (type.toLowerCase()) {
    case 'int':
    case 'integer':
    case 'bigint':
    case 'decimal':
    case 'numeric':
    case 'float':
    case 'double':
      return value.toString()
      
    case 'boolean':
    case 'bool':
      return value ? '1' : '0'
      
    default:
      // Escape single quotes for strings
      const str = value.toString().replace(/'/g, "''")
      return `'${str}'`
  }
}

async function copySQL() {
  try {
    await navigator.clipboard.writeText(generatedSQL.value)
    toast.show({
      title: 'Copied to clipboard',
      color: 'green'
    })
  } catch (error) {
    toast.show({
      title: 'Copy failed',
      description: 'Please select and copy manually',
      color: 'red'
    })
  }
}

function downloadSQL() {
  const blob = new Blob([generatedSQL.value], { type: 'text/sql' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${props.selectedTable?.name}_insert_${Date.now()}.sql`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  
  toast.show({
    title: 'Download started',
    color: 'green'
  })
}

// Watchers
watch(localMapping, (newMapping) => {
  emit('update:mapping', newMapping)
  validateData()
}, { deep: true })

watch(() => props.excelData, () => {
  validateData()
}, { deep: true })

watch(dataOverrides, () => {
  validateData()
}, { deep: true })

// Initial validation
validateData()
</script>

<style scoped>
.mapping-container {
  @apply max-w-7xl mx-auto p-6;
}

.mapping-row {
  @apply p-3 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors;
}

/* Custom scrollbar for preview table */
.overflow-x-auto::-webkit-scrollbar {
  height: 8px;
}

.overflow-x-auto::-webkit-scrollbar-track {
  @apply bg-gray-100 dark:bg-gray-800 rounded;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
  @apply bg-gray-400 dark:bg-gray-600 rounded;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
  @apply bg-gray-500 dark:bg-gray-500;
}
</style>
