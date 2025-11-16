# Vue 3/TypeScript Frontend Code Analysis Report

## Executive Summary
The frontend codebase demonstrates solid Vue 3 Composition API usage with Pinia state management. Good overall code quality with strong testing for utilities. Key areas for improvement: component size, TypeScript strictness, API abstraction, and component testing coverage.

---

## 1. Vue 3 Composition API Usage

### Strengths:
- ✅ Proper use of `<script setup>` syntax throughout
- ✅ Good separation of concerns with composables-style patterns
- ✅ Proper use of lifecycle hooks (onMounted, onUnmounted)
- ✅ Reactive refs and computed properties used correctly

### Issues & Recommendations:

#### Issue 1.1: Missing `defineProps` Type Definitions
**Files Affected:**
- `/frontend/src/pages/Mapping.vue` (no props validation)
- `/frontend/src/components/StepperNav.vue` (no props)
- Most page components lack `defineProps`

**Example Problem:**
```typescript
// CURRENT (No validation)
// Components just assume data exists

// RECOMMENDED
const props = defineProps<{
  initialData?: Record<string, any>
}>()

const emit = defineEmits<{
  update: [value: string]
}>()
```

#### Issue 1.2: Missing `defineEmits` in Components
**Files Affected:**
- Most page components don't define emitted events
- Should use TypeScript-safe emit declarations

**Code Location:** `/frontend/src/pages/History.vue:306+`

**Fix:** Add proper `defineEmits` with type definitions at script top.

#### Issue 1.3: Missing Watchers Cleanup
**File:** `/frontend/src/pages/Mapping.vue:573-585`
```typescript
// Line 573-580: Deep watchers without cleanup
watch(() => store.mapping, (newMapping) => {
  if (newMapping && Object.keys(newMapping).length > 0) {
    localMapping.value = { ...newMapping }
    syncFieldToExcelMapping()
    validateData()
  }
}, { deep: true, immediate: true })
```

**Issue:** Deep watchers can impact performance. Deep watching doesn't stop when component unmounts.

**Recommendation:** Consider using `watchEffect` with cleanup or shallow comparison.

---

## 2. TypeScript Usage

### Strengths:
- ✅ Good interface definitions in stores
- ✅ Type-safe store actions
- ✅ Proper use of generics where applicable

### Issues & Recommendations:

#### Issue 2.1: `any` Type Used in Error Handling
**Files Affected:**
- `/frontend/src/store/authStore.ts:65, 104, 130, 178`
- `/frontend/src/store/importStore.ts:115, 154, 178, 202, 228, 252, 277`
- `/frontend/src/pages/Mapping.vue:1350`

**Problem Code:**
```typescript
// Line 65 - authStore.ts
catch (error: any) {
  this.error = error.message || 'Registration failed'
  throw error
}
```

**Recommendation:**
```typescript
catch (error) {
  const message = error instanceof Error ? error.message : 'Unknown error'
  this.error = message || 'Registration failed'
  throw error
}
```

#### Issue 2.2: Weak Type for API Response Data
**Files Affected:**
- `/frontend/src/store/workflowSessionStore.ts:196`
- Multiple store actions use `any` for response data

**Code:**
```typescript
// Line 196 - workflowSessionStore.ts
async getSession(): Promise<any | null> {
  // Should be typed properly
}
```

**Recommendation:** Create specific response types:
```typescript
interface SessionResponse {
  id: string
  schemaTables: Table[]
  selectedTableName: string | null
  dataHeaders: string[]
  sampleData: any[][]
  columnMapping: Record<string, string>
  fieldTransformations: Record<string, string>
  currentStep: number
}
```

#### Issue 2.3: Untyped Component Refs
**File:** `/frontend/src/pages/UploadData.vue:198-201`
```typescript
const fileInput = ref<HTMLInputElement>()  // Good
const loading = ref(false)  // Good
const error = ref('')  // Should be more specific
const currentFileName = ref<string>('')  // Could use const
```

