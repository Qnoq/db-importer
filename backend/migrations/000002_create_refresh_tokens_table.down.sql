-- Drop cleanup function
DROP FUNCTION IF EXISTS delete_expired_refresh_tokens();

-- Drop indexes
DROP INDEX IF EXISTS idx_refresh_tokens_revoked;
DROP INDEX IF EXISTS idx_refresh_tokens_expires_at;
DROP INDEX IF EXISTS idx_refresh_tokens_token_hash;
DROP INDEX IF EXISTS idx_refresh_tokens_user_id;

-- Drop table
DROP TABLE IF EXISTS refresh_tokens;
