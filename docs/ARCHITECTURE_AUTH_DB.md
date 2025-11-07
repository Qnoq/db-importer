# Architecture - Authentification & Base de Données

## Stack Technique Choisie

### Base de Données
| Composant | Choix | Raison |
|-----------|-------|--------|
| **Database** | PostgreSQL 15+ | Robuste, JSONB, déjà supporté par le parser |
| **Driver** | pgx/pgxpool v5 | Protocole binaire (plus rapide), connection pooling natif |
| **Query Builder** | sqlx v1.4+ | Léger, transparent, bon compromis performance/simplicité |
| **Migrations** | golang-migrate/migrate v4 | Standard de facto, CLI + library |
| **Auth** | golang-jwt/jwt v5 | Standard actuel, sécurisé, bien maintenu |

### Pourquoi ces choix ?

**pgx vs lib/pq** :
- pgx utilise le protocole binaire PostgreSQL → 20-30% plus rapide
- Connection pooling intégré (pgxpool)
- Support PostgreSQL spécifique (COPY, LISTEN/NOTIFY, etc.)

**sqlx vs GORM** :
- GORM peut être lent sur gros volumes
- sqlx est transparent : on écrit du SQL, on contrôle les performances
- Moins de "magie" = plus facile à débugger
- Compatible avec database/sql standard

**golang-migrate** :
- CLI + library (flexible)
- Support rollback
- Versioning clair (timestamp ou séquentiel)
- Intégration CI/CD facile

---

## Architecture Applicative

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (Vue 3)                     │
│  - localStorage (mode guest)                             │
│  - API calls + JWT (mode authenticated)                 │
└─────────────────────────────────────────────────────────┘
                            ↓ HTTP/JSON
