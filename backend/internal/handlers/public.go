package handlers

import (
	"db-importer/errors"
	"db-importer/generator"
	"db-importer/internal/config"
	"db-importer/internal/database"
	"db-importer/logger"
	"db-importer/parser"
	"db-importer/version"
	"encoding/json"
	"io"
	"net/http"
	"strings"
)

// PublicHandler handles public API endpoints
type PublicHandler struct {
	config *config.Config
	db     *database.DB
}

// NewPublicHandler creates a new PublicHandler
func NewPublicHandler(cfg *config.Config) *PublicHandler {
	return &PublicHandler{
		config: cfg,
	}
}

// SetDB sets the database connection (optional)
func (h *PublicHandler) SetDB(db *database.DB) {
	h.db = db
}

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

type ErrorResponse struct {
	Error  string   `json:"error"`
	Detail string   `json:"detail,omitempty"`
	Errors []string `json:"errors,omitempty"`
}

// ParseSchema handles the /parse-schema endpoint
// @Summary      Parse SQL schema from file
// @Description  Upload a SQL dump file (.sql) to extract table definitions and column information
// @Description  Supports MySQL and PostgreSQL schemas using TiDB parser with regex fallbacks
// @Tags         Schema
// @Accept       multipart/form-data
// @Produce      json
// @Param        file  formData  file  true  "SQL schema file (.sql)"
// @Success      200   {object}  ParseSchemaResponse  "Successfully parsed schema with table definitions"
// @Failure      400   {object}  ErrorResponse        "Invalid request (bad file, empty file, or no tables found)"
// @Failure      500   {object}  ErrorResponse        "Internal server error"
// @Router       /parse-schema [post]
func (h *PublicHandler) ParseSchema(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		errors.RespondWithError(w, errors.NewBadRequestError("Method not allowed", "Only POST method is supported"))
		return
	}

	// Parse multipart form with size limit
	err := r.ParseMultipartForm(h.config.MaxUploadSize)
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
	content, err := io.ReadAll(io.LimitReader(file, h.config.MaxUploadSize))
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

// GenerateSQL handles the /generate-sql endpoint
// @Summary      Generate SQL INSERT statements
// @Description  Generate type-safe SQL INSERT statements from mapped data rows
// @Description  Validates data types, constraints (NOT NULL, length, ranges), and produces production-ready SQL
// @Tags         SQL
// @Accept       json
// @Produce      plain
// @Param        request  body      GenerateSQLRequest  true  "Table name, column mappings, data rows, and field definitions"
// @Success      200      {string}  string              "Generated SQL INSERT statements (plain text)"
// @Failure      400      {object}  ErrorResponse       "Invalid request (missing fields, empty data)"
// @Failure      422      {object}  ErrorResponse       "Data validation failed (type mismatches, constraint violations)"
// @Failure      500      {object}  ErrorResponse       "Internal server error"
// @Router       /generate-sql [post]
func (h *PublicHandler) GenerateSQL(w http.ResponseWriter, r *http.Request) {
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

// Validate handles the /validate endpoint
// @Summary      Validate data against schema
// @Description  Validate data rows against field type definitions without generating SQL
// @Description  Checks data types, NOT NULL constraints, length limits, and numeric ranges
// @Tags         SQL
// @Accept       json
// @Produce      json
// @Param        request  body      GenerateSQLRequest  true  "Data rows, field definitions, and column mappings"
// @Success      200      {object}  map[string]interface{}  "Validation results with valid flag and error list"
// @Failure      400      {object}  ErrorResponse           "Invalid request body"
// @Router       /validate [post]
func (h *PublicHandler) Validate(w http.ResponseWriter, r *http.Request) {
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

// Health handles the /health endpoint
// @Summary      Health check
// @Description  Check API server health, version, and database connection status
// @Tags         Health
// @Produce      json
// @Success      200  {object}  map[string]interface{}  "Health status, version, database status, and configuration"
// @Router       /health [get]
func (h *PublicHandler) Health(w http.ResponseWriter, r *http.Request) {
	// Check database health if available
	dbStatus := "not_configured"
	if h.db != nil {
		if err := h.db.Health(r.Context()); err == nil {
			dbStatus = "healthy"
		} else {
			dbStatus = "unhealthy"
		}
	}

	response := map[string]interface{}{
		"status":   "ok",
		"version":  version.GetVersion(),
		"database": dbStatus,
		"config": map[string]interface{}{
			"maxUploadSize":    h.config.MaxUploadSize,
			"rateLimitEnabled": h.config.RateLimitEnabled,
		},
	}
	errors.RespondWithJSON(w, http.StatusOK, response)
}
