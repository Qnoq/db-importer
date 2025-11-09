#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_LOG="$PROJECT_ROOT/backend.log"
FRONTEND_LOG="$PROJECT_ROOT/frontend.log"

# PID tracking
BACKEND_PID=""
FRONTEND_PID=""

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🛑 Stopping all processes...${NC}"

    # Kill all child processes
    pkill -P $$ 2>/dev/null || true

    # Kill specific processes
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi

    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi

    # Kill any remaining go run or npm processes started by this script
    pkill -f "go run.*cmd/server" 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true

    echo -e "${GREEN}✅ All processes stopped${NC}"
    exit 0
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# Check dependencies
check_deps() {
    echo -e "${YELLOW}🔍 Checking dependencies...${NC}"

    # Check Go
    if ! command -v go &> /dev/null; then
        echo -e "${RED}❌ Go is not installed${NC}"
        echo -e "${CYAN}Install from: https://golang.org/dl/${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Go $(go version | cut -d' ' -f3)${NC}"

    # Check Node
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js is not installed${NC}"
        echo -e "${CYAN}Install from: https://nodejs.org/${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Node $(node --version)${NC}"

    # Check if Air is installed (optional, for hot reload)
    if command -v air &> /dev/null; then
        echo -e "${GREEN}✓ Air installed (hot reload enabled)${NC}"
        USE_AIR=true
    else
        echo -e "${YELLOW}⚠ Air not found - using 'go run' (no hot reload)${NC}"
        echo -e "${CYAN}Install Air for hot reload: go install github.com/air-verse/air@latest${NC}"
        USE_AIR=false
    fi
}

# Setup environment
setup_env() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"

    # Check for .env file
    if [ ! -f "$PROJECT_ROOT/.env.local" ] && [ ! -f "$BACKEND_DIR/.env" ]; then
        echo -e "${YELLOW}⚠️  No .env file found${NC}"

        if [ -f "$BACKEND_DIR/.env.example" ]; then
            echo -e "${CYAN}Creating .env.local from .env.example...${NC}"
            cp "$BACKEND_DIR/.env.example" "$PROJECT_ROOT/.env.local"

            # Create backend symlink
            if [ ! -f "$BACKEND_DIR/.env" ]; then
                ln -sf ../.env.local "$BACKEND_DIR/.env"
            fi

            echo -e "${GREEN}✓ Created .env.local${NC}"
            echo -e "${YELLOW}⚠️  Please edit .env.local and add your configuration${NC}"
        else
            echo -e "${RED}❌ No .env.example found${NC}"
        fi
    else
        echo -e "${GREEN}✓ Environment file exists${NC}"

        # Create symlink if needed
        if [ ! -f "$BACKEND_DIR/.env" ] && [ -f "$PROJECT_ROOT/.env.local" ]; then
            ln -sf ../.env.local "$BACKEND_DIR/.env"
            echo -e "${GREEN}✓ Created backend .env symlink${NC}"
        fi
    fi

    # Install backend dependencies if needed
    if [ ! -d "$BACKEND_DIR/vendor" ]; then
        echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
        (cd "$BACKEND_DIR" && go mod download)
        echo -e "${GREEN}✓ Backend dependencies installed${NC}"
    fi

    # Install frontend dependencies if needed
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        echo -e "${YELLOW}📦 Installing frontend dependencies...${NC}"
        (cd "$FRONTEND_DIR" && npm install)
        echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
    fi
}

# Start backend
start_backend() {
    echo -e "${YELLOW}🚀 Starting backend...${NC}"

    cd "$BACKEND_DIR"

    if [ "$USE_AIR" = true ] && [ -f "$BACKEND_DIR/.air.toml" ]; then
        # Use Air for hot reload
        air > "$BACKEND_LOG" 2>&1 &
        BACKEND_PID=$!
        echo -e "${GREEN}✓ Backend started with Air (hot reload enabled) [PID: $BACKEND_PID]${NC}"
    elif [ "$USE_AIR" = true ]; then
        # Air is installed but no config, create one
        cat > "$BACKEND_DIR/.air.toml" << 'EOF'
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main ./cmd/server"
  bin = "tmp/main"
  full_bin = "./tmp/main"
  include_ext = ["go", "tpl", "tmpl", "html"]
  exclude_dir = ["assets", "tmp", "vendor", "frontend", "node_modules"]
  include_dir = []
  exclude_file = []
  delay = 1000
  stop_on_error = true
  log = "air_errors.log"

[log]
  time = true

[color]
  main = "magenta"
  watcher = "cyan"
  build = "yellow"
  runner = "green"
EOF
        air > "$BACKEND_LOG" 2>&1 &
        BACKEND_PID=$!
        echo -e "${GREEN}✓ Backend started with Air (hot reload enabled) [PID: $BACKEND_PID]${NC}"
    else
        # Use go run (no hot reload)
        go run ./cmd/server > "$BACKEND_LOG" 2>&1 &
        BACKEND_PID=$!
        echo -e "${GREEN}✓ Backend started with 'go run' [PID: $BACKEND_PID]${NC}"
    fi

    cd "$PROJECT_ROOT"
}

# Start frontend
start_frontend() {
    echo -e "${YELLOW}🚀 Starting frontend...${NC}"

    cd "$FRONTEND_DIR"
    npm run dev > "$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    cd "$PROJECT_ROOT"

    echo -e "${GREEN}✓ Frontend started (Vite dev server) [PID: $FRONTEND_PID]${NC}"
}

# Wait for backend to be ready
wait_for_backend() {
    echo -e "${YELLOW}⏳ Waiting for backend to be ready...${NC}"

    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:8080/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Backend is ready!${NC}"
            return 0
        fi

        attempt=$((attempt + 1))
        sleep 1
    done

    echo -e "${RED}❌ Backend failed to start within 30 seconds${NC}"
    echo -e "${CYAN}Check logs: tail -f $BACKEND_LOG${NC}"
    return 1
}

# Monitor logs
monitor_logs() {
    echo -e "\n${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Development environment ready!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "📱 Frontend: ${CYAN}http://localhost:5173${NC}"
    echo -e "🔧 Backend:  ${CYAN}http://localhost:8080${NC}"
    echo -e "📊 Health:   ${CYAN}http://localhost:8080/health${NC}"
    echo -e "\n${YELLOW}📝 View logs:${NC}"
    echo -e "  Backend:  ${CYAN}tail -f $BACKEND_LOG${NC}"
    echo -e "  Frontend: ${CYAN}tail -f $FRONTEND_LOG${NC}"
    echo -e "\n${YELLOW}Press Ctrl+C to stop all services${NC}\n"

    # Show combined logs with different colors
    tail -f "$BACKEND_LOG" "$FRONTEND_LOG" 2>/dev/null | while IFS= read -r line; do
        if [[ $line == *"backend.log"* ]]; then
            echo -e "${CYAN}[BACKEND]${NC} "
        elif [[ $line == *"frontend.log"* ]]; then
            echo -e "${GREEN}[FRONTEND]${NC} "
        else
            echo "$line"
        fi
    done
}

# Main execution
main() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       DB Importer Dev Environment      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"

    check_deps
    echo ""
    setup_env
    echo ""
    start_backend

    # Wait for backend to be ready
    if ! wait_for_backend; then
        cleanup
        exit 1
    fi

    echo ""
    start_frontend

    # Wait a bit for frontend to start
    sleep 3

    monitor_logs
}

# Run main function
main
