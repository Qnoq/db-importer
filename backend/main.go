package main

import (
	"db-importer/config"
	"db-importer/errors"
	"db-importer/generator"
	"db-importer/logger"
	"db-importer/middleware"
	"db-importer/parser"
	"encoding/json"
	"io"
	"net/http"
	"strings"
)

// Response structures
type ParseSchemaResponse struct {
	Tables []parser.Table `json:"tables"`
}

type GenerateSQLRequest struct {
	Table   string                `json:"table"`
	Mapping map[string]string     `json:"mapping"`
	Rows    [][]interface{}       `json:"rows"`
	Fields  []generator.FieldInfo `json:"fields"`
}

type GenerateSQLResponse struct {
	SQL string `json:"sql"`
}

type ErrorResponse struct {
	Error  string   `json:"error"`
	Detail string   `json:"detail,omitempty"`
	Errors []string `json:"errors,omitempty"`
}

// Global configuration
var appConfig *config.Config
var rateLimiter *middleware.RateLimiter

// CORS middleware with configurable origins
func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		// Check if origin is allowed
		allowed := false
		for _, allowedOrigin := range appConfig.AllowedOrigins {
			if allowedOrigin == "*" || allowedOrigin == origin {
				allowed = true
				w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
				break
			}
		}

		if !allowed && len(appConfig.AllowedOrigins) > 0 && appConfig.AllowedOrigins[0] != "*" {
			// Origin not allowed
			logger.Warn("CORS: Origin not allowed", map[string]interface{}{
				"origin": origin,
			})
		}

		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		w.Header().Set("Access-Control-Max-Age", "3600")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// Logging middleware
func loggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		logger.Info("Incoming request", map[string]interface{}{
			"method": r.Method,
			"path":   r.URL.Path,
			"ip":     r.RemoteAddr,
		})
		next(w, r)
	}
}

// Handler for /parse-schema
func parseSchemaHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		errors.RespondWithError(w, errors.NewBadRequestError("Method not allowed", "Only POST method is supported"))
		return
	}

	// Parse multipart form with size limit
	err := r.ParseMultipartForm(appConfig.MaxUploadSize)
	if err != nil {
		logger.Error("Failed to parse multipart form", err)
		errors.RespondWithError(w, errors.NewBadRequestError("Failed to parse form", "File size may exceed limit"))
		return
	}

	file, fileHeader, err := r.FormFile("file")
	if err != nil {
		logger.Error("Failed to get file from form", err)
		errors.RespondWithError(w, errors.NewBadRequestError("Failed to get file", "Make sure to upload a file with key 'file'"))
		return
	}
	defer file.Close()

	logger.Info("Processing schema file", map[string]interface{}{
		"filename": fileHeader.Filename,
		"size":     fileHeader.Size,
	})

	// Check file extension
	if !strings.HasSuffix(strings.ToLower(fileHeader.Filename), ".sql") {
		errors.RespondWithError(w, errors.NewBadRequestError("Invalid file type", "Only .sql files are accepted"))
		return
	}

	// Read file content with size check
	content, err := io.ReadAll(io.LimitReader(file, appConfig.MaxUploadSize))
	if err != nil {
		logger.Error("Failed to read file content", err)
		errors.RespondWithError(w, errors.NewInternalError("Failed to read file"))
		return
	}

	if len(content) == 0 {
		errors.RespondWithError(w, errors.NewBadRequestError("Empty file", "The uploaded file is empty"))
		return
	}

	sqlContent := string(content)

	// Try TiDB parser first (robust MySQL/PostgreSQL parser)
	tables := parser.ParseWithTiDB(sqlContent)

	// If no tables found, fallback to regex parsers
	if len(tables) == 0 {
		logger.Debug("TiDB parser found no tables, trying PostgreSQL parser")
		tables = parser.ParsePostgreSQL(sqlContent)

		if len(tables) == 0 {
			logger.Debug("PostgreSQL parser found no tables, trying MySQL parser")
			tables = parser.ParseMySQL(sqlContent)
		}
	}

	if len(tables) == 0 {
		logger.Warn("No tables found in SQL file", map[string]interface{}{
			"filename": fileHeader.Filename,
		})
		errors.RespondWithError(w, errors.NewBadRequestError(
			"No tables found",
			"Could not parse any CREATE TABLE statements from the SQL file. Make sure the file contains valid MySQL or PostgreSQL table definitions.",
		))
		return
	}

	logger.Info("Successfully parsed schema", map[string]interface{}{
		"filename":   fileHeader.Filename,
		"tableCount": len(tables),
	})

	// Return response
	response := ParseSchemaResponse{
		Tables: tables,
	}

	errors.RespondWithJSON(w, http.StatusOK, response)
}

