package generator

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// FieldInfo contains information about a database field
type FieldInfo struct {
	Name     string
	Type     string
	Nullable bool
}

// GenerateInsertSQL generates INSERT statements from the mapping and data
func GenerateInsertSQL(tableName string, mapping map[string]string, rows [][]interface{}, fields []FieldInfo) string {
	if len(rows) == 0 {
		return ""
	}

	// Extract database columns in order from fields array (preserves Excel column order)
	var dbColumns []string
	var excelColumns []string
	var columnFields []FieldInfo

	// Use the fields array order to preserve Excel column order from frontend
	for _, field := range fields {
		// Find the Excel column that maps to this field
		for excelCol, dbCol := range mapping {
			if dbCol == field.Name && dbCol != "" {
				excelColumns = append(excelColumns, excelCol)
				dbColumns = append(dbColumns, field.Name)
				columnFields = append(columnFields, field)
				break
			}
		}
	}

	if len(dbColumns) == 0 {
		return ""
	}

	// Build column list with proper escaping
	var escapedColumns []string
	for _, col := range dbColumns {
		escapedColumns = append(escapedColumns, escapeIdentifier(col))
	}
	columnList := strings.Join(escapedColumns, ", ")

	// Build INSERT statement
	var sql strings.Builder
	sql.WriteString(fmt.Sprintf("INSERT INTO %s (%s) VALUES\n", escapeIdentifier(tableName), columnList))

	// Build values
	var valueRows []string
	for _, row := range rows {
		var values []string
		for i, cell := range row {
			if i < len(columnFields) {
				values = append(values, formatValueByType(cell, columnFields[i].Type))
			} else {
				values = append(values, formatValueByType(cell, "varchar"))
			}
		}
		valueRows = append(valueRows, fmt.Sprintf("(%s)", strings.Join(values, ", ")))
	}

	sql.WriteString(strings.Join(valueRows, ",\n"))
	sql.WriteString(";")

	return sql.String()
}

// escapeIdentifier escapes table and column names
func escapeIdentifier(identifier string) string {
	// Remove any existing backticks
	identifier = strings.ReplaceAll(identifier, "`", "")
	// Wrap in backticks for MySQL or quotes for PostgreSQL
	// Using backticks as default (MySQL/MariaDB style)
	return "`" + identifier + "`"
}

// formatValueByType formats a value based on its SQL type
func formatValueByType(value interface{}, sqlType string) string {
	// Handle NULL values
	if value == nil {
		return "NULL"
	}

	// Check if the value is an empty string
	strValue := fmt.Sprintf("%v", value)
	trimmedValue := strings.TrimSpace(strValue)

	if trimmedValue == "" {
		return "NULL"
	}

	// Check if the value is the string "NULL" (case-insensitive)
	if strings.EqualFold(trimmedValue, "null") {
		return "NULL"
	}

	// Normalize type to lowercase for comparison
	sqlType = strings.ToLower(sqlType)

	// Detect type category
	if isNumericType(sqlType) {
		return formatNumericValue(strValue)
	} else if isBooleanType(sqlType) {
		return formatBooleanValue(strValue)
	} else if isDateTimeType(sqlType) {
		return formatDateTimeValue(strValue)
	} else {
		// Default to string formatting
		return formatStringValue(strValue)
	}
}

// isNumericType checks if the SQL type is numeric
func isNumericType(sqlType string) bool {
	sqlType = strings.ToLower(sqlType)
	numericTypes := []string{
		"int", "integer", "tinyint", "smallint", "mediumint", "bigint",
		"decimal", "numeric", "float", "double", "real",
		"serial", "bigserial",
	}

	for _, numType := range numericTypes {
		if strings.Contains(sqlType, numType) {
			return true
		}
	}
	return false
}

// isBooleanType checks if the SQL type is boolean
func isBooleanType(sqlType string) bool {
	sqlType = strings.ToLower(sqlType)
	return strings.Contains(sqlType, "bool") || strings.Contains(sqlType, "bit")
}

// isDateTimeType checks if the SQL type is date/time
func isDateTimeType(sqlType string) bool {
	sqlType = strings.ToLower(sqlType)
	dateTypes := []string{"date", "time", "timestamp", "datetime", "year"}
	for _, dateType := range dateTypes {
		if strings.Contains(sqlType, dateType) {
			return true
		}
	}
	return false
}

// formatNumericValue formats numeric values without quotes
func formatNumericValue(value string) string {
	value = strings.TrimSpace(value)

	// Try to parse as number to validate
	if _, err := strconv.ParseFloat(value, 64); err == nil {
		return value
	}

	// If parsing fails, return NULL
	return "NULL"
}

// formatBooleanValue formats boolean values
func formatBooleanValue(value string) string {
	value = strings.ToLower(strings.TrimSpace(value))

	switch value {
	case "true", "1", "yes", "y", "t":
		return "TRUE"
	case "false", "0", "no", "n", "f":
		return "FALSE"
	default:
		return "NULL"
	}
}