┌─────────────────────────────────────────────────────────┐
│                   BACKEND (Go)                          │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │  HTTP Layer (net/http ou gin)                   │   │
│  │  - Routes                                        │   │
│  │  - Middleware (CORS, Logger, Auth, RateLimit)   │   │
│  └─────────────────────────────────────────────────┘   │
│                        ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Handlers (API endpoints)                       │   │
│  │  - AuthHandler (login, register, refresh)       │   │
│  │  - ImportHandler (CRUD imports)                 │   │
│  │  - TemplateHandler (CRUD templates)             │   │
│  └─────────────────────────────────────────────────┘   │
│                        ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Services (Business Logic)                      │   │
│  │  - AuthService (JWT generation, validation)     │   │
│  │  - ImportService (import processing)            │   │
│  │  - TemplateService (template management)        │   │
│  └─────────────────────────────────────────────────┘   │
│                        ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Repositories (Data Access)                     │   │
│  │  - UserRepository (CRUD users)                  │   │
│  │  - ImportRepository (CRUD imports)              │   │
│  │  - TemplateRepository (CRUD templates)          │   │
│  └─────────────────────────────────────────────────┘   │
│                        ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Database (pgxpool)                             │   │
│  │  - Connection pool                              │   │
│  │  - Query execution with sqlx                    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│              PostgreSQL 15+                             │
│  - users, imports, templates, schemas                   │
└─────────────────────────────────────────────────────────┘
```

---

## Structure de Projet

```
backend/
├── cmd/
│   └── server/
│       └── main.go              # Point d'entrée
│
├── internal/                    # Code privé (ne peut pas être importé)
│   ├── config/
│   │   └── config.go            # Configuration (env vars)
│   │
│   ├── database/
│   │   ├── postgres.go          # Connection pool setup
│   │   └── migrations.go        # Migration runner (optionnel)
│   │
│   ├── middleware/
│   │   ├── auth.go              # JWT verification middleware
│   │   ├── cors.go              # CORS (existant)
│   │   ├── logger.go            # Logger (existant)
│   │   └── ratelimit.go         # Rate limit (existant)
│   │
│   ├── models/
│   │   ├── user.go              # User model
│   │   ├── import.go            # Import model
│   │   └── template.go          # Template model
│   │
│   ├── repository/
│   │   ├── repository.go        # Interface commune
│   │   ├── user_repo.go         # User repository
│   │   ├── import_repo.go       # Import repository
│   │   └── template_repo.go     # Template repository
│   │
│   ├── service/
│   │   ├── auth_service.go      # Auth business logic
│   │   ├── import_service.go    # Import business logic
│   │   └── template_service.go  # Template business logic
│   │
│   ├── handler/
│   │   ├── auth_handler.go      # Auth endpoints
│   │   ├── import_handler.go    # Import endpoints
│   │   └── template_handler.go  # Template endpoints
│   │
│   └── utils/
│       ├── jwt.go               # JWT helpers
│       ├── password.go          # Bcrypt helpers
│       └── response.go          # HTTP response helpers
│
├── migrations/
│   ├── 000001_create_users_table.up.sql
│   ├── 000001_create_users_table.down.sql
│   ├── 000002_create_imports_table.up.sql
│   └── 000002_create_imports_table.down.sql
│
├── pkg/                         # Code public (peut être importé)
│   └── (vide pour l'instant)
│
├── go.mod
├── go.sum
├── Makefile                     # Commandes utiles
└── .env.example

frontend/
├── src/
│   ├── composables/
│   │   ├── useAuth.ts           # Auth composable (login, logout, etc.)
│   │   └── useApi.ts            # API client avec JWT
│   │
│   ├── services/
│   │   ├── api.ts               # Axios instance avec interceptors
│   │   └── auth.ts              # Auth API calls
│   │
│   └── store/
│       └── authStore.ts         # Pinia store pour auth
│
└── (reste inchangé)
```

---

## Schéma de Base de Données

### Table `users`

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
  last_login_at TIMESTAMP,

  -- Indexes
  CONSTRAINT users_email_key UNIQUE (email)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

### Table `refresh_tokens` (optionnel mais recommandé)

```sql
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  revoked BOOLEAN DEFAULT false,

  -- Indexes
  INDEX idx_refresh_tokens_user (user_id),
  INDEX idx_refresh_tokens_hash (token_hash),
  INDEX idx_refresh_tokens_expires (expires_at)
);

-- Nettoyage automatique des tokens expirés (optionnel)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- SELECT cron.schedule('clean-expired-tokens', '0 3 * * *',
--   'DELETE FROM refresh_tokens WHERE expires_at < NOW()');
```

---

## Flow d'Authentification

### 1. Registration

```
Client                   Backend                  Database
  |                         |                         |
  |--- POST /auth/register --->                       |
  |     { email, password }  |                        |
  |                         |                         |
  |                    Validate input                 |
  |                    Hash password (bcrypt cost 12) |
  |                         |                         |
  |                         |--- INSERT user -------->|
  |                         |<-- user created --------|
  |                         |                         |
  |<-- 201 Created ---------|                         |
  |    { id, email }        |                         |
```

### 2. Login

```
Client                   Backend                  Database
  |                         |                         |
  |--- POST /auth/login ---->                         |
  |     { email, password }  |                        |
  |                         |                         |
  |                         |--- SELECT user -------->|
  |                         |<-- user data -----------|
  |                         |                         |
  |                    Compare password (bcrypt)      |
  |                    Generate JWT (access + refresh)|
  |                         |                         |
  |                         |--- INSERT refresh ----->|
  |                         |<-- token saved ---------|
  |                         |                         |
  |<-- 200 OK --------------|                         |
  |    {                    |                         |
  |      accessToken,       |                         |
  |      refreshToken,      |                         |
  |      user: { id, email }|                         |
  |    }                    |                         |
