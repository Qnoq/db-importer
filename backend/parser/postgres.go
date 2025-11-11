package parser

import (
	"regexp"
	"strings"
)

// ParsePostgreSQL parses PostgreSQL CREATE TABLE statements
func ParsePostgreSQL(sqlContent string) []Table {
	var tables []Table

	// Extract CREATE TABLE statements with proper parenthesis balancing
	statements := extractPostgreSQLCreateTableStatements(sqlContent)

	for _, stmt := range statements {
		// Extract table name (with optional schema)
		tableNameRegex := regexp.MustCompile(`(?i)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[a-zA-Z0-9_]+\.)?([a-zA-Z0-9_]+)`)
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
		fields := parseFields(tableContent, "postgres")

		if len(fields) > 0 {
			tables = append(tables, Table{
				Name:   tableName,
				Fields: fields,
			})
		}
	}

	return tables
}

// extractPostgreSQLCreateTableStatements extracts CREATE TABLE statements with proper parenthesis balancing
func extractPostgreSQLCreateTableStatements(sqlContent string) []string {
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

			// Check if statement is complete
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
