package generator

import (
	"strings"
	"testing"
)

func TestGenerateInsertSQL_BasicInsert(t *testing.T) {
	tableName := "users"
	mapping := map[string]string{
		"col_0": "id",
		"col_1": "name",
		"col_2": "email",
	}
	fields := []FieldInfo{
		{Name: "id", Type: "INT", Nullable: false},
		{Name: "name", Type: "VARCHAR(100)", Nullable: false},
		{Name: "email", Type: "VARCHAR(255)", Nullable: true},
	}
	rows := [][]interface{}{
		{1, "Alice", "alice@example.com"},
		{2, "Bob", "bob@example.com"},
	}

	sql := GenerateInsertSQL(tableName, mapping, rows, fields)

	// Verify structure
	if !strings.Contains(sql, "INSERT INTO `users`") {
		t.Errorf("Expected 'INSERT INTO `users`', got: %s", sql)
	}

	if !strings.Contains(sql, "(`id`, `name`, `email`)") {
		t.Errorf("Expected column list with backticks, got: %s", sql)
	}

	if !strings.Contains(sql, "(1, 'Alice', 'alice@example.com')") {
		t.Errorf("Expected first row values, got: %s", sql)
	}

	if !strings.Contains(sql, "(2, 'Bob', 'bob@example.com')") {
		t.Errorf("Expected second row values, got: %s", sql)
	}

	// Should end with semicolon
	if !strings.HasSuffix(strings.TrimSpace(sql), ";") {
		t.Errorf("Expected SQL to end with semicolon")
	}
}

func TestGenerateInsertSQL_EmptyRows(t *testing.T) {
	tableName := "users"
	mapping := map[string]string{"col_0": "id"}
	fields := []FieldInfo{{Name: "id", Type: "INT", Nullable: false}}
	rows := [][]interface{}{}

	sql := GenerateInsertSQL(tableName, mapping, rows, fields)

	if sql != "" {
		t.Errorf("Expected empty string for empty rows, got: %s", sql)
	}
}

func TestGenerateInsertSQL_EmptyMapping(t *testing.T) {
	tableName := "users"
	mapping := map[string]string{}
	fields := []FieldInfo{{Name: "id", Type: "INT", Nullable: false}}
	rows := [][]interface{}{{1}}

	sql := GenerateInsertSQL(tableName, mapping, rows, fields)

	if sql != "" {
		t.Errorf("Expected empty string for empty mapping, got: %s", sql)
	}
}

func TestFormatValueByType_NumericTypes(t *testing.T) {
	tests := []struct {
		value    interface{}
		sqlType  string
		expected string
	}{
		{42, "INT", "42"},
		{"123", "BIGINT", "123"},
		{3.14, "FLOAT", "3.14"},
		{"99.99", "DECIMAL(10,2)", "99.99"},
		{nil, "INT", "NULL"},
		{"", "INT", "NULL"},
		{"NULL", "INT", "NULL"},
		{"not a number", "INT", "NULL"},
	}

	for _, tt := range tests {
		result := formatValueByType(tt.value, tt.sqlType)
		if result != tt.expected {
			t.Errorf("formatValueByType(%v, %s) = %s, want %s", tt.value, tt.sqlType, result, tt.expected)
		}
	}
}

func TestFormatValueByType_BooleanTypes(t *testing.T) {
	tests := []struct {
		value    interface{}
		sqlType  string
		expected string
	}{
		{true, "BOOLEAN", "TRUE"},
		{"true", "BOOLEAN", "TRUE"},
		{"1", "BOOLEAN", "TRUE"},
		{"yes", "BOOLEAN", "TRUE"},
		{"y", "BOOLEAN", "TRUE"},
		{"t", "BOOLEAN", "TRUE"},
		{false, "BOOLEAN", "FALSE"},
		{"false", "BOOLEAN", "FALSE"},
		{"0", "BOOLEAN", "FALSE"},
		{"no", "BOOLEAN", "FALSE"},
		{"n", "BOOLEAN", "FALSE"},
		{"f", "BOOLEAN", "FALSE"},
		{"invalid", "BOOLEAN", "NULL"},
		{nil, "BOOLEAN", "NULL"},
	}

	for _, tt := range tests {
		result := formatValueByType(tt.value, tt.sqlType)
		if result != tt.expected {
			t.Errorf("formatValueByType(%v, %s) = %s, want %s", tt.value, tt.sqlType, result, tt.expected)
		}
	}
}

