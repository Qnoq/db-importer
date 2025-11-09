# 🚀 Guide d'Amélioration DB Importer

## 📋 Table des matières

1. [Refactoring Backend](#1-refactoring-backend-priorité-haute)
2. [Gestion des Secrets](#2-gestion-des-secrets-et-configuration)
3. [Documentation API avec Swagger](#3-documentation-api-avec-swagger)
4. [Optimisation Frontend](#4-optimisation-frontend)
5. [CI/CD avec GitHub Actions](#5-cicd-avec-github-actions)
6. [Scripts et Makefile](#6-amélioration-des-scripts-et-makefile)
7. [Monitoring et Observabilité](#7-monitoring-et-observabilité)
8. [Quick Wins Immédiats](#8-quick-wins-immédiats)
9. [Architecture Cible](#9-architecture-cible)
10. [Roadmap de Migration](#10-roadmap-de-migration)

---

## 1. Refactoring Backend (Priorité Haute)

### Structure actuelle vs Structure cible

Le `main.go` actuel fait 400+ lignes et mélange plusieurs responsabilités. Voici une architecture plus maintenable :

### Nouvelle structure des dossiers

```
backend/
├── cmd/
│   └── server/
│       └── main.go              # Point d'entrée minimal
├── internal/
│   ├── server/
│   │   ├── server.go            # Structure Server principale
│   │   ├── routes.go            # Configuration des routes
│   │   └── middleware.go        # Setup des middlewares
│   ├── handlers/
│   │   ├── base_handler.go      # Handler de base avec méthodes communes
│   │   ├── schema_handler.go    # Handlers pour parse-schema
│   │   ├── sql_handler.go       # Handlers pour generate-sql
│   │   └── validation_handler.go # Handlers pour validation
│   └── config/
│       └── loader.go             # Chargement centralisé de la config
```

### Nouveau main.go simplifié

```go
// cmd/server/main.go
package main

import (
    "log"
    "os"
    "os/signal"
    "syscall"

    "db-importer/internal/config"
    "db-importer/internal/server"
)

func main() {
    // Chargement de la configuration
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("Failed to load configuration: %v", err)
    }

    // Création et démarrage du serveur
    srv := server.New(cfg)
    
    // Gestion gracieuse de l'arrêt
    go func() {
        sigChan := make(chan os.Signal, 1)
        signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
        <-sigChan
        
        log.Println("Shutting down server...")
        srv.Shutdown()
    }()

    if err := srv.Start(); err != nil {
        log.Fatalf("Server failed: %v", err)
    }
}
```

### Structure Server

```go
// internal/server/server.go
package server

import (
    "context"
    "net/http"
    "time"
    
    "db-importer/internal/config"
    "db-importer/internal/database"
    "db-importer/internal/handlers"
    "db-importer/internal/logger"
    "db-importer/internal/middleware"
)

type Server struct {
    config      *config.Config
    db          *database.DB
    httpServer  *http.Server
    logger      *logger.Logger
    handlers    *handlers.Manager
    rateLimiter *middleware.RateLimiter
}

func New(cfg *config.Config) *Server {
    srv := &Server{
        config: cfg,
        logger: logger.New(cfg.EnableDebugLog),
    }
    
    // Initialisation conditionnelle de la DB
    if cfg.DatabaseURL != "" {
        srv.initDatabase()
    }
    
    // Initialisation des handlers
    srv.handlers = handlers.NewManager(srv.db, srv.logger, cfg)
    
    // Configuration du serveur HTTP
    srv.setupHTTPServer()
    
    return srv
}

func (s *Server) initDatabase() {
    dbConfig := database.Config{
        URL:             s.config.DatabaseURL,
        MaxOpenConns:    s.config.DBMaxOpenConns,
        MaxIdleConns:    s.config.DBMaxIdleConns,
        ConnMaxLifetime: s.config.DBConnMaxLifetime,
        ConnMaxIdleTime: s.config.DBConnMaxIdleTime,
    }
    
    db, err := database.NewDB(dbConfig)
    if err != nil {
        s.logger.Warn("Database connection failed, running in stateless mode", map[string]interface{}{
            "error": err.Error(),
        })
        return
    }
    
    s.db = db
    s.runMigrations()
}

func (s *Server) setupHTTPServer() {
    mux := http.NewServeMux()
    
    // Setup des routes
    s.setupRoutes(mux)
    
    // Chaîne de middlewares
    handler := s.applyMiddlewares(mux)
    
    s.httpServer = &http.Server{
        Addr:         ":" + s.config.Port,
        Handler:      handler,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }
}

func (s *Server) Start() error {
    s.logger.Info("Starting server", map[string]interface{}{
        "port":    s.config.Port,
        "version": s.config.Version,
    })
    
    return s.httpServer.ListenAndServe()
}

func (s *Server) Shutdown() {
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    
    if err := s.httpServer.Shutdown(ctx); err != nil {
        s.logger.Error("Server shutdown error", err)
    }
    
    if s.db != nil {
        s.db.Close()
    }
}
```

### Routes organisées

```go
// internal/server/routes.go
package server

import (
    "net/http"
)

func (s *Server) setupRoutes(mux *http.ServeMux) {
    // Routes publiques
    s.setupPublicRoutes(mux)
    
    // Routes d'authentification (si DB configurée)
    if s.db != nil {
        s.setupAuthRoutes(mux)
        s.setupProtectedRoutes(mux)
    }
}

func (s *Server) setupPublicRoutes(mux *http.ServeMux) {
    // Health check
    mux.HandleFunc("/health", s.handlers.Health)
    
    // Endpoints stateless avec rate limiting optionnel
    if s.config.RateLimitEnabled {
        mux.HandleFunc("/parse-schema", s.withRateLimit(s.handlers.ParseSchema))
        mux.HandleFunc("/generate-sql", s.withRateLimit(s.handlers.GenerateSQL))
        mux.HandleFunc("/validate", s.withRateLimit(s.handlers.Validate))
    } else {
        mux.HandleFunc("/parse-schema", s.handlers.ParseSchema)
        mux.HandleFunc("/generate-sql", s.handlers.GenerateSQL)
        mux.HandleFunc("/validate", s.handlers.Validate)
    }
}

func (s *Server) setupAuthRoutes(mux *http.ServeMux) {
    mux.HandleFunc("/auth/register", s.handlers.Auth.Register)
    mux.HandleFunc("/auth/login", s.handlers.Auth.Login)
    mux.HandleFunc("/auth/refresh", s.handlers.Auth.RefreshToken)
    mux.HandleFunc("/auth/logout", s.handlers.Auth.Logout)
}

func (s *Server) setupProtectedRoutes(mux *http.ServeMux) {
    // Routes protégées nécessitant authentification
    protected := []struct {
        path    string
        handler http.HandlerFunc
    }{
        {"/api/v1/imports", s.handlers.Import.CreateImport},
        {"/api/v1/imports/list", s.handlers.Import.ListImports},
        {"/api/v1/imports/get", s.handlers.Import.GetImport},
        {"/api/v1/imports/sql", s.handlers.Import.GetImportSQL},
        {"/api/v1/imports/delete", s.handlers.Import.DeleteImport},
        {"/api/v1/imports/stats", s.handlers.Import.GetStats},
    }
    
    for _, route := range protected {
        mux.HandleFunc(route.path, s.requireAuth(route.handler))
    }
}

func (s *Server) withRateLimit(next http.HandlerFunc) http.HandlerFunc {
    if s.rateLimiter == nil {
        return next
    }
    return s.rateLimiter.RateLimit(next)
}

func (s *Server) requireAuth(next http.HandlerFunc) http.HandlerFunc {
    return middleware.RequireAuth(s.config.JWTConfig())(next)
}
```

### Handler Manager centralisé

```go
// internal/handlers/manager.go
package handlers

import (
    "db-importer/internal/config"
    "db-importer/internal/database"
    "db-importer/internal/logger"
    "db-importer/internal/service"
    "db-importer/internal/repository"
)

type Manager struct {
    Schema     *SchemaHandler
    SQL        *SQLHandler
    Validation *ValidationHandler
    Auth       *AuthHandler
    Import     *ImportHandler
    Health     http.HandlerFunc
}

func NewManager(db *database.DB, logger *logger.Logger, cfg *config.Config) *Manager {
    m := &Manager{}
    
    // Handlers stateless (toujours disponibles)
    m.Schema = NewSchemaHandler(logger, cfg)
    m.SQL = NewSQLHandler(logger, cfg)
    m.Validation = NewValidationHandler(logger, cfg)
    m.Health = NewHealthHandler(db, cfg)
    
    // Handlers avec DB (si configurée)
    if db != nil {
        m.initAuthHandlers(db, logger, cfg)
        m.initImportHandlers(db, logger, cfg)
    }
    
    return m
}

func (m *Manager) initAuthHandlers(db *database.DB, logger *logger.Logger, cfg *config.Config) {
    userRepo := repository.NewUserRepository(db)
    tokenRepo := repository.NewRefreshTokenRepository(db)
    authService := service.NewAuthService(userRepo, tokenRepo, cfg.JWTConfig())
    m.Auth = NewAuthHandler(authService, logger)
}

func (m *Manager) initImportHandlers(db *database.DB, logger *logger.Logger, cfg *config.Config) {
    importRepo := repository.NewImportRepository(db)
    importService := service.NewImportService(importRepo)
    m.Import = NewImportHandler(importService, logger)
}
```

---

## 2. Gestion des Secrets et Configuration

### Configuration hiérarchique

```go
// internal/config/loader.go
package config

import (
    "os"
    "time"
    "github.com/joho/godotenv"
)

type Config struct {
    // Server
    Port        string
    Environment string // dev, staging, prod
    Version     string
    
    // Security
    JWTAccessSecret  string
    JWTRefreshSecret string
    JWTAccessExpiry  time.Duration
    JWTRefreshExpiry time.Duration
    
    // Database
    DatabaseURL       string
    DBMaxOpenConns    int
    DBMaxIdleConns    int
    DBConnMaxLifetime time.Duration
    DBConnMaxIdleTime time.Duration
    
    // Features
    RateLimitEnabled bool
    RateLimitGuest   int
    RateLimitAuth    int
    
    // Observability
    EnableDebugLog bool
    MetricsEnabled bool
}

func Load() (*Config, error) {
    // Chargement des .env selon l'environnement
    env := os.Getenv("APP_ENV")
    if env == "" {
        env = "development"
    }
    
    envFile := ".env." + env
    if _, err := os.Stat(envFile); err == nil {
        godotenv.Load(envFile)
    } else {
        godotenv.Load(".env")
    }
    
    cfg := &Config{
        Port:        getEnv("PORT", "8080"),
        Environment: env,
        Version:     getEnv("APP_VERSION", "1.0.0"),
        
        // Génération automatique des secrets s'ils n'existent pas
        JWTAccessSecret:  getOrGenerateSecret("JWT_ACCESS_SECRET"),
        JWTRefreshSecret: getOrGenerateSecret("JWT_REFRESH_SECRET"),
        JWTAccessExpiry:  getDuration("JWT_ACCESS_EXPIRY", 15*time.Minute),
        JWTRefreshExpiry: getDuration("JWT_REFRESH_EXPIRY", 7*24*time.Hour),
        
        DatabaseURL:       os.Getenv("DATABASE_URL"),
        DBMaxOpenConns:    getInt("DB_MAX_OPEN_CONNS", 25),
        DBMaxIdleConns:    getInt("DB_MAX_IDLE_CONNS", 5),
        DBConnMaxLifetime: getDuration("DB_CONN_MAX_LIFETIME", 5*time.Minute),
        DBConnMaxIdleTime: getDuration("DB_CONN_MAX_IDLE_TIME", 5*time.Minute),
        
        RateLimitEnabled: getBool("RATE_LIMIT_ENABLED", true),
        RateLimitGuest:   getInt("RATE_LIMIT_GUEST", 3),
        RateLimitAuth:    getInt("RATE_LIMIT_AUTH", 0),
        
        EnableDebugLog: getBool("DEBUG_LOG", env == "development"),
        MetricsEnabled: getBool("METRICS_ENABLED", env == "production"),
    }
    
    return cfg, cfg.Validate()
}

func (c *Config) Validate() error {
    if c.Port == "" {
        return fmt.Errorf("PORT is required")
    }
    
    if c.JWTAccessSecret == "" || c.JWTRefreshSecret == "" {
        return fmt.Errorf("JWT secrets are required")
    }
    
    return nil
}

func (c *Config) IsDevelopment() bool {
    return c.Environment == "development"
}

func (c *Config) IsProduction() bool {
    return c.Environment == "production"
}

func (c *Config) JWTConfig() utils.JWTConfig {
    return utils.JWTConfig{
        AccessSecret:  []byte(c.JWTAccessSecret),
        RefreshSecret: []byte(c.JWTRefreshSecret),
        AccessExpiry:  c.JWTAccessExpiry,
        RefreshExpiry: c.JWTRefreshExpiry,
    }
}

// Helpers
func getOrGenerateSecret(key string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    
    // Génération d'un secret aléatoire
    secret := generateRandomSecret(32)
    os.Setenv(key, secret)
    
    // Log warning en dev
    if os.Getenv("APP_ENV") == "development" {
        log.Printf("WARNING: Generated random %s - please set in .env for production", key)
    }
    
    return secret
}
```

### Script de setup sécurisé

```bash
#!/bin/bash
# scripts/setup-env.sh

set -e

ENV_FILE=${1:-.env.local}
EXAMPLE_FILE=".env.example"

# Fonction pour générer un secret
generate_secret() {
    openssl rand -base64 32
}

# Créer le fichier .env s'il n'existe pas
if [ ! -f "$ENV_FILE" ]; then
    echo "📝 Creating $ENV_FILE from $EXAMPLE_FILE..."
    cp "$EXAMPLE_FILE" "$ENV_FILE"
    
    # Générer les secrets JWT
    echo "🔐 Generating JWT secrets..."
    JWT_ACCESS=$(generate_secret)
    JWT_REFRESH=$(generate_secret)
    
    # Remplacer les placeholders
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|JWT_ACCESS_SECRET=.*|JWT_ACCESS_SECRET=$JWT_ACCESS|" "$ENV_FILE"
        sed -i '' "s|JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$JWT_REFRESH|" "$ENV_FILE"
    else
        # Linux
        sed -i "s|JWT_ACCESS_SECRET=.*|JWT_ACCESS_SECRET=$JWT_ACCESS|" "$ENV_FILE"
        sed -i "s|JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$JWT_REFRESH|" "$ENV_FILE"
    fi
    
    echo "✅ Environment file created: $ENV_FILE"
else
    echo "ℹ️  Environment file already exists: $ENV_FILE"
fi

# Vérifier les secrets manquants
check_secret() {
    local key=$1
    local value=$(grep "^$key=" "$ENV_FILE" | cut -d'=' -f2)
    
    if [ -z "$value" ] || [ "$value" == "changeme" ] || [ "$value" == "your-secret-here" ]; then
        echo "⚠️  WARNING: $key needs to be set in $ENV_FILE"
        return 1
    fi
    return 0
}

echo "🔍 Checking configuration..."
check_secret "JWT_ACCESS_SECRET"
check_secret "JWT_REFRESH_SECRET"
check_secret "DATABASE_URL"

echo "✅ Setup complete!"
```

---

## 3. Documentation API avec Swagger

### Installation et configuration

```go
// internal/docs/swagger.go
package docs

import (
    "github.com/swaggo/swag"
    _ "db-importer/docs" // Generated docs
)

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
    Version:     "1.0",
    Host:        "localhost:8080",
    BasePath:    "/",
    Schemes:     []string{"http", "https"},
    Title:       "DB Importer API",
    Description: "API for SQL schema parsing and data import generation",
}
```

### Annotations Swagger sur les handlers

```go
// internal/handlers/schema_handler.go
package handlers

import (
    "net/http"
    "db-importer/internal/parser"
)

type SchemaHandler struct {
    logger *logger.Logger
    config *config.Config
}

// ParseSchema godoc
// @Summary Parse SQL schema file
// @Description Upload a SQL dump file and extract table definitions
// @Tags Schema
// @Accept multipart/form-data
// @Produce json
// @Param file formData file true "SQL dump file (.sql)"
// @Success 200 {object} ParseSchemaResponse "Successfully parsed schema"
// @Failure 400 {object} ErrorResponse "Invalid file or format"
// @Failure 413 {object} ErrorResponse "File too large"
// @Router /parse-schema [post]
func (h *SchemaHandler) ParseSchema(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        h.respondError(w, http.StatusMethodNotAllowed, "Only POST method is allowed")
        return
    }
    
    // Limit upload size
    r.Body = http.MaxBytesReader(w, r.Body, h.config.MaxUploadSize)
    
    if err := r.ParseMultipartForm(h.config.MaxUploadSize); err != nil {
        h.respondError(w, http.StatusRequestEntityTooLarge, "File size exceeds limit")
        return
    }
    
    file, header, err := r.FormFile("file")
    if err != nil {
        h.respondError(w, http.StatusBadRequest, "File is required")
        return
    }
    defer file.Close()
    
    // Log operation
    h.logger.Info("Parsing schema file", map[string]interface{}{
        "filename": header.Filename,
        "size":     header.Size,
    })
    
    // Parse based on file extension or content
    tables, err := h.parseFile(file, header.Filename)
    if err != nil {
        h.respondError(w, http.StatusBadRequest, err.Error())
        return
    }
    
    h.respondJSON(w, http.StatusOK, ParseSchemaResponse{
        Tables: tables,
        Meta: ResponseMeta{
            Count: len(tables),
        },
    })
}

func (h *SchemaHandler) parseFile(file multipart.File, filename string) ([]Table, error) {
    content, err := io.ReadAll(file)
    if err != nil {
        return nil, fmt.Errorf("failed to read file: %w", err)
    }
    
    // Détection du type de SQL
    sqlType := detectSQLType(string(content))
    
    switch sqlType {
    case "mysql":
        return parser.ParseMySQL(string(content))
    case "postgresql":
        return parser.ParsePostgreSQL(string(content))
    default:
        return nil, fmt.Errorf("unable to detect SQL type")
    }
}

// Response types pour Swagger
type ParseSchemaResponse struct {
    Tables []Table      `json:"tables"`
    Meta   ResponseMeta `json:"meta"`
}

type ResponseMeta struct {
    Count     int    `json:"count"`
    Timestamp string `json:"timestamp"`
}
```

### Génération automatique

```bash
# Installation
go install github.com/swaggo/swag/cmd/swag@latest

# Génération
swag init -g cmd/server/main.go -o ./docs

# Makefile target
docs: ## Generate Swagger documentation
	@swag init -g cmd/server/main.go -o ./docs
	@echo "📚 Swagger docs generated at /docs"
```

### Endpoint Swagger UI

```go
// internal/server/routes.go
import (
    httpSwagger "github.com/swaggo/http-swagger"
)

func (s *Server) setupRoutes(mux *http.ServeMux) {
    // ... autres routes ...
    
    // Swagger UI (dev only)
    if s.config.IsDevelopment() {
        mux.Handle("/swagger/", httpSwagger.WrapHandler)
    }
}
```

---

## 4. Optimisation Frontend

### Composables réutilisables

```typescript
// frontend/src/composables/useImport.ts
import { ref, computed } from 'vue'
import { useMappingStore } from '@/store/mappingStore'
import { useAuthStore } from '@/store/authStore'
import { useToast } from 'primevue/usetoast'

export function useImport() {
  const mappingStore = useMappingStore()
  const authStore = useAuthStore()
  const toast = useToast()
  
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // Validation centralisée
  const validateMapping = () => {
    const errors: string[] = []
    
    if (!mappingStore.selectedTable) {
      errors.push('No table selected')
    }
    
    if (!mappingStore.hasExcelData) {
      errors.push('No data uploaded')
    }
    
    // Vérifier les champs NOT NULL
    const unmapped = mappingStore.unmappedRequiredFields
    if (unmapped.length > 0) {
      errors.push(`Required fields not mapped: ${unmapped.map(f => f.name).join(', ')}`)
    }
    
    return {
      valid: errors.length === 0,
      errors
    }
  }
  
  // Génération SQL
  const generateSQL = async (): Promise<string | null> => {
    const validation = validateMapping()
    
    if (!validation.valid) {
      toast.add({
        severity: 'error',
        summary: 'Validation Error',
        detail: validation.errors[0],
        life: 3000
      })
      return null
    }
    
    loading.value = true
    error.value = null
    
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/generate-sql`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(authStore.isAuthenticated && {
            'Authorization': `Bearer ${authStore.tokens?.accessToken}`
          })
        },
        body: JSON.stringify({
          table: mappingStore.selectedTable!.name,
          fields: mappingStore.selectedTable!.fields,
          mapping: mappingStore.mapping,
          rows: mappingStore.excelData
        })
      })
      
      if (!response.ok) {
        throw new Error(`Failed to generate SQL: ${response.statusText}`)
      }
      
      const sql = await response.text()
      
      toast.add({
        severity: 'success',
        summary: 'Success',
        detail: 'SQL generated successfully',
        life: 3000
      })
      
      return sql
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error'
      toast.add({
        severity: 'error',
        summary: 'Error',
        detail: error.value,
        life: 5000
      })
      return null
    } finally {
      loading.value = false
    }
  }
  
  // Auto-mapping intelligent
  const autoMap = () => {
    if (!mappingStore.selectedTable || !mappingStore.excelHeaders.length) {
      return
    }
    
    const mapping: Record<string, string> = {}
    let mapped = 0
    
    for (const header of mappingStore.excelHeaders) {
      const bestMatch = findBestFieldMatch(
        header,
        mappingStore.selectedTable.fields
      )
      
      if (bestMatch && bestMatch.score > 0.6) {
        mapping[header] = bestMatch.field.name
        mapped++
      }
    }
    
    mappingStore.setMapping(mapping)
    
    toast.add({
      severity: 'info',
      summary: 'Auto-mapping complete',
      detail: `Mapped ${mapped} of ${mappingStore.excelHeaders.length} columns`,
      life: 3000
    })
  }
  
  return {
    loading: computed(() => loading.value),
    error: computed(() => error.value),
    validateMapping,
    generateSQL,
    autoMap
  }
}

// Helper pour le matching de colonnes
function findBestFieldMatch(header: string, fields: Field[]) {
  let bestMatch = null
  let bestScore = 0
  
  const normalizedHeader = normalizeString(header)
  
  for (const field of fields) {
    const normalizedField = normalizeString(field.name)
    
    // Exact match
    if (normalizedHeader === normalizedField) {
      return { field, score: 1 }
    }
    
    // Calcul de similarité
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
}

function calculateSimilarity(str1: string, str2: string): number {
  // Implémentation simplifiée de Levenshtein
  if (str1 === str2) return 1
  if (str1.includes(str2) || str2.includes(str1)) return 0.8
  
  // Calcul basique de similarité
  const longer = str1.length > str2.length ? str1 : str2
  const shorter = str1.length > str2.length ? str2 : str1
  
  if (longer.length === 0) return 1.0
  
  const editDistance = levenshteinDistance(longer, shorter)
  return (longer.length - editDistance) / longer.length
}
```

### Store optimisé avec persistance

```typescript
// frontend/src/store/base.store.ts
import { watch } from 'vue'

export abstract class PersistentStore {
  protected abstract storageKey: string
  protected abstract version: string
  
  protected loadFromStorage<T>(): T | null {
    try {
      const stored = localStorage.getItem(this.storageKey)
      if (!stored) return null
      
      const parsed = JSON.parse(stored)
      
      if (parsed.version !== this.version) {
        console.warn(`Storage version mismatch for ${this.storageKey}`)
        this.clearStorage()
        return null
      }
      
      return parsed.data
    } catch (error) {
      console.error(`Failed to load ${this.storageKey}:`, error)
      return null
    }
  }
  
  protected saveToStorage<T>(data: T): void {
    try {
      const toStore = {
        version: this.version,
        timestamp: new Date().toISOString(),
        data
      }
      
      localStorage.setItem(this.storageKey, JSON.stringify(toStore))
    } catch (error) {
      console.error(`Failed to save ${this.storageKey}:`, error)
      
      // Si quota dépassé, nettoyer le storage
      if (error instanceof DOMException && error.name === 'QuotaExceededError') {
        this.clearOldData()
        // Réessayer
        try {
          localStorage.setItem(this.storageKey, JSON.stringify(toStore))
        } catch {
          // Abandon
        }
      }
    }
  }
  
  protected clearStorage(): void {
    localStorage.removeItem(this.storageKey)
  }
  
  private clearOldData(): void {
    const keys = Object.keys(localStorage)
    const appKeys = keys.filter(k => k.startsWith('db-importer-'))
    
    // Supprimer les plus anciennes entrées
    const entries = appKeys.map(key => {
      const item = localStorage.getItem(key)
      if (!item) return null
      
      try {
        const parsed = JSON.parse(item)
        return { key, timestamp: parsed.timestamp || 0 }
      } catch {
        return { key, timestamp: 0 }
      }
    }).filter(Boolean)
    
    entries.sort((a, b) => a!.timestamp - b!.timestamp)
    
    // Supprimer la moitié des entrées les plus anciennes
    const toRemove = Math.floor(entries.length / 2)
    for (let i = 0; i < toRemove; i++) {
      localStorage.removeItem(entries[i]!.key)
    }
  }
}
```

### Error Boundary pour Vue

```vue
<!-- frontend/src/components/ErrorBoundary.vue -->
<template>
  <div v-if="hasError" class="error-boundary">
    <div class="max-w-2xl mx-auto p-8 text-center">
      <div class="bg-red-50 border border-red-200 rounded-lg p-6">
        <i class="pi pi-exclamation-triangle text-5xl text-red-500 mb-4"></i>
        <h2 class="text-xl font-semibold text-gray-800 mb-2">
          Oops! Something went wrong
        </h2>
        <p class="text-gray-600 mb-4">
          {{ errorMessage }}
        </p>
        <div class="flex gap-3 justify-center">
          <Button 
            label="Reload Page" 
            icon="pi pi-refresh" 
            @click="reload"
            severity="danger"
          />
          <Button 
            label="Go Home" 
            icon="pi pi-home" 
            @click="goHome"
            text
          />
        </div>
        
        <details v-if="isDev" class="mt-4 text-left">
          <summary class="cursor-pointer text-sm text-gray-500">
            Technical details
          </summary>
          <pre class="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto">{{ errorDetails }}</pre>
        </details>
      </div>
    </div>
  </div>
  <slot v-else />
</template>

<script setup lang="ts">
import { ref, onErrorCaptured } from 'vue'
import { useRouter } from 'vue-router'
import Button from 'primevue/button'

const router = useRouter()
const hasError = ref(false)
const errorMessage = ref('An unexpected error occurred')
const errorDetails = ref('')
const isDev = import.meta.env.DEV

onErrorCaptured((error: Error) => {
  hasError.value = true
  errorMessage.value = error.message || 'Unknown error'
  errorDetails.value = error.stack || ''
  
  // Log to console in dev
  if (isDev) {
    console.error('Error caught by boundary:', error)
  }
  
  // Send to monitoring in production
  if (!isDev && window.Sentry) {
    window.Sentry.captureException(error)
  }
  
  return false // Prevent propagation
})

const reload = () => {
  window.location.reload()
}

const goHome = () => {
  hasError.value = false
  router.push('/')
}
</script>
```

---

## 5. CI/CD avec GitHub Actions

### Workflow principal

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  GO_VERSION: '1.21'
  NODE_VERSION: '20'
  DOCKER_REGISTRY: ghcr.io

jobs:
  # === Backend Jobs ===
  backend-lint:
    name: Backend Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ env.GO_VERSION }}
          cache: true
          cache-dependency-path: backend/go.sum
      
      - name: Install tools
        working-directory: backend
        run: |
          go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
          go install golang.org/x/tools/cmd/goimports@latest
      
      - name: Run gofmt
        working-directory: backend
        run: |
          if [ "$(gofmt -s -l . | wc -l)" -gt 0 ]; then
            echo "Code is not formatted. Run 'gofmt -s -w .' to fix."
            gofmt -s -d .
            exit 1
          fi
      
      - name: Run golangci-lint
        working-directory: backend
        run: golangci-lint run --timeout 5m
  
  backend-build:
    name: Backend Build
    runs-on: ubuntu-latest
    needs: backend-lint
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ env.GO_VERSION }}
          cache: true
          cache-dependency-path: backend/go.sum
      
      - name: Build
        working-directory: backend
        run: |
          CGO_ENABLED=0 go build -v -o db-importer ./cmd/server
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: backend-binary
          path: backend/db-importer
  
  # === Frontend Jobs ===
  frontend-lint:
    name: Frontend Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: frontend
        run: npm ci
      
      - name: Run ESLint
        working-directory: frontend
        run: npm run lint
      
      - name: Type check
        working-directory: frontend
        run: npm run type-check
  
  frontend-build:
    name: Frontend Build
    runs-on: ubuntu-latest
    needs: frontend-lint
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: frontend
        run: npm ci
      
      - name: Build
        working-directory: frontend
        run: npm run build
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: frontend-dist
          path: frontend/dist
  
  # === Docker Build ===
  docker:
    name: Docker Build & Push
    runs-on: ubuntu-latest
    needs: [backend-build, frontend-build]
    if: github.event_name == 'push' || github.event_name == 'release'
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{date 'YYYYMMDD'}}-
      
      - name: Build and push Backend
        uses: docker/build-push-action@v5
        with:
          context: backend
          push: true
          tags: ${{ steps.meta.outputs.tags }}-backend
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Build and push Frontend
        uses: docker/build-push-action@v5
        with:
          context: frontend
          push: true
          tags: ${{ steps.meta.outputs.tags }}-frontend
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
  
  # === Deployment ===
  deploy:
    name: Deploy to VPS
    runs-on: ubuntu-latest
    needs: docker
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /opt/db-importer
            git pull origin main
            docker-compose pull
            docker-compose up -d
            docker system prune -af
```

---

## 6. Amélioration des Scripts et Makefile

### Script de développement unifié

```bash
#!/bin/bash
# scripts/dev.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"
BACKEND_LOG="backend.log"
FRONTEND_LOG="frontend.log"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🛑 Stopping all processes...${NC}"
    
    # Kill all child processes
    pkill -P $$ 2>/dev/null || true
    
    # Kill specific processes
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ All processes stopped${NC}"
    exit 0
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# Check dependencies
check_deps() {
    echo -e "${YELLOW}🔍 Checking dependencies...${NC}"
    
    # Check Go
    if ! command -v go &> /dev/null; then
        echo -e "${RED}❌ Go is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Go $(go version | cut -d' ' -f3)${NC}"
    
    # Check Node
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Node $(node --version)${NC}"
    
    # Check Air
    if ! command -v air &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Air for hot reload...${NC}"
        go install github.com/cosmtrek/air@latest
    fi
    echo -e "${GREEN}✓ Air installed${NC}"
}

# Setup environment
setup_env() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"
    
    # Create .env symlinks if they don't exist
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        ln -sf ../.env.local "$BACKEND_DIR/.env"
        echo -e "${GREEN}✓ Backend .env linked${NC}"
    fi
    
    if [ ! -f "$FRONTEND_DIR/.env" ]; then
        ln -sf ../.env.local "$FRONTEND_DIR/.env"
        echo -e "${GREEN}✓ Frontend .env linked${NC}"
    fi
    
    # Install dependencies if needed
    if [ ! -d "$BACKEND_DIR/vendor" ]; then
        echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
        (cd "$BACKEND_DIR" && go mod download)
    fi
    
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        echo -e "${YELLOW}📦 Installing frontend dependencies...${NC}"
        (cd "$FRONTEND_DIR" && npm install)
    fi
}

# Start backend
start_backend() {
    echo -e "${YELLOW}🚀 Starting backend with hot reload...${NC}"
    
    cd "$BACKEND_DIR"
    
    # Create .air.toml if it doesn't exist
    if [ ! -f ".air.toml" ]; then
        cat > .air.toml << 'EOF'
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main ./cmd/server"
  bin = "tmp/main"
  full_bin = "./tmp/main"
  include_ext = ["go", "tpl", "tmpl", "html"]
  exclude_dir = ["assets", "tmp", "vendor", "frontend"]
  include_dir = []
  exclude_file = []
  delay = 1000
  stop_on_error = true
  log = "air_errors.log"

[log]
  time = true

[color]
  main = "magenta"
  watcher = "cyan"
  build = "yellow"
  runner = "green"
EOF
    fi
    
    air > "../$BACKEND_LOG" 2>&1 &
    BACKEND_PID=$!
    cd ..
    
    echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
}

# Start frontend
start_frontend() {
    echo -e "${YELLOW}🚀 Starting frontend with hot reload...${NC}"
    
    cd "$FRONTEND_DIR"
    npm run dev > "../$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    cd ..
    
    echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
}

# Monitor logs
monitor_logs() {
    echo -e "\n${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Development environment ready!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "📱 Frontend: ${YELLOW}http://localhost:5173${NC}"
    echo -e "🔧 Backend:  ${YELLOW}http://localhost:8080${NC}"
    echo -e "📊 Health:   ${YELLOW}http://localhost:8080/health${NC}"
    echo -e "\n${YELLOW}📝 Logs:${NC}"
    echo -e "  Backend:  ${YELLOW}tail -f $BACKEND_LOG${NC}"
    echo -e "  Frontend: ${YELLOW}tail -f $FRONTEND_LOG${NC}"
    echo -e "\n${YELLOW}Press Ctrl+C to stop all services${NC}\n"
    
    # Tail frontend logs by default
    tail -f "$FRONTEND_LOG"
}

# Main execution
main() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       DB Importer Dev Environment      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    
    check_deps
    setup_env
    start_backend
    
    # Wait a bit for backend to start
    sleep 2
    
    start_frontend
    
    # Wait for services to be ready
    sleep 3
    
    monitor_logs
}

# Run main function
main
```

### Makefile amélioré

```makefile
# Makefile racine
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Variables
BACKEND_DIR := backend
FRONTEND_DIR := frontend
DOCKER_REGISTRY := ghcr.io
IMAGE_NAME := $(DOCKER_REGISTRY)/$(shell git config --get remote.origin.url | sed 's/.*://;s/.git$$//')
VERSION := $(shell git describe --tags --always --dirty)

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m # No Color

.PHONY: help
help: ## Show this help message
	@echo -e "$(GREEN)DB Importer - Available commands$(NC)"
	@echo -e "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Development

.PHONY: dev
dev: ## Start development environment with hot reload
	@./scripts/dev.sh

.PHONY: stop
stop: ## Stop all development services
	@echo -e "$(YELLOW)Stopping services...$(NC)"
	@pkill -f "air" || true
	@pkill -f "npm run dev" || true
	@echo -e "$(GREEN)✓ Services stopped$(NC)"

.PHONY: install
install: ## Install all dependencies
	@echo -e "$(YELLOW)Installing backend dependencies...$(NC)"
	@cd $(BACKEND_DIR) && go mod download
	@echo -e "$(YELLOW)Installing frontend dependencies...$(NC)"
	@cd $(FRONTEND_DIR) && npm ci
	@echo -e "$(GREEN)✓ Dependencies installed$(NC)"

.PHONY: clean
clean: ## Clean build artifacts and temp files
	@echo -e "$(YELLOW)Cleaning...$(NC)"
	@rm -rf $(BACKEND_DIR)/tmp $(BACKEND_DIR)/vendor
	@rm -rf $(FRONTEND_DIR)/dist $(FRONTEND_DIR)/node_modules
	@rm -f *.log
	@echo -e "$(GREEN)✓ Cleaned$(NC)"

##@ Backend

.PHONY: backend-run
backend-run: ## Run backend server
	@cd $(BACKEND_DIR) && go run cmd/server/main.go

.PHONY: backend-build
backend-build: ## Build backend binary
	@echo -e "$(YELLOW)Building backend...$(NC)"
	@cd $(BACKEND_DIR) && CGO_ENABLED=0 go build -ldflags="-s -w" -o db-importer cmd/server/main.go
	@echo -e "$(GREEN)✓ Backend built$(NC)"

.PHONY: backend-lint
backend-lint: ## Lint backend code
	@echo -e "$(YELLOW)Linting backend...$(NC)"
	@cd $(BACKEND_DIR) && golangci-lint run
	@echo -e "$(GREEN)✓ Backend linted$(NC)"

.PHONY: backend-fmt
backend-fmt: ## Format backend code
	@echo -e "$(YELLOW)Formatting backend...$(NC)"
	@cd $(BACKEND_DIR) && go fmt ./...
	@cd $(BACKEND_DIR) && goimports -w .
	@echo -e "$(GREEN)✓ Backend formatted$(NC)"

##@ Frontend

.PHONY: frontend-run
frontend-run: ## Run frontend dev server
	@cd $(FRONTEND_DIR) && npm run dev

.PHONY: frontend-build
frontend-build: ## Build frontend for production
	@echo -e "$(YELLOW)Building frontend...$(NC)"
	@cd $(FRONTEND_DIR) && npm run build
	@echo -e "$(GREEN)✓ Frontend built$(NC)"

.PHONY: frontend-lint
frontend-lint: ## Lint frontend code
	@echo -e "$(YELLOW)Linting frontend...$(NC)"
	@cd $(FRONTEND_DIR) && npm run lint
	@echo -e "$(GREEN)✓ Frontend linted$(NC)"

.PHONY: frontend-type-check
frontend-type-check: ## Type check frontend code
	@echo -e "$(YELLOW)Type checking frontend...$(NC)"
	@cd $(FRONTEND_DIR) && npm run type-check
	@echo -e "$(GREEN)✓ Frontend type checked$(NC)"

##@ Database

.PHONY: migrate-up
migrate-up: ## Run database migrations
	@echo -e "$(YELLOW)Running migrations...$(NC)"
	@cd $(BACKEND_DIR) && go run cmd/migrate/main.go up
	@echo -e "$(GREEN)✓ Migrations completed$(NC)"

.PHONY: migrate-down
migrate-down: ## Rollback last migration
	@echo -e "$(YELLOW)Rolling back migration...$(NC)"
	@cd $(BACKEND_DIR) && go run cmd/migrate/main.go down
	@echo -e "$(GREEN)✓ Rollback completed$(NC)"

.PHONY: migrate-create
migrate-create: ## Create new migration (use: make migrate-create name=add_users_table)
	@if [ -z "$(name)" ]; then \
		echo -e "$(RED)Error: Please provide a migration name$(NC)"; \
		echo "Usage: make migrate-create name=your_migration_name"; \
		exit 1; \
	fi
	@echo -e "$(YELLOW)Creating migration: $(name)$(NC)"
	@cd $(BACKEND_DIR) && go run cmd/migrate/main.go create $(name)
	@echo -e "$(GREEN)✓ Migration created$(NC)"

##@ Docker

.PHONY: docker-build
docker-build: ## Build Docker images
	@echo -e "$(YELLOW)Building Docker images...$(NC)"
	@docker build -t $(IMAGE_NAME)-backend:$(VERSION) $(BACKEND_DIR)
	@docker build -t $(IMAGE_NAME)-frontend:$(VERSION) $(FRONTEND_DIR)
	@echo -e "$(GREEN)✓ Docker images built$(NC)"

.PHONY: docker-push
docker-push: docker-build ## Push Docker images to registry
	@echo -e "$(YELLOW)Pushing Docker images...$(NC)"
	@docker push $(IMAGE_NAME)-backend:$(VERSION)
	@docker push $(IMAGE_NAME)-frontend:$(VERSION)
	@echo -e "$(GREEN)✓ Docker images pushed$(NC)"

.PHONY: docker-up
docker-up: ## Start services with Docker Compose
	@docker-compose up -d

.PHONY: docker-down
docker-down: ## Stop Docker Compose services
	@docker-compose down

.PHONY: docker-logs
docker-logs: ## Show Docker Compose logs
	@docker-compose logs -f

##@ Deployment

.PHONY: deploy
deploy: ## Deploy to production VPS
	@echo -e "$(YELLOW)Deploying to production...$(NC)"
	@ssh $(VPS_USER)@$(VPS_HOST) "cd /opt/db-importer && git pull && docker-compose pull && docker-compose up -d"
	@echo -e "$(GREEN)✓ Deployed to production$(NC)"

##@ Documentation

.PHONY: docs
docs: ## Generate API documentation with Swagger
	@echo -e "$(YELLOW)Generating API documentation...$(NC)"
	@cd $(BACKEND_DIR) && swag init -g cmd/server/main.go -o ./docs
	@echo -e "$(GREEN)✓ API docs generated at /docs$(NC)"

##@ Utilities

.PHONY: setup
setup: ## Initial project setup
	@echo -e "$(YELLOW)Setting up project...$(NC)"
	@./scripts/setup-env.sh
	@$(MAKE) install
	@echo -e "$(GREEN)✓ Project setup complete$(NC)"

.PHONY: check
check: backend-lint frontend-lint frontend-type-check ## Run all checks
	@echo -e "$(GREEN)✓ All checks passed$(NC)"

.PHONY: fmt
fmt: backend-fmt ## Format all code
	@echo -e "$(GREEN)✓ Code formatted$(NC)"

.PHONY: logs-backend
logs-backend: ## Show backend logs
	@tail -f backend.log

.PHONY: logs-frontend
logs-frontend: ## Show frontend logs
	@tail -f frontend.log
```

---

## 7. Monitoring et Observabilité

### Métriques avec Prometheus

```go
// internal/metrics/metrics.go
package metrics

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

var (
    // HTTP metrics
    HTTPRequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    HTTPRequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request latencies in seconds",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "endpoint"},
    )
    
    // Business metrics
    ImportsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "imports_total",
            Help: "Total number of imports",
        },
        []string{"table", "status"},
    )
    
    RowsImported = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "rows_imported_total",
            Help: "Total number of rows imported",
        },
        []string{"table"},
    )
    
    SQLGenerationDuration = promauto.NewHistogram(
        prometheus.HistogramOpts{
            Name:    "sql_generation_duration_seconds",
            Help:    "Time taken to generate SQL",
            Buckets: []float64{0.1, 0.5, 1, 2, 5, 10},
        },
    )
    
    // System metrics
    DBConnectionsActive = promauto.NewGauge(
        prometheus.GaugeOpts{
            Name: "db_connections_active",
            Help: "Number of active database connections",
        },
    )
)
```

### Middleware de métriques

```go
// internal/middleware/metrics.go
package middleware

import (
    "net/http"
    "strconv"
    "time"
    
    "db-importer/internal/metrics"
)

func MetricsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        // Wrap ResponseWriter to capture status code
        wrapped := &responseWriter{
            ResponseWriter: w,
            statusCode:    http.StatusOK,
        }
        
        // Process request
        next.ServeHTTP(wrapped, r)
        
        // Record metrics
        duration := time.Since(start).Seconds()
        status := strconv.Itoa(wrapped.statusCode)
        
        metrics.HTTPRequestsTotal.WithLabelValues(
            r.Method,
            r.URL.Path,
            status,
        ).Inc()
        
        metrics.HTTPRequestDuration.WithLabelValues(
            r.Method,
            r.URL.Path,
        ).Observe(duration)
    })
}

type responseWriter struct {
    http.ResponseWriter
    statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}
```

### Structured Logging amélioré

```go
// internal/logger/logger.go
package logger

import (
    "encoding/json"
    "fmt"
    "os"
    "runtime"
    "time"
)

type Level int

const (
    DEBUG Level = iota
    INFO
    WARN
    ERROR
    FATAL
)

type Logger struct {
    level  Level
    fields map[string]interface{}
}

func New(debug bool) *Logger {
    level := INFO
    if debug {
        level = DEBUG
    }
    
    return &Logger{
        level:  level,
        fields: make(map[string]interface{}),
    }
}

func (l *Logger) WithFields(fields map[string]interface{}) *Logger {
    newLogger := &Logger{
        level:  l.level,
        fields: make(map[string]interface{}),
    }
    
    // Copy existing fields
    for k, v := range l.fields {
        newLogger.fields[k] = v
    }
    
    // Add new fields
    for k, v := range fields {
        newLogger.fields[k] = v
    }
    
    return newLogger
}

func (l *Logger) log(level Level, msg string, err error) {
    if level < l.level {
        return
    }
    
    entry := map[string]interface{}{
        "timestamp": time.Now().UTC().Format(time.RFC3339),
        "level":     levelString(level),
        "message":   msg,
    }
    
    // Add fields
    for k, v := range l.fields {
        entry[k] = v
    }
    
    // Add error if present
    if err != nil {
        entry["error"] = err.Error()
    }
    
    // Add caller information for errors
    if level >= ERROR {
        _, file, line, _ := runtime.Caller(2)
        entry["caller"] = fmt.Sprintf("%s:%d", file, line)
    }
    
    // Output JSON
    json.NewEncoder(os.Stdout).Encode(entry)
}

func (l *Logger) Debug(msg string) {
    l.log(DEBUG, msg, nil)
}

func (l *Logger) Info(msg string) {
    l.log(INFO, msg, nil)
}

func (l *Logger) Warn(msg string) {
    l.log(WARN, msg, nil)
}

func (l *Logger) Error(msg string, err error) {
    l.log(ERROR, msg, err)
}

func (l *Logger) Fatal(msg string, err error) {
    l.log(FATAL, msg, err)
    os.Exit(1)
}

func levelString(level Level) string {
    switch level {
    case DEBUG:
        return "debug"
    case INFO:
        return "info"
    case WARN:
        return "warn"
    case ERROR:
        return "error"
    case FATAL:
        return "fatal"
    default:
        return "unknown"
    }
}
```

---

## 8. Quick Wins Immédiats

### Validation SQL sécurisée

```typescript
// frontend/src/utils/sqlValidation.ts
export interface ValidationResult {
  valid: boolean
  warnings: string[]
  errors: string[]
}

export function validateSQL(sql: string): ValidationResult {
  const result: ValidationResult = {
    valid: true,
    warnings: [],
    errors: []
  }
  
  // Dangerous keywords that should not be in generated INSERT statements
  const dangerousKeywords = [
    'DROP', 'DELETE', 'TRUNCATE', 'ALTER', 
    'CREATE', 'GRANT', 'REVOKE', 'EXEC', 'EXECUTE'
  ]
  
  const upperSQL = sql.toUpperCase()
  
  for (const keyword of dangerousKeywords) {
    if (upperSQL.includes(keyword)) {
      result.errors.push(`Dangerous SQL detected: ${keyword}`)
      result.valid = false
    }
  }
  
  // Check for SQL injection patterns
  const injectionPatterns = [
    /;\s*DROP/i,
    /;\s*DELETE/i,
    /--\s*$/gm,
    /\/\*.*\*\//,
    /\bUNION\b.*\bSELECT\b/i,
    /\bOR\b.*=.*\bOR\b/i
  ]
  
  for (const pattern of injectionPatterns) {
    if (pattern.test(sql)) {
      result.errors.push('Potential SQL injection pattern detected')
      result.valid = false
    }
  }
  
  // Warnings for potentially problematic content
  if (sql.length > 1000000) {
    result.warnings.push('SQL file is very large (>1MB), may cause performance issues')
  }
  
  const lineCount = sql.split('\n').length
  if (lineCount > 10000) {
    result.warnings.push(`SQL contains ${lineCount} lines, consider splitting into smaller batches`)
  }
  
  return result
}

export function sanitizeValue(value: any, fieldType: string): string {
  if (value === null || value === undefined || value === '') {
    return 'NULL'
  }
  
  // Handle different types
  switch (fieldType.toLowerCase()) {
    case 'int':
    case 'integer':
    case 'bigint':
    case 'smallint':
    case 'tinyint':
    case 'decimal':
    case 'numeric':
    case 'float':
    case 'double':
    case 'real':
      // Ensure it's a valid number
      const num = Number(value)
      if (isNaN(num)) {
        throw new Error(`Invalid number: ${value}`)
      }
      return num.toString()
    
    case 'boolean':
    case 'bool':
    case 'bit':
      return value ? '1' : '0'
    
    default:
      // String types - escape single quotes
      const str = String(value)
      const escaped = str.replace(/'/g, "''")
      return `'${escaped}'`
  }
}
```

### Rate limiting amélioré

```go
// internal/middleware/ratelimit.go
package middleware

import (
    "fmt"
    "net/http"
    "sync"
    "time"
    
    "golang.org/x/time/rate"
)

type RateLimiter struct {
    visitors map[string]*visitor
    mu       sync.RWMutex
    
    guestRate  rate.Limit
    guestBurst int
    authRate   rate.Limit
    authBurst  int
}

type visitor struct {
    limiter  *rate.Limiter
    lastSeen time.Time
}

func NewRateLimiter(guestRequests, guestWindow, authRequests, authWindow int) *RateLimiter {
    rl := &RateLimiter{
        visitors: make(map[string]*visitor),
    }
    
    // Configure guest limits
    if guestRequests > 0 && guestWindow > 0 {
        rl.guestRate = rate.Limit(float64(guestRequests) / float64(guestWindow))
        rl.guestBurst = guestRequests
    } else {
        rl.guestRate = rate.Inf
        rl.guestBurst = 0
    }
    
    // Configure auth limits
    if authRequests > 0 && authWindow > 0 {
        rl.authRate = rate.Limit(float64(authRequests) / float64(authWindow))
        rl.authBurst = authRequests
    } else {
        rl.authRate = rate.Inf
        rl.authBurst = 0
    }
    
    // Start cleanup routine
    go rl.cleanupVisitors()
    
    return rl
}

func (rl *RateLimiter) getVisitor(key string, isAuth bool) *rate.Limiter {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    v, exists := rl.visitors[key]
    if !exists {
        var limiter *rate.Limiter
        if isAuth {
            limiter = rate.NewLimiter(rl.authRate, rl.authBurst)
        } else {
            limiter = rate.NewLimiter(rl.guestRate, rl.guestBurst)
        }
        
        rl.visitors[key] = &visitor{
            limiter:  limiter,
            lastSeen: time.Now(),
        }
        return limiter
    }
    
    v.lastSeen = time.Now()
    return v.limiter
}

func (rl *RateLimiter) RateLimit(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Check if user is authenticated
        userID := r.Context().Value("userID")
        isAuth := userID != nil
        
        // Get identifier
        var key string
        if isAuth {
            key = fmt.Sprintf("user:%v", userID)
        } else {
            key = fmt.Sprintf("ip:%s", getIP(r))
        }
        
        // Get limiter
        limiter := rl.getVisitor(key, isAuth)
        
        // Check rate limit
        if !limiter.Allow() {
            rl.sendRateLimitResponse(w, isAuth)
            return
        }
        
        next(w, r)
    }
}

func (rl *RateLimiter) sendRateLimitResponse(w http.ResponseWriter, isAuth bool) {
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", rl.guestBurst))
    w.Header().Set("X-RateLimit-Remaining", "0")
    w.Header().Set("X-RateLimit-Reset", fmt.Sprintf("%d", time.Now().Add(time.Hour).Unix()))
    
    w.WriteHeader(http.StatusTooManyRequests)
    
    message := "Rate limit exceeded. Please try again later."
    if !isAuth {
        message = "Rate limit exceeded for guest users (3 requests per day). Please sign in for unlimited access."
    }
    
    json.NewEncoder(w).Encode(map[string]string{
        "error": message,
    })
}

func (rl *RateLimiter) cleanupVisitors() {
    for {
        time.Sleep(time.Minute)
        
        rl.mu.Lock()
        for key, v := range rl.visitors {
            if time.Since(v.lastSeen) > time.Hour {
                delete(rl.visitors, key)
            }
        }
        rl.mu.Unlock()
    }
}

func getIP(r *http.Request) string {
    // Check X-Forwarded-For header
    if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
        return xff
    }
    
    // Check X-Real-IP header
    if xri := r.Header.Get("X-Real-IP"); xri != "" {
        return xri
    }
    
    // Fall back to RemoteAddr
    return r.RemoteAddr
}
```

---

## 9. Architecture Cible

### Vision globale de l'architecture refactorée

```
db-importer/
├── backend/
│   ├── cmd/
│   │   ├── server/          # API server entry point
│   │   ├── migrate/         # Migration tool
│   │   └── cli/             # CLI tools
│   ├── internal/
│   │   ├── server/          # Server configuration
│   │   ├── config/          # Configuration management
│   │   ├── handlers/        # HTTP handlers
│   │   ├── services/        # Business logic
│   │   ├── repositories/    # Data access layer
│   │   ├── middleware/      # HTTP middleware
│   │   ├── database/        # Database connection
│   │   ├── parser/          # SQL parsing
│   │   ├── generator/       # SQL generation
│   │   ├── validator/       # Data validation
│   │   ├── metrics/         # Prometheus metrics
│   │   └── logger/          # Structured logging
│   ├── pkg/                 # Public packages
│   │   └── utils/           # Shared utilities
│   ├── migrations/          # SQL migrations
│   ├── docs/                # Swagger docs
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── composables/     # Vue composables
│   │   ├── components/      # Reusable components
│   │   ├── pages/           # Page components
│   │   ├── store/           # Pinia stores
│   │   ├── router/          # Vue Router
│   │   ├── utils/           # Utility functions
│   │   └── types/           # TypeScript types
│   ├── public/
│   ├── Dockerfile
│   └── nginx.conf
│
├── scripts/                 # Development & deployment scripts
├── .github/                 # GitHub Actions workflows
└── docs/                    # Project documentation
```

---

## 10. Roadmap de Migration

### Phase 1 : Fondations (1 semaine)

**Objectif** : Refactoring du backend et amélioration de la structure

- [ ] Créer la nouvelle structure de dossiers
- [ ] Extraire le code de `main.go` vers les modules appropriés
- [ ] Implémenter le pattern Server
- [ ] Créer le Handler Manager
- [ ] Ajouter le script `dev.sh`
- [ ] Améliorer le Makefile

### Phase 2 : Qualité (1 semaine)

**Objectif** : Améliorer la qualité et la maintenabilité

- [ ] Ajouter la documentation Swagger
- [ ] Implémenter les composables Vue
- [ ] Créer l'Error Boundary
- [ ] Améliorer la validation SQL
- [ ] Optimiser les stores Pinia

### Phase 3 : DevOps (2 semaines)

**Objectif** : Automatisation et CI/CD

- [ ] Configurer GitHub Actions
- [ ] Ajouter les métriques Prometheus
- [ ] Implémenter le structured logging
- [ ] Créer les scripts de déploiement
- [ ] Documenter les processus

### Phase 4 : Optimisations (2 semaines)

**Objectif** : Performance et scalabilité

- [ ] Ajouter un cache Redis (optionnel)
- [ ] Implémenter la compression des réponses
- [ ] Optimiser les requêtes DB
- [ ] Ajouter le monitoring avec Grafana
- [ ] WebSocket pour progress real-time

---

## Conclusion

Ces améliorations transformeront ton projet en une application **production-ready**, **maintenable** et **scalable**. La priorité est de :

1. **Refactorer le backend** pour une meilleure séparation des responsabilités
2. **Automatiser** avec des scripts et CI/CD
3. **Monitorer** avec des métriques et logs structurés
4. **Documenter** avec Swagger et README détaillés

Le code sera plus **propre**, **DRY** et **facile à maintenir** pour toi et ton équipe ! 🚀