**Recommendation:** More specific typing for better autocomplete and safety.

#### Issue 2.4: Missing Type Safety in `Record<string, any>`
**Files:** Throughout stores and components
**Locations:** Lines with `Record<string, any>` should use specific types

**Example from `Mapping.vue:512`:**
```typescript
const localMapping = ref<Record<string, string>>({})  // Good
const previousFieldTransformations = ref<Record<string, TransformationType>>({})  // Good
```

Good examples exist but need consistency across all files.

---

## 3. State Management (Pinia)

### Strengths:
- ✅ Well-organized store files by domain (auth, import, mapping, workflow)
- ✅ Clear separation of concerns
- ✅ Type-safe store interfaces
- ✅ Good use of getters for derived data

### Issues & Recommendations:

#### Issue 3.1: API Logic Not Abstracted to Composables
**Files Affected:**
- `/frontend/src/store/authStore.ts:35-71`
- `/frontend/src/store/importStore.ts:94-121`
- `/frontend/src/store/workflowSessionStore.ts:29-68`

**Problem:** Fetch calls mixed with state management. Code is repetitive.

**Current Pattern (ANTI-PATTERN):**
```typescript
// Repeated in many places
try {
  const response = await fetch(`${API_URL}/path`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(data)
  })
  
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}))
    throw new Error(errorData.error || 'Failed')
  }
  // ... handle success
} catch (error: any) {
  // ... handle error
}
```

**Recommendation - Create API Service:**
```typescript
// utils/api.ts
export async function apiPost<T>(
  path: string,
  data: any,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(
    `${import.meta.env.VITE_API_URL}${path}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      ...options,
      body: JSON.stringify(data)
    }
  )
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || `HTTP ${response.status}`)
  }
  
  return response.json()
}
```

#### Issue 3.2: Computed Properties Missing for Derived State
**File:** `/frontend/src/store/mappingStore.ts:158-197`

**Good Examples Already Exist:**
```typescript
// Lines 159-180 - Well done!
hasSchema: (state) => state.tables.length > 0
allRequiredFieldsMapped: (state) => {
  if (!state.selectedTable) return false
  for (const field of state.selectedTable.fields) {
    if (!field.nullable) {
      const isMapped = Object.values(state.mapping).includes(field.name)
      if (!isMapped) return false
    }
  }
  return true
}
```

**Recommendation:** Apply same pattern to other stores.
- `authStore`: Add `isGuest`, `hasCompleteProfile` getters
- `importStore`: Add filtered lists as getters

#### Issue 3.3: Inconsistent API URL Access
**Files:**
- `/frontend/src/store/authStore.ts:22`
- `/frontend/src/store/importStore.ts:79`
- `/frontend/src/pages/Mapping.vue:545`

**Problem:** API_URL defined in multiple places

**Current:**
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'
```

**Recommendation:** Create single config file:
```typescript
// utils/config.ts
export const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

// Then import everywhere
import { API_URL } from '../utils/config'
```

#### Issue 3.4: Loading State Management
**Files:** All stores use `this.loading = true/false`

**Problem:** Multiple async operations can't track individual request status

**Current Issue:** If two async actions run simultaneously in a store, loading state gets mixed up.

**Recommendation:** Use request counter or operation-specific loading:
```typescript
const pendingRequests = ref(0)

const isLoading = computed(() => pendingRequests.value > 0)
```

---

## 4. Component Structure

### Issues & Recommendations:

#### Issue 4.1: Mapping.vue is Too Large
**File:** `/frontend/src/pages/Mapping.vue`
**Size:** 1,355 lines (entire file including template and script)

**Current Structure:**
- Template: Lines 1-492
- Script: Lines 494-1355 (862 lines of logic)

**Components to Extract:**