// formatDateTimeValue formats date/time values
func formatDateTimeValue(value string) string {
	value = strings.TrimSpace(value)

	// Check for invalid date values that should be NULL
	// MySQL/MariaDB reject '0', '0000-00-00', empty strings, etc.
	if value == "" || value == "0" || value == "0000-00-00" || value == "0000-00-00 00:00:00" {
		return "NULL"
	}

	// Try to parse common date formats
	dateFormats := []string{
		"2006-01-02",
		"2006-01-02 15:04:05",
		"01/02/2006",
		"02/01/2006",
		"2006/01/02",
		time.RFC3339,
	}

	for _, format := range dateFormats {
		if _, err := time.Parse(format, value); err == nil {
			// Valid date, escape and quote it
			return formatStringValue(value)
		}
	}

	// If not a valid date format, return NULL instead of invalid string
	// This prevents MySQL errors like "Incorrect date value: '0'"
	return "NULL"
}

// formatStringValue formats string values with proper escaping
func formatStringValue(value string) string {
	// Escape backslashes first
	value = strings.ReplaceAll(value, "\\", "\\\\")

	// Escape single quotes
	value = strings.ReplaceAll(value, "'", "''")

	// Escape NULL bytes
	value = strings.ReplaceAll(value, "\x00", "")

	// Escape other special characters
	value = strings.ReplaceAll(value, "\n", "\\n")
	value = strings.ReplaceAll(value, "\r", "\\r")
	value = strings.ReplaceAll(value, "\t", "\\t")

	// Return quoted string
	return fmt.Sprintf("'%s'", value)
}

// ValidateFieldTypes validates that data matches field constraints
func ValidateFieldTypes(rows [][]interface{}, fields []FieldInfo, mapping map[string]string) []string {
	var errors []string

	for rowIdx, row := range rows {
		for colIdx, cell := range row {
			if colIdx >= len(fields) {
				continue
			}

			field := fields[colIdx]

			// Check NOT NULL constraint
			cellStr := fmt.Sprintf("%v", cell)
			trimmedCell := strings.TrimSpace(cellStr)
			isNullValue := cell == nil || trimmedCell == "" || strings.EqualFold(trimmedCell, "null")

			// For date/time fields, also treat "0" and invalid date strings as NULL
			if isDateTimeType(field.Type) {
				if trimmedCell == "0" || trimmedCell == "0000-00-00" || trimmedCell == "0000-00-00 00:00:00" {
					isNullValue = true
				}
			}

			if !field.Nullable && isNullValue {
				errors = append(errors, fmt.Sprintf("Row %d: Field '%s' cannot be NULL", rowIdx+1, field.Name))
			}

			// Validate type (skip if NULL)
			if !isNullValue {
				if err := validateValueType(cell, field.Type); err != nil {
					errors = append(errors, fmt.Sprintf("Row %d, Field '%s': %s", rowIdx+1, field.Name, err.Error()))
				}
			}
		}
	}

	return errors
}

// validateValueType validates a value against its expected SQL type
func validateValueType(value interface{}, sqlType string) error {
	strValue := fmt.Sprintf("%v", value)
	trimmedValue := strings.TrimSpace(strValue)
	sqlType = strings.ToLower(sqlType)

	// Skip validation for NULL strings
	if strings.EqualFold(trimmedValue, "null") || trimmedValue == "" {
		return nil
	}

	// For date/time fields, skip validation for invalid date values that will become NULL
	if isDateTimeType(sqlType) {
		if trimmedValue == "0" || trimmedValue == "0000-00-00" || trimmedValue == "0000-00-00 00:00:00" {
			return nil
		}
	}

	if isNumericType(sqlType) {
		if _, err := strconv.ParseFloat(strValue, 64); err != nil {
			return fmt.Errorf("expected numeric value, got '%s'", strValue)
		}

		// Check length constraints for integers
		if strings.Contains(sqlType, "int") {
			val, _ := strconv.ParseInt(strValue, 10, 64)
			if strings.Contains(sqlType, "tinyint") && (val < -128 || val > 127) {
				return fmt.Errorf("value %d out of range for TINYINT", val)
			}
			if strings.Contains(sqlType, "smallint") && (val < -32768 || val > 32767) {
				return fmt.Errorf("value %d out of range for SMALLINT", val)
			}
		}
	}

	// Check VARCHAR/CHAR length
	if strings.Contains(sqlType, "varchar") || strings.Contains(sqlType, "char") {
		re := regexp.MustCompile(`\((\d+)\)`)
		matches := re.FindStringSubmatch(sqlType)
		if len(matches) > 1 {
			maxLen, _ := strconv.Atoi(matches[1])
			if len(strValue) > maxLen {
				return fmt.Errorf("value length %d exceeds maximum %d for %s", len(strValue), maxLen, sqlType)
			}
		}
	}

	return nil
}
