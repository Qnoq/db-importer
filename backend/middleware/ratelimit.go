package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
)

// RateLimiter implements a simple token bucket rate limiter with different limits for guests and authenticated users
type RateLimiter struct {
	requests    map[string]*clientLimit
	mu          sync.RWMutex
	guestLimit  int           // Limit for guest users
	authLimit   int           // Limit for authenticated users (0 = unlimited)
	guestWindow time.Duration // Time window for guest users
	authWindow  time.Duration // Time window for authenticated users
}

type clientLimit struct {
	count     int
	resetTime time.Time
}

// NewRateLimiter creates a new rate limiter with different limits for guests and authenticated users
func NewRateLimiter(guestRequests int, guestWindowSeconds int, authRequests int, authWindowSeconds int) *RateLimiter {
	rl := &RateLimiter{
		requests:    make(map[string]*clientLimit),
		guestLimit:  guestRequests,
		authLimit:   authRequests,
		guestWindow: time.Duration(guestWindowSeconds) * time.Second,
		authWindow:  time.Duration(authWindowSeconds) * time.Second,
	}

	// Cleanup old entries every minute
	go rl.cleanup()

	return rl
}

// RateLimit middleware checks rate limits per IP for guest users and per user ID for authenticated users
func (rl *RateLimiter) RateLimit(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Check if user is authenticated by looking at context
		userID, isAuthenticated := r.Context().Value("userID").(uuid.UUID)

		var identifier string
		var limit int
		var window time.Duration

		if isAuthenticated {
			// Use user ID for authenticated users
			identifier = "user:" + userID.String()
			limit = rl.authLimit
			window = rl.authWindow
		} else {
			// Use IP for guest users
			identifier = "ip:" + getClientIP(r)
			limit = rl.guestLimit
			window = rl.guestWindow
		}

		// If auth limit is 0, it means unlimited for authenticated users
		if isAuthenticated && rl.authLimit == 0 {
			next(w, r)
			return
		}

		if !rl.allow(identifier, limit, window) {
			remainingTime := rl.getRemainingTime(identifier)
			if isAuthenticated {
				http.Error(w, "Rate limit exceeded. Please try again later.", http.StatusTooManyRequests)
			} else {
				http.Error(w,
					"Rate limit exceeded for guest users (3 requests per day). Please sign in for unlimited access or try again in "+remainingTime,
					http.StatusTooManyRequests)
			}
			return
		}

		next(w, r)
	}
}

// allow checks if a request from an identifier is allowed
func (rl *RateLimiter) allow(identifier string, limit int, window time.Duration) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()

	client, exists := rl.requests[identifier]
	if !exists || now.After(client.resetTime) {
		rl.requests[identifier] = &clientLimit{
			count:     1,
			resetTime: now.Add(window),
		}
		return true
	}

	if client.count >= limit {
		return false
	}

	client.count++
	return true
}

// getRemainingTime returns the remaining time until the rate limit resets
func (rl *RateLimiter) getRemainingTime(identifier string) string {
	rl.mu.RLock()
	defer rl.mu.RUnlock()

	client, exists := rl.requests[identifier]
	if !exists {
		return "0s"
	}

	remaining := time.Until(client.resetTime)
	if remaining < 0 {
		return "0s"
	}

	// Format the remaining time nicely
	if remaining > 24*time.Hour {
		hours := int(remaining.Hours())
		return (time.Duration(hours) * time.Hour).String()
	}

	return remaining.Round(time.Second).String()
}

// cleanup removes expired entries
func (rl *RateLimiter) cleanup() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()

	for range ticker.C {
		rl.mu.Lock()
		now := time.Now()
		for id, client := range rl.requests {
			if now.After(client.resetTime) {
				delete(rl.requests, id)
			}
		}
		rl.mu.Unlock()
	}
}

// getClientIP extracts the client IP from the request
func getClientIP(r *http.Request) string {
	// Check X-Forwarded-For header first (for proxies)
	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		return forwarded
	}

	// Check X-Real-IP header
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	// Fall back to RemoteAddr
	return r.RemoteAddr
}
