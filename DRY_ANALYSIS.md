# Comprehensive DRY (Don't Repeat Yourself) Analysis

## BACKEND (Go) VIOLATIONS

### 1. USER ID EXTRACTION AND VALIDATION
**Severity:** HIGH | **Duplicates:** 17+ occurrences

**Files:**
- `/home/user/db-importer/backend/internal/handler/auth_handler.go` (lines 247-257)
- `/home/user/db-importer/backend/internal/handler/import_handler.go` (lines 54-65, 106-116, 155-165, 195-206, 276-286, 310-320, 345-355)
- `/home/user/db-importer/backend/internal/handler/workflow_session_handler.go` (lines 38-48, 73-83, 129-139, 181-191, 237-247, 293-303, 332-342, 373-383)

**Code Pattern:**
```go
userID, ok := r.Context().Value("userID").(string)
if !ok {
    utils.Unauthorized(w, "Unauthorized")
    return
}

uid, err := utils.ParseUUID(userID)
if err != nil {
    utils.BadRequest(w, "Invalid user ID")
    return
}
```

**Recommendation:** Extract to a helper function in the utils package:
```go
// GetUserIDFromContext extracts and validates user ID from request context
func GetUserIDFromContext(r *http.Request, w http.ResponseWriter) (uuid.UUID, bool) {
    userID, ok := r.Context().Value("userID").(string)
    if !ok {
        Unauthorized(w, "Unauthorized")
        return uuid.UUID{}, false
    }
    
    uid, err := ParseUUID(userID)
    if err != nil {
        BadRequest(w, "Invalid user ID")
        return uuid.UUID{}, false
    }
    
    return uid, true
}
```

---

### 2. JSON REQUEST BODY PARSING AND VALIDATION
**Severity:** HIGH | **Duplicates:** 9 occurrences

**Files:**
- `/home/user/db-importer/backend/internal/handler/auth_handler.go` (lines 39-51, 81-93)
- `/home/user/db-importer/backend/internal/handler/import_handler.go` (lines 40-52)
- `/home/user/db-importer/backend/internal/handler/workflow_session_handler.go` (lines 114-126, 166-178, 222-234, 278-290)

**Code Pattern:**
```go
var req models.SomeRequest

// Parse request body
if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
    utils.BadRequest(w, "Invalid request body: "+err.Error())
    return
}

// Validate request
if err := utils.ValidateStruct(&req); err != nil {
    utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
    return
}
```

**Recommendation:** Create a handler utility function:
```go
// DecodeAndValidateJSON decodes and validates a JSON request body
func DecodeAndValidateJSON(r *http.Request, w http.ResponseWriter, v interface{}) error {
    if err := json.NewDecoder(r.Body).Decode(v); err != nil {
        BadRequest(w, "Invalid request body: "+err.Error())
        return err
    }
    
    if err := ValidateStruct(v); err != nil {
        RespondError(w, http.StatusBadRequest, ErrValidationFailed, err.Error(), nil)
        return err
    }
    
    return nil
}
```

---

### 3. COOKIE SETTING LOGIC (Access & Refresh Tokens)
**Severity:** MEDIUM | **Duplicates:** 6 occurrences

**Files:**
- `/home/user/db-importer/backend/internal/handler/auth_handler.go` (lines 111-137, 170-192, 217-238)

**Code Pattern:**
```go
accessCookie := &http.Cookie{
    Name:     "access_token",
    Value:    tokens.AccessToken,
    Path:     "/",
    HttpOnly: true,
    Secure:   r.TLS != nil,
    SameSite: http.SameSiteLaxMode,
    MaxAge:   15 * 60,
}
http.SetCookie(w, accessCookie)
```

