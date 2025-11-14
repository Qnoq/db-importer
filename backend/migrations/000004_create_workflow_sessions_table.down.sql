-- Drop workflow_sessions table
DROP TRIGGER IF EXISTS update_workflow_sessions_updated_at ON workflow_sessions;
DROP INDEX IF EXISTS idx_workflow_sessions_user_active;
DROP INDEX IF EXISTS idx_workflow_sessions_user_updated;
DROP INDEX IF EXISTS idx_workflow_sessions_expires_at;
DROP INDEX IF EXISTS idx_workflow_sessions_user_id;
DROP TABLE IF EXISTS workflow_sessions;