func TestFormatValueByType_DateTimeTypes(t *testing.T) {
	tests := []struct {
		value    interface{}
		sqlType  string
		expected string
	}{
		{"2024-01-15", "DATE", "'2024-01-15'"},
		{"2024-01-15 14:30:00", "DATETIME", "'2024-01-15 14:30:00'"},
		{"2024-01-15 14:30:00", "TIMESTAMP", "'2024-01-15 14:30:00'"},
		{"0", "DATE", "NULL"},
		{"0000-00-00", "DATE", "NULL"},
		{"0000-00-00 00:00:00", "DATETIME", "NULL"},
		{"", "DATE", "NULL"},
		{nil, "DATE", "NULL"},
		{"invalid-date", "DATE", "NULL"},
	}

	for _, tt := range tests {
		result := formatValueByType(tt.value, tt.sqlType)
		if result != tt.expected {
			t.Errorf("formatValueByType(%v, %s) = %s, want %s", tt.value, tt.sqlType, result, tt.expected)
		}
	}
}

func TestFormatValueByType_StringTypes(t *testing.T) {
	tests := []struct {
		value    interface{}
		sqlType  string
		expected string
	}{
		{"hello", "VARCHAR(100)", "'hello'"},
		{"world", "TEXT", "'world'"},
		{"O'Brien", "VARCHAR(50)", "'O''Brien'"},        // Single quote escaped
		{"Line 1\nLine 2", "TEXT", "'Line 1\\nLine 2'"}, // Newline escaped
		{"Tab\there", "TEXT", "'Tab\\there'"},           // Tab escaped
		{"back\\slash", "TEXT", "'back\\\\slash'"},      // Backslash escaped
		{nil, "VARCHAR(100)", "NULL"},
		{"", "VARCHAR(100)", "NULL"},
		{"NULL", "VARCHAR(100)", "NULL"},
		{"  ", "VARCHAR(100)", "NULL"}, // Whitespace trimmed to empty
	}

	for _, tt := range tests {
		result := formatValueByType(tt.value, tt.sqlType)
		if result != tt.expected {
			t.Errorf("formatValueByType(%v, %s) = %s, want %s", tt.value, tt.sqlType, result, tt.expected)
		}
	}
}

func TestEscapeIdentifier(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"users", "`users`"},
		{"user_id", "`user_id`"},
		{"`already_escaped`", "`already_escaped`"},
		{"table-name", "`table-name`"},
	}

	for _, tt := range tests {
		result := escapeIdentifier(tt.input)
		if result != tt.expected {
			t.Errorf("escapeIdentifier(%s) = %s, want %s", tt.input, result, tt.expected)
		}
	}
}

func TestIsNumericType(t *testing.T) {
	numericTypes := []string{"INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT", "DECIMAL(10,2)", "FLOAT", "DOUBLE", "NUMERIC", "SERIAL"}
	for _, sqlType := range numericTypes {
		if !isNumericType(sqlType) {
			t.Errorf("isNumericType(%s) should be true", sqlType)
		}
	}

	nonNumericTypes := []string{"VARCHAR(100)", "TEXT", "DATE", "BOOLEAN", "JSON"}
	for _, sqlType := range nonNumericTypes {
		if isNumericType(sqlType) {
			t.Errorf("isNumericType(%s) should be false", sqlType)
		}
	}
}

