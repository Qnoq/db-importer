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
// @Summary      Register new user
// @Description  Create a new user account with email and password
// @Description  Password must be at least 8 characters. Email must be unique.
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      models.CreateUserRequest  true  "User registration details"
// @Success      201      {object}  map[string]interface{}    "User created successfully with user data"
// @Failure      400      {object}  map[string]interface{}    "Invalid request body or validation failed"
// @Failure      409      {object}  map[string]interface{}    "Email already exists"
// @Failure      500      {object}  map[string]interface{}    "Internal server error"
// @Router       /auth/register [post]
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
// @Summary      User login
// @Description  Authenticate user with email and password, returns JWT access and refresh tokens
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      models.LoginRequest     true  "Login credentials"
// @Success      200      {object}  map[string]interface{}  "Login successful with tokens and user data"
// @Failure      400      {object}  map[string]interface{}  "Invalid request body or validation failed"
// @Failure      401      {object}  map[string]interface{}  "Invalid credentials"
// @Failure      403      {object}  map[string]interface{}  "User account not active"
// @Failure      500      {object}  map[string]interface{}  "Internal server error"
// @Router       /auth/login [post]
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
// @Summary      Refresh access token
// @Description  Generate new access and refresh tokens using a valid refresh token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      models.RefreshTokenRequest  true  "Refresh token"
// @Success      200      {object}  map[string]interface{}      "Tokens refreshed successfully with new tokens"
// @Failure      400      {object}  map[string]interface{}      "Invalid request body or validation failed"
// @Failure      401      {object}  map[string]interface{}      "Invalid or expired refresh token"
// @Router       /auth/refresh [post]
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
// @Summary      User logout
// @Description  Invalidate the refresh token to log out the user
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request  body      models.RefreshTokenRequest  true  "Refresh token to invalidate"
// @Success      200      {object}  map[string]interface{}      "Logout successful"
// @Failure      400      {object}  map[string]interface{}      "Invalid request body or validation failed"
// @Failure      500      {object}  map[string]interface{}      "Internal server error"
// @Router       /auth/logout [post]
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