```

**Access Token Claims** :
```json
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "exp": 1700000000,
  "iat": 1699999100,
  "type": "access"
}
```

**Refresh Token Claims** :
```json
{
  "sub": "user-uuid",
  "jti": "unique-token-id",
  "exp": 1700604800,
  "iat": 1699999100,
  "type": "refresh"
}
```

### 3. Protected Request

```
Client                   Backend                  Database
  |                         |                         |
  |--- GET /imports ------->|                         |
  |  Header:                |                         |
  |  Authorization:         |                         |
  |    Bearer <JWT>         |                         |
  |                         |                         |
  |                    Middleware:                    |
  |                    1. Extract JWT                 |
  |                    2. Verify signature            |
  |                    3. Check expiration            |
  |                    4. Extract user ID             |
  |                         |                         |
  |                         |--- SELECT imports ----->|
  |                         |    WHERE user_id = ?    |
  |                         |<-- imports data --------|
  |                         |                         |
  |<-- 200 OK --------------|                         |
  |    { imports: [...] }   |                         |
```

### 4. Token Refresh

```
Client                   Backend                  Database
  |                         |                         |
  |--- POST /auth/refresh -->                         |
  |  { refreshToken }       |                         |
  |                         |                         |
  |                    Verify refresh token           |
  |                         |                         |
  |                         |--- SELECT token ------->|
  |                         |<-- token valid ---------|
  |                         |                         |
  |                    Generate new access token      |
  |                    (optionnel: rotate refresh)    |
  |                         |                         |
  |<-- 200 OK --------------|                         |
  |    {                    |                         |
  |      accessToken,       |                         |
  |      refreshToken       |                         |
  |    }                    |                         |
```

### 5. Logout

```
Client                   Backend                  Database
  |                         |                         |
  |--- POST /auth/logout --->                         |
  |  { refreshToken }       |                         |
  |                         |                         |
  |                         |--- UPDATE token ------->|
  |                         |    SET revoked = true   |
  |                         |<-- token revoked -------|
  |                         |                         |
  |<-- 200 OK --------------|                         |
```

---

## Configuration

### Variables d'Environnement

```bash
# Database
DATABASE_URL=postgres://user:password@localhost:5432/dbname?sslmode=disable
DB_MAX_OPEN_CONNS=25
DB_MAX_IDLE_CONNS=5
DB_CONN_MAX_LIFETIME=5m
DB_CONN_MAX_IDLE_TIME=10m

# JWT
JWT_ACCESS_SECRET=your-super-secret-key-min-32-chars
JWT_REFRESH_SECRET=your-refresh-secret-key-min-32-chars
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=168h  # 7 days

# Server
PORT=8080
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:8081
DEBUG_LOG=false

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS_GUEST=3
RATE_LIMIT_REQUESTS_AUTH=100
RATE_LIMIT_WINDOW=86400  # 24h for guests, 1h for auth
```

---

## Sécurité

### Password Hashing
```go
import "golang.org/x/crypto/bcrypt"

// Cost 12 = ~250ms sur hardware moderne (bon compromis)
const bcryptCost = 12

func HashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcryptCost)
    return string(bytes), err
}

func CheckPassword(password, hash string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    return err == nil
}
```

### JWT Signing
```go
import "github.com/golang-jwt/jwt/v5"

// Utiliser HMAC-SHA256 (HS256) pour la simplicité
// Alternative : RS256 (RSA) pour multi-services

type Claims struct {
    UserID string `json:"sub"`
    Email  string `json:"email"`
    Type   string `json:"type"` // "access" ou "refresh"
    jwt.RegisteredClaims
}

