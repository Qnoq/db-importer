package service

import (
	"bytes"
	"compress/gzip"
	"context"
	"fmt"
	"io"

	"db-importer/internal/models"
	"db-importer/internal/repository"

	"github.com/google/uuid"
)

// ImportService handles import business logic
type ImportService struct {
	importRepo *repository.ImportRepository
}

// NewImportService creates a new ImportService
func NewImportService(importRepo *repository.ImportRepository) *ImportService {
	return &ImportService{
		importRepo: importRepo,
	}
}

// compressSQL compresses SQL using gzip
func compressSQL(sql string) (string, error) {
	if sql == "" {
		return "", nil
	}

	var buf bytes.Buffer
	writer := gzip.NewWriter(&buf)

	_, err := writer.Write([]byte(sql))
	if err != nil {
		return "", fmt.Errorf("failed to write compressed data: %w", err)
	}

	err = writer.Close()
	if err != nil {
		return "", fmt.Errorf("failed to close gzip writer: %w", err)
	}

	return buf.String(), nil
}

// decompressSQL decompresses gzip-compressed SQL
func decompressSQL(compressedSQL string) (string, error) {
	if compressedSQL == "" {
		return "", nil
	}

	reader, err := gzip.NewReader(bytes.NewReader([]byte(compressedSQL)))
	if err != nil {
		return "", fmt.Errorf("failed to create gzip reader: %w", err)
	}
	defer reader.Close()

	var buf bytes.Buffer
	_, err = io.Copy(&buf, reader)
	if err != nil {
		return "", fmt.Errorf("failed to decompress data: %w", err)
	}

	return buf.String(), nil
}

// CreateImport creates a new import record with compressed SQL
func (s *ImportService) CreateImport(ctx context.Context, userID uuid.UUID, req *models.CreateImportRequest) (*models.ImportResponse, error) {
	// Compress the SQL
	compressedSQL, err := compressSQL(req.GeneratedSQL)
	if err != nil {
		return nil, fmt.Errorf("failed to compress SQL: %w", err)
	}

	// Create import model
	imp := &models.Import{
		UserID:       userID,
		TableName:    req.TableName,
		RowCount:     req.RowCount,
		Status:       req.Status,
		GeneratedSQL: &compressedSQL,
		ErrorCount:   req.ErrorCount,
		WarningCount: req.WarningCount,
		Metadata:     req.Metadata,
	}

	// Save to database
	err = s.importRepo.Create(ctx, imp)
	if err != nil {
		return nil, fmt.Errorf("failed to create import: %w", err)
	}

	return imp.ToResponse(), nil
}

// GetImport retrieves an import by ID (without SQL)
func (s *ImportService) GetImport(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*models.ImportResponse, error) {
	imp, err := s.importRepo.GetByID(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	return imp.ToResponse(), nil
}

// GetImportWithSQL retrieves an import by ID including decompressed SQL
func (s *ImportService) GetImportWithSQL(ctx context.Context, id uuid.UUID, userID uuid.UUID) (*models.ImportWithSQL, error) {
	imp, err := s.importRepo.GetByIDWithSQL(ctx, id, userID)
	if err != nil {
		return nil, err
	}

	// Decompress SQL
	var decompressedSQL string
	if imp.GeneratedSQL != nil && *imp.GeneratedSQL != "" {
		decompressedSQL, err = decompressSQL(*imp.GeneratedSQL)
		if err != nil {
			return nil, fmt.Errorf("failed to decompress SQL: %w", err)
		}
	}

	result := &models.ImportWithSQL{
		ImportResponse: *imp.ToResponse(),
		GeneratedSQL:   decompressedSQL,
	}

	return result, nil
}

// ListImports retrieves imports with pagination and filters
func (s *ImportService) ListImports(ctx context.Context, userID uuid.UUID, req *models.GetImportsRequest) (*models.GetImportsResponse, error) {
	imports, total, err := s.importRepo.List(ctx, userID, req)
	if err != nil {
		return nil, err
	}

	// Convert to responses
	importResponses := make([]*models.ImportResponse, len(imports))
	for i, imp := range imports {
		importResponses[i] = imp.ToResponse()
	}

	// Calculate pagination
	page := req.Page
	if page == 0 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize == 0 {
		pageSize = 20
	}

	totalPages := int(total) / pageSize
	if int(total)%pageSize != 0 {
		totalPages++
	}

	return &models.GetImportsResponse{
		Imports:    importResponses,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	}, nil
}

// DeleteImport deletes an import by ID
func (s *ImportService) DeleteImport(ctx context.Context, id uuid.UUID, userID uuid.UUID) error {
	return s.importRepo.Delete(ctx, id, userID)
}

// GetStats retrieves statistics about user's imports
func (s *ImportService) GetStats(ctx context.Context, userID uuid.UUID) (*models.ImportStats, error) {
	return s.importRepo.GetStats(ctx, userID)
}

// DeleteOldImports deletes imports older than the specified number of days
func (s *ImportService) DeleteOldImports(ctx context.Context, userID uuid.UUID, olderThanDays int) (int64, error) {
	if olderThanDays <= 0 {
		return 0, fmt.Errorf("olderThanDays must be positive")
	}

	return s.importRepo.DeleteOldImports(ctx, userID, olderThanDays)
}
