package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// ImportStatus represents the status of an import
type ImportStatus string

const (
	ImportStatusSuccess ImportStatus = "success"
	ImportStatusWarning ImportStatus = "warning"
	ImportStatusFailed  ImportStatus = "failed"
)

// ImportMetadata contains additional information about the import
type ImportMetadata struct {
	SourceFileName   string                 `json:"sourceFileName,omitempty"`
	MappingSummary   map[string]string      `json:"mappingSummary,omitempty"`   // column -> source column
	Transformations  []string               `json:"transformations,omitempty"`  // list of transformations applied
	DatabaseType     string                 `json:"databaseType,omitempty"`     // mysql, postgresql, etc.
	ValidationErrors []string               `json:"validationErrors,omitempty"` // error messages if any
	ValidationWarnings []string             `json:"validationWarnings,omitempty"` // warning messages if any
	Extra            map[string]interface{} `json:"extra,omitempty"`            // any additional data
}

// Scan implements the sql.Scanner interface for ImportMetadata
func (m *ImportMetadata) Scan(value interface{}) error {
	if value == nil {
		*m = ImportMetadata{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, m)
}

// Value implements the driver.Valuer interface for ImportMetadata
func (m ImportMetadata) Value() (driver.Value, error) {
	return json.Marshal(m)
}

// Import represents an import record in the database
type Import struct {
	ID           uuid.UUID       `db:"id" json:"id"`
	UserID       uuid.UUID       `db:"user_id" json:"userId"`
	TableName    string          `db:"table_name" json:"tableName"`
	RowCount     int             `db:"row_count" json:"rowCount"`
	Status       ImportStatus    `db:"status" json:"status"`
	GeneratedSQL *string         `db:"generated_sql" json:"-"` // Compressed, not exposed in JSON
	ErrorCount   int             `db:"error_count" json:"errorCount"`
	WarningCount int             `db:"warning_count" json:"warningCount"`
	Metadata     ImportMetadata  `db:"metadata" json:"metadata"`
	CreatedAt    time.Time       `db:"created_at" json:"createdAt"`
	UpdatedAt    time.Time       `db:"updated_at" json:"updatedAt"`
}

// ImportResponse is the response returned to clients
type ImportResponse struct {
	ID           uuid.UUID      `json:"id"`
	UserID       uuid.UUID      `json:"userId"`
	TableName    string         `json:"tableName"`
	RowCount     int            `json:"rowCount"`
	Status       ImportStatus   `json:"status"`
	ErrorCount   int            `json:"errorCount"`
	WarningCount int            `json:"warningCount"`
	Metadata     ImportMetadata `json:"metadata"`
	CreatedAt    time.Time      `json:"createdAt"`
	UpdatedAt    time.Time      `json:"updatedAt"`
}

// ToResponse converts Import to ImportResponse
func (i *Import) ToResponse() *ImportResponse {
	return &ImportResponse{
		ID:           i.ID,
		UserID:       i.UserID,
		TableName:    i.TableName,
		RowCount:     i.RowCount,
		Status:       i.Status,
		ErrorCount:   i.ErrorCount,
		WarningCount: i.WarningCount,
		Metadata:     i.Metadata,
		CreatedAt:    i.CreatedAt,
		UpdatedAt:    i.UpdatedAt,
	}
}

// ImportWithSQL includes the generated SQL (for download)
type ImportWithSQL struct {
	ImportResponse
	GeneratedSQL string `json:"generatedSql"` // Decompressed SQL
}

// CreateImportRequest represents the request to create a new import record
type CreateImportRequest struct {
	TableName    string         `json:"tableName" validate:"required,min=1,max=255"`
	RowCount     int            `json:"rowCount" validate:"required,gte=0"`
	Status       ImportStatus   `json:"status" validate:"required,oneof=success warning failed"`
	GeneratedSQL string         `json:"generatedSql" validate:"required"` // Will be compressed before storage
	ErrorCount   int            `json:"errorCount" validate:"gte=0"`
	WarningCount int            `json:"warningCount" validate:"gte=0"`
	Metadata     ImportMetadata `json:"metadata"`
}

// GetImportsRequest represents query parameters for listing imports
type GetImportsRequest struct {
	TableName string       `form:"tableName"`
	Status    ImportStatus `form:"status"`
	Page      int          `form:"page" validate:"omitempty,gte=1"`
	PageSize  int          `form:"pageSize" validate:"omitempty,gte=1,lte=100"`
	SortBy    string       `form:"sortBy" validate:"omitempty,oneof=created_at table_name row_count"`
	SortOrder string       `form:"sortOrder" validate:"omitempty,oneof=asc desc"`
}

// GetImportsResponse represents paginated imports response
type GetImportsResponse struct {
	Imports    []*ImportResponse `json:"imports"`
	Total      int64             `json:"total"`
	Page       int               `json:"page"`
	PageSize   int               `json:"pageSize"`
	TotalPages int               `json:"totalPages"`
}

// ImportStats represents statistics about user's imports
type ImportStats struct {
	TotalImports    int     `json:"totalImports"`
	TotalRows       int64   `json:"totalRows"`
	SuccessCount    int     `json:"successCount"`
	WarningCount    int     `json:"warningCount"`
	FailedCount     int     `json:"failedCount"`
	SuccessRate     float64 `json:"successRate"`
	MostUsedTable   string  `json:"mostUsedTable,omitempty"`
	LastImportDate  *time.Time `json:"lastImportDate,omitempty"`
}