func GenerateAccessToken(userID, email string, secret []byte) (string, error) {
    claims := &Claims{
        UserID: userID,
        Email:  email,
        Type:   "access",
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(secret)
}
```

### Validation Input
```go
import "github.com/go-playground/validator/v10"

type RegisterRequest struct {
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required,min=8,max=72"` // bcrypt max 72
}

var validate = validator.New()

func ValidateRequest(req interface{}) error {
    return validate.Struct(req)
}
```

---

## Gestion des Erreurs

### Structure d'erreur standardisée

```go
type ErrorResponse struct {
    Error   string `json:"error"`
    Message string `json:"message"`
    Code    string `json:"code,omitempty"`
}

// HTTP Status Codes
const (
    ErrBadRequest          = "BAD_REQUEST"
    ErrUnauthorized        = "UNAUTHORIZED"
    ErrForbidden           = "FORBIDDEN"
    ErrNotFound            = "NOT_FOUND"
    ErrConflict            = "CONFLICT"
    ErrInternalServer      = "INTERNAL_SERVER_ERROR"
    ErrEmailAlreadyExists  = "EMAIL_ALREADY_EXISTS"
    ErrInvalidCredentials  = "INVALID_CREDENTIALS"
    ErrTokenExpired        = "TOKEN_EXPIRED"
    ErrTokenInvalid        = "TOKEN_INVALID"
)
```

---

## Tests

### Structure de Tests

```
backend/
├── internal/
│   ├── service/
│   │   ├── auth_service.go
│   │   └── auth_service_test.go
│   ├── repository/
│   │   ├── user_repo.go
│   │   └── user_repo_test.go
│   └── handler/
│       ├── auth_handler.go
│       └── auth_handler_test.go
```

### Types de Tests

1. **Unit Tests** : Services, repositories, utils
2. **Integration Tests** : Handlers avec DB test
3. **E2E Tests** : Flow complet via HTTP

```go
// Example: user_repo_test.go
func TestUserRepository_Create(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()

    repo := NewUserRepository(db)

    user := &User{
        Email:        "test@example.com",
        PasswordHash: "hashed",
    }

    err := repo.Create(context.Background(), user)
    require.NoError(t, err)
    assert.NotEmpty(t, user.ID)
}
```

---

## Migration depuis Mode Stateless

### Phase de Transition

**Backend** :
1. ✅ Mode actuel (stateless) reste fonctionnel
2. ✅ Nouveaux endpoints `/api/v1/auth/*` ajoutés
3. ✅ Endpoints existants fonctionnent sans auth (mode guest)
4. ✅ Middleware auth optionnel (si JWT présent → mode auth)

**Frontend** :
1. ✅ localStorage reste fonctionnel (mode guest)
2. ✅ Ajout d'un bouton "Se connecter" (optionnel)
3. ✅ Si connecté → calls API + JWT
4. ✅ Si guest → localStorage uniquement

**Pas de breaking changes !**

---

## Commandes Utiles (Makefile)

```makefile
.PHONY: dev migrate-up migrate-down migrate-create test

dev:
	go run cmd/server/main.go

migrate-up:
	migrate -path migrations -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path migrations -database "$(DATABASE_URL)" down 1

migrate-create:
	migrate create -ext sql -dir migrations -seq $(name)

test:
	go test -v -race -coverprofile=coverage.out ./...

test-integration:
	go test -v -tags=integration ./...

docker-db:
	docker-compose up -d postgres

clean:
	docker-compose down -v
```

---

## Prochaines Étapes d'Implémentation

### Sprint 1 : Fondations (Cette semaine)

1. **Setup Database**
   - [ ] Ajouter PostgreSQL au docker-compose
   - [ ] Créer les migrations initiales (users, refresh_tokens)
   - [ ] Setup pgxpool + sqlx

2. **Authentification**
   - [ ] Implémenter JWT utils (generate, verify)
   - [ ] Implémenter password utils (hash, compare)
   - [ ] Créer User repository
   - [ ] Créer Auth service
   - [ ] Créer Auth handler (register, login, refresh, logout)

3. **Middleware**
   - [ ] Auth middleware (JWT verification)
   - [ ] Rate limit différencié (guest vs auth)

4. **Tests**
   - [ ] Unit tests pour services
   - [ ] Integration tests pour repositories
   - [ ] E2E tests pour auth flow

---

**Dernière mise à jour** : 2025-11-07
**Auteur** : Claude
**Version** : 1.0
