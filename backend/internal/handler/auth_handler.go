package handler

import (
	"encoding/json"
	"errors"
	"net/http"

	"db-importer/internal/models"
	"db-importer/internal/service"
	"db-importer/internal/utils"
)

// AuthHandler handles authentication HTTP requests
type AuthHandler struct {
	authService *service.AuthService
}

// NewAuthHandler creates a new AuthHandler
func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// Register handles user registration
// POST /auth/register
func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req models.CreateUserRequest

	// Parse request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.BadRequest(w, "Invalid request body")
		return
	}

	// Validate request
	if err := utils.ValidateStruct(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
		return
	}

	// Register user
	user, err := h.authService.Register(r.Context(), &req)
	if err != nil {
		if errors.Is(err, service.ErrEmailAlreadyExists) {
			utils.RespondError(w, http.StatusConflict, utils.ErrEmailAlreadyExists, "Email already exists", nil)
			return
		}
		utils.InternalServerError(w, "Failed to register user")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, user, "User registered successfully")
}

// Login handles user login
// POST /auth/login
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req models.LoginRequest

	// Parse request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.BadRequest(w, "Invalid request body")
		return
	}

	// Validate request
	if err := utils.ValidateStruct(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
		return
	}

	// Login user
	loginResp, err := h.authService.Login(r.Context(), &req)
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			utils.RespondError(w, http.StatusUnauthorized, utils.ErrInvalidCredentials, "Invalid email or password", nil)
			return
		}
		if errors.Is(err, service.ErrUserNotActive) {
			utils.RespondError(w, http.StatusForbidden, utils.ErrForbidden, "User account is not active", nil)
			return
		}
		utils.InternalServerError(w, "Failed to login")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, loginResp, "Login successful")
}

// RefreshToken handles token refresh
// POST /auth/refresh
func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	var req models.RefreshTokenRequest

	// Parse request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.BadRequest(w, "Invalid request body")
		return
	}

	// Validate request
	if err := utils.ValidateStruct(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
		return
	}

	// Refresh tokens
	tokens, err := h.authService.RefreshTokens(r.Context(), req.RefreshToken)
	if err != nil {
		utils.RespondError(w, http.StatusUnauthorized, utils.ErrTokenInvalid, "Invalid or expired refresh token", nil)
		return
	}

	utils.RespondSuccess(w, http.StatusOK, tokens, "Tokens refreshed successfully")
}

// Logout handles user logout
// POST /auth/logout
func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var req models.RefreshTokenRequest

	// Parse request body
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.BadRequest(w, "Invalid request body")
		return
	}

	// Validate request
	if err := utils.ValidateStruct(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, utils.ErrValidationFailed, err.Error(), nil)
		return
	}

	// Logout user
	if err := h.authService.Logout(r.Context(), req.RefreshToken); err != nil {
		utils.InternalServerError(w, "Failed to logout")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, nil, "Logout successful")
}

// Me returns the current authenticated user
// GET /auth/me
func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	// Get user ID from context (set by auth middleware)
	userID, ok := r.Context().Value("userID").(string)
	if !ok {
		utils.Unauthorized(w, "Unauthorized")
		return
	}

	// Parse user ID
	uid, err := utils.ParseUUID(userID)
	if err != nil {
		utils.BadRequest(w, "Invalid user ID")
		return
	}

	// Get user
	user, err := h.authService.GetUserByID(r.Context(), uid)
	if err != nil {
		utils.NotFound(w, "User not found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, user, "")
}
