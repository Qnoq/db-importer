package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"db-importer/internal/database"
	"db-importer/internal/models"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"
)

// UserRepository handles database operations for users
type UserRepository struct {
	db *database.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *database.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create creates a new user
func (r *UserRepository) Create(ctx context.Context, user *models.User) error {
	query := `
		INSERT INTO users (email, password_hash, first_name, last_name)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, updated_at, is_active, email_verified
	`

	err := r.db.Sqlx.QueryRowContext(
		ctx,
		query,
		user.Email,
		user.PasswordHash,
		user.FirstName,
		user.LastName,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt, &user.IsActive, &user.EmailVerified)

	if err != nil {
		// Check for unique constraint violation (duplicate email)
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return fmt.Errorf("email already exists")
		}
		return fmt.Errorf("failed to create user: %w", err)
	}

	return nil
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	var user models.User

	query := `
		SELECT id, email, password_hash, first_name, last_name, is_active,
		       email_verified, created_at, updated_at, last_login_at
		FROM users
		WHERE id = $1 AND is_active = true
	`

	err := r.db.Sqlx.GetContext(ctx, &user, query, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	var user models.User

	query := `
		SELECT id, email, password_hash, first_name, last_name, is_active,
		       email_verified, created_at, updated_at, last_login_at
		FROM users
		WHERE email = $1
	`

	err := r.db.Sqlx.GetContext(ctx, &user, query, email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

// Update updates a user
func (r *UserRepository) Update(ctx context.Context, user *models.User) error {
	query := `
		UPDATE users
		SET first_name = $1, last_name = $2, email_verified = $3, is_active = $4
		WHERE id = $5
		RETURNING updated_at
	`

	err := r.db.Sqlx.QueryRowContext(
		ctx,
		query,
		user.FirstName,
		user.LastName,
		user.EmailVerified,
		user.IsActive,
		user.ID,
	).Scan(&user.UpdatedAt)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return fmt.Errorf("user not found")
		}
		return fmt.Errorf("failed to update user: %w", err)
	}

	return nil
}

// UpdateLastLogin updates the last login timestamp
func (r *UserRepository) UpdateLastLogin(ctx context.Context, userID uuid.UUID) error {
	query := `
		UPDATE users
		SET last_login_at = NOW()
		WHERE id = $1
	`

	_, err := r.db.Sqlx.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("failed to update last login: %w", err)
	}

	return nil
}

// Delete soft deletes a user (sets is_active to false)
func (r *UserRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `
		UPDATE users
		SET is_active = false
		WHERE id = $1
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

// EmailExists checks if an email already exists
func (r *UserRepository) EmailExists(ctx context.Context, email string) (bool, error) {
	var exists bool

	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`

	err := r.db.Sqlx.GetContext(ctx, &exists, query, email)
	if err != nil {
		return false, fmt.Errorf("failed to check email existence: %w", err)
	}

	return exists, nil
}