1. **Transform Preview Modal** (Lines 427-464)
   - Extract to: `components/TransformPreviewModal.vue`
   - Props: transformPreviewColumn, showTransformPreview, fieldTransformations
   - Emits: close, applyTransform

2. **Clear Mapping Dialog** (Lines 466-490)
   - Extract to: `components/ClearMappingConfirm.vue`
   - Props: visible
   - Emits: confirm, cancel

3. **Data Preview Table** (Lines 325-379)
   - Extract to: `components/DataPreviewTable.vue`
   - Props: data, headers, validations
   - Emits: none (display-only)

4. **Column Mapping Card** (Lines 191-292)
   - Extract to: `components/FieldMappingRow.vue`
   - Props: field, mappedColumn, transformation
   - Emits: update-mapping, update-transformation

**Recommended Final Structure:**
```
Mapping.vue (max 400 lines)
├─ TransformPreviewModal.vue
├─ ClearMappingConfirm.vue
├─ DataPreviewTable.vue
└─ FieldMappingRow.vue
```

#### Issue 4.2: History.vue Large Table with Many Computed Properties
**File:** `/frontend/src/pages/History.vue`
**Size:** 602 lines

**Improvements Needed:**

1. Extract table columns config to separate constant file
2. Extract pagination logic to composable
3. Extract filter logic to composable

**Recommended Structure:**
```typescript
// composables/useHistoryFilters.ts
export function useHistoryFilters() {
  const filters = ref({ tableName: '', status: null })
  // ... filter logic
  return { filters, applyFilter, resetFilters }
}

// composables/useHistoryPagination.ts
export function useHistoryPagination(items) {
  const currentPage = ref(1)
  // ... pagination logic
  return { currentPage, visiblePages, goToPage }
}
```

#### Issue 4.3: Missing Child Component Props Validation
**Files:**
- `/frontend/src/components/StepperNav.vue` - No props
- Most pages - No explicit prop validation

**Current Pattern:**
```typescript
// No props defined - relying on context
const router = useRouter()
const store = useMappingStore()
```

**Better Pattern:**
```typescript
defineProps<{
  // Any props if needed
}>()

const router = useRouter()
const store = useMappingStore()
```

---

## 5. Props and Emits Type Safety

### Issues & Recommendations:

#### Issue 5.1: No EmitsDefined in Page Components
**Files:**
- `/frontend/src/pages/History.vue` - Uses `useToast()` directly
- `/frontend/src/pages/Mapping.vue` - No emits defined
- Should use `defineEmits` for child-parent communication

#### Issue 5.2: Form Input Validation Not Centralized
**Files:**
- `/frontend/src/pages/Login.vue:152-175`
- `/frontend/src/pages/Register.vue:203-238`

**Problem:** Email and password validation duplicated

**Recommendation - Create Composable:**
```typescript
// composables/useFormValidation.ts
export function useEmailValidation() {
  const error = ref('')
  const validate = (email: string) => {
    error.value = ''
    if (!email) {
      error.value = 'Email is required'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      error.value = 'Please enter a valid email'
    }
    return !error.value
  }
  return { error, validate }
}
```

---

## 6. Code Duplication

### High Priority Issues:

#### Issue 6.1: Fetch Call Pattern Duplicated 10+ Times
**Occurrences:**
- `/frontend/src/store/authStore.ts:40-52, 78-89, 114-120, 138-144, 159-165`
- `/frontend/src/store/importStore.ts:99-106, 137-139, 167-169, 191-193, 215-217, 241-243, 265-267`
- `/frontend/src/store/workflowSessionStore.ts:41-51, 84-93, 126-137, 167-177, 207-209, 312-315`

**Total Occurrences:** ~25 fetch patterns

**Refactoring:** Create `utils/api.ts` service (1385 lines total could reduce to ~500)

#### Issue 6.2: Error Handling Pattern Duplicated
**Pattern Repeated:**
```typescript
if (!response.ok) {
  const errorData = await response.json().catch(() => ({ error: 'Failed to ...' }))
  throw new Error(errorData.error || 'Failed to ...')
}
```