func TestIsBooleanType(t *testing.T) {
	booleanTypes := []string{"BOOLEAN", "BOOL", "BIT", "BIT(1)"}
	for _, sqlType := range booleanTypes {
		if !isBooleanType(sqlType) {
			t.Errorf("isBooleanType(%s) should be true", sqlType)
		}
	}

	nonBooleanTypes := []string{"INT", "VARCHAR(100)", "DATE"}
	for _, sqlType := range nonBooleanTypes {
		if isBooleanType(sqlType) {
			t.Errorf("isBooleanType(%s) should be false", sqlType)
		}
	}
}

func TestIsDateTimeType(t *testing.T) {
	dateTimeTypes := []string{"DATE", "DATETIME", "TIMESTAMP", "TIME", "YEAR"}
	for _, sqlType := range dateTimeTypes {
		if !isDateTimeType(sqlType) {
			t.Errorf("isDateTimeType(%s) should be true", sqlType)
		}
	}

	nonDateTimeTypes := []string{"INT", "VARCHAR(100)", "BOOLEAN", "TEXT"}
	for _, sqlType := range nonDateTimeTypes {
		if isDateTimeType(sqlType) {
			t.Errorf("isDateTimeType(%s) should be false", sqlType)
		}
	}
}

func TestValidateFieldTypes_NullableConstraints(t *testing.T) {
	fields := []FieldInfo{
		{Name: "id", Type: "INT", Nullable: false},
		{Name: "name", Type: "VARCHAR(100)", Nullable: false},
		{Name: "email", Type: "VARCHAR(255)", Nullable: true},
	}

	mapping := map[string]string{
		"col_0": "id",
		"col_1": "name",
		"col_2": "email",
	}

	// Valid data
	rows := [][]interface{}{
		{1, "Alice", "alice@example.com"},
		{2, "Bob", nil}, // email is nullable
	}

	errors := ValidateFieldTypes(rows, fields, mapping)
	if len(errors) != 0 {
		t.Errorf("Expected no errors for valid data, got: %v", errors)
	}

	// Invalid data - NOT NULL violation
	invalidRows := [][]interface{}{
		{1, nil, "alice@example.com"}, // name is NOT NULL
	}

	errors = ValidateFieldTypes(invalidRows, fields, mapping)
	if len(errors) != 1 {
		t.Errorf("Expected 1 error for NOT NULL violation, got %d: %v", len(errors), errors)
	}

	if !strings.Contains(errors[0], "cannot be NULL") {
		t.Errorf("Expected 'cannot be NULL' error, got: %s", errors[0])
	}
}

func TestValidateFieldTypes_TypeValidation(t *testing.T) {
	fields := []FieldInfo{
		{Name: "age", Type: "INT", Nullable: false},
		{Name: "name", Type: "VARCHAR(10)", Nullable: false},
	}

	mapping := map[string]string{
		"col_0": "age",
		"col_1": "name",
	}

	// Invalid numeric value
	rows := [][]interface{}{
		{"not a number", "Alice"},
	}

	errors := ValidateFieldTypes(rows, fields, mapping)
	if len(errors) == 0 {
		t.Error("Expected error for invalid numeric value")
	}

	if !strings.Contains(errors[0], "expected numeric value") {
		t.Errorf("Expected 'expected numeric value' error, got: %s", errors[0])
	}

	// String too long
	rows = [][]interface{}{
		{25, "This name is way too long for VARCHAR(10)"},
	}

	errors = ValidateFieldTypes(rows, fields, mapping)
	if len(errors) == 0 {
		t.Error("Expected error for string too long")
	}

	if !strings.Contains(errors[0], "exceeds maximum") {
		t.Errorf("Expected 'exceeds maximum' error, got: %s", errors[0])
	}
}

