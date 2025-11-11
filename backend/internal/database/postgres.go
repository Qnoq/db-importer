package database

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib" // Register pgx driver for database/sql
	"github.com/jmoiron/sqlx"
)

// DB wraps the database connection
type DB struct {
	Pool *pgxpool.Pool
	Sqlx *sqlx.DB
}

// Config holds database configuration
type Config struct {
	URL             string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
	ConnMaxIdleTime time.Duration
}

// NewDB creates a new database connection with pgxpool and sqlx
func NewDB(cfg Config) (*DB, error) {
	// Parse connection string
	poolConfig, err := pgxpool.ParseConfig(cfg.URL)
	if err != nil {
		return nil, fmt.Errorf("unable to parse database URL: %w", err)
	}

	// Configure connection pool
	poolConfig.MaxConns = int32(cfg.MaxOpenConns)
	poolConfig.MinConns = int32(cfg.MaxIdleConns)
	poolConfig.MaxConnLifetime = cfg.ConnMaxLifetime
	poolConfig.MaxConnIdleTime = cfg.ConnMaxIdleTime

	// Use custom dialer with proper timeout settings
	poolConfig.ConnConfig.DialFunc = func(ctx context.Context, network, addr string) (net.Conn, error) {
		d := &net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
		}
		return d.DialContext(ctx, network, addr)
	}

	// Create pgxpool connection
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, fmt.Errorf("unable to create connection pool: %w", err)
	}

	// Test connection
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("unable to ping database: %w", err)
	}

	// Create sqlx connection for easier scanning
	sqlxDB, err := sqlx.Open("pgx", cfg.URL)
	if err != nil {
		pool.Close()
		return nil, fmt.Errorf("unable to create sqlx connection: %w", err)
	}

	// Configure sqlx pool
	sqlxDB.SetMaxOpenConns(cfg.MaxOpenConns)
	sqlxDB.SetMaxIdleConns(cfg.MaxIdleConns)
	sqlxDB.SetConnMaxLifetime(cfg.ConnMaxLifetime)
	sqlxDB.SetConnMaxIdleTime(cfg.ConnMaxIdleTime)

	log.Println("✅ Database connection established successfully")

	return &DB{
		Pool: pool,
		Sqlx: sqlxDB,
	}, nil
}

// Close closes both database connections
func (db *DB) Close() {
	if db.Pool != nil {
		db.Pool.Close()
	}
	if db.Sqlx != nil {
		db.Sqlx.Close()
	}
	log.Println("Database connections closed")
}

// Health checks database connectivity
func (db *DB) Health(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	return db.Pool.Ping(ctx)
}