**Appears in:** ~15 locations

#### Issue 6.3: Validation Logic Duplicated
**Files:**
- `/frontend/src/utils/dataValidation.ts:45-52, 56-63` - NULL checks
- `/frontend/src/utils/transformations.ts:136-143` - Boolean conversion logic
- `/frontend/src/pages/Login.vue:161-163` - Email validation
- `/frontend/src/pages/Register.vue:214-216` - Same email validation

---

## 7. Error Handling

### Strengths:
- ✅ Try-catch blocks used appropriately
- ✅ User-facing error messages
- ✅ Graceful fallbacks (e.g., localStorage fallback in workflowSessionStore)

### Issues:

#### Issue 7.1: Generic Error Messages Don't Help Debugging
**File:** `/frontend/src/pages/UploadData.vue:243-245`
```typescript
// Logging but users see generic message
console.error('Error saving data file to session:', error)
// User sees: "Failed to save data file"
```

**Improvement:** Different messages for different errors:
```typescript
if (error instanceof TypeError) {
  this.error = 'Network error - please check your connection'
} else if (error instanceof Error) {
  this.error = error.message
} else {
  this.error = 'An unexpected error occurred'
}
```

#### Issue 7.2: Missing Error Context for Async Operations
**Files:**
- `/frontend/src/store/importStore.ts:236-258` - getStats() doesn't indicate which stats failed
- No operation-specific error tracking

**Recommendation:**
```typescript
interface ApiError {
  operation: string
  status?: number
  message: string
  timestamp: Date
}
```

#### Issue 7.3: Silent Failures in Session Restoration
**File:** `/frontend/src/store/workflowSessionStore.ts:239-296`
```typescript
// Line 239-246
async restoreSession(): Promise<boolean> {
  try {
    const session = await this.getSession()
    if (!session) {
      this.isRestoring = false
      return false  // Silently returns
    }
    // ...
  } catch (error) {
    console.error('Error restoring session:', error)
    this.isRestoring = false
    return false  // No user feedback
  }
}
```

**Issue:** User doesn't know why session restoration failed

---

## 8. Performance Issues

### Issues & Recommendations:

#### Issue 8.1: Deep Watchers on Large Objects
**File:** `/frontend/src/pages/Mapping.vue:573-585`
```typescript
watch(() => store.mapping, (newMapping) => {
  // Deep watching the entire mapping object
}, { deep: true, immediate: true })
```

**Problem:** Triggers on any nested property change, even if not relevant

**Recommendation:**
```typescript
watch(
  () => Object.keys(store.mapping).length,  // Watch only the count
  () => {
    localMapping.value = { ...store.mapping }
    syncFieldToExcelMapping()
    validateData()
  }
)
```

#### Issue 8.2: Unnecessary Recalculations in Computed Properties
**File:** `/frontend/src/pages/SelectTable.vue:235-264`
```typescript
const filteredTables = computed(() => {
  let tables = store.tables
  
  // Filter and sort happens every time any reactive property changes
  if (searchQuery.value) {
    // ... complex filter
  }
  // ... complex sort
  return sorted
})
```

**Impact:** With 100+ tables, this recalculates on each keystroke

**Recommendation:**
```typescript
const filteredTables = computed(() => {
  return store.tables
    .filter(t => t.name.toLowerCase().includes(searchQuery.value.toLowerCase()))
    .sort((a, b) => {
      // ... sorting logic
    })
})

// For large lists, consider pagination in UI
```

#### Issue 8.3: Excel Data Parsing Not Optimized
**File:** `/frontend/src/pages/UploadData.vue:220-221`
```typescript
const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 }) as any[][]
const rows = jsonData.slice(1).filter(row => row.some(cell => ...))
```

**Issue:** Filters entire dataset to remove empty rows. With 100k rows, this is slow.