func TestValidateFieldTypes_IntegerRanges(t *testing.T) {
	fields := []FieldInfo{
		{Name: "tiny", Type: "TINYINT", Nullable: false},
		{Name: "small", Type: "SMALLINT", Nullable: false},
	}

	mapping := map[string]string{
		"col_0": "tiny",
		"col_1": "small",
	}

	// TINYINT out of range (-128 to 127)
	rows := [][]interface{}{
		{200, 100},
	}

	errors := ValidateFieldTypes(rows, fields, mapping)
	if len(errors) == 0 {
		t.Error("Expected error for TINYINT out of range")
	}

	if !strings.Contains(errors[0], "out of range for TINYINT") {
		t.Errorf("Expected 'out of range for TINYINT' error, got: %s", errors[0])
	}

	// SMALLINT out of range (-32768 to 32767)
	rows = [][]interface{}{
		{100, 40000},
	}

	errors = ValidateFieldTypes(rows, fields, mapping)
	if len(errors) == 0 {
		t.Error("Expected error for SMALLINT out of range")
	}

	if !strings.Contains(errors[0], "out of range for SMALLINT") {
		t.Errorf("Expected 'out of range for SMALLINT' error, got: %s", errors[0])
	}
}

func TestFormatStringValue_SpecialCharacters(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"simple", "'simple'"},
		{"O'Reilly", "'O''Reilly'"},                 // Single quote
		{"Line1\nLine2", "'Line1\\nLine2'"},         // Newline
		{"Tab\tSeparated", "'Tab\\tSeparated'"},     // Tab
		{"Carriage\rReturn", "'Carriage\\rReturn'"}, // Carriage return
		{"Back\\slash", "'Back\\\\slash'"},          // Backslash
		{"Mix'd\nText", "'Mix''d\\nText'"},          // Multiple escapes
	}

	for _, tt := range tests {
		result := formatStringValue(tt.input)
		if result != tt.expected {
			t.Errorf("formatStringValue(%q) = %s, want %s", tt.input, result, tt.expected)
		}
	}
}

func TestGenerateInsertSQL_RealWorldScenario(t *testing.T) {
	tableName := "products"
	mapping := map[string]string{
		"col_0": "id",
		"col_1": "name",
		"col_2": "price",
		"col_3": "stock",
		"col_4": "created_at",
	}
	fields := []FieldInfo{
		{Name: "id", Type: "INT", Nullable: false},
		{Name: "name", Type: "VARCHAR(200)", Nullable: false},
		{Name: "price", Type: "DECIMAL(10,2)", Nullable: false},
		{Name: "stock", Type: "INT", Nullable: true},
		{Name: "created_at", Type: "DATETIME", Nullable: true},
	}
	rows := [][]interface{}{
		{1, "Laptop", "999.99", 10, "2024-01-15 10:00:00"},
		{2, "Mouse", "29.99", nil, "2024-01-16 11:30:00"},
		{3, "Keyboard", "79.99", 0, nil},
	}

	sql := GenerateInsertSQL(tableName, mapping, rows, fields)

	// Verify table name
	if !strings.Contains(sql, "INSERT INTO `products`") {
		t.Error("Missing table name")
	}

	// Verify columns
	if !strings.Contains(sql, "(`id`, `name`, `price`, `stock`, `created_at`)") {
		t.Error("Missing or incorrect column list")
	}

	// Verify row 1 - all values present
	if !strings.Contains(sql, "(1, 'Laptop', 999.99, 10, '2024-01-15 10:00:00')") {
		t.Error("Row 1 formatting incorrect")
	}

	// Verify row 2 - NULL stock
	if !strings.Contains(sql, "(2, 'Mouse', 29.99, NULL, '2024-01-16 11:30:00')") {
		t.Error("Row 2 NULL handling incorrect")
	}

	// Verify row 3 - NULL created_at, 0 stock
	if !strings.Contains(sql, "(3, 'Keyboard', 79.99, 0, NULL)") {
		t.Error("Row 3 formatting incorrect")
	}
}
