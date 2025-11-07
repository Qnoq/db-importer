.PHONY: help build run dev test clean migrate-up migrate-down migrate-create docker-up docker-down

# Variables
BINARY_NAME=db-importer
MIGRATIONS_PATH=./migrations
DATABASE_URL?=postgres://dbimporter:dbimporter_dev_password@localhost:5432/dbimporter_dev?sslmode=disable

## help: Display this help message
help:
	@echo "Available commands:"
	@echo "  make build          - Build the application"
	@echo "  make run            - Run the application"
	@echo "  make dev            - Run in development mode (hot reload with air if available)"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make migrate-up     - Run database migrations up"
	@echo "  make migrate-down   - Rollback last migration"
	@echo "  make migrate-create - Create a new migration (use: make migrate-create name=my_migration)"
	@echo "  make docker-up      - Start docker-compose services"
	@echo "  make docker-down    - Stop docker-compose services"
	@echo "  make tidy           - Run go mod tidy"

## build: Build the application
build:
	@echo "Building $(BINARY_NAME)..."
	go build -o $(BINARY_NAME) .
	@echo "Build complete: ./$(BINARY_NAME)"

## run: Run the application
run:
	@echo "Running $(BINARY_NAME)..."
	go run .

## dev: Run in development mode
dev:
	@echo "Running in development mode..."
	@if command -v air > /dev/null; then \
		air; \
	else \
		echo "Air not found. Install it with: go install github.com/cosmtrek/air@latest"; \
		echo "Running with go run instead..."; \
		go run .; \
	fi

## test: Run tests
test:
	@echo "Running tests..."
	go test -v -race -coverprofile=coverage.out ./...
	@echo "Coverage report generated: coverage.out"

## test-coverage: Show test coverage in browser
test-coverage: test
	go tool cover -html=coverage.out

## clean: Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -f $(BINARY_NAME)
	rm -f coverage.out
	@echo "Clean complete"

## migrate-up: Run all migrations
migrate-up:
	@echo "Running migrations..."
	@if command -v migrate > /dev/null; then \
		migrate -path $(MIGRATIONS_PATH) -database "$(DATABASE_URL)" up; \
	else \
		echo "Error: golang-migrate not found. Install it with:"; \
		echo "  brew install golang-migrate"; \
		echo "  or download from: https://github.com/golang-migrate/migrate/releases"; \
		exit 1; \
	fi

## migrate-down: Rollback last migration
migrate-down:
	@echo "Rolling back last migration..."
	@if command -v migrate > /dev/null; then \
		migrate -path $(MIGRATIONS_PATH) -database "$(DATABASE_URL)" down 1; \
	else \
		echo "Error: golang-migrate not found."; \
		exit 1; \
	fi

## migrate-create: Create a new migration file
migrate-create:
	@if [ -z "$(name)" ]; then \
		echo "Error: Please provide a migration name: make migrate-create name=my_migration"; \
		exit 1; \
	fi
	@echo "Creating migration: $(name)"
	@if command -v migrate > /dev/null; then \
		migrate create -ext sql -dir $(MIGRATIONS_PATH) -seq $(name); \
	else \
		echo "Error: golang-migrate not found."; \
		exit 1; \
	fi

## migrate-force: Force migration version (use: make migrate-force version=1)
migrate-force:
	@if [ -z "$(version)" ]; then \
		echo "Error: Please provide a version: make migrate-force version=1"; \
		exit 1; \
	fi
	@echo "Forcing migration to version $(version)..."
	migrate -path $(MIGRATIONS_PATH) -database "$(DATABASE_URL)" force $(version)

## docker-up: Start docker-compose services
docker-up:
	@echo "Starting Docker services..."
	docker-compose -f ../docker-compose.dev.yml up -d
	@echo "Waiting for database to be ready..."
	@sleep 5
	@echo "Docker services started"

## docker-down: Stop docker-compose services
docker-down:
	@echo "Stopping Docker services..."
	docker-compose -f ../docker-compose.dev.yml down
	@echo "Docker services stopped"

## docker-logs: View docker logs
docker-logs:
	docker-compose -f ../docker-compose.dev.yml logs -f

## tidy: Run go mod tidy
tidy:
	@echo "Running go mod tidy..."
	go mod tidy
	@echo "Dependencies tidied"

## fmt: Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...
	@echo "Code formatted"

## vet: Run go vet
vet:
	@echo "Running go vet..."
	go vet ./...
	@echo "Vet complete"

## lint: Run linters (requires golangci-lint)
lint:
	@echo "Running linters..."
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found. Install it with:"; \
		echo "  brew install golangci-lint"; \
		echo "  or: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

## install-tools: Install development tools
install-tools:
	@echo "Installing development tools..."
	go install github.com/cosmtrek/air@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "Tools installed"

## setup: Initial setup (install tools, tidy deps)
setup: install-tools tidy
	@echo "Setup complete!"