**Recommendation:** Create cookie helper functions:
```go
// SetAccessTokenCookie sets the access token HTTP-only cookie
func SetAccessTokenCookie(w http.ResponseWriter, token string, isSecure bool) {
    cookie := &http.Cookie{
        Name:     "access_token",
        Value:    token,
        Path:     "/",
        HttpOnly: true,
        Secure:   isSecure,
        SameSite: http.SameSiteLaxMode,
        MaxAge:   15 * 60,
    }
    http.SetCookie(w, cookie)
}

// SetRefreshTokenCookie sets the refresh token HTTP-only cookie
func SetRefreshTokenCookie(w http.ResponseWriter, token string, isSecure bool, rememberMe bool) {
    maxAge := 24 * 60 * 60 // 1 day
    if rememberMe {
        maxAge = 72 * 60 * 60 // 3 days
    }
    
    cookie := &http.Cookie{
        Name:     "refresh_token",
        Value:    token,
        Path:     "/",
        HttpOnly: true,
        Secure:   isSecure,
        SameSite: http.SameSiteLaxMode,
        MaxAge:   maxAge,
    }
    http.SetCookie(w, cookie)
}

// ClearAuthCookies clears both auth cookies
func ClearAuthCookies(w http.ResponseWriter, isSecure bool) {
    for _, name := range []string{"access_token", "refresh_token"} {
        cookie := &http.Cookie{
            Name:     name,
            Value:    "",
            Path:     "/",
            HttpOnly: true,
            Secure:   isSecure,
            SameSite: http.SameSiteLaxMode,
            MaxAge:   -1,
        }
        http.SetCookie(w, cookie)
    }
}
```

---

### 4. QUERY PARAMETER PARSING FROM URL
**Severity:** MEDIUM | **Duplicates:** 4 occurrences

**Files:**
- `/home/user/db-importer/backend/internal/handler/import_handler.go` (lines 92-103, 141-152, 262-273)
- `/home/user/db-importer/backend/internal/handler/workflow_session_handler.go` (lines 357-364)

**Code Pattern:**
```go
importID := r.URL.Query().Get("id")
if importID == "" {
    utils.BadRequest(w, "Missing import ID")
    return
}

id, err := utils.ParseUUID(importID)
if err != nil {
    utils.BadRequest(w, "Invalid import ID")
    return
}
```

**Recommendation:** Create a helper function:
```go
// GetUUIDQueryParam extracts and validates a UUID query parameter
func GetUUIDQueryParam(r *http.Request, w http.ResponseWriter, paramName string, errorMsg string) (uuid.UUID, bool) {
    paramValue := r.URL.Query().Get(paramName)
    if paramValue == "" {
        BadRequest(w, "Missing "+paramName)
        return uuid.UUID{}, false
    }
    
    id, err := ParseUUID(paramValue)
    if err != nil {
        BadRequest(w, errorMsg)
        return uuid.UUID{}, false
    }
    
    return id, true
}
```

---

### 5. ROWS AFFECTED VALIDATION (Repository Layer)
**Severity:** MEDIUM | **Duplicates:** 6 occurrences

**Files:**
- `/home/user/db-importer/backend/internal/repository/user_repo.go` (lines 157-164)
- `/home/user/db-importer/backend/internal/repository/import_repo.go` (lines 192-200)
- `/home/user/db-importer/backend/internal/repository/workflow_session_repo.go` (lines 144-151, 168-177, 192-197, 213-221)

**Code Pattern:**
```go
result, err := r.db.Sqlx.ExecContext(ctx, query, args...)
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

rowsAffected, err := result.RowsAffected()
if err != nil {
    return fmt.Errorf("failed to get rows affected: %w", err)
}

if rowsAffected == 0 {
    return fmt.Errorf("resource not found")
}
```

**Recommendation:** Create a repository utility:
```go
// CheckRowsAffected validates that at least one row was affected
func CheckRowsAffected(result sql.Result, errorMsg string) error {
    rowsAffected, err := result.RowsAffected()
    if err != nil {
        return fmt.Errorf("failed to get rows affected: %w", err)
    }
    
    if rowsAffected == 0 {
        return fmt.Errorf(errorMsg)
    }
    
    return nil
}
```

---

### 6. SELECT STATEMENT WITH DUPLICATE COLUMNS
**Severity:** MEDIUM | **Duplicates:** Multiple pairs

**Files:**
- `/home/user/db-importer/backend/internal/repository/user_repo.go` (lines 59-64, 81-86)
  - GetByID and GetByEmail have identical SELECT columns

- `/home/user/db-importer/backend/internal/repository/import_repo.go` (lines 61-66, 84-89)
  - GetByID and GetByIDWithSQL - same query except GeneratedSQL column