// Handler for /generate-sql
func generateSQLHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		errors.RespondWithError(w, errors.NewBadRequestError("Method not allowed", "Only POST method is supported"))
		return
	}

	// Parse JSON body
	var req GenerateSQLRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		logger.Error("Failed to decode JSON request", err)
		errors.RespondWithError(w, errors.NewBadRequestError("Invalid JSON", err.Error()))
		return
	}

	// Validate request
	if req.Table == "" {
		errors.RespondWithError(w, errors.NewBadRequestError("Missing table name", "The 'table' field is required"))
		return
	}

	if len(req.Mapping) == 0 {
		errors.RespondWithError(w, errors.NewBadRequestError("Missing mapping", "At least one column mapping is required"))
		return
	}

	if len(req.Rows) == 0 {
		errors.RespondWithError(w, errors.NewBadRequestError("Missing data", "At least one data row is required"))
		return
	}

	logger.Info("Generating SQL", map[string]interface{}{
		"table":    req.Table,
		"rowCount": len(req.Rows),
		"columns":  len(req.Mapping),
	})

	// Validate data types if fields are provided
	if len(req.Fields) > 0 {
		validationErrors := generator.ValidateFieldTypes(req.Rows, req.Fields, req.Mapping)
		if len(validationErrors) > 0 {
			logger.Warn("Data validation errors", map[string]interface{}{
				"errorCount": len(validationErrors),
			})

			// Return validation errors
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnprocessableEntity)
			json.NewEncoder(w).Encode(ErrorResponse{
				Error:  "Data validation failed",
				Detail: "Some data does not match field constraints",
				Errors: validationErrors,
			})
			return
		}
	}

	// Generate SQL
	sql := generator.GenerateInsertSQL(req.Table, req.Mapping, req.Rows, req.Fields)

	if sql == "" {
		logger.Error("SQL generation returned empty result", nil)
		errors.RespondWithError(w, errors.NewInternalError("Failed to generate SQL"))
		return
	}

	logger.Info("SQL generated successfully", map[string]interface{}{
		"table":     req.Table,
		"sqlLength": len(sql),
	})

	// Return plain text SQL
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte(sql))
}

// Handler for /validate
func validateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		errors.RespondWithError(w, errors.NewBadRequestError("Method not allowed", "Only POST method is supported"))
		return
	}

	var req GenerateSQLRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		errors.RespondWithError(w, errors.NewBadRequestError("Invalid JSON", err.Error()))
		return
	}

	// Validate data
	validationErrors := generator.ValidateFieldTypes(req.Rows, req.Fields, req.Mapping)

	response := map[string]interface{}{
		"valid":  len(validationErrors) == 0,
		"errors": validationErrors,
	}

	errors.RespondWithJSON(w, http.StatusOK, response)
}

// Health check handler
func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":  "ok",
		"version": "1.0.0",
		"config": map[string]interface{}{
			"maxUploadSize":    appConfig.MaxUploadSize,
			"rateLimitEnabled": appConfig.RateLimitEnabled,
		},
	}
	errors.RespondWithJSON(w, http.StatusOK, response)
}

func main() {
	// Load configuration
	appConfig = config.LoadConfig()

	// Initialize logger
	logger.Init(appConfig.EnableDebugLog)

	logger.Info("Starting DB Importer API", map[string]interface{}{
		"port":             appConfig.Port,
		"allowedOrigins":   appConfig.AllowedOrigins,
		"maxUploadSize":    appConfig.MaxUploadSize,
		"rateLimitEnabled": appConfig.RateLimitEnabled,
	})

	// Initialize rate limiter
	if appConfig.RateLimitEnabled {
		rateLimiter = middleware.NewRateLimiter(appConfig.RateLimitRequests, appConfig.RateLimitWindow)
		logger.Info("Rate limiting enabled", map[string]interface{}{
			"requests": appConfig.RateLimitRequests,
			"window":   appConfig.RateLimitWindow,
		})
	}

	// Create middleware chain
	corsMiddleware := enableCORS
	logMiddleware := loggingMiddleware

	// Register handlers with middleware
	http.HandleFunc("/health", corsMiddleware(healthHandler))

	if appConfig.RateLimitEnabled {
		http.HandleFunc("/parse-schema", corsMiddleware(logMiddleware(rateLimiter.RateLimit(parseSchemaHandler))))
		http.HandleFunc("/generate-sql", corsMiddleware(logMiddleware(rateLimiter.RateLimit(generateSQLHandler))))
		http.HandleFunc("/validate", corsMiddleware(logMiddleware(rateLimiter.RateLimit(validateHandler))))
	} else {
		http.HandleFunc("/parse-schema", corsMiddleware(logMiddleware(parseSchemaHandler)))
		http.HandleFunc("/generate-sql", corsMiddleware(logMiddleware(generateSQLHandler)))
		http.HandleFunc("/validate", corsMiddleware(logMiddleware(validateHandler)))
	}

	// Start server
	addr := ":" + appConfig.Port
	logger.Info("Server started successfully", map[string]interface{}{
		"address": addr,
	})

	if err := http.ListenAndServe(addr, nil); err != nil {
		logger.Error("Server failed to start", err)
		panic(err)
	}
}
