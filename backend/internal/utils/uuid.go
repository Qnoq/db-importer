package utils

import (
	"fmt"

	"github.com/google/uuid"
)

// ParseUUID parses a string into a UUID
func ParseUUID(s string) (uuid.UUID, error) {
	uid, err := uuid.Parse(s)
	if err != nil {
		return uuid.Nil, fmt.Errorf("invalid UUID: %w", err)
	}
	return uid, nil
}
