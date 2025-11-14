package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// WorkflowStep represents the current step in the workflow
type WorkflowStep int

const (
	StepUploadSchema WorkflowStep = 1
	StepSelectTable  WorkflowStep = 2
	StepUploadData   WorkflowStep = 3
	StepMapColumns   WorkflowStep = 4
)

// TableDefinition represents a parsed table from the schema
type TableDefinition struct {
	Name   string  `json:"name"`
	Fields []Field `json:"fields"`
}

// Field represents a database column
type Field struct {
	Name     string `json:"name"`
	Type     string `json:"type"`
	Nullable bool   `json:"nullable"`
}

// TableDefinitions is a slice of TableDefinition with custom JSON marshaling
type TableDefinitions []TableDefinition

// Scan implements the sql.Scanner interface for TableDefinitions
func (t *TableDefinitions) Scan(value interface{}) error {
	if value == nil {
		*t = TableDefinitions{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, t)
}

// Value implements the driver.Valuer interface for TableDefinitions
func (t TableDefinitions) Value() (driver.Value, error) {
	if len(t) == 0 {
		return json.Marshal([]TableDefinition{})
	}
	return json.Marshal(t)
}

// DataHeaders is a slice of strings with custom JSON marshaling
type DataHeaders []string

// Scan implements the sql.Scanner interface for DataHeaders
func (h *DataHeaders) Scan(value interface{}) error {
	if value == nil {
		*h = DataHeaders{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, h)
}

// Value implements the driver.Valuer interface for DataHeaders
func (h DataHeaders) Value() (driver.Value, error) {
	if len(h) == 0 {
		return json.Marshal([]string{})
	}
	return json.Marshal(h)
}

// SampleData represents sample rows from the data file
type SampleData [][]interface{}

// Scan implements the sql.Scanner interface for SampleData
func (s *SampleData) Scan(value interface{}) error {
	if value == nil {
		*s = SampleData{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, s)
}

// Value implements the driver.Valuer interface for SampleData
func (s SampleData) Value() (driver.Value, error) {
	if len(s) == 0 {
		return json.Marshal([][]interface{}{})
	}
	return json.Marshal(s)
}

// ColumnMapping represents mapping from data file columns to database columns
type ColumnMapping map[string]string

// Scan implements the sql.Scanner interface for ColumnMapping
func (m *ColumnMapping) Scan(value interface{}) error {
	if value == nil {
		*m = ColumnMapping{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, m)
}

// Value implements the driver.Valuer interface for ColumnMapping
func (m ColumnMapping) Value() (driver.Value, error) {
	if len(m) == 0 {
		return json.Marshal(map[string]string{})
	}
	return json.Marshal(m)
}

// FieldTransformations represents transformations applied to fields (DB field -> transformation type)
type FieldTransformations map[string]string

// Scan implements the sql.Scanner interface for FieldTransformations
func (f *FieldTransformations) Scan(value interface{}) error {
	if value == nil {
		*f = FieldTransformations{}
		return nil
	}
	bytes, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(bytes, f)
}

// Value implements the driver.Valuer interface for FieldTransformations
func (f FieldTransformations) Value() (driver.Value, error) {
	if len(f) == 0 {
		return json.Marshal(map[string]string{})
	}
	return json.Marshal(f)
}

// WorkflowSession represents a user's workflow session in the database
type WorkflowSession struct {
	ID          uuid.UUID `db:"id" json:"id"`
	UserID      uuid.UUID `db:"user_id" json:"userId"`
	CurrentStep int       `db:"current_step" json:"currentStep"`

	// Step 1: Schema upload
	SchemaContent *string          `db:"schema_content" json:"-"` // Compressed, not exposed in JSON
	SchemaTables  TableDefinitions `db:"schema_tables" json:"schemaTables"`

	// Step 2: Table selection
	SelectedTableName *string `db:"selected_table_name" json:"selectedTableName,omitempty"`

	// Step 3: Data file upload
	DataFileName *string     `db:"data_file_name" json:"dataFileName,omitempty"`
	DataHeaders  DataHeaders `db:"data_headers" json:"dataHeaders"`
	SampleData   SampleData  `db:"sample_data" json:"sampleData"`

	// Step 4: Column mapping
	ColumnMapping        ColumnMapping        `db:"column_mapping" json:"columnMapping"`
	FieldTransformations FieldTransformations `db:"field_transformations" json:"fieldTransformations"`

	// Metadata
	ExpiresAt time.Time `db:"expires_at" json:"expiresAt"`
	CreatedAt time.Time `db:"created_at" json:"createdAt"`
	UpdatedAt time.Time `db:"updated_at" json:"updatedAt"`
}

// WorkflowSessionResponse is the response returned to clients
type WorkflowSessionResponse struct {
	ID                   uuid.UUID            `json:"id"`
	UserID               uuid.UUID            `json:"userId"`
	CurrentStep          int                  `json:"currentStep"`
	SchemaTables         TableDefinitions     `json:"schemaTables"`
	SelectedTableName    *string              `json:"selectedTableName,omitempty"`
	DataFileName         *string              `json:"dataFileName,omitempty"`
	DataHeaders          DataHeaders          `json:"dataHeaders"`
	SampleData           SampleData           `json:"sampleData"`
	ColumnMapping        ColumnMapping        `json:"columnMapping"`
	FieldTransformations FieldTransformations `json:"fieldTransformations"`
	ExpiresAt            time.Time            `json:"expiresAt"`
	CreatedAt            time.Time            `json:"createdAt"`
	UpdatedAt            time.Time            `json:"updatedAt"`
}

// ToResponse converts WorkflowSession to WorkflowSessionResponse
func (w *WorkflowSession) ToResponse() *WorkflowSessionResponse {
	return &WorkflowSessionResponse{
		ID:                   w.ID,
		UserID:               w.UserID,
		CurrentStep:          w.CurrentStep,
		SchemaTables:         w.SchemaTables,
		SelectedTableName:    w.SelectedTableName,
		DataFileName:         w.DataFileName,
		DataHeaders:          w.DataHeaders,
		SampleData:           w.SampleData,
		ColumnMapping:        w.ColumnMapping,
		FieldTransformations: w.FieldTransformations,
		ExpiresAt:            w.ExpiresAt,
		CreatedAt:            w.CreatedAt,
		UpdatedAt:            w.UpdatedAt,
	}
}

// WorkflowSessionWithSchema includes the schema content (decompressed)
type WorkflowSessionWithSchema struct {
	WorkflowSessionResponse
	SchemaContent string `json:"schemaContent"`
}

// SaveSchemaRequest represents the request to save schema (step 1)
type SaveSchemaRequest struct {
	SchemaContent string              `json:"schemaContent" validate:"required"`
	Tables        []TableDefinition   `json:"tables" validate:"required,min=1"`
}

// SaveTableSelectionRequest represents the request to save table selection (step 2)
type SaveTableSelectionRequest struct {
	TableName string `json:"tableName" validate:"required,min=1,max=255"`
}

// SaveDataFileRequest represents the request to save data file info (step 3)
type SaveDataFileRequest struct {
	FileName    string          `json:"fileName" validate:"required,min=1,max=255"`
	Headers     []string        `json:"headers" validate:"required,min=1"`
	SampleData  [][]interface{} `json:"sampleData" validate:"required,min=1,max=50"`
}

// SaveMappingRequest represents the request to save column mapping (step 4)
type SaveMappingRequest struct {
	Mapping        map[string]string `json:"mapping" validate:"required,min=1"`
	Transformations map[string]string `json:"transformations"`
}
