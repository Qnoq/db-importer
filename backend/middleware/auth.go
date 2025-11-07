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
			// Extract token from Authorization header
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				utils.Unauthorized(w, "Missing authorization header")
				return
			}

			// Check if it starts with "Bearer "
			parts := strings.Split(authHeader, " ")
			if len(parts) != 2 || parts[0] != "Bearer" {
				utils.Unauthorized(w, "Invalid authorization header format")
				return
			}

			tokenString := parts[1]

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
			// Extract token from Authorization header
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				// No token, continue without authentication
				next.ServeHTTP(w, r)
				return
			}

			// Check if it starts with "Bearer "
			parts := strings.Split(authHeader, " ")
			if len(parts) != 2 || parts[0] != "Bearer" {
				// Invalid format, continue without authentication
				next.ServeHTTP(w, r)
				return
			}

			tokenString := parts[1]

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