**Code Pattern:**
```go
// GetByID
query := `
    SELECT id, email, password_hash, first_name, last_name, is_active,
           email_verified, created_at, updated_at, last_login_at
    FROM users
    WHERE id = $1 AND is_active = true
`

// GetByEmail - identical SELECT, different WHERE
query := `
    SELECT id, email, password_hash, first_name, last_name, is_active,
           email_verified, created_at, updated_at, last_login_at
    FROM users
    WHERE email = $1
`
```

**Recommendation:** Create helper to build SELECT lists:
```go
const userSelectColumns = `
    id, email, password_hash, first_name, last_name, is_active,
    email_verified, created_at, updated_at, last_login_at
`

// GetByID
query := fmt.Sprintf("SELECT %s FROM users WHERE id = $1 AND is_active = true", userSelectColumns)

// GetByEmail
query := fmt.Sprintf("SELECT %s FROM users WHERE email = $1", userSelectColumns)
```

---

### 7. PARSER DUPLICATE - Extract CREATE TABLE Statements
**Severity:** MEDIUM | **Duplicates:** 2 nearly identical functions

**Files:**
- `/home/user/db-importer/backend/parser/postgres.go` (lines 45-93)
  - `extractPostgreSQLCreateTableStatements()`
- `/home/user/db-importer/backend/parser/mysql.go` (lines 58-102)
  - `extractMySQLCreateTableStatements()`

**Code Pattern:**
Both functions have identical logic for extracting CREATE TABLE statements with parenthesis balancing. Only difference is the function name.

**Recommendation:** Extract to a single shared function:
```go
// extractCreateTableStatements extracts CREATE TABLE statements with proper parenthesis balancing
func extractCreateTableStatements(sqlContent string) []string {
    var statements []string
    var currentStmt strings.Builder
    inCreateTable := false
    parenDepth := 0
    
    lines := strings.Split(sqlContent, "\n")
    
    for _, line := range lines {
        upperLine := strings.ToUpper(strings.TrimSpace(line))
        
        if strings.Contains(upperLine, "CREATE TABLE") {
            if currentStmt.Len() > 0 {
                statements = append(statements, currentStmt.String())
            }
            currentStmt.Reset()
            inCreateTable = true
        }
        
        if inCreateTable {
            parenDepth += strings.Count(line, "(")
            parenDepth -= strings.Count(line, ")")
            
            if currentStmt.Len() > 0 {
                currentStmt.WriteString("\n")
            }
            currentStmt.WriteString(line)
            
            if parenDepth == 0 && strings.Contains(line, ")") {
                statements = append(statements, currentStmt.String())
                currentStmt.Reset()
                inCreateTable = false
            }
        }
    }
    
    if currentStmt.Len() > 0 {
        statements = append(statements, currentStmt.String())
    }
    
    return statements
}
```

Then replace both function implementations with calls to this shared function.

---

### 8. ERROR MESSAGE FOR "SESSION NOT FOUND"
**Severity:** LOW | **Duplicates:** 3 occurrences

**Files:**
- `/home/user/db-importer/backend/internal/handler/workflow_session_handler.go` (lines 196, 252, 308, 347, 397)

**Code Pattern:**
```go
if err.Error() == "no active session found" {
    utils.NotFound(w, "No active session found")
    return
}
```

**Recommendation:** Create custom error type in errors package:
```go
// errors/errors.go
var ErrNoActiveSession = errors.New("no active session found")
var ErrWorkflowSessionNotFound = errors.New("workflow session not found")
var ErrWorkflowSessionExpired = errors.New("workflow session not found or expired")
```

Then use in handlers:
```go
if errors.Is(err, errors.ErrNoActiveSession) {
    utils.NotFound(w, "No active session found")
    return
}
```

---

## FRONTEND (TypeScript/Vue) VIOLATIONS

### 1. FETCH API WRAPPER PATTERN
**Severity:** HIGH | **Duplicates:** 18+ occurrences

**Files:**
- `/home/user/db-importer/frontend/src/store/authStore.ts` (lines 40-45, 78-82, 114-118, 138-142, 159-163)
- `/home/user/db-importer/frontend/src/store/importStore.ts` (lines 99-106, 137-139, 167-169, 191-193, 215-218, 241-243, 265-268)
- `/home/user/db-importer/frontend/src/store/workflowSessionStore.ts` (lines 41-51, 84-93, 126-137, 167-177, 207-209, 312-315)

