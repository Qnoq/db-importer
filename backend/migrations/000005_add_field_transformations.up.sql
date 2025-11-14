-- Add field_transformations column to workflow_sessions table
ALTER TABLE workflow_sessions
ADD COLUMN field_transformations JSONB DEFAULT '{}'::jsonb;

-- Add comment for documentation
COMMENT ON COLUMN workflow_sessions.field_transformations IS 'Field transformations mapping (DB field -> transformation type)';