**Recommendation:**
```typescript
// Use streaming for large files
const CHUNK_SIZE = 10000
for (let i = 0; i < rows.length; i += CHUNK_SIZE) {
  processChunk(rows.slice(i, i + CHUNK_SIZE))
}
```

#### Issue 8.4: Levenshtein Distance Recalculated Many Times
**File:** `/frontend/src/pages/Mapping.vue:590-618, 662-732`
```typescript
// For each header, this calculates similarity against ALL fields
for (const header of store.excelHeaders) {
  for (const field of store.selectedTable?.fields || []) {
    const similarity = calculateSimilarity(header, field.name)
    // This is O(n*m) complexity - can be slow with many columns
  }
}
```

**Optimization Potential:** Use memoization or pre-calculate similarity scores

---

## 9. Reactivity Issues

### Strengths:
- ✅ Correct use of `ref()` for mutable state
- ✅ Correct use of `computed()` for derived state
- ✅ Proper cleanup of event listeners (line 569)

### Issues:

#### Issue 9.1: Direct Object Mutation in Stores
**File:** `/frontend/src/store/mappingStore.ts:120-122`
```typescript
updateMapping(excelColumn: string, dbColumn: string) {
  this.mapping[excelColumn] = dbColumn  // Direct mutation
  this.persist()
}
```

**Issue:** This mutates `this.mapping` directly instead of replacing the object

**Better Pattern:**
```typescript
updateMapping(excelColumn: string, dbColumn: string) {
  this.mapping = {
    ...this.mapping,
    [excelColumn]: dbColumn
  }
  this.persist()
}
```

#### Issue 9.2: Array Reference Mutations
**File:** `/frontend/src/store/importStore.ts:226`
```typescript
// Mutating array reference
this.imports = this.imports.filter(imp => imp.id !== id)
```

**Good practice exists** but should be consistent:
```typescript
// Better approach for clarity
const updatedImports = this.imports.filter(imp => imp.id !== id)
this.imports = updatedImports
```

#### Issue 9.3: Missing Reactive Root in Watchers
**File:** `/frontend/src/pages/History.vue:481-495`
```typescript
watch(filters, () => {
  // Watches entire filters object
  filterDebounceTimer = setTimeout(...)
}, { deep: true })
```

**Problem:** Can't distinguish which filter changed

**Better:**
```typescript
watch([() => filters.value.tableName, () => filters.value.status], () => {
  // More specific watching
})
```

---

## 10. Testing Coverage

### Current State:
- ✅ Utility functions well-tested: 1,385 lines of test code
  - `/frontend/src/utils/dataValidation.test.ts` - 330 lines
  - `/frontend/src/utils/sqlSanitization.test.ts` - 337 lines
  - `/frontend/src/utils/sqlValidation.test.ts` - 267 lines
  - `/frontend/src/utils/transformations.test.ts` - 451 lines

### Major Gaps:

#### Issue 10.1: Zero Component Tests
**Missing Test Files:**
- No `*.spec.ts` or `*.test.ts` files for components
- No tests for any `.vue` files

**Recommendation - Add Component Tests:**
```typescript
// components/FieldMappingRow.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import FieldMappingRow from './FieldMappingRow.vue'

describe('FieldMappingRow.vue', () => {
  it('should emit update-mapping when selection changes', async () => {
    const wrapper = mount(FieldMappingRow, {
      props: {
        field: { name: 'id', type: 'INT', nullable: false }
      }
    })
    
    // Test logic
  })
})
```

#### Issue 10.2: No Store Tests
**Missing Test Coverage:**
- No tests for Pinia stores
- No tests for async actions
- No tests for getters

#### Issue 10.3: No Integration Tests
**Missing:**
- No tests for workflows (e.g., upload → select → map → generate)
- No tests for error scenarios
- No tests for session persistence

