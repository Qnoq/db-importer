# Contributing to DB Importer

Thank you for considering contributing to DB Importer! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Go 1.21+ (for local backend development)
- Node.js 20+ (for local frontend development)
- Git

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/db-importer.git
   cd db-importer
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/db-importer.git
   ```

## Development Setup

### Using Docker (Recommended)

Start the development environment:

```bash
docker-compose -f docker-compose.dev.yml up
```

- Backend: http://localhost:8080
- Frontend: http://localhost:5173

### Local Development

#### Backend

```bash
cd backend
go mod download
go run main.go
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Project Structure

```
db-importer/
├── backend/
│   ├── config/          # Configuration management
│   ├── errors/          # Error types and handlers
│   ├── generator/       # SQL generation logic
│   ├── logger/          # Structured logging
│   ├── middleware/      # HTTP middleware (rate limiting, etc.)
│   ├── parser/          # SQL schema parsers
│   ├── main.go          # Main application entry
│   ├── go.mod           # Go dependencies
│   └── Dockerfile       # Production Docker image
│
├── frontend/
│   ├── src/
│   │   ├── pages/       # Vue page components
│   │   ├── router/      # Vue Router configuration
│   │   ├── store/       # Pinia state management
│   │   ├── App.vue      # Root component
│   │   └── main.ts      # Application entry
│   ├── package.json     # Node dependencies
│   ├── Dockerfile       # Production Docker image (nginx)
│   ├── Dockerfile.dev   # Development Docker image
│   └── nginx.conf       # Nginx configuration
│
├── examples/            # Example SQL and CSV files
├── docker-compose.yml   # Production Docker Compose
├── docker-compose.dev.yml  # Development Docker Compose
├── .env.example         # Environment variables template
├── SECURITY.md          # Security documentation
└── README.md            # Project documentation
```

## Making Changes

### Creating a Branch

Always create a new branch for your changes:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Use descriptive branch names:
- `feature/add-postgresql-support`
- `fix/sql-injection-vulnerability`
- `docs/update-readme`

### Backend Development

#### Adding a New Feature

1. Create necessary package files in appropriate directories
2. Update `main.go` to register new handlers/routes
3. Add configuration options in `config/config.go`
4. Add logging for important operations
5. Handle errors using `errors` package
6. Update API documentation

#### Code Style

- Follow Go conventions and best practices
- Use `gofmt` to format code
- Run `go vet` to check for common mistakes
- Add comments for exported functions
- Keep functions small and focused

### Frontend Development

#### Adding a New Feature

1. Create Vue components in `src/pages/` or `src/components/`
2. Update routes in `src/router/index.ts`
3. Update Pinia store if state management is needed
4. Use TypeScript interfaces for type safety
5. Follow existing component structure

#### Code Style

- Use TypeScript for type safety
- Follow Vue 3 Composition API patterns
- Use proper TypeScript types (avoid `any`)
- Keep components small and reusable
- Add comments for complex logic

## Testing

### Backend Testing

```bash
cd backend
go test ./...
```

### Frontend Testing

```bash
cd frontend
npm run test
```

### Manual Testing

1. Test with example files in `examples/` directory
2. Try different SQL databases (MySQL, PostgreSQL)
3. Test with large files
4. Verify error handling
5. Check browser console for errors

## Code Style

### Go

- Use `gofmt` for formatting
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Keep line length under 100 characters
- Use descriptive variable names
- Add package documentation

### TypeScript/Vue

- Use 2 spaces for indentation
- Use single quotes for strings
- Add trailing commas in objects/arrays
- Use semicolons
- Follow Vue 3 best practices

### Commit Messages

Write clear, descriptive commit messages:

```
Add Levenshtein distance algorithm for column matching

- Implement Levenshtein distance calculation
- Improve auto-mapping accuracy
- Add similarity threshold of 0.6
```

Format:
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description (wrap at 72 chars)

## Pull Request Process

### Before Submitting

1. Update your branch with latest upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. Ensure all tests pass
3. Update documentation if needed
4. Test your changes thoroughly

### Submitting

1. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Create a Pull Request on GitHub

3. Fill out the PR template:
   - **Description**: What does this PR do?
   - **Motivation**: Why is this change needed?
   - **Testing**: How was this tested?
   - **Screenshots**: For UI changes

4. Link related issues:
   - "Fixes #123"
   - "Closes #456"

### PR Review Process

- Maintainers will review your PR
- Address feedback and push updates
- Once approved, your PR will be merged

## Reporting Issues

### Bug Reports

Use the bug report template and include:

- **Description**: Clear description of the bug
- **Steps to reproduce**: Detailed steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: OS, browser, versions
- **Screenshots**: If applicable
- **Logs**: Relevant error messages

### Feature Requests

Use the feature request template and include:

- **Problem**: What problem does this solve?
- **Solution**: Proposed solution
- **Alternatives**: Other approaches considered
- **Additional context**: Any other information

## Questions?

- Check existing issues and documentation
- Ask in GitHub Discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Thank You!

Your contributions help make DB Importer better for everyone!
