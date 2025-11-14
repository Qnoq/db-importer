package server

import (
	"db-importer/logger"
	"db-importer/middleware"
	"net/http"

	_ "db-importer/docs" // Import swagger docs
	httpSwagger "github.com/swaggo/http-swagger"
)

// setupRoutes configures all HTTP routes
func (s *Server) setupRoutes(mux *http.ServeMux) {
	// Setup public routes
	s.setupPublicRoutes(mux)

	// Setup auth routes if database is configured
	if s.db != nil {
		s.setupAuthRoutes(mux)
		s.setupProtectedRoutes(mux)
	}
}

// setupPublicRoutes registers public routes (no auth required)
func (s *Server) setupPublicRoutes(mux *http.ServeMux) {
	// Health check - no middlewares needed
	mux.HandleFunc("/health", s.publicHandler.Health)

	// Swagger documentation
	mux.HandleFunc("/swagger/", httpSwagger.WrapHandler)

	// Main endpoints with CORS, logging, and rate limiting
	corsAndLog := s.withCORS(s.withLogging)

	if s.config.RateLimitEnabled {
		// With rate limiting
		if s.db != nil {
			// With optional auth for differentiated rate limiting
			mux.HandleFunc("/parse-schema", corsAndLog(s.withOptionalAuth(s.withRateLimit(s.publicHandler.ParseSchema))))
			mux.HandleFunc("/generate-sql", corsAndLog(s.withOptionalAuth(s.withRateLimit(s.publicHandler.GenerateSQL))))
			mux.HandleFunc("/validate", corsAndLog(s.withOptionalAuth(s.withRateLimit(s.publicHandler.Validate))))
		} else {
			// Without auth
			mux.HandleFunc("/parse-schema", corsAndLog(s.withRateLimit(s.publicHandler.ParseSchema)))
			mux.HandleFunc("/generate-sql", corsAndLog(s.withRateLimit(s.publicHandler.GenerateSQL)))
			mux.HandleFunc("/validate", corsAndLog(s.withRateLimit(s.publicHandler.Validate)))
		}
	} else {
		// Without rate limiting
		mux.HandleFunc("/parse-schema", corsAndLog(s.publicHandler.ParseSchema))
		mux.HandleFunc("/generate-sql", corsAndLog(s.publicHandler.GenerateSQL))
		mux.HandleFunc("/validate", corsAndLog(s.publicHandler.Validate))
	}
}

// setupAuthRoutes registers authentication routes
func (s *Server) setupAuthRoutes(mux *http.ServeMux) {
	logger.Info("Registering authentication endpoints", nil)

	corsAndLog := s.withCORS(s.withLogging)

	mux.HandleFunc("/auth/register", corsAndLog(s.authHandler.Register))
	mux.HandleFunc("/auth/login", corsAndLog(s.authHandler.Login))
	mux.HandleFunc("/auth/refresh", corsAndLog(s.authHandler.RefreshToken))
	mux.HandleFunc("/auth/logout", corsAndLog(s.authHandler.Logout))
}

// setupProtectedRoutes registers routes that require authentication
func (s *Server) setupProtectedRoutes(mux *http.ServeMux) {
	logger.Info("Registering protected endpoints", nil)

	corsAndLog := s.withCORS(s.withLogging)
	requireAuth := s.withRequireAuth

	// Import endpoints
	mux.HandleFunc("/api/v1/imports", corsAndLog(requireAuth(s.importHandler.CreateImport)))
	mux.HandleFunc("/api/v1/imports/list", corsAndLog(requireAuth(s.importHandler.ListImports)))
	mux.HandleFunc("/api/v1/imports/get", corsAndLog(requireAuth(s.importHandler.GetImport)))
	mux.HandleFunc("/api/v1/imports/sql", corsAndLog(requireAuth(s.importHandler.GetImportSQL)))
	mux.HandleFunc("/api/v1/imports/delete", corsAndLog(requireAuth(s.importHandler.DeleteImport)))
	mux.HandleFunc("/api/v1/imports/stats", corsAndLog(requireAuth(s.importHandler.GetStats)))
	mux.HandleFunc("/api/v1/imports/old", corsAndLog(requireAuth(s.importHandler.DeleteOldImports)))

	// Workflow session endpoints
	mux.HandleFunc("/api/v1/workflow/session", corsAndLog(requireAuth(s.handleWorkflowSession)))
	mux.HandleFunc("/api/v1/workflow/session/schema", corsAndLog(requireAuth(s.handleWorkflowSessionSchema)))
	mux.HandleFunc("/api/v1/workflow/session/table", corsAndLog(requireAuth(s.workflowSessionHandler.SaveTableSelection)))
	mux.HandleFunc("/api/v1/workflow/session/data", corsAndLog(requireAuth(s.workflowSessionHandler.SaveDataFile)))
	mux.HandleFunc("/api/v1/workflow/session/mapping", corsAndLog(requireAuth(s.workflowSessionHandler.SaveMapping)))
	mux.HandleFunc("/api/v1/workflow/session/extend", corsAndLog(requireAuth(s.workflowSessionHandler.ExtendExpiration)))
}

