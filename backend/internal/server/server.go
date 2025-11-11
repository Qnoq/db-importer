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
	"fmt"
	"net"
	"net/http"
	"net/url"
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

	// Handlers
	authHandler   *handler.AuthHandler
	importHandler *handler.ImportHandler
	publicHandler *handlers.PublicHandler
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

	// Resolve DATABASE_URL to IPv4 for golang-migrate compatibility
	// golang-migrate creates its own connection and doesn't use our custom resolver
	databaseURL, err := resolveIPv4InURL(s.config.DatabaseURL)
	if err != nil {
		logger.Warn("Failed to resolve IPv4 address, using original URL", map[string]interface{}{
			"error": err.Error(),
		})
		databaseURL = s.config.DatabaseURL
	}

	m, err := migrate.New(
		migrationsPath,
		databaseURL,
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

		// Initialize services
		authService := service.NewAuthService(userRepo, refreshTokenRepo, jwtConfig)
		importService := service.NewImportService(importRepo)

		// Initialize handlers
		s.authHandler = handler.NewAuthHandler(authService)
		s.importHandler = handler.NewImportHandler(importService)

		logger.Info("Authentication and import systems initialized", nil)
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

// Shutdown gracefully shuts down the server
func (s *Server) Shutdown(ctx context.Context) error {
	logger.Info("Shutting down server", nil)

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

// resolveIPv4InURL resolves the hostname in a PostgreSQL connection URL to IPv4
// This is necessary for golang-migrate which doesn't use our custom resolver
func resolveIPv4InURL(dbURL string) (string, error) {
	// Parse the URL
	parsedURL, err := url.Parse(dbURL)
	if err != nil {
		return "", fmt.Errorf("failed to parse database URL: %w", err)
	}

	// Extract hostname (without port)
	hostname := parsedURL.Hostname()
	port := parsedURL.Port()

	// Check if it's already an IP address
	if ip := net.ParseIP(hostname); ip != nil {
		// Already an IP, return as-is
		return dbURL, nil
	}

	// Resolve to IPv4 only
	resolver := &net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			d := net.Dialer{Timeout: 10 * time.Second}
			return d.DialContext(ctx, "udp4", address)
		},
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	addrs, err := resolver.LookupHost(ctx, hostname)
	if err != nil {
		return "", fmt.Errorf("failed to resolve hostname %s: %w", hostname, err)
	}

	// Find first IPv4 address
	var ipv4Addr string
	for _, addr := range addrs {
		if ip := net.ParseIP(addr); ip != nil && ip.To4() != nil {
			ipv4Addr = addr
			break
		}
	}

	if ipv4Addr == "" {
		return "", fmt.Errorf("no IPv4 address found for hostname %s", hostname)
	}

	// Replace hostname with IPv4 in the URL
	newHost := ipv4Addr
	if port != "" {
		newHost = net.JoinHostPort(ipv4Addr, port)
	}

	parsedURL.Host = newHost
	resolvedURL := parsedURL.String()

	logger.Info("Resolved database hostname to IPv4", map[string]interface{}{
		"hostname": hostname,
		"ipv4":     ipv4Addr,
	})

	return resolvedURL, nil
}
