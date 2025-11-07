package utils

import (
	"fmt"
	"strings"

	"github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
	validate = validator.New()
}

// ValidateStruct validates a struct and returns user-friendly error messages
func ValidateStruct(s interface{}) error {
	err := validate.Struct(s)
	if err == nil {
		return nil
	}

	// Convert validation errors to user-friendly messages
	validationErrors := err.(validator.ValidationErrors)
	var messages []string

	for _, e := range validationErrors {
		messages = append(messages, formatValidationError(e))
	}

	return fmt.Errorf("%s", strings.Join(messages, "; "))
}

// formatValidationError converts validator.FieldError to a user-friendly message
func formatValidationError(e validator.FieldError) string {
	field := strings.ToLower(e.Field())

	switch e.Tag() {
	case "required":
		return fmt.Sprintf("%s is required", field)
	case "email":
		return fmt.Sprintf("%s must be a valid email address", field)
	case "min":
		return fmt.Sprintf("%s must be at least %s characters long", field, e.Param())
	case "max":
		return fmt.Sprintf("%s must be at most %s characters long", field, e.Param())
	case "gte":
		return fmt.Sprintf("%s must be greater than or equal to %s", field, e.Param())
	case "lte":
		return fmt.Sprintf("%s must be less than or equal to %s", field, e.Param())
	default:
		return fmt.Sprintf("%s is invalid", field)
	}
}
