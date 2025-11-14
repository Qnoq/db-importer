package middleware

import (
	"context"
	"net/http"
	"strings"

	"db-importer/internal/utils"
)

// AuthMiddleware creates a middleware that validates JWT tokens
func AuthMiddleware(jwtConfig utils.JWTConfig) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			var tokenString string

			// Try to get token from Authorization header first
			authHeader := r.Header.Get("Authorization")
			if authHeader != "" {
				// Check if it starts with "Bearer "
				parts := strings.Split(authHeader, " ")
				if len(parts) == 2 && parts[0] == "Bearer" {
					tokenString = parts[1]
				}
			}

			// If no token in header, try to get from cookie
			if tokenString == "" {
				cookie, err := r.Cookie("access_token")
				if err != nil {
					utils.Unauthorized(w, "Missing authorization token")
					return
				}
				tokenString = cookie.Value
			}

			// Validate access token
			claims, err := utils.ValidateAccessToken(tokenString, jwtConfig)
			if err != nil {
				if err == utils.ErrExpiredToken {
					utils.RespondError(w, http.StatusUnauthorized, utils.ErrTokenExpired, "Token has expired", nil)
					return
				}
				utils.RespondError(w, http.StatusUnauthorized, utils.ErrTokenInvalid, "Invalid token", nil)
				return
			}

			// Add user ID and email to request context
			ctx := context.WithValue(r.Context(), "userID", claims.UserID)
			ctx = context.WithValue(ctx, "email", claims.Email)

			// Call next handler with updated context
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// OptionalAuthMiddleware validates JWT tokens if present, but doesn't require them
func OptionalAuthMiddleware(jwtConfig utils.JWTConfig) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			var tokenString string

			// Try to get token from Authorization header first
			authHeader := r.Header.Get("Authorization")
			if authHeader != "" {
				// Check if it starts with "Bearer "
				parts := strings.Split(authHeader, " ")
				if len(parts) == 2 && parts[0] == "Bearer" {
					tokenString = parts[1]
				}
			}

			// If no token in header, try to get from cookie
			if tokenString == "" {
				cookie, err := r.Cookie("access_token")
				if err == nil {
					tokenString = cookie.Value
				}
			}

			// If no token found, continue without authentication
			if tokenString == "" {
				next.ServeHTTP(w, r)
				return
			}

			// Validate access token
			claims, err := utils.ValidateAccessToken(tokenString, jwtConfig)
			if err != nil {
				// Invalid token, continue without authentication
				next.ServeHTTP(w, r)
				return
			}

			// Add user ID and email to request context
			ctx := context.WithValue(r.Context(), "userID", claims.UserID)
			ctx = context.WithValue(ctx, "email", claims.Email)

			// Call next handler with updated context
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
