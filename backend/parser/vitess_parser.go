package parser

import (
	"regexp"
	"strings"

	"github.com/blastrain/vitess-sqlparser/sqlparser"
)

// ParseWithVitess parses SQL dumps using vitess-sqlparser (multi-database)
func ParseWithVitess(sqlContent string) []Table {
	var tables []Table

	// Use a more robust statement splitting approach
	// Split by semicolon but ensure we have complete statements
	statements := splitSQLStatements(sqlContent)

	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" || strings.HasPrefix(strings.ToUpper(stmt), "--") || strings.HasPrefix(stmt, "/*") {
			continue
		}

		// Parse the statement
		parsedStmt, err := sqlparser.Parse(stmt)
		if err != nil {
			// Skip unparseable statements silently
			continue
		}

		// Check if it's a CREATE TABLE statement
		createTable, ok := parsedStmt.(*sqlparser.CreateTable)
		if !ok {
			continue
		}

		// Extract table name from the original SQL instead of parsed structure
		tableName := extractTableNameFromSQL(stmt)

		// Skip if we couldn't extract table name
		if tableName == "" {
			continue
		}

		// Extract columns
		var fields []Field
		for _, col := range createTable.Columns {
			fieldName := string(col.Name)
			fieldType := string(col.Type)

			// Check if nullable (look for NOT NULL in options)
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

		if len(fields) > 0 {
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

// min returns the minimum of two integers
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
