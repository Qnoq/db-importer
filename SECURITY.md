# Security Policy

## Overview

This document outlines the security features and best practices implemented in DB Importer.

## Security Features

### 1. SQL Injection Prevention

- **Type-aware SQL generation**: Values are formatted based on their SQL type (numeric, string, boolean, datetime)
- **Proper escaping**: All string values are properly escaped for SQL injection prevention
  - Single quotes are doubled (`'` → `''`)
  - Backslashes are escaped (`\` → `\\`)
  - Special characters (newlines, tabs, etc.) are escaped
  - NULL bytes are removed
- **Identifier escaping**: Table and column names are escaped with backticks
- **No direct string interpolation**: All SQL is generated programmatically

### 2. Rate Limiting

- Configurable rate limiting per IP address
- Default: 100 requests per 60 seconds
- Token bucket algorithm for fair distribution
- Automatic cleanup of expired entries
- Can be disabled in development via environment variables

### 3. CORS (Cross-Origin Resource Sharing)

- Configurable allowed origins (no more wildcards by default)
- Set via `ALLOWED_ORIGINS` environment variable
- Comma-separated list support for multiple origins
- Logging of rejected origins

### 4. Input Validation

- **File size limits**: Configurable via `MAX_UPLOAD_SIZE` (default 50MB)
- **File type validation**: Only `.sql` files accepted for schema
- **Empty file detection**: Prevents processing of empty uploads
- **Data type validation**: Server-side validation of data against schema types
  - Numeric range checks (TINYINT, SMALLINT, etc.)
  - VARCHAR/CHAR length validation
  - Type compatibility checks

### 5. Error Handling

- **Structured error responses**: Clear, actionable error messages
- **No sensitive information leakage**: Stack traces not exposed in production
- **Detailed logging**: All errors logged with context for debugging
- **HTTP status codes**: Proper use of 400, 422, 500 status codes

### 6. Logging

- **Structured JSON logging**: All logs in machine-readable format
- **Log levels**: DEBUG, INFO, WARN, ERROR
- **Request logging**: All incoming requests logged with method, path, IP
- **Sensitive data protection**: No passwords or secrets in logs

### 7. Docker Security

- **Non-root users**: Both backend and frontend run as non-root users
- **Multi-stage builds**: Minimal attack surface with Alpine-based images
- **Health checks**: Built-in health monitoring
- **Read-only filesystem**: Backend binary is read-only

### 8. No Database Connection

- **Zero trust architecture**: Application never connects to user databases
- **User-controlled execution**: Users execute generated SQL in their own environment
- **No credential storage**: No database passwords or connection strings

## Configuration

### Environment Variables

```bash
# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60

# Upload Limits
MAX_UPLOAD_SIZE=52428800  # 50MB in bytes

# Logging
DEBUG_LOG=false  # Enable for development only
```

### Production Recommendations

1. **Set specific CORS origins**
   ```bash
   ALLOWED_ORIGINS=https://yourdomain.com
   ```

2. **Enable rate limiting**
   ```bash
   RATE_LIMIT_ENABLED=true
   ```

3. **Disable debug logging**
   ```bash
   DEBUG_LOG=false
   ```

4. **Use HTTPS**: Always deploy behind a reverse proxy with TLS
   - Use nginx, Caddy, or cloud load balancer
   - Enable HTTP Strict Transport Security (HSTS)

5. **Set upload limits appropriately**
   - Adjust `MAX_UPLOAD_SIZE` based on your needs
   - Monitor disk space usage

6. **Regular updates**
   - Keep dependencies up to date
   - Monitor security advisories

## Known Limitations

1. **No authentication**: Application does not include user authentication
   - Implement authentication at the reverse proxy level if needed
   - Consider OAuth2, Basic Auth, or API keys

2. **No data encryption at rest**: Uploaded files are not encrypted
   - Data is ephemeral (processed in-memory)
   - No persistent storage of user data

3. **CSV encoding detection**: Limited automatic encoding detection
   - UTF-8 is assumed by default
   - Users should ensure proper encoding

## Reporting Security Issues

If you discover a security vulnerability, please:

1. **Do not** open a public GitHub issue
2. Email security concerns to your project maintainer
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Checklist

Before deploying to production:

- [ ] Set specific CORS origins
- [ ] Enable rate limiting
- [ ] Disable debug logging
- [ ] Deploy behind HTTPS/TLS
- [ ] Set appropriate upload size limits
- [ ] Configure monitoring and alerts
- [ ] Review and update dependencies
- [ ] Implement authentication (if needed)
- [ ] Set up firewall rules
- [ ] Enable container security scanning
- [ ] Configure backup strategy

## Security Updates

### Version 1.0 (Current)

- ✅ Type-aware SQL generation with proper escaping
- ✅ Rate limiting implementation
- ✅ Configurable CORS
- ✅ Input validation (file size, type, data)
- ✅ Structured error handling
- ✅ Structured logging
- ✅ Non-root Docker containers
- ✅ Health checks

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
