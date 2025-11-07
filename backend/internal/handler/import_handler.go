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
// POST /api/v1/imports
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
// GET /api/v1/imports/get?id=xxx
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
// GET /api/v1/imports/sql?id=xxx
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
// GET /api/v1/imports
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
// DELETE /api/v1/imports/delete?id=xxx
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
// GET /api/v1/imports/stats
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
// DELETE /api/v1/imports/old
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
		"deletedCount": deletedCount,
		"olderThanDays": olderThanDays,
	}

	utils.RespondSuccess(w, http.StatusOK, result, "Old imports deleted successfully")
}