**Code Pattern:**
```typescript
const response = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    credentials: 'include',
    body: JSON.stringify({ ... })
})

if (!response.ok) {
    const errorData = await response.json().catch(() => ({ error: 'Failed to login' }))
    throw new Error(errorData.error || 'Failed to login')
}

const data = await response.json()
```

**Recommendation:** Create an API client service in `/home/user/db-importer/frontend/src/utils/apiClient.ts`:

```typescript
export interface ApiClientOptions {
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
    body?: any
    headers?: Record<string, string>
}

export interface ApiResponse<T> {
    data?: T
    error?: string
    message?: string
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

async function handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ error: 'Request failed' }))
        throw new Error(errorData.error || `HTTP ${response.status}`)
    }
    return response.json()
}

export async function apiCall<T>(
    endpoint: string,
    options: ApiClientOptions = {}
): Promise<ApiResponse<T>> {
    const {
        method = 'GET',
        body = undefined,
        headers = {}
    } = options
    
    try {
        const response = await fetch(`${API_URL}${endpoint}`, {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...headers
            },
            credentials: 'include',
            ...(body && { body: JSON.stringify(body) })
        })
        
        const data = await handleResponse<T>(response)
        return { data }
    } catch (error: any) {
        return { error: error.message }
    }
}

export async function apiGet<T>(endpoint: string): Promise<ApiResponse<T>> {
    return apiCall<T>(endpoint, { method: 'GET' })
}

export async function apiPost<T>(endpoint: string, body: any): Promise<ApiResponse<T>> {
    return apiCall<T>(endpoint, { method: 'POST', body })
}

export async function apiDelete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return apiCall<T>(endpoint, { method: 'DELETE' })
}
```

---

### 2. LOADING STATE AND ERROR HANDLING PATTERN
**Severity:** HIGH | **Duplicates:** 15+ occurrences

**Files:**
- All store files (authStore.ts, importStore.ts, workflowSessionStore.ts)

**Code Pattern:**
```typescript
async someAction() {
    this.loading = true
    this.error = null
    
    try {
        // ... API call
        // ... success handling
    } catch (error: any) {
        this.error = error.message || 'Failed to do something'
        throw error
    } finally {
        this.loading = false
    }
}
```

**Recommendation:** Create a mixin or helper function:

```typescript
// utils/storeHelpers.ts
export function createAsyncAction<T>(
    storeThis: any,
    action: () => Promise<T>,
    errorMessage: string = 'Action failed'
): Promise<T> {
    storeThis.loading = true
    storeThis.error = null
    
    try {
        return action()
    } catch (error: any) {
        storeThis.error = error.message || errorMessage
        throw error
    } finally {
        storeThis.loading = false
    }
}
```

Usage:
```typescript
async login(email: string, password: string) {
    return createAsyncAction(this, async () => {
        const { data, error } = await apiPost('/auth/login', { email, password })
        if (error) throw new Error(error)
        this.user = data.user
        return data
    }, 'Login failed')
}
```

---

### 3. API_URL DEFINITION DUPLICATION
**Severity:** MEDIUM | **Duplicates:** 3 occurrences

**Files:**
- `/home/user/db-importer/frontend/src/store/authStore.ts` (line 22)
- `/home/user/db-importer/frontend/src/store/importStore.ts` (line 79)
- `/home/user/db-importer/frontend/src/store/workflowSessionStore.ts` (line 14)

