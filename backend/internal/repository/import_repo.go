package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"db-importer/internal/database"
	"db-importer/internal/models"

	"github.com/google/uuid"
)

// ImportRepository handles database operations for imports
type ImportRepository struct {
	db *database.DB
}

// NewImportRepository creates a new ImportRepository
func NewImportRepository(db *database.DB) *ImportRepository {
	return &ImportRepository{db: db}
}

// Create creates a new import record
func (r *ImportRepository) Create(ctx context.Context, imp *models.Import) error {
	query := `
		INSERT INTO imports (
			user_id, table_name, row_count, status, generated_sql,
			error_count, warning_count, metadata
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at
	`

	err := r.db.Sqlx.QueryRowContext(
		ctx,
		query,
		imp.UserID,
		imp.TableName,
		imp.RowCount,
		imp.Status,
		imp.GeneratedSQL,
		imp.ErrorCount,
		imp.WarningCount,
		imp.Metadata,
	).Scan(&imp.ID, &imp.CreatedAt, &imp.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to create import: %w", err)
	}

	return nil
}

// GetByID retrieves an import by ID (without SQL)
func (r *ImportRepository) GetByID(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*models.Import, error) {
	var imp models.Import

	query := `
		SELECT id, user_id, table_name, row_count, status,
		       error_count, warning_count, metadata,
		       created_at, updated_at
		FROM imports
		WHERE id = $1 AND user_id = $2
	`

	err := r.db.Sqlx.GetContext(ctx, &imp, query, id, userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("import not found")
		}
		return nil, fmt.Errorf("failed to get import: %w", err)
	}

	return &imp, nil
}

// GetByIDWithSQL retrieves an import by ID including the generated SQL
func (r *ImportRepository) GetByIDWithSQL(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*models.Import, error) {
	var imp models.Import

	query := `
		SELECT id, user_id, table_name, row_count, status, generated_sql,
		       error_count, warning_count, metadata,
		       created_at, updated_at
		FROM imports
		WHERE id = $1 AND user_id = $2
	`

	err := r.db.Sqlx.GetContext(ctx, &imp, query, id, userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("import not found")
		}
		return nil, fmt.Errorf("failed to get import: %w", err)
	}

	return &imp, nil
}

// List retrieves imports with pagination and filters
func (r *ImportRepository) List(ctx context.Context, userID uuid.UUID, req *models.GetImportsRequest) ([]*models.Import, int64, error) {
	// Set defaults
	page := 1
	pageSize := 20
	sortBy := "created_at"
	sortOrder := "desc"

	if req.Page > 0 {
		page = req.Page
	}
	if req.PageSize > 0 && req.PageSize <= 100 {
		pageSize = req.PageSize
	}
	if req.SortBy != "" {
		sortBy = req.SortBy
	}
	if req.SortOrder != "" {
		sortOrder = req.SortOrder
	}

	// Build WHERE clause
	whereConditions := []string{"user_id = $1"}
	args := []interface{}{userID}
	argCounter := 2

	if req.TableName != "" {
		whereConditions = append(whereConditions, fmt.Sprintf("table_name ILIKE $%d", argCounter))
		args = append(args, "%"+req.TableName+"%")
		argCounter++
	}

	if req.Status != "" {
		whereConditions = append(whereConditions, fmt.Sprintf("status = $%d", argCounter))
		args = append(args, req.Status)
		argCounter++
	}

	whereClause := strings.Join(whereConditions, " AND ")

	// Get total count
	countQuery := fmt.Sprintf(`
		SELECT COUNT(*)
		FROM imports
		WHERE %s
	`, whereClause)

	var total int64
	err := r.db.Sqlx.GetContext(ctx, &total, countQuery, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count imports: %w", err)
	}

	// Get paginated results
	offset := (page - 1) * pageSize

	query := fmt.Sprintf(`
		SELECT id, user_id, table_name, row_count, status,
		       error_count, warning_count, metadata,
		       created_at, updated_at
		FROM imports
		WHERE %s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argCounter, argCounter+1)

	args = append(args, pageSize, offset)

	var imports []*models.Import
	err = r.db.Sqlx.SelectContext(ctx, &imports, query, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list imports: %w", err)
	}

	return imports, total, nil
}

// Delete deletes an import by ID
func (r *ImportRepository) Delete(ctx context.Context, id uuid.UUID, userID uuid.UUID) error {
	query := `
		DELETE FROM imports
		WHERE id = $1 AND user_id = $2
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query, id, userID)
	if err != nil {
		return fmt.Errorf("failed to delete import: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("import not found")
	}

	return nil
}

// GetStats retrieves statistics about user's imports
func (r *ImportRepository) GetStats(ctx context.Context, userID uuid.UUID) (*models.ImportStats, error) {
	query := `
		SELECT
			COUNT(*) as total_imports,
			COALESCE(SUM(row_count), 0) as total_rows,
			COUNT(*) FILTER (WHERE status = 'success') as success_count,
			COUNT(*) FILTER (WHERE status = 'warning') as warning_count,
			COUNT(*) FILTER (WHERE status = 'failed') as failed_count,
			MAX(created_at) as last_import_date
		FROM imports
		WHERE user_id = $1
	`

	var stats struct {
		TotalImports   int           `db:"total_imports"`
		TotalRows      int64         `db:"total_rows"`
		SuccessCount   int           `db:"success_count"`
		WarningCount   int           `db:"warning_count"`
		FailedCount    int           `db:"failed_count"`
		LastImportDate *sql.NullTime `db:"last_import_date"`
	}

	err := r.db.Sqlx.GetContext(ctx, &stats, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get import stats: %w", err)
	}

	// Calculate success rate
	successRate := 0.0
	if stats.TotalImports > 0 {
		successRate = float64(stats.SuccessCount) / float64(stats.TotalImports) * 100
	}

	// Get most used table
	mostUsedQuery := `
		SELECT table_name
		FROM imports
		WHERE user_id = $1
		GROUP BY table_name
		ORDER BY COUNT(*) DESC
		LIMIT 1
	`

	var mostUsedTable sql.NullString
	_ = r.db.Sqlx.GetContext(ctx, &mostUsedTable, mostUsedQuery, userID)

	result := &models.ImportStats{
		TotalImports: stats.TotalImports,
		TotalRows:    stats.TotalRows,
		SuccessCount: stats.SuccessCount,
		WarningCount: stats.WarningCount,
		FailedCount:  stats.FailedCount,
		SuccessRate:  successRate,
	}

	if mostUsedTable.Valid {
		result.MostUsedTable = mostUsedTable.String
	}

	if stats.LastImportDate != nil && stats.LastImportDate.Valid {
		result.LastImportDate = &stats.LastImportDate.Time
	}

	return result, nil
}

// DeleteOldImports deletes imports older than the specified number of days
func (r *ImportRepository) DeleteOldImports(ctx context.Context, userID uuid.UUID, olderThanDays int) (int64, error) {
	query := `
		DELETE FROM imports
		WHERE user_id = $1 AND created_at < NOW() - INTERVAL '1 day' * $2
	`

	result, err := r.db.Sqlx.ExecContext(ctx, query, userID, olderThanDays)
	if err != nil {
		return 0, fmt.Errorf("failed to delete old imports: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return 0, fmt.Errorf("failed to get rows affected: %w", err)
	}

	return rowsAffected, nil
}
