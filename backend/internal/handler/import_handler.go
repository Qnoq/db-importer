package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"db-importer/internal/models"
	"db-importer/internal/service"
	"db-importer/internal/utils"
)

// ImportHandler handles import HTTP requests
type ImportHandler struct {
	importService *service.ImportService
}

// NewImportHandler creates a new ImportHandler
func NewImportHandler(importService *service.ImportService) *ImportHandler {
	return &ImportHandler{
		importService: importService,
	}
}

// CreateImport handles creating a new import record
// @Summary      Create import record
// @Description  Save a new import record with generated SQL and metadata
// @Description  Stores table name, row count, SQL (gzipped), mappings, transformations, and validation results
// @Tags         Imports
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      models.CreateImportRequest  true  "Import details (table, rows, SQL, metadata)"
// @Success      201      {object}  map[string]interface{}      "Import created successfully with import data"
// @Failure      400      {object}  map[string]interface{}      "Invalid request or validation failed"
// @Failure      401      {object}  map[string]interface{}      "Unauthorized - missing or invalid token"
// @Failure      500      {object}  map[string]interface{}      "Internal server error"
// @Router       /api/v1/imports [post]
func (h *ImportHandler) CreateImport(w http.ResponseWriter, r *http.Request) {
	var req models.CreateImportRequest

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

	// Get user ID from context (set by auth middleware)
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

	// Create import
	importResp, err := h.importService.CreateImport(r.Context(), uid, &req)
	if err != nil {
		// Log the actual error for debugging
		utils.InternalServerError(w, "Failed to create import: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, importResp, "Import created successfully")
}

// GetImport handles retrieving an import by ID
// @Summary      Get import details
// @Description  Retrieve import metadata by ID (without SQL content)
// @Description  Returns table name, row count, status, timestamps, and statistics
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Param        id   query     string  true  "Import UUID"
// @Success      200  {object}  map[string]interface{}  "Import details"
// @Failure      400  {object}  map[string]interface{}  "Invalid or missing import ID"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      404  {object}  map[string]interface{}  "Import not found"
// @Router       /api/v1/imports/get [get]
func (h *ImportHandler) GetImport(w http.ResponseWriter, r *http.Request) {
	importID := r.URL.Query().Get("id")
	if importID == "" {
		utils.BadRequest(w, "Missing import ID")
		return
	}

	// Parse import ID
	id, err := utils.ParseUUID(importID)
	if err != nil {
		utils.BadRequest(w, "Invalid import ID")
		return
	}

	// Get user ID from context
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

	// Get import
	importResp, err := h.importService.GetImport(r.Context(), id, uid)
	if err != nil {
		utils.NotFound(w, "Import not found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, importResp, "")
}

// GetImportSQL handles retrieving an import with its SQL
// @Summary      Get import with SQL
// @Description  Retrieve import details including the generated SQL content (decompressed)
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Param        id   query     string  true  "Import UUID"
// @Success      200  {object}  map[string]interface{}  "Import details with SQL content"
// @Failure      400  {object}  map[string]interface{}  "Invalid or missing import ID"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      404  {object}  map[string]interface{}  "Import not found"
// @Router       /api/v1/imports/sql [get]
func (h *ImportHandler) GetImportSQL(w http.ResponseWriter, r *http.Request) {
	importID := r.URL.Query().Get("id")
	if importID == "" {
		utils.BadRequest(w, "Missing import ID")
		return
	}

	// Parse import ID
	id, err := utils.ParseUUID(importID)
	if err != nil {
		utils.BadRequest(w, "Invalid import ID")
		return
	}

	// Get user ID from context
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

	// Get import with SQL
	importWithSQL, err := h.importService.GetImportWithSQL(r.Context(), id, uid)
	if err != nil {
		utils.NotFound(w, "Import not found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, importWithSQL, "")
}

// ListImports handles listing imports with pagination and filters
// @Summary      List user imports
// @Description  List imports with pagination, filtering by table/status, and sorting
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Param        page       query     int     false  "Page number (default: 1)"
// @Param        pageSize   query     int     false  "Page size, max 100 (default: 20)"
// @Param        tableName  query     string  false  "Filter by table name"
// @Param        status     query     string  false  "Filter by status (success/warning/failed)"
// @Param        sortBy     query     string  false  "Sort field (createdAt/tableName/rowCount)"
// @Param        sortOrder  query     string  false  "Sort order (asc/desc)"
// @Success      200        {object}  map[string]interface{}  "Paginated list of imports"
// @Failure      400        {object}  map[string]interface{}  "Invalid query parameters"
// @Failure      401        {object}  map[string]interface{}  "Unauthorized"
// @Failure      500        {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/imports/list [get]
func (h *ImportHandler) ListImports(w http.ResponseWriter, r *http.Request) {
	// Get user ID from context
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

	// Parse query parameters
	queryParams := r.URL.Query()
	req := &models.GetImportsRequest{
		TableName: queryParams.Get("tableName"),
		Status:    models.ImportStatus(queryParams.Get("status")),
		SortBy:    queryParams.Get("sortBy"),
		SortOrder: queryParams.Get("sortOrder"),
	}

	// Parse page
	if pageStr := queryParams.Get("page"); pageStr != "" {
		page, err := strconv.Atoi(pageStr)
		if err == nil && page > 0 {
			req.Page = page
		}
	}

	// Parse pageSize
	if pageSizeStr := queryParams.Get("pageSize"); pageSizeStr != "" {
		pageSize, err := strconv.Atoi(pageSizeStr)
		if err == nil && pageSize > 0 && pageSize <= 100 {
			req.PageSize = pageSize
		}
	}

	// Validate request
	if err := utils.ValidateStruct(req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
		return
	}

	// List imports
	imports, err := h.importService.ListImports(r.Context(), uid, req)
	if err != nil {
		utils.InternalServerError(w, "Failed to list imports")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, imports, "")
}

// DeleteImport handles deleting an import by ID
// @Summary      Delete import
// @Description  Delete a specific import record by ID
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Param        id   query     string  true  "Import UUID to delete"
// @Success      200  {object}  map[string]interface{}  "Import deleted successfully"
// @Failure      400  {object}  map[string]interface{}  "Invalid or missing import ID"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      404  {object}  map[string]interface{}  "Import not found"
// @Router       /api/v1/imports/delete [delete]
func (h *ImportHandler) DeleteImport(w http.ResponseWriter, r *http.Request) {
	importID := r.URL.Query().Get("id")
	if importID == "" {
		utils.BadRequest(w, "Missing import ID")
		return
	}

	// Parse import ID
	id, err := utils.ParseUUID(importID)
	if err != nil {
		utils.BadRequest(w, "Invalid import ID")
		return
	}

	// Get user ID from context
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

	// Delete import
	err = h.importService.DeleteImport(r.Context(), id, uid)
	if err != nil {
		utils.NotFound(w, "Import not found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, nil, "Import deleted successfully")
}

// GetStats handles retrieving import statistics
// @Summary      Get import statistics
// @Description  Retrieve user's import statistics (total count, success/warning/failed counts, total rows)
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "Import statistics"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      500  {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/imports/stats [get]
func (h *ImportHandler) GetStats(w http.ResponseWriter, r *http.Request) {
	// Get user ID from context
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

	// Get stats
	stats, err := h.importService.GetStats(r.Context(), uid)
	if err != nil {
		utils.InternalServerError(w, "Failed to get import stats")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, stats, "")
}

// DeleteOldImports handles deleting old imports
// @Summary      Delete old imports
// @Description  Delete imports older than specified number of days (default: 30)
// @Tags         Imports
// @Produce      json
// @Security     BearerAuth
// @Param        days  query     int  false  "Delete imports older than this many days (default: 30)"
// @Success      200   {object}  map[string]interface{}  "Number of imports deleted"
// @Failure      401   {object}  map[string]interface{}  "Unauthorized"
// @Failure      500   {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/imports/old [delete]
func (h *ImportHandler) DeleteOldImports(w http.ResponseWriter, r *http.Request) {
	// Get user ID from context
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

	// Parse query parameter for days
	olderThanDays := 30 // default to 30 days
	if daysStr := r.URL.Query().Get("days"); daysStr != "" {
		days, err := strconv.Atoi(daysStr)
		if err == nil && days > 0 {
			olderThanDays = days
		}
	}

	// Delete old imports
	deletedCount, err := h.importService.DeleteOldImports(r.Context(), uid, olderThanDays)
	if err != nil {
		utils.InternalServerError(w, "Failed to delete old imports")
		return
	}

	result := map[string]interface{}{
		"deletedCount":  deletedCount,
		"olderThanDays": olderThanDays,
	}

	utils.RespondSuccess(w, http.StatusOK, result, "Old imports deleted successfully")
}
