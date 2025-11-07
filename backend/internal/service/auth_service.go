package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"db-importer/internal/models"
	"db-importer/internal/repository"
	"db-importer/internal/utils"

	"github.com/google/uuid"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrEmailAlreadyExists = errors.New("email already exists")
	ErrUserNotActive      = errors.New("user account is not active")
)

// AuthService handles authentication business logic
type AuthService struct {
	userRepo         *repository.UserRepository
	refreshTokenRepo *repository.RefreshTokenRepository
	jwtConfig        utils.JWTConfig
}

// NewAuthService creates a new AuthService
func NewAuthService(
	userRepo *repository.UserRepository,
	refreshTokenRepo *repository.RefreshTokenRepository,
	jwtConfig utils.JWTConfig,
) *AuthService {
	return &AuthService{
		userRepo:         userRepo,
		refreshTokenRepo: refreshTokenRepo,
		jwtConfig:        jwtConfig,
	}
}

// Register creates a new user account
func (s *AuthService) Register(ctx context.Context, req *models.CreateUserRequest) (*models.UserResponse, error) {
	// Check if email already exists
	exists, err := s.userRepo.EmailExists(ctx, req.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to check email: %w", err)
	}
	if exists {
		return nil, ErrEmailAlreadyExists
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Create user
	user := &models.User{
		Email:        req.Email,
		PasswordHash: hashedPassword,
		FirstName:    req.FirstName,
		LastName:     req.LastName,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return user.ToResponse(), nil
}

// Login authenticates a user and returns tokens
func (s *AuthService) Login(ctx context.Context, req *models.LoginRequest) (*models.LoginResponse, error) {
	// Get user by email
	user, err := s.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, ErrInvalidCredentials
	}

	// Check if user is active
	if !user.IsActive {
		return nil, ErrUserNotActive
	}

	// Verify password
	if err := utils.CheckPassword(req.Password, user.PasswordHash); err != nil {
		return nil, ErrInvalidCredentials
	}

	// Generate access token
	accessToken, err := utils.GenerateAccessToken(user.ID, user.Email, s.jwtConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	// Generate refresh token
	refreshToken, _, err := utils.GenerateRefreshToken(user.ID, s.jwtConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	// Store refresh token hash in database
	tokenHash := utils.HashRefreshToken(refreshToken)
	refreshTokenModel := &models.RefreshToken{
		UserID:    user.ID,
		TokenHash: tokenHash,
		ExpiresAt: time.Now().Add(s.jwtConfig.RefreshExpiry),
	}

	if err := s.refreshTokenRepo.Create(ctx, refreshTokenModel); err != nil {
		return nil, fmt.Errorf("failed to store refresh token: %w", err)
	}

	// Update last login timestamp
	if err := s.userRepo.UpdateLastLogin(ctx, user.ID); err != nil {
		// Log error but don't fail the login
		fmt.Printf("Warning: failed to update last login: %v\n", err)
	}

	return &models.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         user.ToResponse(),
	}, nil
}

// RefreshTokens generates new access and refresh tokens
func (s *AuthService) RefreshTokens(ctx context.Context, refreshTokenString string) (*models.RefreshTokenResponse, error) {
	// Validate refresh token
	claims, err := utils.ValidateRefreshToken(refreshTokenString, s.jwtConfig)
	if err != nil {
		return nil, fmt.Errorf("invalid refresh token: %w", err)
	}

	// Get token hash
	tokenHash := utils.HashRefreshToken(refreshTokenString)

	// Check if token exists and is valid
	storedToken, err := s.refreshTokenRepo.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		return nil, fmt.Errorf("refresh token not found: %w", err)
	}

	// Verify token is valid
	if !storedToken.IsValid() {
		return nil, errors.New("refresh token is expired or revoked")
	}

	// Parse user ID
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID: %w", err)
	}

	// Get user
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	// Revoke old refresh token
	if err := s.refreshTokenRepo.Revoke(ctx, tokenHash); err != nil {
		// Log error but continue with token generation
		fmt.Printf("Warning: failed to revoke old refresh token: %v\n", err)
	}

	// Generate new access token
	newAccessToken, err := utils.GenerateAccessToken(user.ID, user.Email, s.jwtConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	// Generate new refresh token
	newRefreshToken, _, err := utils.GenerateRefreshToken(user.ID, s.jwtConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	// Store new refresh token
	newTokenHash := utils.HashRefreshToken(newRefreshToken)
	refreshTokenModel := &models.RefreshToken{
		UserID:    user.ID,
		TokenHash: newTokenHash,
		ExpiresAt: time.Now().Add(s.jwtConfig.RefreshExpiry),
	}

	if err := s.refreshTokenRepo.Create(ctx, refreshTokenModel); err != nil {
		return nil, fmt.Errorf("failed to store refresh token: %w", err)
	}

	return &models.RefreshTokenResponse{
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
	}, nil
}

// Logout revokes a refresh token
func (s *AuthService) Logout(ctx context.Context, refreshTokenString string) error {
	// Get token hash
	tokenHash := utils.HashRefreshToken(refreshTokenString)

	// Revoke token
	if err := s.refreshTokenRepo.Revoke(ctx, tokenHash); err != nil {
		return fmt.Errorf("failed to logout: %w", err)
	}

	return nil
}

// GetUserByID retrieves a user by ID
func (s *AuthService) GetUserByID(ctx context.Context, userID uuid.UUID) (*models.UserResponse, error) {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}
