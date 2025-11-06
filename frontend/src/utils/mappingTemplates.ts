/**
 * Mapping templates system
 * Save and reuse column mappings for frequently imported data
 */

import type { TransformationType } from './transformations'

export interface MappingTemplate {
  id: string
  name: string
  description?: string
  tableName: string
  mapping: Record<string, string> // excelColumn -> dbColumn
  transformations?: Record<string, TransformationType> // excelColumn -> transformation
  createdAt: string
  updatedAt: string
}

const STORAGE_KEY = 'db-importer-mapping-templates'
const STORAGE_VERSION = '1.0'

interface StorageData {
  version: string
  templates: MappingTemplate[]
}

/**
 * Load all templates from localStorage
 */
export function loadTemplates(): MappingTemplate[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return []

    const data: StorageData = JSON.parse(stored)

    // Check version
    if (data.version !== STORAGE_VERSION) {
      console.warn('Template storage version mismatch, clearing')
      localStorage.removeItem(STORAGE_KEY)
      return []
    }

    return data.templates || []
  } catch (error) {
    console.error('Failed to load templates:', error)
    return []
  }
}

/**
 * Save all templates to localStorage
 */
function saveTemplates(templates: MappingTemplate[]): void {
  try {
    const data: StorageData = {
      version: STORAGE_VERSION,
      templates
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch (error) {
    console.error('Failed to save templates:', error)
  }
}

/**
 * Create a new template
 */
export function createTemplate(
  name: string,
  tableName: string,
  mapping: Record<string, string>,
  transformations?: Record<string, TransformationType>,
  description?: string
): MappingTemplate {
  const template: MappingTemplate = {
    id: generateTemplateId(),
    name,
    description,
    tableName,
    mapping: { ...mapping },
    transformations: transformations ? { ...transformations } : undefined,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  const templates = loadTemplates()
  templates.push(template)
  saveTemplates(templates)

  return template
}

/**
 * Update an existing template
 */
export function updateTemplate(
  id: string,
  updates: Partial<Omit<MappingTemplate, 'id' | 'createdAt'>>
): MappingTemplate | null {
  const templates = loadTemplates()
  const index = templates.findIndex(t => t.id === id)

  if (index === -1) return null

  const updated: MappingTemplate = {
    ...templates[index],
    ...updates,
    updatedAt: new Date().toISOString()
  }

  templates[index] = updated
  saveTemplates(templates)

  return updated
}

/**
 * Delete a template
 */
export function deleteTemplate(id: string): boolean {
  const templates = loadTemplates()
  const filtered = templates.filter(t => t.id !== id)

  if (filtered.length === templates.length) return false

  saveTemplates(filtered)
  return true
}

/**
 * Get a template by ID
 */
export function getTemplate(id: string): MappingTemplate | null {
  const templates = loadTemplates()
  return templates.find(t => t.id === id) || null
}

/**
 * Get templates for a specific table
 */
export function getTemplatesForTable(tableName: string): MappingTemplate[] {
  const templates = loadTemplates()
  return templates.filter(t => t.tableName === tableName)
}

/**
 * Search templates by name
 */
export function searchTemplates(query: string): MappingTemplate[] {
  const templates = loadTemplates()
  const lowerQuery = query.toLowerCase()

  return templates.filter(t =>
    t.name.toLowerCase().includes(lowerQuery) ||
    t.description?.toLowerCase().includes(lowerQuery) ||
    t.tableName.toLowerCase().includes(lowerQuery)
  )
}

/**
 * Generate unique template ID
 */
function generateTemplateId(): string {
  return `template_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
}

/**
 * Export templates as JSON file
 */
export function exportTemplates(): string {
  const templates = loadTemplates()
  return JSON.stringify(templates, null, 2)
}

/**
 * Import templates from JSON
 */
export function importTemplates(jsonString: string): {
  success: boolean
  imported: number
  errors: string[]
} {
  const errors: string[] = []
  let imported = 0

  try {
    const importedTemplates = JSON.parse(jsonString) as MappingTemplate[]

    if (!Array.isArray(importedTemplates)) {
      throw new Error('Invalid format: expected array of templates')
    }

    const existingTemplates = loadTemplates()

    for (const template of importedTemplates) {
      // Validate template structure
      if (!template.name || !template.tableName || !template.mapping) {
        errors.push(`Invalid template: ${template.name || 'unnamed'}`)
        continue
      }

      // Check for duplicates
      const duplicate = existingTemplates.find(
        t => t.name === template.name && t.tableName === template.tableName
      )

      if (duplicate) {
        errors.push(`Duplicate template: ${template.name} for table ${template.tableName}`)
        continue
      }

      // Create new template with fresh ID and timestamps
      createTemplate(
        template.name,
        template.tableName,
        template.mapping,
        template.transformations,
        template.description
      )

      imported++
    }

    return {
      success: imported > 0,
      imported,
      errors
    }
  } catch (error) {
    return {
      success: false,
      imported: 0,
      errors: [error instanceof Error ? error.message : 'Unknown error']
    }
  }
}

/**
 * Check if a mapping matches a template
 */
export function matchesTemplate(
  mapping: Record<string, string>,
  template: MappingTemplate
): { matches: boolean; similarity: number } {
  const mappingKeys = Object.keys(mapping)
  const templateKeys = Object.keys(template.mapping)

  if (mappingKeys.length === 0 || templateKeys.length === 0) {
    return { matches: false, similarity: 0 }
  }

  // Count matching mappings
  let matchCount = 0
  for (const [excelCol, dbCol] of Object.entries(mapping)) {
    if (template.mapping[excelCol] === dbCol) {
      matchCount++
    }
  }

  const similarity = matchCount / Math.max(mappingKeys.length, templateKeys.length)
  const matches = similarity > 0.8 // 80% similarity threshold

  return { matches, similarity }
}

/**
 * Suggest templates based on current mapping
 */
export function suggestTemplates(
  tableName: string,
  currentMapping: Record<string, string>
): MappingTemplate[] {
  const tableTemplates = getTemplatesForTable(tableName)

  return tableTemplates
    .map(template => ({
      template,
      ...matchesTemplate(currentMapping, template)
    }))
    .filter(item => item.similarity > 0.5) // At least 50% similar
    .sort((a, b) => b.similarity - a.similarity)
    .map(item => item.template)
}
