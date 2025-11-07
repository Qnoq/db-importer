package models

import (
	"time"

	"github.com/google/uuid"
)

// RefreshToken represents a refresh token in the database
type RefreshToken struct {
	ID        uuid.UUID  `db:"id" json:"id"`
	UserID    uuid.UUID  `db:"user_id" json:"userId"`
	TokenHash string     `db:"token_hash" json:"-"` // Never expose token hash
	ExpiresAt time.Time  `db:"expires_at" json:"expiresAt"`
	CreatedAt time.Time  `db:"created_at" json:"createdAt"`
	Revoked   bool       `db:"revoked" json:"revoked"`
	RevokedAt *time.Time `db:"revoked_at" json:"revokedAt,omitempty"`
}

// IsValid checks if the refresh token is valid (not expired and not revoked)
func (rt *RefreshToken) IsValid() bool {
	return !rt.Revoked && time.Now().Before(rt.ExpiresAt)
}
