package parser

import (
	"reflect"
	"testing"
)

func TestParseMySQL_SimpleTable(t *testing.T) {
	sql := `CREATE TABLE users (
		id INT NOT NULL,
		name VARCHAR(255) NOT NULL,
		email VARCHAR(255),
		created_at DATETIME
	);`

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	table := tables[0]
	if table.Name != "users" {
		t.Errorf("Expected table name 'users', got '%s'", table.Name)
	}

	if len(table.Fields) != 4 {
		t.Fatalf("Expected 4 fields, got %d", len(table.Fields))
	}

	// Test field: id
	if table.Fields[0].Name != "id" {
		t.Errorf("Field 0: expected name 'id', got '%s'", table.Fields[0].Name)
	}
	if table.Fields[0].Type != "INT" {
		t.Errorf("Field 0: expected type 'INT', got '%s'", table.Fields[0].Type)
	}
	if table.Fields[0].Nullable != false {
		t.Errorf("Field 0: expected nullable=false, got %v", table.Fields[0].Nullable)
	}

	// Test field: name
	if table.Fields[1].Name != "name" {
		t.Errorf("Field 1: expected name 'name', got '%s'", table.Fields[1].Name)
	}
	if table.Fields[1].Type != "VARCHAR(255)" {
		t.Errorf("Field 1: expected type 'VARCHAR(255)', got '%s'", table.Fields[1].Type)
	}
	if table.Fields[1].Nullable != false {
		t.Errorf("Field 1: expected nullable=false, got %v", table.Fields[1].Nullable)
	}

	// Test field: email (should be nullable by default)
	if table.Fields[2].Name != "email" {
		t.Errorf("Field 2: expected name 'email', got '%s'", table.Fields[2].Name)
	}
	if table.Fields[2].Nullable != true {
		t.Errorf("Field 2: expected nullable=true (no NOT NULL constraint), got %v", table.Fields[2].Nullable)
	}

	// Test field: created_at
	if table.Fields[3].Name != "created_at" {
		t.Errorf("Field 3: expected name 'created_at', got '%s'", table.Fields[3].Name)
	}
	if table.Fields[3].Type != "DATETIME" {
		t.Errorf("Field 3: expected type 'DATETIME', got '%s'", table.Fields[3].Type)
	}
}

func TestParseMySQL_WithBackticks(t *testing.T) {
	sql := "CREATE TABLE `products` (`id` INT NOT NULL, `name` VARCHAR(100), PRIMARY KEY (`id`));"

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	table := tables[0]
	if table.Name != "products" {
		t.Errorf("Expected table name 'products' (backticks removed), got '%s'", table.Name)
	}

	if len(table.Fields) != 2 {
		t.Fatalf("Expected 2 fields (PRIMARY KEY should be skipped), got %d", len(table.Fields))
	}

	if table.Fields[0].Name != "id" {
		t.Errorf("Expected field name 'id' (backticks removed), got '%s'", table.Fields[0].Name)
	}
}

func TestParseMySQL_SkipConstraints(t *testing.T) {
	sql := `CREATE TABLE orders (
		id INT NOT NULL,
		user_id INT,
		total DECIMAL(10,2),
		PRIMARY KEY (id),
		KEY idx_user (user_id),
		FOREIGN KEY (user_id) REFERENCES users(id),
		UNIQUE KEY uk_order (id, user_id),
		INDEX idx_total (total)
	);`

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	table := tables[0]

	// Should only have 3 fields, all constraints should be skipped
	if len(table.Fields) != 3 {
		t.Fatalf("Expected 3 fields (constraints should be skipped), got %d fields: %+v", len(table.Fields), table.Fields)
	}

	expectedFields := []string{"id", "user_id", "total"}
	for i, expected := range expectedFields {
		if table.Fields[i].Name != expected {
			t.Errorf("Field %d: expected name '%s', got '%s'", i, expected, table.Fields[i].Name)
		}
	}
}

func TestParseMySQL_MultipleTables(t *testing.T) {
	sql := `
		CREATE TABLE users (id INT, name VARCHAR(100));
		CREATE TABLE products (id INT, title VARCHAR(200));
		CREATE TABLE orders (id INT, user_id INT);
	`

	tables := ParseMySQL(sql)

	if len(tables) != 3 {
		t.Fatalf("Expected 3 tables, got %d", len(tables))
	}

	expectedNames := []string{"users", "products", "orders"}
	for i, expected := range expectedNames {
		if tables[i].Name != expected {
			t.Errorf("Table %d: expected name '%s', got '%s'", i, expected, tables[i].Name)
		}
	}
}

func TestParseMySQL_IfNotExists(t *testing.T) {
	sql := "CREATE TABLE IF NOT EXISTS categories (id INT, name VARCHAR(50));"

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	if tables[0].Name != "categories" {
		t.Errorf("Expected table name 'categories', got '%s'", tables[0].Name)
	}
}

