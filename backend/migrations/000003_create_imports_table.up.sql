-- Create imports table
CREATE TABLE IF NOT EXISTS imports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    table_name VARCHAR(255) NOT NULL,
    row_count INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'success',
    generated_sql TEXT,
    error_count INTEGER DEFAULT 0,
    warning_count INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT imports_status_check CHECK (status IN ('success', 'failed', 'warning')),
    CONSTRAINT imports_row_count_check CHECK (row_count >= 0),
    CONSTRAINT imports_error_count_check CHECK (error_count >= 0),
    CONSTRAINT imports_warning_count_check CHECK (warning_count >= 0)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_imports_user_id ON imports(user_id);
CREATE INDEX IF NOT EXISTS idx_imports_user_created ON imports(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_imports_table_name ON imports(table_name);
CREATE INDEX IF NOT EXISTS idx_imports_status ON imports(status);
CREATE INDEX IF NOT EXISTS idx_imports_created_at ON imports(created_at DESC);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_imports_user_status_created ON imports(user_id, status, created_at DESC);

-- Create trigger to auto-update updated_at (reuse existing function)
CREATE TRIGGER update_imports_updated_at
    BEFORE UPDATE ON imports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON TABLE imports IS 'Stores history of data imports performed by users';
COMMENT ON COLUMN imports.generated_sql IS 'Compressed SQL statements using gzip';
COMMENT ON COLUMN imports.metadata IS 'JSON data containing source_file_name, mapping_summary, transformations, etc.';
COMMENT ON COLUMN imports.status IS 'Import result status: success (no errors), warning (has warnings), failed (has errors)';
