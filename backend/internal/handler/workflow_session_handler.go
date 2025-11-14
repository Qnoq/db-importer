package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"db-importer/internal/models"
	"db-importer/internal/service"
	"db-importer/internal/utils"
)

// WorkflowSessionHandler handles workflow session HTTP requests
type WorkflowSessionHandler struct {
	sessionService *service.WorkflowSessionService
}

// NewWorkflowSessionHandler creates a new WorkflowSessionHandler
func NewWorkflowSessionHandler(sessionService *service.WorkflowSessionService) *WorkflowSessionHandler {
	return &WorkflowSessionHandler{
		sessionService: sessionService,
	}
}

// GetSession handles retrieving the active workflow session
// @Summary      Get active workflow session
// @Description  Retrieve the current workflow session for the authenticated user
// @Description  Returns nil if no active session exists
// @Tags         Workflow Sessions
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "Active session or null if none exists"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      500  {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/workflow/session [get]
func (h *WorkflowSessionHandler) GetSession(w http.ResponseWriter, r *http.Request) {
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

	// Get session
	session, err := h.sessionService.GetSession(r.Context(), uid)
	if err != nil {
		utils.InternalServerError(w, "Failed to get session: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "")
}

// GetSessionWithSchema handles retrieving the session with schema content
// @Summary      Get session with schema content
// @Description  Retrieve the workflow session including decompressed schema content
// @Tags         Workflow Sessions
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "Session with schema content"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      404  {object}  map[string]interface{}  "No active session found"
// @Failure      500  {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/workflow/session/schema [get]
func (h *WorkflowSessionHandler) GetSessionWithSchema(w http.ResponseWriter, r *http.Request) {
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

	// Get session with schema
	session, err := h.sessionService.GetSessionWithSchema(r.Context(), uid)
	if err != nil {
		utils.InternalServerError(w, "Failed to get session: "+err.Error())
		return
	}

	if session == nil {
		utils.NotFound(w, "No active session found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "")
}

// SaveSchema handles saving schema content (step 1)
// @Summary      Save schema (Step 1)
// @Description  Save SQL schema content and parsed tables for the workflow
// @Tags         Workflow Sessions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      models.SaveSchemaRequest  true  "Schema content and tables"
// @Success      200      {object}  map[string]interface{}    "Session updated successfully"
// @Failure      400      {object}  map[string]interface{}    "Invalid request or validation failed"
// @Failure      401      {object}  map[string]interface{}    "Unauthorized"
// @Failure      500      {object}  map[string]interface{}    "Internal server error"
// @Router       /api/v1/workflow/session/schema [post]
func (h *WorkflowSessionHandler) SaveSchema(w http.ResponseWriter, r *http.Request) {
	var req models.SaveSchemaRequest

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

	// Save schema
	session, err := h.sessionService.SaveSchema(r.Context(), uid, &req)
	if err != nil {
		utils.InternalServerError(w, "Failed to save schema: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "Schema saved successfully")
}

// SaveTableSelection handles saving table selection (step 2)
// @Summary      Save table selection (Step 2)
// @Description  Save the selected table name for the workflow
// @Tags         Workflow Sessions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      models.SaveTableSelectionRequest  true  "Table name"
// @Success      200      {object}  map[string]interface{}            "Session updated successfully"
// @Failure      400      {object}  map[string]interface{}            "Invalid request or validation failed"
// @Failure      401      {object}  map[string]interface{}            "Unauthorized"
// @Failure      404      {object}  map[string]interface{}            "No active session found"
// @Failure      500      {object}  map[string]interface{}            "Internal server error"
// @Router       /api/v1/workflow/session/table [post]
func (h *WorkflowSessionHandler) SaveTableSelection(w http.ResponseWriter, r *http.Request) {
	var req models.SaveTableSelectionRequest

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

	// Save table selection
	session, err := h.sessionService.SaveTableSelection(r.Context(), uid, &req)
	if err != nil {
		if err.Error() == "no active session found" {
			utils.NotFound(w, "No active session found")
			return
		}
		utils.InternalServerError(w, "Failed to save table selection: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "Table selection saved successfully")
}

// SaveDataFile handles saving data file information (step 3)
// @Summary      Save data file (Step 3)
// @Description  Save data file name, headers, and sample data for the workflow
// @Tags         Workflow Sessions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      models.SaveDataFileRequest  true  "Data file information"
// @Success      200      {object}  map[string]interface{}      "Session updated successfully"
// @Failure      400      {object}  map[string]interface{}      "Invalid request or validation failed"
// @Failure      401      {object}  map[string]interface{}      "Unauthorized"
// @Failure      404      {object}  map[string]interface{}      "No active session found"
// @Failure      500      {object}  map[string]interface{}      "Internal server error"
// @Router       /api/v1/workflow/session/data [post]
func (h *WorkflowSessionHandler) SaveDataFile(w http.ResponseWriter, r *http.Request) {
	var req models.SaveDataFileRequest

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

	// Save data file
	session, err := h.sessionService.SaveDataFile(r.Context(), uid, &req)
	if err != nil {
		if err.Error() == "no active session found" {
			utils.NotFound(w, "No active session found")
			return
		}
		utils.InternalServerError(w, "Failed to save data file: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "Data file saved successfully")
}

// SaveMapping handles saving column mapping (step 4)
// @Summary      Save column mapping (Step 4)
// @Description  Save the column mapping between data file and database table
// @Tags         Workflow Sessions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request  body      models.SaveMappingRequest  true  "Column mapping"
// @Success      200      {object}  map[string]interface{}     "Session updated successfully"
// @Failure      400      {object}  map[string]interface{}     "Invalid request or validation failed"
// @Failure      401      {object}  map[string]interface{}     "Unauthorized"
// @Failure      404      {object}  map[string]interface{}     "No active session found"
// @Failure      500      {object}  map[string]interface{}     "Internal server error"
// @Router       /api/v1/workflow/session/mapping [post]
func (h *WorkflowSessionHandler) SaveMapping(w http.ResponseWriter, r *http.Request) {
	var req models.SaveMappingRequest

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

	// Save mapping
	session, err := h.sessionService.SaveMapping(r.Context(), uid, &req)
	if err != nil {
		if err.Error() == "no active session found" {
			utils.NotFound(w, "No active session found")
			return
		}
		utils.InternalServerError(w, "Failed to save mapping: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, session, "Mapping saved successfully")
}

// DeleteSession handles deleting a workflow session
// @Summary      Delete workflow session
// @Description  Delete the current workflow session for the authenticated user
// @Tags         Workflow Sessions
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}  "Session deleted successfully"
// @Failure      401  {object}  map[string]interface{}  "Unauthorized"
// @Failure      404  {object}  map[string]interface{}  "Session not found"
// @Failure      500  {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/workflow/session [delete]
func (h *WorkflowSessionHandler) DeleteSession(w http.ResponseWriter, r *http.Request) {
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

	// Delete session
	err = h.sessionService.DeleteSession(r.Context(), uid)
	if err != nil {
		if err.Error() == "workflow session not found" {
			utils.NotFound(w, "Session not found")
			return
		}
		utils.InternalServerError(w, "Failed to delete session: "+err.Error())
		return
	}

	utils.RespondSuccess(w, http.StatusOK, nil, "Session deleted successfully")
}

// ExtendExpiration handles extending session expiration
// @Summary      Extend session expiration
// @Description  Extend the expiration time of the current workflow session
// @Tags         Workflow Sessions
// @Produce      json
// @Security     BearerAuth
// @Param        days  query     int  false  "Number of days to extend (1-30, default: 7)"
// @Success      200   {object}  map[string]interface{}  "Expiration extended successfully"
// @Failure      400   {object}  map[string]interface{}  "Invalid days parameter"
// @Failure      401   {object}  map[string]interface{}  "Unauthorized"
// @Failure      404   {object}  map[string]interface{}  "Session not found or expired"
// @Failure      500   {object}  map[string]interface{}  "Internal server error"
// @Router       /api/v1/workflow/session/extend [post]
func (h *WorkflowSessionHandler) ExtendExpiration(w http.ResponseWriter, r *http.Request) {
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
	days := 7 // default to 7 days
	if daysStr := r.URL.Query().Get("days"); daysStr != "" {
		parsedDays, err := strconv.Atoi(daysStr)
		if err == nil && parsedDays > 0 && parsedDays <= 30 {
			days = parsedDays
		}
	}

	// Extend expiration
	err = h.sessionService.ExtendExpiration(r.Context(), uid, days)
	if err != nil {
		if err.Error() == "workflow session not found or expired" {
			utils.NotFound(w, "Session not found or expired")
			return
		}
		utils.InternalServerError(w, "Failed to extend expiration: "+err.Error())
		return
	}

	result := map[string]interface{}{
		"extendedDays": days,
	}

	utils.RespondSuccess(w, http.StatusOK, result, "Expiration extended successfully")
}
