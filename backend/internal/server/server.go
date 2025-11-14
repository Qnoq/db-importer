package server

import (
	"context"
	"db-importer/internal/config"
	"db-importer/internal/database"
	"db-importer/internal/handler"
	"db-importer/internal/handlers"
	"db-importer/internal/repository"
	"db-importer/internal/service"
	"db-importer/logger"
	"db-importer/middleware"
	"net/http"
	"time"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// Server represents the HTTP server
type Server struct {
	config      *config.Config
	db          *database.DB
	httpServer  *http.Server
	rateLimiter *middleware.RateLimiter

	// Services
	workflowSessionService *service.WorkflowSessionService

	// Handlers
	authHandler           *handler.AuthHandler
	importHandler         *handler.ImportHandler
	workflowSessionHandler *handler.WorkflowSessionHandler
	publicHandler         *handlers.PublicHandler

	// Cleanup
	cleanupCancel context.CancelFunc
}

// New creates a new Server instance
func New(cfg *config.Config) *Server {
	srv := &Server{
		config: cfg,
	}

	// Initialize logger
	logger.Init(cfg.EnableDebugLog)

	logger.Info("Initializing server", map[string]interface{}{
		"port":        cfg.Port,
		"environment": cfg.Environment,
		"version":     cfg.Version,
	})

	// Initialize database if configured
	if cfg.DatabaseURL != "" {
		srv.initDatabase()
	} else {
		logger.Info("Database not configured, running in stateless mode", nil)
	}

	// Initialize handlers
	srv.initHandlers()

	// Initialize rate limiter
	if cfg.RateLimitEnabled {
		srv.rateLimiter = middleware.NewRateLimiter(
			cfg.RateLimitGuest,
			cfg.RateLimitWindow,
			cfg.RateLimitAuth,
			cfg.RateLimitWindow,
		)
		logger.Info("Rate limiting enabled", map[string]interface{}{
			"guestRequests": cfg.RateLimitGuest,
			"guestWindow":   cfg.RateLimitWindow,
			"authRequests":  cfg.RateLimitAuth,
		})
	}

	// Setup HTTP server
	srv.setupHTTPServer()

	return srv
}

// initDatabase initializes the database connection and runs migrations
func (s *Server) initDatabase() {
	logger.Info("Initializing database connection", nil)

	// Run migrations
	if err := s.runMigrations(); err != nil {
		logger.Warn("Database migrations failed (continuing anyway)", map[string]interface{}{
			"error": err.Error(),
		})
	}

	// Initialize database
	dbConfig := database.Config{
		URL:             s.config.DatabaseURL,
		MaxOpenConns:    s.config.DBMaxOpenConns,
		MaxIdleConns:    s.config.DBMaxIdleConns,
		ConnMaxLifetime: s.config.DBConnMaxLifetime,
		ConnMaxIdleTime: s.config.DBConnMaxIdleTime,
	}

	var err error
	s.db, err = database.NewDB(dbConfig)
	if err != nil {
		logger.Warn("Failed to connect to database, running in stateless mode", map[string]interface{}{
			"error": err.Error(),
		})
		s.db = nil
		return
	}

	logger.Info("Database connection established", nil)
}

// runMigrations runs database migrations
func (s *Server) runMigrations() error {
	logger.Info("Running database migrations", nil)

	// Determine migrations path based on environment
	migrationsPath := "file://migrations"
	if s.config.IsProduction() {
		migrationsPath = "file:///app/migrations"
	}

	m, err := migrate.New(
		migrationsPath,
		s.config.DatabaseURL,
	)
	if err != nil {
		return err
	}
	defer m.Close()

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return err
	}

	logger.Info("Database migrations completed successfully", nil)
	return nil
}

// initHandlers initializes all HTTP handlers
func (s *Server) initHandlers() {
	// Public handlers (always available)
	s.publicHandler = handlers.NewPublicHandler(s.config)

	// Database-dependent handlers
	if s.db != nil {
		jwtConfig := s.config.JWTConfig()

		// Initialize repositories
		userRepo := repository.NewUserRepository(s.db)
		refreshTokenRepo := repository.NewRefreshTokenRepository(s.db)
		importRepo := repository.NewImportRepository(s.db)
		workflowSessionRepo := repository.NewWorkflowSessionRepository(s.db)

		// Initialize services
		authService := service.NewAuthService(userRepo, refreshTokenRepo, jwtConfig)
		importService := service.NewImportService(importRepo)
		s.workflowSessionService = service.NewWorkflowSessionService(workflowSessionRepo)

		// Initialize handlers
		s.authHandler = handler.NewAuthHandler(authService)
		s.importHandler = handler.NewImportHandler(importService)
		s.workflowSessionHandler = handler.NewWorkflowSessionHandler(s.workflowSessionService)

		// Start cleanup job for expired workflow sessions
		s.startCleanupJob()

		logger.Info("Authentication, import, and workflow session systems initialized", nil)
	}
}

// setupHTTPServer configures the HTTP server and routes
func (s *Server) setupHTTPServer() {
	mux := http.NewServeMux()

	// Setup routes
	s.setupRoutes(mux)

	// Apply global middlewares
	handler := s.applyMiddlewares(mux)

	s.httpServer = &http.Server{
		Addr:         ":" + s.config.Port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
}

// applyMiddlewares applies global middlewares to the handler
func (s *Server) applyMiddlewares(handler http.Handler) http.Handler {
	// Middleware chain is applied in reverse order
	// Last middleware wraps first

	// Add any global middlewares here if needed
	// For now, middlewares are applied per-route in setupRoutes

	return handler
}

// Start starts the HTTP server
func (s *Server) Start() error {
	logger.Info("Starting server", map[string]interface{}{
		"address": s.httpServer.Addr,
	})

	return s.httpServer.ListenAndServe()
}

// startCleanupJob starts a background job to cleanup expired workflow sessions
func (s *Server) startCleanupJob() {
	if s.workflowSessionService == nil {
		return
	}

	ctx, cancel := context.WithCancel(context.Background())
	s.cleanupCancel = cancel

	go func() {
		// Run immediately on startup
		s.cleanupExpiredSessions()

		// Then run every hour
		ticker := time.NewTicker(1 * time.Hour)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				s.cleanupExpiredSessions()
			case <-ctx.Done():
				logger.Info("Cleanup job stopped", nil)
				return
			}
		}
	}()

	logger.Info("Workflow session cleanup job started (runs every hour)", nil)
}

// cleanupExpiredSessions removes expired workflow sessions
func (s *Server) cleanupExpiredSessions() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	deleted, err := s.workflowSessionService.CleanupExpiredSessions(ctx)
	if err != nil {
		logger.Error("Failed to cleanup expired workflow sessions", err)
		return
	}

	if deleted > 0 {
		logger.Info("Cleaned up expired workflow sessions", map[string]interface{}{
			"deleted_count": deleted,
		})
	}
}

// Shutdown gracefully shuts down the server
func (s *Server) Shutdown(ctx context.Context) error {
	logger.Info("Shutting down server", nil)

	// Stop cleanup job
	if s.cleanupCancel != nil {
		s.cleanupCancel()
	}

	// Shutdown HTTP server
	if err := s.httpServer.Shutdown(ctx); err != nil {
		logger.Error("Server shutdown error", err)
		return err
	}

	// Close database connection
	if s.db != nil {
		s.db.Close()
	}

	logger.Info("Server shut down successfully", nil)
	return nil
}
