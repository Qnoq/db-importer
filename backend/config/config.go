package config

import (
	"os"
	"strconv"
	"strings"
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
}

// LoadConfig loads configuration from environment variables
func LoadConfig() *Config {
	return &Config{
		Port:              getEnv("PORT", "8080"),
		AllowedOrigins:    parseOrigins(getEnv("ALLOWED_ORIGINS", "*")),
		MaxUploadSize:     parseInt64(getEnv("MAX_UPLOAD_SIZE", "52428800")), // 50MB default
		EnableDebugLog:    parseBool(getEnv("DEBUG_LOG", "false")),
		RateLimitEnabled:  parseBool(getEnv("RATE_LIMIT_ENABLED", "true")),
		RateLimitRequests: parseInt(getEnv("RATE_LIMIT_REQUESTS", "100")),
		RateLimitWindow:   parseInt(getEnv("RATE_LIMIT_WINDOW", "60")), // 60 seconds
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