func TestParseMySQL_VariousTypes(t *testing.T) {
	sql := `CREATE TABLE data_types (
		col_int INT,
		col_bigint BIGINT,
		col_varchar VARCHAR(255),
		col_text TEXT,
		col_decimal DECIMAL(10,2),
		col_float FLOAT,
		col_date DATE,
		col_datetime DATETIME,
		col_timestamp TIMESTAMP,
		col_boolean BOOLEAN,
		col_json JSON
	);`

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	expectedTypes := []string{
		"INT",
		"BIGINT",
		"VARCHAR(255)",
		"TEXT",
		"DECIMAL(10,2)",
		"FLOAT",
		"DATE",
		"DATETIME",
		"TIMESTAMP",
		"BOOLEAN",
		"JSON",
	}

	if len(tables[0].Fields) != len(expectedTypes) {
		t.Fatalf("Expected %d fields, got %d", len(expectedTypes), len(tables[0].Fields))
	}

	for i, expectedType := range expectedTypes {
		if tables[0].Fields[i].Type != expectedType {
			t.Errorf("Field %d: expected type '%s', got '%s'", i, expectedType, tables[0].Fields[i].Type)
		}
	}
}

func TestParseMySQL_EmptyInput(t *testing.T) {
	tables := ParseMySQL("")

	if len(tables) != 0 {
		t.Errorf("Expected 0 tables for empty input, got %d", len(tables))
	}
}

func TestParseMySQL_NoTables(t *testing.T) {
	sql := `
		INSERT INTO users VALUES (1, 'test');
		SELECT * FROM users;
		DROP TABLE IF EXISTS old_table;
	`

	tables := ParseMySQL(sql)

	if len(tables) != 0 {
		t.Errorf("Expected 0 tables (no CREATE TABLE), got %d", len(tables))
	}
}

func TestSplitByComma_IgnoresParentheses(t *testing.T) {
	tests := []struct {
		input    string
		expected []string
	}{
		{
			input:    "id INT, name VARCHAR(255)",
			expected: []string{"id INT", " name VARCHAR(255)"},
		},
		{
			input:    "amount DECIMAL(10,2), description TEXT",
			expected: []string{"amount DECIMAL(10,2)", " description TEXT"},
		},
		{
			input:    "status ENUM('active','inactive','pending'), created_at DATETIME",
			expected: []string{"status ENUM('active','inactive','pending')", " created_at DATETIME"},
		},
	}

	for _, tt := range tests {
		result := splitByComma(tt.input)
		if !reflect.DeepEqual(result, tt.expected) {
			t.Errorf("splitByComma(%q) = %v, want %v", tt.input, result, tt.expected)
		}
	}
}

func TestParseFieldLine_ExtractsParts(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		dbType   string
		expected Field
	}{
		{
			name:   "Simple NOT NULL",
			input:  "id INT NOT NULL",
			dbType: "mysql",
			expected: Field{
				Name:     "id",
				Type:     "INT",
				Nullable: false,
			},
		},
		{
			name:   "Nullable by default",
			input:  "email VARCHAR(255)",
			dbType: "mysql",
			expected: Field{
				Name:     "email",
				Type:     "VARCHAR(255)",
				Nullable: true,
			},
		},
		{
			name:   "With backticks",
			input:  "`name` VARCHAR(100) NOT NULL",
			dbType: "mysql",
			expected: Field{
				Name:     "name",
				Type:     "VARCHAR(100)",
				Nullable: false,
			},
		},
		{
			name:   "Trailing comma",
			input:  "age INT,",
			dbType: "mysql",
			expected: Field{
				Name:     "age",
				Type:     "INT",
				Nullable: true,
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := parseFieldLine(tt.input, tt.dbType)
			if result.Name != tt.expected.Name {
				t.Errorf("Name: got '%s', want '%s'", result.Name, tt.expected.Name)
			}
			if result.Type != tt.expected.Type {
				t.Errorf("Type: got '%s', want '%s'", result.Type, tt.expected.Type)
			}
			if result.Nullable != tt.expected.Nullable {
				t.Errorf("Nullable: got %v, want %v", result.Nullable, tt.expected.Nullable)
			}
		})
	}
}

func TestParseMySQL_RealWorldExample(t *testing.T) {
	// Real-world example from phpMyAdmin export
	sql := `
		-- Table structure for table users
		CREATE TABLE IF NOT EXISTS users (
		  id int(11) NOT NULL AUTO_INCREMENT,
		  username varchar(50) NOT NULL,
		  email varchar(100) DEFAULT NULL,
		  password varchar(255) NOT NULL,
		  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		  updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
		  is_active tinyint(1) DEFAULT 1,
		  PRIMARY KEY (id),
		  UNIQUE KEY uk_username (username),
		  KEY idx_email (email)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	`

	tables := ParseMySQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	table := tables[0]
	if table.Name != "users" {
		t.Errorf("Expected table name 'users', got '%s'", table.Name)
	}

	// Should have 7 fields, no constraints
	expectedFieldCount := 7
	if len(table.Fields) != expectedFieldCount {
		t.Fatalf("Expected %d fields, got %d: %+v", expectedFieldCount, len(table.Fields), table.Fields)
	}

	// Verify key fields
	idField := table.Fields[0]
	if idField.Name != "id" || idField.Nullable != false {
		t.Errorf("id field: got {Name:%s, Nullable:%v}, want {Name:id, Nullable:false}", idField.Name, idField.Nullable)
	}

	emailField := table.Fields[2]
	if emailField.Name != "email" || emailField.Nullable != true {
		t.Errorf("email field should be nullable (has DEFAULT NULL)")
	}
}
