package parser

import (
	"regexp"
	"strings"
)

// Field represents a database column
type Field struct {
	Name     string `json:"name"`
	Type     string `json:"type"`
	Nullable bool   `json:"nullable"`
}

// Table represents a database table
type Table struct {
	Name   string  `json:"name"`
	Fields []Field `json:"fields"`
}

// ParseMySQL parses MySQL/MariaDB CREATE TABLE statements
func ParseMySQL(sqlContent string) []Table {
	var tables []Table

	// Extract CREATE TABLE statements with proper parenthesis balancing
	statements := extractMySQLCreateTableStatements(sqlContent)

	for _, stmt := range statements {
		// Extract table name
		tableNameRegex := regexp.MustCompile(`(?i)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?` + "`?" + `([a-zA-Z0-9_]+)` + "`?")
		nameMatch := tableNameRegex.FindStringSubmatch(stmt)
		if len(nameMatch) < 2 {
			continue
		}
		tableName := nameMatch[1]

		// Extract content between first '(' and last ')'
		firstParen := strings.Index(stmt, "(")
		lastParen := strings.LastIndex(stmt, ")")
		if firstParen == -1 || lastParen == -1 || firstParen >= lastParen {
			continue
		}

		tableContent := stmt[firstParen+1 : lastParen]
		fields := parseFields(tableContent, "mysql")

		if len(fields) > 0 {
			tables = append(tables, Table{
				Name:   tableName,
				Fields: fields,
			})
		}
	}

	return tables
}

// extractMySQLCreateTableStatements extracts CREATE TABLE statements with proper parenthesis balancing
func extractMySQLCreateTableStatements(sqlContent string) []string {
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

			// Check if statement is complete (parenDepth back to 0 and ends with semicolon or parenDepth is 0)
			if parenDepth == 0 && strings.Contains(line, ")") {
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

// parseFields extracts field definitions from table content
func parseFields(content string, dbType string) []Field {
	var fields []Field

	// First, split by lines to handle multi-line definitions
	lines := strings.Split(content, "\n")

	// Process each line
	for _, line := range lines {
		line = strings.TrimSpace(line)

		// Skip empty lines
		if line == "" {
			continue
		}

		// Split by comma to handle multiple fields on same line
		parts := splitByComma(line)

		for _, part := range parts {
			part = strings.TrimSpace(part)

			// Skip constraints and keys
			upperPart := strings.ToUpper(part)
			if strings.HasPrefix(upperPart, "PRIMARY KEY") ||
				strings.HasPrefix(upperPart, "KEY ") ||
				strings.HasPrefix(upperPart, "INDEX") ||
				strings.HasPrefix(upperPart, "UNIQUE KEY") ||
				strings.HasPrefix(upperPart, "UNIQUE (") || // PostgreSQL UNIQUE constraint
				strings.HasPrefix(upperPart, "CONSTRAINT") ||
				strings.HasPrefix(upperPart, "FOREIGN KEY") ||
				strings.HasPrefix(upperPart, "CHECK ") { // CHECK constraint
				continue
			}

			field := parseFieldLine(part, dbType)
			if field.Name != "" {
				fields = append(fields, field)
			}
		}
	}

	return fields
}

// splitByComma splits a string by comma, but ignores commas inside parentheses
func splitByComma(s string) []string {
	var result []string
	var current strings.Builder
	parenDepth := 0

	for _, ch := range s {
		if ch == '(' {
			parenDepth++
			current.WriteRune(ch)
		} else if ch == ')' {
			parenDepth--
			current.WriteRune(ch)
		} else if ch == ',' && parenDepth == 0 {
			if current.Len() > 0 {
				result = append(result, current.String())
				current.Reset()
			}
		} else {
			current.WriteRune(ch)
		}
	}

	if current.Len() > 0 {
		result = append(result, current.String())
	}

	return result
}

// parseFieldLine parses a single field definition
func parseFieldLine(line string, dbType string) Field {
	line = strings.TrimSpace(line)
	line = strings.TrimSuffix(line, ",")

	// Remove backticks for MySQL
	line = strings.ReplaceAll(line, "`", "")

	parts := strings.Fields(line)
	if len(parts) < 2 {
		return Field{}
	}

	fieldName := parts[0]
	fieldType := parts[1]

	// Check if NOT NULL
	nullable := true
	upperLine := strings.ToUpper(line)
	if strings.Contains(upperLine, "NOT NULL") {
		nullable = false
	}

	return Field{
		Name:     fieldName,
		Type:     fieldType,
		Nullable: nullable,
	}
}
