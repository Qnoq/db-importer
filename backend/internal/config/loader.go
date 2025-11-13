package config

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"db-importer/internal/utils"

	"github.com/joho/godotenv"
)

// Config holds application configuration
type Config struct {
	// Server
	Port        string
	Environment string // dev, staging, prod
	Version     string

	// Security
	JWTAccessSecret  string
	JWTRefreshSecret string
	JWTAccessExpiry  time.Duration
	JWTRefreshExpiry time.Duration

	// CORS
	AllowedOrigins []string

	// Upload
	MaxUploadSize int64

	// Database
	DatabaseURL       string
	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime time.Duration
	DBConnMaxIdleTime time.Duration

	// Features
	RateLimitEnabled bool
	RateLimitGuest   int // requests per window for guest users
	RateLimitAuth    int // requests per window for authenticated users (0 = unlimited)
	RateLimitWindow  int // window in seconds

	// Observability
	EnableDebugLog bool
	MetricsEnabled bool
}

// Load loads configuration from environment variables and .env files
func Load() (*Config, error) {
	// Determine environment
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "development"
	}

	// Try to load environment files in order of priority:
	// 1. .env.{environment} (e.g., .env.development, .env.production)
	// 2. .env.local (local overrides, gitignored)
	// 3. .env (default, committed to git)

	envFiles := []string{
		".env." + env, // Environment-specific
		".env.local",  // Local overrides (gitignored)
		".env",        // Default
	}

	loaded := false
	for _, file := range envFiles {
		if _, err := os.Stat(file); err == nil {
			if err := godotenv.Load(file); err != nil {
				log.Printf("Warning: Failed to load %s: %v", file, err)
			} else {
				log.Printf("✓ Loaded configuration from %s", file)
				loaded = true
				break
			}
		}
	}

	if !loaded {
		log.Printf("Warning: No .env file found, using environment variables only")
	}

	cfg := &Config{
		Port:        getEnv("PORT", "3000"),
		Environment: env,
		Version:     getEnv("APP_VERSION", "1.0.0"),

		// Security - generate secrets if not provided (dev only)
		JWTAccessSecret:  getOrGenerateSecret("JWT_ACCESS_SECRET", env),
		JWTRefreshSecret: getOrGenerateSecret("JWT_REFRESH_SECRET", env),
		JWTAccessExpiry:  getDuration("JWT_ACCESS_EXPIRY", 15*time.Minute),
		JWTRefreshExpiry: getDuration("JWT_REFRESH_EXPIRY", 7*24*time.Hour),

		// CORS
		AllowedOrigins: parseOrigins(getEnv("ALLOWED_ORIGINS", "*")),

		// Upload
		MaxUploadSize: getInt64("MAX_UPLOAD_SIZE", 52428800), // 50MB default

		// Database
		DatabaseURL:       os.Getenv("DATABASE_URL"),
		DBMaxOpenConns:    getInt("DB_MAX_OPEN_CONNS", 25),
		DBMaxIdleConns:    getInt("DB_MAX_IDLE_CONNS", 5),
		DBConnMaxLifetime: getDuration("DB_CONN_MAX_LIFETIME", 5*time.Minute),
		DBConnMaxIdleTime: getDuration("DB_CONN_MAX_IDLE_TIME", 10*time.Minute),

		// Rate limiting
		RateLimitEnabled: getBool("RATE_LIMIT_ENABLED", true),
		RateLimitGuest:   getInt("RATE_LIMIT_GUEST", 3),
		RateLimitAuth:    getInt("RATE_LIMIT_AUTH", 0),       // 0 = unlimited
		RateLimitWindow:  getInt("RATE_LIMIT_WINDOW", 86400), // 24h default for guest

		// Observability
		EnableDebugLog: getBool("DEBUG_LOG", env == "development"),
		MetricsEnabled: getBool("METRICS_ENABLED", env == "production"),
	}

	// Validate configuration
	if err := cfg.Validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

// Validate checks if the configuration is valid
func (c *Config) Validate() error {
	if c.Port == "" {
		return fmt.Errorf("PORT is required")
	}

	// JWT secrets are required in production
	if c.Environment == "production" {
		if c.JWTAccessSecret == "" || c.JWTRefreshSecret == "" {
			return fmt.Errorf("JWT secrets are required in production")
		}
	}

	if c.MaxUploadSize <= 0 {
		return fmt.Errorf("MAX_UPLOAD_SIZE must be positive")
	}

	return nil
}

// IsDevelopment returns true if running in development mode
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction returns true if running in production mode
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}

// JWTConfig returns the JWT configuration for utils
func (c *Config) JWTConfig() utils.JWTConfig {
	return utils.JWTConfig{
		AccessSecret:  []byte(c.JWTAccessSecret),
		RefreshSecret: []byte(c.JWTRefreshSecret),
		AccessExpiry:  c.JWTAccessExpiry,
		RefreshExpiry: c.JWTRefreshExpiry,
	}
}

// Helper functions

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getBool(key string, defaultValue bool) bool {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	result, err := strconv.ParseBool(value)
	if err != nil {
		log.Printf("Warning: Invalid boolean value for %s, using default %v", key, defaultValue)
		return defaultValue
	}
	return result
}

func getInt(key string, defaultValue int) int {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	result, err := strconv.Atoi(value)
	if err != nil {
		log.Printf("Warning: Invalid integer value for %s, using default %d", key, defaultValue)
		return defaultValue
	}
	return result
}

func getInt64(key string, defaultValue int64) int64 {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	result, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		log.Printf("Warning: Invalid int64 value for %s, using default %d", key, defaultValue)
		return defaultValue
	}
	return result
}

func getDuration(key string, defaultValue time.Duration) time.Duration {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	result, err := time.ParseDuration(value)
	if err != nil {
		log.Printf("Warning: Invalid duration value for %s, using default %s", key, defaultValue)
		return defaultValue
	}
	return result
}

func parseOrigins(value string) []string {
	if value == "*" {
		return []string{"*"}
	}
	origins := strings.Split(value, ",")
	for i, origin := range origins {
		origins[i] = strings.TrimSpace(origin)
	}
	return origins
}

// getOrGenerateSecret gets a secret from env or generates a random one
func getOrGenerateSecret(key, env string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}

	// Only generate in development
	if env == "development" {
		secret := generateRandomSecret(32)
		os.Setenv(key, secret)
		log.Printf("⚠️  WARNING: Generated random %s for development - set it in .env for persistence", key)
		return secret
	}

	// In production, return empty (will fail validation)
	return ""
}

// generateRandomSecret generates a random base64-encoded secret
func generateRandomSecret(length int) string {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		log.Fatalf("Failed to generate random secret: %v", err)
	}
	return base64.StdEncoding.EncodeToString(bytes)
}