// handleWorkflowSession routes GET and DELETE for /api/v1/workflow/session
func (s *Server) handleWorkflowSession(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		s.workflowSessionHandler.GetSession(w, r)
	case http.MethodDelete:
		s.workflowSessionHandler.DeleteSession(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

// handleWorkflowSessionSchema routes GET and POST for /api/v1/workflow/session/schema
func (s *Server) handleWorkflowSessionSchema(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		s.workflowSessionHandler.GetSessionWithSchema(w, r)
	case http.MethodPost:
		s.workflowSessionHandler.SaveSchema(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

// Middleware helpers

// withCORS wraps a handler with CORS middleware
func (s *Server) withCORS(next func(http.HandlerFunc) http.HandlerFunc) func(http.HandlerFunc) http.HandlerFunc {
	return func(handler http.HandlerFunc) http.HandlerFunc {
		return s.corsMiddleware(next(handler))
	}
}

// withLogging wraps a handler with logging middleware
func (s *Server) withLogging(handler http.HandlerFunc) http.HandlerFunc {
	return s.loggingMiddleware(handler)
}

// withRateLimit wraps a handler with rate limiting middleware
func (s *Server) withRateLimit(handler http.HandlerFunc) http.HandlerFunc {
	if s.rateLimiter == nil {
		return handler
	}
	return s.rateLimiter.RateLimit(handler)
}

// withOptionalAuth wraps a handler with optional auth middleware (for rate limiting differentiation)
func (s *Server) withOptionalAuth(handler http.HandlerFunc) http.HandlerFunc {
	jwtConfig := s.config.JWTConfig()
	return func(w http.ResponseWriter, r *http.Request) {
		middleware.OptionalAuthMiddleware(jwtConfig)(http.HandlerFunc(handler)).ServeHTTP(w, r)
	}
}

// withRequireAuth wraps a handler with required auth middleware
func (s *Server) withRequireAuth(handler http.HandlerFunc) http.HandlerFunc {
	jwtConfig := s.config.JWTConfig()
	return func(w http.ResponseWriter, r *http.Request) {
		middleware.AuthMiddleware(jwtConfig)(http.HandlerFunc(handler)).ServeHTTP(w, r)
	}
}

// corsMiddleware handles CORS with configurable origins
func (s *Server) corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		// Check if origin is allowed
		allowed := false
		for _, allowedOrigin := range s.config.AllowedOrigins {
			if allowedOrigin == "*" || allowedOrigin == origin {
				allowed = true
				w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
				break
			}
		}

		if !allowed && len(s.config.AllowedOrigins) > 0 && s.config.AllowedOrigins[0] != "*" {
			logger.Warn("CORS: Origin not allowed", map[string]interface{}{
				"origin": origin,
			})
		}

		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Max-Age", "3600")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// loggingMiddleware logs incoming HTTP requests
func (s *Server) loggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		logger.Info("Incoming request", map[string]interface{}{
			"method": r.Method,
			"path":   r.URL.Path,
			"ip":     r.RemoteAddr,
		})
		next(w, r)
	}
}
