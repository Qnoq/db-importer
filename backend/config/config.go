package config

import (
	"os"
	"strconv"
	"strings"
	"time"
)

// Config holds application configuration
type Config struct {
	Port              string
	AllowedOrigins    []string
	MaxUploadSize     int64
	EnableDebugLog    bool
	RateLimitEnabled  bool
	RateLimitRequests int
	RateLimitWindow   int // seconds

	// Database configuration
	DatabaseURL       string
	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime time.Duration
	DBConnMaxIdleTime time.Duration

	// JWT configuration
	JWTAccessSecret  string
	JWTRefreshSecret string
	JWTAccessExpiry  time.Duration
	JWTRefreshExpiry time.Duration
}

// LoadConfig loads configuration from environment variables
func LoadConfig() *Config {
	return &Config{
		Port:              getEnv("PORT", "3000"),
		AllowedOrigins:    parseOrigins(getEnv("ALLOWED_ORIGINS", "*")),
		MaxUploadSize:     parseInt64(getEnv("MAX_UPLOAD_SIZE", "52428800")), // 50MB default
		EnableDebugLog:    parseBool(getEnv("DEBUG_LOG", "false")),
		RateLimitEnabled:  parseBool(getEnv("RATE_LIMIT_ENABLED", "true")),
		RateLimitRequests: parseInt(getEnv("RATE_LIMIT_REQUESTS", "100")),
		RateLimitWindow:   parseInt(getEnv("RATE_LIMIT_WINDOW", "60")), // 60 seconds

		// Database configuration
		DatabaseURL:       getEnv("DATABASE_URL", ""),
		DBMaxOpenConns:    parseInt(getEnv("DB_MAX_OPEN_CONNS", "25")),
		DBMaxIdleConns:    parseInt(getEnv("DB_MAX_IDLE_CONNS", "5")),
		DBConnMaxLifetime: parseDuration(getEnv("DB_CONN_MAX_LIFETIME", "5m")),
		DBConnMaxIdleTime: parseDuration(getEnv("DB_CONN_MAX_IDLE_TIME", "10m")),

		// JWT configuration
		JWTAccessSecret:  getEnv("JWT_ACCESS_SECRET", ""),
		JWTRefreshSecret: getEnv("JWT_REFRESH_SECRET", ""),
		JWTAccessExpiry:  parseDuration(getEnv("JWT_ACCESS_EXPIRY", "15m")),
		JWTRefreshExpiry: parseDuration(getEnv("JWT_REFRESH_EXPIRY", "168h")), // 7 days
	}
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

// parseBool parses a string to bool
func parseBool(value string) bool {
	result, _ := strconv.ParseBool(value)
	return result
}

// parseInt parses a string to int
func parseInt(value string) int {
	result, err := strconv.Atoi(value)
	if err != nil {
		return 0
	}
	return result
}

// parseInt64 parses a string to int64
func parseInt64(value string) int64 {
	result, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return 0
	}
	return result
}

// parseOrigins parses comma-separated origins
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

// parseDuration parses a string to time.Duration
func parseDuration(value string) time.Duration {
	duration, err := time.ParseDuration(value)
	if err != nil {
		return 0
	}
	return duration
}
