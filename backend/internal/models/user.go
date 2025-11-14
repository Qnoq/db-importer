package models

import (
	"time"

	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID            uuid.UUID  `db:"id" json:"id"`
	Email         string     `db:"email" json:"email"`
	PasswordHash  string     `db:"password_hash" json:"-"` // Never expose password hash
	FirstName     *string    `db:"first_name" json:"firstName,omitempty"`
	LastName      *string    `db:"last_name" json:"lastName,omitempty"`
	IsActive      bool       `db:"is_active" json:"isActive"`
	EmailVerified bool       `db:"email_verified" json:"emailVerified"`
	CreatedAt     time.Time  `db:"created_at" json:"createdAt"`
	UpdatedAt     time.Time  `db:"updated_at" json:"updatedAt"`
	LastLoginAt   *time.Time `db:"last_login_at" json:"lastLoginAt,omitempty"`
}

// UserResponse is the sanitized user response (no sensitive data)
type UserResponse struct {
	ID            uuid.UUID  `json:"id"`
	Email         string     `json:"email"`
	FirstName     *string    `json:"firstName,omitempty"`
	LastName      *string    `json:"lastName,omitempty"`
	IsActive      bool       `json:"isActive"`
	EmailVerified bool       `json:"emailVerified"`
	CreatedAt     time.Time  `json:"createdAt"`
	LastLoginAt   *time.Time `json:"lastLoginAt,omitempty"`
}

// ToResponse converts User to UserResponse
func (u *User) ToResponse() *UserResponse {
	return &UserResponse{
		ID:            u.ID,
		Email:         u.Email,
		FirstName:     u.FirstName,
		LastName:      u.LastName,
		IsActive:      u.IsActive,
		EmailVerified: u.EmailVerified,
		CreatedAt:     u.CreatedAt,
		LastLoginAt:   u.LastLoginAt,
	}
}

// CreateUserRequest represents the request to create a new user
type CreateUserRequest struct {
	Email     string  `json:"email" validate:"required,email"`
	Password  string  `json:"password" validate:"required,min=8,max=72"` // bcrypt max 72 bytes
	FirstName *string `json:"firstName,omitempty" validate:"omitempty,min=1,max=100"`
	LastName  *string `json:"lastName,omitempty" validate:"omitempty,min=1,max=100"`
}

// LoginRequest represents the login credentials
type LoginRequest struct {
	Email      string `json:"email" validate:"required,email"`
	Password   string `json:"password" validate:"required"`
	RememberMe bool   `json:"rememberMe"`
}

// LoginResponse represents the response after successful login
type LoginResponse struct {
	AccessToken  string        `json:"accessToken"`
	RefreshToken string        `json:"refreshToken"`
	User         *UserResponse `json:"user"`
}

// RefreshTokenRequest represents the request to refresh an access token
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" validate:"required"`
}

// RefreshTokenResponse represents the response after refreshing tokens
type RefreshTokenResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}
