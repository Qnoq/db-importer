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

	// Regex to match CREATE TABLE statements with (?s) flag for multiline
	createTableRegex := regexp.MustCompile(`(?is)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?` + "`?" + `([a-zA-Z0-9_]+)` + "`?" + `\s*\((.*?)\)`)

	matches := createTableRegex.FindAllStringSubmatch(sqlContent, -1)

	for _, match := range matches {
		if len(match) < 3 {
			continue
		}

		tableName := match[1]
		tableContent := match[2]

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
				strings.HasPrefix(upperPart, "CONSTRAINT") ||
				strings.HasPrefix(upperPart, "FOREIGN KEY") {
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
