-- Drop trigger
DROP TRIGGER IF EXISTS update_imports_updated_at ON imports;

-- Drop indexes
DROP INDEX IF EXISTS idx_imports_user_status_created;
DROP INDEX IF EXISTS idx_imports_created_at;
DROP INDEX IF EXISTS idx_imports_status;
DROP INDEX IF EXISTS idx_imports_table_name;
DROP INDEX IF EXISTS idx_imports_user_created;
DROP INDEX IF EXISTS idx_imports_user_id;

-- Drop table
DROP TABLE IF EXISTS imports;
