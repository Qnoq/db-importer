-- Remove field_transformations column from workflow_sessions table
ALTER TABLE workflow_sessions
DROP COLUMN IF EXISTS field_transformations;
