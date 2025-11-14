package service

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/base64"
	"fmt"
	"io"
	"time"

	"db-importer/internal/models"
	"db-importer/internal/repository"

	"github.com/google/uuid"
)

// WorkflowSessionService handles workflow session business logic
type WorkflowSessionService struct {
	sessionRepo *repository.WorkflowSessionRepository
}

// NewWorkflowSessionService creates a new WorkflowSessionService
func NewWorkflowSessionService(sessionRepo *repository.WorkflowSessionRepository) *WorkflowSessionService {
	return &WorkflowSessionService{
		sessionRepo: sessionRepo,
	}
}

// compressContent compresses content using gzip and encodes to base64
func compressContent(content string) (string, error) {
	if content == "" {
		return "", nil
	}

	var buf bytes.Buffer
	writer := gzip.NewWriter(&buf)

	_, err := writer.Write([]byte(content))
	if err != nil {
		return "", fmt.Errorf("failed to write compressed data: %w", err)
	}

	err = writer.Close()
	if err != nil {
		return "", fmt.Errorf("failed to close gzip writer: %w", err)
	}

	// Encode to base64 to make it safe for TEXT columns
	encoded := base64.StdEncoding.EncodeToString(buf.Bytes())
	return encoded, nil
}

// decompressContent decodes from base64 and decompresses gzip-compressed content
func decompressContent(compressedContent string) (string, error) {
	if compressedContent == "" {
		return "", nil
	}

	// Decode from base64
	decoded, err := base64.StdEncoding.DecodeString(compressedContent)
	if err != nil {
		return "", fmt.Errorf("failed to decode base64: %w", err)
	}

	reader, err := gzip.NewReader(bytes.NewReader(decoded))
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

// GetSession retrieves the active workflow session for a user
func (s *WorkflowSessionService) GetSession(ctx context.Context, userID uuid.UUID) (*models.WorkflowSessionResponse, error) {
	session, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if session == nil {
		return nil, nil // No active session
	}

	return session.ToResponse(), nil
}

// GetSessionWithSchema retrieves the active workflow session including schema content
func (s *WorkflowSessionService) GetSessionWithSchema(ctx context.Context, userID uuid.UUID) (*models.WorkflowSessionWithSchema, error) {
	session, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if session == nil {
		return nil, nil // No active session
	}

	// Decompress schema content
	var schemaContent string
	if session.SchemaContent != nil && *session.SchemaContent != "" {
		schemaContent, err = decompressContent(*session.SchemaContent)
		if err != nil {
			return nil, fmt.Errorf("failed to decompress schema content: %w", err)
		}
	}

	result := &models.WorkflowSessionWithSchema{
		WorkflowSessionResponse: *session.ToResponse(),
		SchemaContent:           schemaContent,
	}

	return result, nil
}

// SaveSchema saves schema content and tables (step 1)
func (s *WorkflowSessionService) SaveSchema(ctx context.Context, userID uuid.UUID, req *models.SaveSchemaRequest) (*models.WorkflowSessionResponse, error) {
	// Compress schema content
	compressedSchema, err := compressContent(req.SchemaContent)
	if err != nil {
		return nil, fmt.Errorf("failed to compress schema: %w", err)
	}

	// Check if session already exists
	existingSession, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	expiresAt := time.Now().Add(7 * 24 * time.Hour) // 7 days

	if existingSession != nil {
		// Update existing session
		existingSession.CurrentStep = int(models.StepUploadSchema)
		existingSession.SchemaContent = &compressedSchema
		existingSession.SchemaTables = req.Tables
		existingSession.ExpiresAt = expiresAt

		err = s.sessionRepo.Update(ctx, existingSession)
		if err != nil {
			return nil, fmt.Errorf("failed to update session: %w", err)
		}

		return existingSession.ToResponse(), nil
	}

	// Create new session
	session := &models.WorkflowSession{
		UserID:        userID,
		CurrentStep:   int(models.StepUploadSchema),
		SchemaContent: &compressedSchema,
		SchemaTables:  req.Tables,
		ExpiresAt:     expiresAt,
	}

	err = s.sessionRepo.Create(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to create session: %w", err)
	}

	return session.ToResponse(), nil
}

// SaveTableSelection saves selected table (step 2)
func (s *WorkflowSessionService) SaveTableSelection(ctx context.Context, userID uuid.UUID, req *models.SaveTableSelectionRequest) (*models.WorkflowSessionResponse, error) {
	session, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if session == nil {
		return nil, fmt.Errorf("no active session found")
	}

	// Update session
	session.CurrentStep = int(models.StepSelectTable)
	session.SelectedTableName = &req.TableName

	err = s.sessionRepo.Update(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to update session: %w", err)
	}

	return session.ToResponse(), nil
}

// SaveDataFile saves data file information (step 3)
func (s *WorkflowSessionService) SaveDataFile(ctx context.Context, userID uuid.UUID, req *models.SaveDataFileRequest) (*models.WorkflowSessionResponse, error) {
	session, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if session == nil {
		return nil, fmt.Errorf("no active session found")
	}

	// Limit sample data to 50 rows
	sampleData := req.SampleData
	if len(sampleData) > 50 {
		sampleData = sampleData[:50]
	}

	// Update session
	session.CurrentStep = int(models.StepUploadData)
	session.DataFileName = &req.FileName
	session.DataHeaders = req.Headers
	session.SampleData = sampleData

	err = s.sessionRepo.Update(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to update session: %w", err)
	}

	return session.ToResponse(), nil
}

// SaveMapping saves column mapping (step 4)
func (s *WorkflowSessionService) SaveMapping(ctx context.Context, userID uuid.UUID, req *models.SaveMappingRequest) (*models.WorkflowSessionResponse, error) {
	session, err := s.sessionRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if session == nil {
		return nil, fmt.Errorf("no active session found")
	}

	// Update session
	session.CurrentStep = int(models.StepMapColumns)
	session.ColumnMapping = req.Mapping

	err = s.sessionRepo.Update(ctx, session)
	if err != nil {
		return nil, fmt.Errorf("failed to update session: %w", err)
	}

	return session.ToResponse(), nil
}

// DeleteSession deletes a workflow session
func (s *WorkflowSessionService) DeleteSession(ctx context.Context, userID uuid.UUID) error {
	return s.sessionRepo.Delete(ctx, userID)
}

// CleanupExpiredSessions deletes all expired workflow sessions
func (s *WorkflowSessionService) CleanupExpiredSessions(ctx context.Context) (int64, error) {
	return s.sessionRepo.DeleteExpired(ctx)
}

// ExtendExpiration extends the expiration time of a session
func (s *WorkflowSessionService) ExtendExpiration(ctx context.Context, userID uuid.UUID, days int) error {
	if days <= 0 || days > 30 {
		return fmt.Errorf("days must be between 1 and 30")
	}

	return s.sessionRepo.ExtendExpiration(ctx, userID, days)
}
