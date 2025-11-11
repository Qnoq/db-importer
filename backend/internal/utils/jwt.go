package utils

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// JWTClaims represents the claims in a JWT token
type JWTClaims struct {
	UserID string `json:"sub"`
	Email  string `json:"email"`
	Type   string `json:"type"` // "access" or "refresh"
	jwt.RegisteredClaims
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	AccessSecret  []byte
	RefreshSecret []byte
	AccessExpiry  time.Duration
	RefreshExpiry time.Duration
}

var (
	ErrInvalidToken  = errors.New("invalid token")
	ErrExpiredToken  = errors.New("token has expired")
	ErrInvalidType   = errors.New("invalid token type")
	ErrInvalidClaims = errors.New("invalid token claims")
)

// GenerateAccessToken creates a new access token for a user
func GenerateAccessToken(userID uuid.UUID, email string, cfg JWTConfig) (string, error) {
	claims := &JWTClaims{
		UserID: userID.String(),
		Email:  email,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(cfg.AccessExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(cfg.AccessSecret)
}

// GenerateRefreshToken creates a new refresh token for a user
func GenerateRefreshToken(userID uuid.UUID, cfg JWTConfig) (string, uuid.UUID, error) {
	jti := uuid.New()

	claims := &JWTClaims{
		UserID: userID.String(),
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        jti.String(),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(cfg.RefreshExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString(cfg.RefreshSecret)
	if err != nil {
		return "", uuid.Nil, err
	}

	return signedToken, jti, nil
}

// ValidateAccessToken validates an access token and returns the claims
func ValidateAccessToken(tokenString string, cfg JWTConfig) (*JWTClaims, error) {
	return validateToken(tokenString, cfg.AccessSecret, "access")
}

// ValidateRefreshToken validates a refresh token and returns the claims
func ValidateRefreshToken(tokenString string, cfg JWTConfig) (*JWTClaims, error) {
	return validateToken(tokenString, cfg.RefreshSecret, "refresh")
}

// validateToken is a helper function to validate tokens
func validateToken(tokenString string, secret []byte, expectedType string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Verify signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return secret, nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrExpiredToken
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidClaims
	}

	// Verify token type
	if claims.Type != expectedType {
		return nil, ErrInvalidType
	}

	return claims, nil
}

// HashRefreshToken creates a SHA256 hash of the refresh token for secure storage
func HashRefreshToken(token string) string {
	hash := sha256.Sum256([]byte(token))
	return hex.EncodeToString(hash[:])
}
