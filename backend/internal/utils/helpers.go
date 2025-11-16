package utils

import (
	"net/http"

	"github.com/google/uuid"
)

// GetUserIDFromContext extracts and validates the user ID from the request context.
// Returns the parsed UUID and a boolean indicating success.
// If extraction or validation fails, it writes the appropriate error response to the ResponseWriter.
func GetUserIDFromContext(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	// Get user ID from context (set by auth middleware)
	userID, ok := r.Context().Value("userID").(string)
	if !ok {
		Unauthorized(w, "Unauthorized")
		return uuid.UUID{}, false
	}

	// Parse user ID
	uid, err := ParseUUID(userID)
	if err != nil {
		BadRequest(w, "Invalid user ID")
		return uuid.UUID{}, false
	}

	return uid, true
}

// SetCookie creates and sets an HTTP cookie with common security settings.
// The cookie will automatically use Secure flag if the request is over HTTPS.
func SetCookie(w http.ResponseWriter, r *http.Request, name, value string, maxAge int) {
	cookie := &http.Cookie{
		Name:     name,
		Value:    value,
		Path:     "/",
		HttpOnly: true,
		Secure:   r.TLS != nil, // Secure only in HTTPS
		SameSite: http.SameSiteLaxMode,
		MaxAge:   maxAge,
	}
	http.SetCookie(w, cookie)
}

// ClearCookie clears a cookie by setting its MaxAge to -1.
func ClearCookie(w http.ResponseWriter, r *http.Request, name string) {
	SetCookie(w, r, name, "", -1)
}
