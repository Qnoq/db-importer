# Authentication System Documentation

## Overview

The DB Importer application implements a **hybrid authentication model** that allows users to use the application in two modes:

1. **Guest Mode** (Default): Immediate access with limited features
2. **Authenticated Mode**: Full access with additional features and unlimited usage

This approach provides the best of both worlds: instant accessibility for new users while offering powerful features for registered users.

---

## Authentication Flow

### User Registration

**Endpoint**: `POST /auth/register`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "first_name": "John",  // Optional
  "last_name": "Doe"     // Optional
}
```

**Response** (200 OK):
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "is_active": true,
    "email_verified": false,
    "created_at": "2025-11-07T10:00:00Z"
  }
}
```

**Password Requirements**:
- Minimum 8 characters
- Mix of letters, numbers, and symbols recommended

---

### User Login

**Endpoint**: `POST /auth/login`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Response** (200 OK):
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "is_active": true,
    "email_verified": false
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900  // 15 minutes in seconds
}
```

**Token Storage**:
- Frontend stores tokens in localStorage
- Access token expires in **15 minutes**
- Refresh token expires in **7 days**

---

### Token Refresh

**Endpoint**: `POST /auth/refresh`

**Request Body**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900
}
```

**Automatic Refresh**:
- Frontend automatically refreshes tokens **5 minutes before expiration**
- Implemented in router navigation guards
- If refresh fails, user is redirected to login

---

### User Logout

**Endpoint**: `POST /auth/logout`

**Headers**:
```
Authorization: Bearer <access_token>
```

**Request Body**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "message": "Logged out successfully"
}
```

**Logout Process**:
1. Revokes refresh token in database
2. Clears localStorage in frontend
3. Redirects to home page

---

## Frontend Implementation

### Auth Store (Pinia)

Located at: `frontend/src/store/authStore.ts`

**State**:
```typescript
{
  user: User | null,
  tokens: AuthTokens | null,
  isAuthenticated: boolean,
  isGuest: boolean,
  loading: boolean,
  error: string | null
}
```

**Actions**:
- `register(email, password, firstName?, lastName?)` - Register new user
- `login(email, password)` - Login user
- `logout()` - Logout user
- `refreshAccessToken()` - Refresh access token
- `continueAsGuest()` - Switch to guest mode

**Getters**:
- `userDisplayName` - Returns formatted user display name
- `isTokenExpired` - Checks if access token is expired

---

### Navigation Guards

Located at: `frontend/src/router/index.ts`

**Route Meta**:
```typescript
{
  requiresAuth: boolean,  // Requires authentication
  guestOnly: boolean      // Only accessible as guest
}
```

**Guard Logic**:
1. Check if token needs refresh before each navigation
2. Redirect to login if route requires auth and user is not authenticated
3. Redirect to home if route is guest-only and user is authenticated

---

### UI Components

#### Login Page
- Located at: `frontend/src/pages/Login.vue`
- PrimeVue components: Card, InputText, Password, Button
- Features:
  - Email/password form
  - "Continue as Guest" option
  - Link to registration page

#### Register Page
- Located at: `frontend/src/pages/Register.vue`
- Features:
  - Email/password form with confirmation
  - Optional first/last name
  - Terms acceptance checkbox
  - "Continue as Guest" option

#### Header Component
- Located at: `frontend/src/App.vue`
- Shows different UI based on auth state:
  - **Guest**: "Guest Mode" badge + Sign In/Sign Up buttons
  - **Authenticated**: User avatar + display name + sign out button

---

## Backend Implementation

### Middleware

#### AuthMiddleware
Located at: `backend/middleware/auth.go`

**Function**: `AuthMiddleware(jwtConfig)`
- Validates JWT access token from Authorization header
- Adds `userID` and `email` to request context
- Returns 401 if token is invalid or missing

**Function**: `OptionalAuthMiddleware(jwtConfig)`
- Same as AuthMiddleware but doesn't fail if token is missing
- Used for endpoints that work for both guests and authenticated users

---

#### Rate Limiting
Located at: `backend/middleware/ratelimit.go`

**Differentiated Limits**:
- **Guest Users** (by IP): 3 requests per day
- **Authenticated Users** (by User ID): Unlimited (0)

**Implementation**:
```go
rateLimiter = middleware.NewRateLimiter(
    3,      // guestRequests
    86400,  // guestWindow (24h in seconds)
    0,      // authRequests (0 = unlimited)
    3600,   // authWindow
)
```

**Error Messages**:
- Guest: "Rate limit exceeded for guest users (3 requests per day). Please sign in for unlimited access or try again in X hours"
- Auth: "Rate limit exceeded. Please try again later."

---

### Database Schema

#### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP
);
```

#### Refresh Tokens Table
```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    revoked BOOLEAN DEFAULT false,
    revoked_at TIMESTAMP
);
```

---

## Security Considerations

### Password Hashing
- Uses **bcrypt** with cost factor 12
- Passwords are never stored in plain text
- Hash verification is constant-time to prevent timing attacks

### JWT Tokens
- Access tokens expire in **15 minutes**
- Refresh tokens expire in **7 days**
- Tokens are signed with HMAC-SHA256
- Secrets must be at least 32 characters

### Rate Limiting
- Prevents brute force attacks
- Different limits for guests and authenticated users
- Based on IP for guests, User ID for authenticated users

### HTTPS
- **Required in production**
- All tokens are transmitted over HTTPS only
- Set `Secure` flag on cookies if using cookie-based auth

---

## Configuration

### Environment Variables

```bash
# JWT Configuration
JWT_ACCESS_SECRET=your-secret-key-minimum-32-characters-long
JWT_REFRESH_SECRET=your-refresh-secret-key-minimum-32-characters-long
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=168h  # 7 days

# Database Configuration
DATABASE_URL=postgres://user:password@host:5432/dbname?sslmode=disable

# Rate Limiting
RATE_LIMIT_ENABLED=true
```

---

## Testing the Authentication Flow

### 1. Start the Application
```bash
docker-compose -f docker-compose.dev.yml up
```

### 2. Register a New User
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePassword123",
    "first_name": "Test",
    "last_name": "User"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePassword123"
  }'
```

### 4. Make Authenticated Request
```bash
curl -X POST http://localhost:8080/generate-sql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{...}'
```

### 5. Test Rate Limiting (Guest)
```bash
# Make 4 requests in a row without auth token
# The 4th request should be rate limited
for i in {1..4}; do
  curl -X POST http://localhost:8080/parse-schema -F "file=@schema.sql"
  echo ""
done
```

---

## Future Enhancements

### Sprint 2 and Beyond
- Email verification
- Password reset flow
- OAuth providers (Google, GitHub)
- Two-factor authentication (2FA)
- Session management dashboard
- User profile management

---

## Troubleshooting

### "Token has expired"
- Frontend should automatically refresh the token
- If refresh fails, user is redirected to login
- Check that JWT secrets are configured correctly

### "Rate limit exceeded"
- Guest users are limited to 3 requests per day
- Sign in for unlimited access
- Rate limit resets after 24 hours

### "Invalid token"
- Token may be malformed or tampered with
- JWT secrets might be misconfigured
- Try logging out and logging in again

---

**Last Updated**: 2025-11-07
**Version**: 1.0
**Sprint**: Sprint 1 - Foundations
