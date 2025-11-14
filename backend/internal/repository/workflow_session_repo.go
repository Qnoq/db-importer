package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"db-importer/internal/database"
	"db-importer/internal/models"

	"github.com/google/uuid"
)

// WorkflowSessionRepository handles database operations for workflow sessions
type WorkflowSessionRepository struct {
	db *database.DB
}

// NewWorkflowSessionRepository creates a new WorkflowSessionRepository
func NewWorkflowSessionRepository(db *database.DB) *WorkflowSessionRepository {
	return &WorkflowSessionRepository{db: db}
}

// GetByUserID retrieves the active workflow session for a user
func (r *WorkflowSessionRepository) GetByUserID(ctx context.Context, userID uuid.UUID) (*models.WorkflowSession, error) {
	var session models.WorkflowSession

	query := `
		SELECT id, user_id, current_step, schema_content, schema_tables,
		       selected_table_name, data_file_name, data_headers, sample_data,
		       column_mapping, field_transformations, expires_at, created_at, updated_at
		FROM workflow_sessions
		WHERE user_id = $1 AND expires_at > NOW()
	`

	err := r.db.Sqlx.GetContext(ctx, &session, query, userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil // No session found is not an error
		}
		return nil, fmt.Errorf("failed to get workflow session: %w", err)
	}

	return &session, nil
}

// Create creates a new workflow session (replaces existing one for user)
func (r *WorkflowSessionRepository) Create(ctx context.Context, session *models.WorkflowSession) error {
	// Delete existing session first (due to unique constraint on user_id)
	_, _ = r.db.Sqlx.ExecContext(ctx, "DELETE FROM workflow_sessions WHERE user_id = $1", session.UserID)

	query := `
		INSERT INTO workflow_sessions (
			user_id, current_step, schema_content, schema_tables,
			selected_table_name, data_file_name, data_headers, sample_data,
			column_mapping, field_transformations, expires_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at
	`

	err := r.db.Sqlx.QueryRowContext(
		ctx,
		query,
		session.UserID,
		session.CurrentStep,
		session.SchemaContent,
		session.SchemaTables,
		session.SelectedTableName,
		session.DataFileName,
		session.DataHeaders,
		session.SampleData,
		session.ColumnMapping,
		session.FieldTransformations,
		session.ExpiresAt,
	).Scan(&session.ID, &session.CreatedAt, &session.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to create workflow session: %w", err)
	}

	return nil
}

// Update updates an existing workflow session
func (r *WorkflowSessionRepository) Update(ctx context.Context, session *models.WorkflowSession) error {
	query := `
		UPDATE workflow_sessions
		SET current_step = $1,
		    schema_content = $2,
		    schema_tables = $3,
		    selected_table_name = $4,
		    data_file_name = $5,
		    data_headers = $6,
		    sample_data = $7,
		    column_mapping = $8,
		    field_transformations = $9,
		    expires_at = $10
		WHERE id = $11 AND user_id = $12
		RETURNING updated_at
	`

	err := r.db.Sqlx.QueryRowContext(
		ctx,
		query,
		session.CurrentStep,
		session.SchemaContent,
		session.SchemaTables,
		session.SelectedTableName,
		session.DataFileName,
		session.DataHeaders,
		session.SampleData,
		session.ColumnMapping,
		session.FieldTransformations,
		session.ExpiresAt,
		session.ID,
		session.UserID,
	).Scan(&session.UpdatedAt)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return fmt.Errorf("workflow session not found")
		}
		return fmt.Errorf("failed to update workflow session: %w", err)
	}

	return nil
}

// UpdateStep updates only the current step
func (r *WorkflowSessionRepository) UpdateStep(ctx context.Context, userID uuid.UUID, step int) error {
	query := `
		UPDATE workflow_sessions
		SET current_step = $1
		WHERE user_id = $2 AND expires_at > NOW()
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query, step, userID)
	if err != nil {
		return fmt.Errorf("failed to update workflow step: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("workflow session not found or expired")
	}

	return nil
}

// Delete deletes a workflow session
func (r *WorkflowSessionRepository) Delete(ctx context.Context, userID uuid.UUID) error {
	query := `
		DELETE FROM workflow_sessions
		WHERE user_id = $1
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("failed to delete workflow session: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("workflow session not found")
	}

	return nil
}

// DeleteExpired deletes all expired workflow sessions
func (r *WorkflowSessionRepository) DeleteExpired(ctx context.Context) (int64, error) {
	query := `
		DELETE FROM workflow_sessions
		WHERE expires_at <= NOW()
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query)
	if err != nil {
		return 0, fmt.Errorf("failed to delete expired workflow sessions: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("failed to get rows affected: %w", err)
	}

	return rowsAffected, nil
}

// ExtendExpiration extends the expiration time of a session
func (r *WorkflowSessionRepository) ExtendExpiration(ctx context.Context, userID uuid.UUID, days int) error {
	query := `
		UPDATE workflow_sessions
		SET expires_at = NOW() + INTERVAL '%d days'
		WHERE user_id = $1 AND expires_at > NOW()
	`

	result, err := r.db.Sqlx.ExecContext(ctx, fmt.Sprintf(query, days), userID)
	if err != nil {
		return fmt.Errorf("failed to extend expiration: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("workflow session not found or expired")
	}

	return nil
}
