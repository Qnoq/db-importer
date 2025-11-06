package parser

import (
	"regexp"
)

// ParsePostgreSQL parses PostgreSQL CREATE TABLE statements
func ParsePostgreSQL(sqlContent string) []Table {
	var tables []Table

	// Regex to match CREATE TABLE statements (PostgreSQL style) with (?s) flag for multiline
	createTableRegex := regexp.MustCompile(`(?is)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[a-zA-Z0-9_]+\.)?([a-zA-Z0-9_]+)\s*\((.*?)\)`)

	matches := createTableRegex.FindAllStringSubmatch(sqlContent, -1)

	for _, match := range matches {
		if len(match) < 3 {
			continue
		}

		tableName := match[1]
		tableContent := match[2]

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
