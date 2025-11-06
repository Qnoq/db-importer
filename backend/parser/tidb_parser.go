package parser

import (
	"strings"

	"github.com/pingcap/tidb/parser"
	"github.com/pingcap/tidb/parser/ast"
	_ "github.com/pingcap/tidb/parser/test_driver"
)

// ParseWithTiDB parses SQL dumps using hybrid approach:
// 1. Extract each CREATE TABLE with regex
// 2. Parse each table individually with TiDB
func ParseWithTiDB(sqlContent string) []Table {
	var tables []Table

	// Clean SQL content (remove phpMyAdmin directives and comments)
	sqlContent = cleanSQLContent(sqlContent)

	// Extract all CREATE TABLE statements using regex
	createTableStatements := extractCreateTableStatements(sqlContent)

	// Create a new parser
	p := parser.New()

	// Parse each CREATE TABLE individually
	for _, stmt := range createTableStatements {
		// Try to parse this single CREATE TABLE
		stmts, _, err := p.Parse(stmt, "", "")
		if err != nil {
			// Skip tables that fail to parse
			continue
		}

		// Process the parsed statement
		for _, parsedStmt := range stmts {
			createTableStmt, ok := parsedStmt.(*ast.CreateTableStmt)
			if !ok {
				continue
			}

			// Extract table name
			tableName := createTableStmt.Table.Name.String()

			// Extract columns
			var fields []Field
			for _, col := range createTableStmt.Cols {
				fieldName := col.Name.Name.String()

				// Get field type as string
				fieldType := "unknown"
				if col.Tp != nil {
					fieldType = col.Tp.String()
				}

				// Check if nullable
				nullable := true
				for _, opt := range col.Options {
					if opt.Tp == ast.ColumnOptionNotNull {
						nullable = false
						break
					}
				}

				fields = append(fields, Field{
					Name:     fieldName,
					Type:     fieldType,
					Nullable: nullable,
				})
			}

			if len(fields) > 0 {
				tables = append(tables, Table{
					Name:   tableName,
					Fields: fields,
				})
			}
		}
	}

	return tables
}

// parseStatementByStatement tries to parse SQL statement by statement
func parseStatementByStatement(sqlContent string) []Table {
	var tables []Table
	p := parser.New()

	// Split by semicolon, but handle multi-line CREATE TABLE
	statements := smartSplitStatements(sqlContent)

	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" || !strings.Contains(strings.ToUpper(stmt), "CREATE TABLE") {
			continue
		}

		// Try to parse this single statement
		stmts, _, err := p.Parse(stmt+";", "", "")
		if err != nil {
			// If TiDB fails, continue to next statement
			continue
		}

		for _, parsedStmt := range stmts {
			createTableStmt, ok := parsedStmt.(*ast.CreateTableStmt)
			if !ok {
				continue
			}

			tableName := createTableStmt.Table.Name.String()
			var fields []Field

			for _, col := range createTableStmt.Cols {
				fieldName := col.Name.Name.String()

				// Get field type as string
				fieldType := "unknown"
				if col.Tp != nil {
					fieldType = col.Tp.String()
				}

				nullable := true
				for _, opt := range col.Options {
					if opt.Tp == ast.ColumnOptionNotNull {
						nullable = false
						break
					}
				}

				fields = append(fields, Field{
					Name:     fieldName,
					Type:     fieldType,
					Nullable: nullable,
				})
			}

			if len(fields) > 0 {
				tables = append(tables, Table{
					Name:   tableName,
					Fields: fields,
				})
			}
		}
	}

	return tables
}

// cleanSQLContent removes phpMyAdmin directives and problematic statements
func cleanSQLContent(sqlContent string) string {
	lines := strings.Split(sqlContent, "\n")
	var cleanedLines []string

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Skip phpMyAdmin directives, SET statements, and comments
		if trimmed == "" ||
			strings.HasPrefix(trimmed, "--") ||
			strings.HasPrefix(trimmed, "/*") ||
			strings.HasPrefix(trimmed, "/*!") ||
			strings.HasPrefix(trimmed, "SET ") ||
			strings.HasPrefix(trimmed, "START TRANSACTION") ||
			strings.HasPrefix(trimmed, "COMMIT") ||
			strings.HasPrefix(trimmed, "LOCK TABLES") ||
			strings.HasPrefix(trimmed, "UNLOCK TABLES") {
			continue
		}

		// Also skip lines containing only closing comment markers
		if trimmed == "*/" {
			continue
		}

		cleanedLines = append(cleanedLines, line)
	}

	return strings.Join(cleanedLines, "\n")
}

// smartSplitStatements splits SQL content into individual statements
// handling multi-line CREATE TABLE statements properly
func smartSplitStatements(sqlContent string) []string {
	var statements []string
	var currentStmt strings.Builder
	inCreateTable := false
	parenDepth := 0

	lines := strings.Split(sqlContent, "\n")

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Check if starting a CREATE TABLE
		if strings.Contains(strings.ToUpper(trimmed), "CREATE TABLE") {
			inCreateTable = true
			currentStmt.Reset()
		}

		// Track parenthesis depth
		parenDepth += strings.Count(line, "(")
		parenDepth -= strings.Count(line, ")")

		// Add line to current statement
		if currentStmt.Len() > 0 {
			currentStmt.WriteString("\n")
		}
		currentStmt.WriteString(line)

		// Check if statement is complete
		if inCreateTable && parenDepth == 0 && strings.HasSuffix(trimmed, ";") {
			statements = append(statements, currentStmt.String())
			currentStmt.Reset()
			inCreateTable = false
		}
	}

	// Add last statement if any
	if currentStmt.Len() > 0 {
		statements = append(statements, currentStmt.String())
	}

	return statements
}

// extractCreateTableStatements extracts all CREATE TABLE statements from SQL content
func extractCreateTableStatements(sqlContent string) []string {
	var statements []string
	var currentStmt strings.Builder
	inCreateTable := false
	parenDepth := 0

	lines := strings.Split(sqlContent, "\n")

	for _, line := range lines {
		upperLine := strings.ToUpper(strings.TrimSpace(line))

		// Check if starting a CREATE TABLE
		if strings.Contains(upperLine, "CREATE TABLE") {
			// Save previous statement if any
			if currentStmt.Len() > 0 {
				statements = append(statements, currentStmt.String())
			}
			currentStmt.Reset()
			inCreateTable = true
		}

		if inCreateTable {
			// Track parenthesis depth
			parenDepth += strings.Count(line, "(")
			parenDepth -= strings.Count(line, ")")

			// Add line to current statement
			if currentStmt.Len() > 0 {
				currentStmt.WriteString("\n")
			}
			currentStmt.WriteString(line)

			// Check if statement is complete (parenDepth back to 0 and ends with semicolon)
			if parenDepth == 0 && strings.HasSuffix(strings.TrimSpace(line), ";") {
				statements = append(statements, currentStmt.String())
				currentStmt.Reset()
				inCreateTable = false
			}
		}
	}

	// Add last statement if any
	if currentStmt.Len() > 0 {
		statements = append(statements, currentStmt.String())
	}

	return statements
}
