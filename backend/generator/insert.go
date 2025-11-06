package generator

import (
	"fmt"
	"strings"
)

// GenerateInsertSQL generates INSERT statements from the mapping and data
func GenerateInsertSQL(tableName string, mapping map[string]string, rows [][]interface{}) string {
	if len(rows) == 0 {
		return ""
	}

	// Extract database columns in order from mapping values
	var dbColumns []string
	var excelColumns []string

	for excelCol, dbCol := range mapping {
		if dbCol != "" {
			excelColumns = append(excelColumns, excelCol)
			dbColumns = append(dbColumns, dbCol)
		}
	}

	if len(dbColumns) == 0 {
		return ""
	}

	// Build column list
	columnList := strings.Join(dbColumns, ", ")

	// Build INSERT statement
	var sql strings.Builder
	sql.WriteString(fmt.Sprintf("INSERT INTO %s (%s) VALUES\n", tableName, columnList))

	// Build values
	var valueRows []string
	for _, row := range rows {
		var values []string
		for _, cell := range row {
			values = append(values, formatValue(cell))
		}
		valueRows = append(valueRows, fmt.Sprintf("(%s)", strings.Join(values, ", ")))
	}

	sql.WriteString(strings.Join(valueRows, ",\n"))
	sql.WriteString(";")

	return sql.String()
}

// formatValue formats a value for SQL
func formatValue(value interface{}) string {
	if value == nil {
		return "NULL"
	}

	strValue := fmt.Sprintf("%v", value)

	// Escape single quotes
	strValue = strings.ReplaceAll(strValue, "'", "''")

	// Return quoted string
	return fmt.Sprintf("'%s'", strValue)
}
