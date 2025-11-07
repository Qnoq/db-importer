package parser

import (
	"regexp"
	"strings"

	"github.com/blastrain/vitess-sqlparser/sqlparser"
)

// ParseWithVitess parses SQL dumps using vitess-sqlparser with regex fallback
func ParseWithVitess(sqlContent string) []Table {
	var tables []Table

	// Use a more robust statement splitting approach
	statements := splitSQLStatements(sqlContent)

	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" || strings.HasPrefix(strings.ToUpper(stmt), "--") || strings.HasPrefix(stmt, "/*") {
			continue
		}

		// Check if it's a CREATE TABLE statement
		if !strings.Contains(strings.ToUpper(stmt), "CREATE TABLE") {
			continue
		}

		// Try parsing with vitess first
		parsedStmt, err := sqlparser.Parse(stmt)
		var fields []Field
		var tableName string

		if err == nil {
			// Vitess parsing succeeded
			createTable, ok := parsedStmt.(*sqlparser.CreateTable)
			if ok {
				tableName = extractTableNameFromSQL(stmt)

				// Extract columns from vitess parser
				for _, col := range createTable.Columns {
					fieldName := string(col.Name)
					fieldType := string(col.Type)

					// Check if nullable
					nullable := true
					for _, opt := range col.Options {
						if opt != nil && opt.Type == sqlparser.ColumnOptionNotNull {
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
			}
		}

		// If vitess failed or found no columns, use regex fallback
		if len(fields) == 0 {
			tableName = extractTableNameFromSQL(stmt)
			fields = extractFieldsWithRegex(stmt)
		}

		// Add table if we found both name and fields
		if tableName != "" && len(fields) > 0 {
			tables = append(tables, Table{
				Name:   tableName,
				Fields: fields,
			})
		}
	}

	return tables
}

// splitSQLStatements splits SQL content by semicolons
func splitSQLStatements(sqlContent string) []string {
	return strings.Split(sqlContent, ";")
}

// extractTableNameFromSQL extracts table name using regex as fallback
func extractTableNameFromSQL(sql string) string {
	// Try to extract table name from CREATE TABLE statement using regex
	patterns := []string{
		`(?i)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?` + "`" + `([a-zA-Z0-9_]+)` + "`",
		`(?i)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_]+)`,
	}

	for _, pattern := range patterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindStringSubmatch(sql)
		if len(matches) > 1 {
			return matches[1]
		}
	}

	return ""
}

// extractFieldsWithRegex extracts column definitions using regex (fallback method)
func extractFieldsWithRegex(sql string) []Field {
	var fields []Field

	// Remove everything before the first opening parenthesis
	startIdx := strings.Index(sql, "(")
	if startIdx == -1 {
		return fields
	}

	// Find the matching closing parenthesis
	depth := 0
	endIdx := -1
	for i := startIdx; i < len(sql); i++ {
		if sql[i] == '(' {
			depth++
		} else if sql[i] == ')' {
			depth--
			if depth == 0 {
				endIdx = i
				break
			}
		}
	}

	if endIdx == -1 {
		return fields
	}

	// Extract the content between parentheses
	content := sql[startIdx+1 : endIdx]

	// Split by lines and commas to find column definitions
	lines := strings.Split(content, "\n")

	for _, line := range lines {
		line = strings.TrimSpace(line)

		// Skip empty lines, comments, and constraint definitions
		if line == "" ||
			strings.HasPrefix(line, "--") ||
			strings.HasPrefix(line, "/*") ||
			strings.HasPrefix(strings.ToUpper(line), "PRIMARY KEY") ||
			strings.HasPrefix(strings.ToUpper(line), "UNIQUE KEY") ||
			strings.HasPrefix(strings.ToUpper(line), "KEY") ||
			strings.HasPrefix(strings.ToUpper(line), "FOREIGN KEY") ||
			strings.HasPrefix(strings.ToUpper(line), "CONSTRAINT") ||
			strings.HasPrefix(strings.ToUpper(line), "INDEX") {
			continue
		}

		// Remove trailing comma
		line = strings.TrimRight(line, ",")

		// Try to parse column definition
		// Pattern: `column_name` type [anything...]
		// or: column_name type [anything...]
		patterns := []string{
			// With backticks - capture column name and the rest of the line
			"`" + `([a-zA-Z0-9_]+)` + "`" + `\s+(.+)`,
			// Without backticks
			`^([a-zA-Z0-9_]+)\s+(.+)`,
		}

		for _, pattern := range patterns {
			re := regexp.MustCompile(pattern)
			matches := re.FindStringSubmatch(line)

			if len(matches) >= 3 {
				fieldName := matches[1]
				restOfLine := matches[2]

				// Extract just the type (first word before space or parenthesis content)
				typeRegex := regexp.MustCompile(`^([a-zA-Z0-9_]+(?:\([^)]+\))?)(?:\s+UNSIGNED)?`)
				typeMatches := typeRegex.FindStringSubmatch(restOfLine)

				if len(typeMatches) < 2 {
					// Fallback: just take first word
					fieldType := strings.Fields(restOfLine)[0]
					typeMatches = []string{"", fieldType}
				}

				fieldType := typeMatches[1]

				// Check for UNSIGNED
				if strings.Contains(strings.ToUpper(restOfLine), "UNSIGNED") {
					fieldType += " UNSIGNED"
				}

				// Determine if nullable
				nullable := true
				if strings.Contains(strings.ToUpper(line), "NOT NULL") {
					nullable = false
				}

				fields = append(fields, Field{
					Name:     fieldName,
					Type:     fieldType,
					Nullable: nullable,
				})
				break
			}
		}
	}

	return fields
}

// min returns the minimum of two integers
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
