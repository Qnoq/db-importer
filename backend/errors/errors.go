package errors

import (
	"encoding/json"
	"net/http"
)

// AppError represents an application error with HTTP status
type AppError struct {
	Message    string `json:"message"`
	StatusCode int    `json:"-"`
	Detail     string `json:"detail,omitempty"`
}

// Error implements the error interface
func (e *AppError) Error() string {
	return e.Message
}

// NewBadRequestError creates a 400 error
func NewBadRequestError(message string, detail string) *AppError {
	return &AppError{
		Message:    message,
		StatusCode: http.StatusBadRequest,
		Detail:     detail,
	}
}

// NewInternalError creates a 500 error
func NewInternalError(message string) *AppError {
	return &AppError{
		Message:    message,
		StatusCode: http.StatusInternalServerError,
	}
}

// NewNotFoundError creates a 404 error
func NewNotFoundError(message string) *AppError {
	return &AppError{
		Message:    message,
		StatusCode: http.StatusNotFound,
	}
}

// RespondWithError sends an error response
func RespondWithError(w http.ResponseWriter, err error) {
	appErr, ok := err.(*AppError)
	if !ok {
		appErr = NewInternalError("An unexpected error occurred")
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(appErr.StatusCode)
	json.NewEncoder(w).Encode(appErr)
}

// RespondWithJSON sends a JSON response
func RespondWithJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(data)
}
