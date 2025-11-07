package utils

import (
	"encoding/json"
	"net/http"
)

// ErrorCode represents standardized error codes
type ErrorCode string

const (
	ErrBadRequest         ErrorCode = "BAD_REQUEST"
	ErrUnauthorized       ErrorCode = "UNAUTHORIZED"
	ErrForbidden          ErrorCode = "FORBIDDEN"
	ErrNotFound           ErrorCode = "NOT_FOUND"
	ErrConflict           ErrorCode = "CONFLICT"
	ErrInternalServer     ErrorCode = "INTERNAL_SERVER_ERROR"
	ErrEmailAlreadyExists ErrorCode = "EMAIL_ALREADY_EXISTS"
	ErrInvalidCredentials ErrorCode = "INVALID_CREDENTIALS"
	ErrTokenExpired       ErrorCode = "TOKEN_EXPIRED"
	ErrTokenInvalid       ErrorCode = "TOKEN_INVALID"
	ErrValidationFailed   ErrorCode = "VALIDATION_FAILED"
)

// ErrorResponse represents a standardized error response
type ErrorResponse struct {
	Error   string    `json:"error"`
	Message string    `json:"message"`
	Code    ErrorCode `json:"code,omitempty"`
	Details interface{} `json:"details,omitempty"`
}

// SuccessResponse represents a standardized success response
type SuccessResponse struct {
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message,omitempty"`
}

// RespondJSON sends a JSON response
func RespondJSON(w http.ResponseWriter, statusCode int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)

	if payload != nil {
		if err := json.NewEncoder(w).Encode(payload); err != nil {
			// If encoding fails, try to send a simple error message
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		}
	}
}

// RespondError sends a standardized error response
func RespondError(w http.ResponseWriter, statusCode int, code ErrorCode, message string, details interface{}) {
	RespondJSON(w, statusCode, ErrorResponse{
		Error:   http.StatusText(statusCode),
		Message: message,
		Code:    code,
		Details: details,
	})
}

// RespondSuccess sends a standardized success response
func RespondSuccess(w http.ResponseWriter, statusCode int, data interface{}, message string) {
	RespondJSON(w, statusCode, SuccessResponse{
		Data:    data,
		Message: message,
	})
}

// Common error responses
func BadRequest(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusBadRequest, ErrBadRequest, message, nil)
}

func Unauthorized(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusUnauthorized, ErrUnauthorized, message, nil)
}

func Forbidden(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusForbidden, ErrForbidden, message, nil)
}

func NotFound(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusNotFound, ErrNotFound, message, nil)
}

func Conflict(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusConflict, ErrConflict, message, nil)
}

func InternalServerError(w http.ResponseWriter, message string) {
	RespondError(w, http.StatusInternalServerError, ErrInternalServer, message, nil)
}
