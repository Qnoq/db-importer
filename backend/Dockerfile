# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Copy go mod files
COPY go.mod go.sum* ./

# Download dependencies (cached layer)
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
# Use TARGETARCH to build for the correct architecture (amd64 or arm64)
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a \
    -o /app/db-importer \
    main.go

# Final stage - minimal runtime image
FROM alpine:3.19

# Add ca-certificates for HTTPS and timezone data
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/db-importer /app/db-importer

# Copy migrations directory
COPY --from=builder /app/migrations /app/migrations

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
ENTRYPOINT ["/app/db-importer"]
