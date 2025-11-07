package utils

import (
	"errors"

	"golang.org/x/crypto/bcrypt"
)

const (
	// BcryptCost is the cost factor for bcrypt hashing
	// Cost 12 = ~250ms on modern hardware (good balance between security and UX)
	BcryptCost = 12
)

var (
	ErrPasswordTooLong = errors.New("password is too long (max 72 bytes)")
)

// HashPassword creates a bcrypt hash of the password
func HashPassword(password string) (string, error) {
	// bcrypt has a maximum password length of 72 bytes
	if len(password) > 72 {
		return "", ErrPasswordTooLong
	}

	bytes, err := bcrypt.GenerateFromPassword([]byte(password), BcryptCost)
	if err != nil {
		return "", err
	}

	return string(bytes), nil
}

// CheckPassword compares a password with its hash
func CheckPassword(password, hash string) error {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
}