**Recommended Coverage Targets:**
- ✅ Utility functions: 80%+ (already achieved)
- ⚠️ Components: Target 60%+ (currently 0%)
- ⚠️ Stores: Target 70%+ (currently 0%)
- ⚠️ E2E workflows: Target 40%+ (currently 0%)

---

## 11. Accessibility Issues

### Strengths:
- ✅ Good use of aria-labels (line 14 in Mapping.vue)
- ✅ Proper form labels
- ✅ Error messages associated with inputs
- ✅ Color contrast appears sufficient

### Issues:

#### Issue 11.1: Missing ARIA Labels on Interactive Elements
**File:** `/frontend/src/pages/History.vue:307-395`
```typescript
// Line 370: Icon button without accessible label
h(UButton, {
  icon: 'i-heroicons-eye',
  // Missing aria-label or tooltip for screen readers
})
```

**Fix:**
```typescript
h(UButton, {
  icon: 'i-heroicons-eye',
  'aria-label': 'View details for import'
})
```

#### Issue 11.2: Semantic HTML Issues
**File:** `/frontend/src/pages/SelectTable.vue:76-84`
```html
<!-- Using div and buttons instead of semantic select -->
<div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
  🔍
</div>
<select>  <!-- This is better but could be improved -->
```

#### Issue 11.3: Insufficient Keyboard Navigation
**Files:**
- `/frontend/src/pages/SelectTable.vue:106-151`
```typescript
// Divs are clickable but not keyboard accessible
<div
  @click="selectTable(table.name)"
  class="cursor-pointer rounded-lg..."
>
```

**Fix:** Use buttons or add role/tabindex:
```html
<button
  @click="selectTable(table.name)"
  :aria-pressed="selectedTableName === table.name"
  class="rounded-lg..."
>
```

#### Issue 11.4: Missing `alt` Text on Icon Emojis
**Files:**
- `/frontend/src/pages/UploadSchema.vue:47` - `<div class="text-4xl">☁️</div>`
- `/frontend/src/pages/UploadData.vue:69` - `<div class="text-4xl">📊</div>`
- Multiple locations

**Fix:**
```html
<div class="text-4xl" aria-label="Cloud upload icon">☁️</div>
```

---

## 12. Security Issues

### Strengths:
- ✅ HTML escaping in place (Vue templates auto-escape)
- ✅ Input validation present
- ✅ No direct DOM manipulation
- ✅ Credentials sent with `include` flag

### Issues:

#### Issue 12.1: XSS Risk in Dynamic Content
**File:** `/frontend/src/pages/History.vue:236`
```typescript
<pre class="text-sm text-green-400 font-mono whitespace-pre-wrap">
  {{ getSQLPreview(selectedImportSQL) }}
</pre>
```

**Risk:** If SQL contains HTML-like content, it could execute

**Actually Safe** - Vue escapes this. But worth verifying in dynamic content.

#### Issue 12.2: SQL Injection in Client (Presentation Risk)
**File:** `/frontend/src/pages/Mapping.vue:1262-1267`
```typescript
body: JSON.stringify({
  table: store.selectedTable.name,
  mapping: localMapping.value,  // User input directly sent
  rows: mappedRows,
  fields: fields
})
```

**Assessment:** SAFE - Backend should validate and sanitize. Client sends data, backend executes SQL.

#### Issue 12.3: Missing CSRF Token
**Potential Issue:** Fetch requests use `credentials: 'include'` but no CSRF tokens sent

**Check:** Ensure backend implements CSRF protection:
- Use SameSite cookies
- Or add CSRF token header to requests

#### Issue 12.4: localStorage Usage Not Encrypted
**File:** `/frontend/src/store/mappingStore.ts:52-71`
```typescript
localStorage.setItem(STORAGE_KEY, JSON.stringify(toStore))
```

**Risk:** Session data stored in plain text localStorage
- Contains: schema, table names, mappings
- Could expose user workflow if device compromised

