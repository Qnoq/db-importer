-- Create workflow_sessions table
CREATE TABLE IF NOT EXISTS workflow_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Current workflow step (1-4)
    current_step INTEGER NOT NULL DEFAULT 1,

    -- Step 1: Schema upload
    schema_content TEXT,
    schema_tables JSONB DEFAULT '[]'::jsonb,

    -- Step 2: Table selection
    selected_table_name VARCHAR(255),

    -- Step 3: Data file upload
    data_file_name VARCHAR(255),
    data_headers JSONB DEFAULT '[]'::jsonb,
    sample_data JSONB DEFAULT '[]'::jsonb, -- First 50 rows for preview

    -- Step 4: Column mapping
    column_mapping JSONB DEFAULT '{}'::jsonb, -- Map excel columns to db columns

    -- Session metadata
    expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '7 days',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT workflow_sessions_step_check CHECK (current_step >= 1 AND current_step <= 4)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workflow_sessions_user_id ON workflow_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workflow_sessions_expires_at ON workflow_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_workflow_sessions_user_updated ON workflow_sessions(user_id, updated_at DESC);

-- Ensure user can only have one active session at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_workflow_sessions_user_active ON workflow_sessions(user_id);

-- Create trigger to auto-update updated_at (reuse existing function)
CREATE TRIGGER update_workflow_sessions_updated_at
    BEFORE UPDATE ON workflow_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON TABLE workflow_sessions IS 'Stores active workflow sessions to allow users to resume after page refresh';
COMMENT ON COLUMN workflow_sessions.current_step IS 'Current step in workflow: 1=upload schema, 2=select table, 3=upload data, 4=map columns';
COMMENT ON COLUMN workflow_sessions.schema_content IS 'Original SQL schema file content (compressed with gzip)';
COMMENT ON COLUMN workflow_sessions.schema_tables IS 'Parsed table definitions from schema';
COMMENT ON COLUMN workflow_sessions.sample_data IS 'First 50 rows of data file for preview/validation';
COMMENT ON COLUMN workflow_sessions.column_mapping IS 'Mapping of data file columns to database columns';
COMMENT ON COLUMN workflow_sessions.expires_at IS 'Session expiration timestamp (default 7 days)';