**Code Pattern:**
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'
```

**Recommendation:** Create a config file `/home/user/db-importer/frontend/src/config/api.ts`:
```typescript
export const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const API_ENDPOINTS = {
    AUTH: {
        LOGIN: '/auth/login',
        REGISTER: '/auth/register',
        LOGOUT: '/auth/logout',
        REFRESH: '/auth/refresh',
        ME: '/auth/me'
    },
    IMPORTS: {
        CREATE: '/api/v1/imports',
        LIST: '/api/v1/imports/list',
        GET: '/api/v1/imports/get',
        GET_SQL: '/api/v1/imports/sql',
        DELETE: '/api/v1/imports/delete',
        STATS: '/api/v1/imports/stats',
        DELETE_OLD: '/api/v1/imports/old'
    },
    WORKFLOW: {
        SESSION: '/api/v1/workflow/session',
        SCHEMA: '/api/v1/workflow/session/schema',
        TABLE: '/api/v1/workflow/session/table',
        DATA: '/api/v1/workflow/session/data',
        MAPPING: '/api/v1/workflow/session/mapping',
        EXTEND: '/api/v1/workflow/session/extend'
    }
}
```

---

### 4. AUTHENTICATION STATE RESET PATTERN
**Severity:** LOW | **Duplicates:** 3+ occurrences

**Files:**
- `/home/user/db-importer/frontend/src/store/authStore.ts` (lines 175-186, 149-153)

**Code Pattern:**
```typescript
// In checkAuth error handler
this.user = null
this.isAuthenticated = false
this.isGuest = false
this.initialized = true

// In logout
this.user = null
this.isAuthenticated = false
this.isGuest = true
this.error = null
```

**Recommendation:** Create a helper method:
```typescript
private resetAuthState(asGuest: boolean = false) {
    this.user = null
    this.isAuthenticated = false
    this.isGuest = asGuest
    this.error = null
}
```

---

### 5. AUTH STORE CHECK IN MULTIPLE STORE METHODS
**Severity:** MEDIUM | **Duplicates:** 8 occurrences

**Files:**
- `/home/user/db-importer/frontend/src/store/workflowSessionStore.ts` (lines 30-35, 74-78, 113-117, 157-161, 197-201, 240-246, 302-306)

**Code Pattern:**
```typescript
const authStore = useAuthStore()

if (!authStore.isAuthenticated) {
    return // Guest users rely on mappingStore's localStorage
}
```

**Recommendation:** Create a mixin or composable:
```typescript
// composables/useRequireAuth.ts
export function useRequireAuth() {
    const authStore = useAuthStore()
    
    if (!authStore.isAuthenticated) {
        return false
    }
    
    return true
}
```

Or use in methods:
```typescript
private requireAuth(): boolean {
    const authStore = useAuthStore()
    return authStore.isAuthenticated
}

async saveSchema(schemaContent: string, tables: Table[]): Promise<void> {
    if (!this.requireAuth()) return
    // ... rest of method
}
```

---

### 6. RESPONSE DATA EXTRACTION
**Severity:** LOW | **Duplicates:** Multiple occurrences

**Files:**
- Throughout store files

**Code Pattern:**
```typescript
const data = await response.json()
return data.data  // Double .data pattern
// or
this.user = data.data.user
```

**Recommendation:** Standardize response handling with a helper:
```typescript
export function extractResponseData<T>(response: ApiResponse<T>): T {
    if (!response.data) {
        throw new Error('No data in response')
    }
    return response.data
}
```

---

## SUMMARY TABLE

| Category | Type | Count | Severity |
|----------|------|-------|----------|
| User ID Extraction | Go Handler | 17+ | HIGH |
| JSON Parse/Validate | Go Handler | 9 | HIGH |
| Fetch API Calls | TypeScript Store | 18+ | HIGH |
| Loading State Pattern | TypeScript | 15+ | HIGH |
| Cookie Setting | Go Handler | 6 | MEDIUM |
| Rows Affected Check | Go Repo | 6 | MEDIUM |
| API_URL Definition | TypeScript | 3 | MEDIUM |
| Auth Check | TypeScript | 8 | MEDIUM |
| Query Param Parsing | Go Handler | 4 | MEDIUM |
| SELECT Columns | Go Repo | 2+ | MEDIUM |
| Parser Functions | Go | 2 | MEDIUM |
| Error Messages | Go Handler | 3-5 | LOW |
| Auth State Reset | TypeScript | 3+ | LOW |

**Total Violations Identified: 100+**

---

## IMPLEMENTATION PRIORITY

1. **IMMEDIATE (Week 1):**
   - Create API client wrapper for frontend
   - Extract user ID validation to helper
   - Create async action helper for stores

2. **SHORT TERM (Week 2-3):**
   - Consolidate parser functions
   - Create repository helpers
   - Centralize configuration

3. **MEDIUM TERM (Week 4):**
   - Refactor all handlers to use new utilities
   - Update all stores to use new helpers
   - Add custom error types