**Recommendation:**
- Store only non-sensitive data in localStorage
- Keep sensitive data in memory only
- Use sessionStorage instead for temporary data

#### Issue 12.5: No Input Validation on File Upload
**File:** `/frontend/src/pages/UploadData.vue:262-264`
```typescript
function handleDrop(event: DragEvent) {
  const file = event.dataTransfer?.files?.[0]
  if (file && (file.name.endsWith('.xlsx') || file.name.endsWith('.xls') || file.name.endsWith('.csv'))) {
    currentFileName.value = file.name
    processFile(file)
  }
}
```

**Issue:** Only checks file extension, not content
**Fix:** Validate file content:
```typescript
// Read first few bytes to verify actual file type
const header = new Uint8Array(await file.slice(0, 4).arrayBuffer())
const isPDF = header[0] === 0x25 && header[1] === 0x50  // %P
const isXLSX = header[0] === 0x50 && header[1] === 0x4B  // PK (ZIP)
```

---

## Summary of Issues by Priority

### CRITICAL (Fix Immediately)
1. **Replace `any` types** in error handling (20+ occurrences)
2. **Extract API fetch logic** to centralized service
3. **Add component tests** (currently 0% coverage)

### HIGH (Fix Soon)
1. **Split Mapping.vue** (1,355 lines too large)
2. **Add TypeScript types** for API responses
3. **Create form validation composables** (eliminate duplication)
4. **Add localStorage encryption** for sensitive data

### MEDIUM (Fix Next Sprint)
1. **Optimize deep watchers** and computed properties
2. **Add CSRF token** verification
3. **Create API error service** for consistent handling
4. **Add accessibility improvements** (ARIA labels, semantic HTML)
5. **Extract pagination/filter logic** to composables

### LOW (Technical Debt)
1. **Add component tests** for remaining components
2. **Improve accessibility** across the board
3. **Optimize large list rendering** with virtualization
4. **Add JSDoc comments** for complex functions

---

## Recommended Refactoring Timeline

### Week 1: Critical Fixes
- Create `utils/api.ts` service
- Replace `any` types with proper types
- Create form validation composables

### Week 2: High-Priority Improvements
- Split `Mapping.vue` into components
- Add localStorage encryption
- Add basic component tests (top 5 components)

### Week 3: Medium-Priority
- Create pagination/filter composables
- Add CSRF protection
- Add accessibility improvements

### Week 4: Documentation & Polish
- Add component JSDoc comments
- Expand test coverage to 40%+
- Performance optimization

---

## File-Level Recommendations

| File | Lines | Issues | Priority | Action |
|------|-------|--------|----------|--------|
| Mapping.vue | 1,355 | Too large, complex logic | CRITICAL | Split into 5 components |
| authStore.ts | 212 | `any` types, duplication | HIGH | Extract API calls |
| importStore.ts | 306 | `any` types, duplication | HIGH | Extract API calls |
| History.vue | 602 | Large component, many computed | MEDIUM | Extract composables |
| UploadSchema.vue | 320 | OK | LOW | Minor improvements |
| SelectTable.vue | 324 | Performance issues | MEDIUM | Add virtualization |
| UploadData.vue | 273 | OK | LOW | Minor improvements |
| Login.vue | 193 | Duplication | MEDIUM | Extract validation |
| Register.vue | 261 | Duplication | MEDIUM | Extract validation |
| dataValidation.ts | ~250 | Well-tested | OK | No changes |
| transformations.ts | ~400 | Well-tested | OK | No changes |

---

## Conclusion

**Overall Grade: B+ (Good)**

The codebase demonstrates solid Vue 3/TypeScript practices with strong utility test coverage. Main areas for improvement are:
1. Component size and organization
2. TypeScript strictness (eliminating `any` types)
3. Eliminating code duplication (especially API calls)
4. Adding component and store tests
5. Accessibility and security enhancements

Following the recommended refactoring timeline will bring the codebase to **A-grade** quality within 4 weeks.

