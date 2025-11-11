package parser

import (
	"testing"
)

func TestParsePostgreSQL_SimpleTable(t *testing.T) {
	sql := `CREATE TABLE users (
		id SERIAL NOT NULL,
		username VARCHAR(50) NOT NULL,
		email VARCHAR(100),
		created_at TIMESTAMP
	);`

	tables := ParsePostgreSQL(sql)

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
	if table.Fields[0].Type != "SERIAL" {
		t.Errorf("Field 0: expected type 'SERIAL', got '%s'", table.Fields[0].Type)
	}
	if table.Fields[0].Nullable != false {
		t.Errorf("Field 0: expected nullable=false, got %v", table.Fields[0].Nullable)
	}

	// Test field: email (nullable by default)
	if table.Fields[2].Nullable != true {
		t.Errorf("Field 2 (email): expected nullable=true, got %v", table.Fields[2].Nullable)
	}
}

func TestParsePostgreSQL_WithSchema(t *testing.T) {
	sql := `CREATE TABLE public.products (
		id INTEGER NOT NULL,
		name TEXT
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	// Should extract just the table name, not the schema
	if tables[0].Name != "products" {
		t.Errorf("Expected table name 'products' (schema stripped), got '%s'", tables[0].Name)
	}

	if len(tables[0].Fields) != 2 {
		t.Fatalf("Expected 2 fields, got %d", len(tables[0].Fields))
	}
}

func TestParsePostgreSQL_IfNotExists(t *testing.T) {
	sql := `CREATE TABLE IF NOT EXISTS categories (
		id BIGSERIAL,
		name VARCHAR(100) NOT NULL
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	if tables[0].Name != "categories" {
		t.Errorf("Expected table name 'categories', got '%s'", tables[0].Name)
	}

	if len(tables[0].Fields) != 2 {
		t.Fatalf("Expected 2 fields, got %d", len(tables[0].Fields))
	}
}

func TestParsePostgreSQL_PostgreSQLTypes(t *testing.T) {
	sql := `CREATE TABLE data_types (
		col_serial SERIAL,
		col_bigserial BIGSERIAL,
		col_varchar VARCHAR(255),
		col_text TEXT,
		col_integer INTEGER,
		col_bigint BIGINT,
		col_numeric NUMERIC(10,2),
		col_real REAL,
		col_double DOUBLE PRECISION,
		col_boolean BOOLEAN,
		col_date DATE,
		col_timestamp TIMESTAMP,
		col_timestamptz TIMESTAMPTZ,
		col_json JSON,
		col_jsonb JSONB,
		col_uuid UUID,
		col_bytea BYTEA
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	expectedCount := 17
	if len(tables[0].Fields) != expectedCount {
		t.Fatalf("Expected %d fields, got %d", expectedCount, len(tables[0].Fields))
	}

	// Test some specific PostgreSQL types
	expectedTypes := map[int]string{
		0:  "SERIAL",
		1:  "BIGSERIAL",
		8:  "DOUBLE", // Note: "DOUBLE PRECISION" becomes "DOUBLE" (first word)
		13: "JSON",
		14: "JSONB",
		15: "UUID",
	}

	for idx, expectedType := range expectedTypes {
		if tables[0].Fields[idx].Type != expectedType {
			t.Errorf("Field %d: expected type '%s', got '%s'", idx, expectedType, tables[0].Fields[idx].Type)
		}
	}
}

func TestParsePostgreSQL_SkipConstraints(t *testing.T) {
	sql := `CREATE TABLE orders (
		id SERIAL NOT NULL,
		user_id INTEGER,
		total NUMERIC(10,2),
		PRIMARY KEY (id),
		FOREIGN KEY (user_id) REFERENCES users(id),
		CONSTRAINT check_total CHECK (total >= 0),
		UNIQUE (user_id, total)
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	// Should only have 3 fields, constraints should be skipped
	if len(tables[0].Fields) != 3 {
		t.Fatalf("Expected 3 fields (constraints skipped), got %d: %+v", len(tables[0].Fields), tables[0].Fields)
	}

	expectedFields := []string{"id", "user_id", "total"}
	for i, expected := range expectedFields {
		if tables[0].Fields[i].Name != expected {
			t.Errorf("Field %d: expected name '%s', got '%s'", i, expected, tables[0].Fields[i].Name)
		}
	}
}

func TestParsePostgreSQL_MultipleTables(t *testing.T) {
	sql := `
		CREATE TABLE users (id SERIAL, name TEXT);
		CREATE TABLE products (id SERIAL, title TEXT);
		CREATE TABLE orders (id SERIAL, user_id INTEGER);
	`

	tables := ParsePostgreSQL(sql)

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

func TestParsePostgreSQL_EmptyInput(t *testing.T) {
	tables := ParsePostgreSQL("")

	if len(tables) != 0 {
		t.Errorf("Expected 0 tables for empty input, got %d", len(tables))
	}
}

func TestParsePostgreSQL_NoTables(t *testing.T) {
	sql := `
		INSERT INTO users VALUES (1, 'test');
		SELECT * FROM users;
		DROP TABLE IF EXISTS old_table;
	`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 0 {
		t.Errorf("Expected 0 tables (no CREATE TABLE), got %d", len(tables))
	}
}

func TestParsePostgreSQL_RealWorldExample(t *testing.T) {
	// Real-world PostgreSQL export example
	sql := `
		-- PostgreSQL database dump
		CREATE TABLE IF NOT EXISTS public.users (
		  id integer NOT NULL,
		  username character varying(50) NOT NULL,
		  email character varying(100),
		  password character varying(255) NOT NULL,
		  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
		  updated_at timestamp without time zone,
		  is_active boolean DEFAULT true,
		  PRIMARY KEY (id),
		  UNIQUE (username)
		);
	`

	tables := ParsePostgreSQL(sql)

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

	// email should be nullable (no NOT NULL constraint)
	emailField := table.Fields[2]
	if emailField.Name != "email" || emailField.Nullable != true {
		t.Errorf("email field: got {Name:%s, Nullable:%v}, want {Name:email, Nullable:true}", emailField.Name, emailField.Nullable)
	}
}

func TestParsePostgreSQL_ArrayTypes(t *testing.T) {
	sql := `CREATE TABLE test_arrays (
		tags TEXT[],
		numbers INTEGER[],
		matrix INTEGER[][]
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	if len(tables[0].Fields) != 3 {
		t.Fatalf("Expected 3 fields, got %d", len(tables[0].Fields))
	}

	// Array types should be captured (at least the base type)
	if tables[0].Fields[0].Name != "tags" {
		t.Errorf("Field 0: expected name 'tags', got '%s'", tables[0].Fields[0].Name)
	}
}

func TestParsePostgreSQL_DefaultValues(t *testing.T) {
	sql := `CREATE TABLE test_defaults (
		id SERIAL,
		status VARCHAR(20) DEFAULT 'active',
		created_at TIMESTAMP DEFAULT NOW(),
		count INTEGER DEFAULT 0 NOT NULL
	);`

	tables := ParsePostgreSQL(sql)

	if len(tables) != 1 {
		t.Fatalf("Expected 1 table, got %d", len(tables))
	}

	if len(tables[0].Fields) != 4 {
		t.Fatalf("Expected 4 fields, got %d", len(tables[0].Fields))
	}

	// count field has NOT NULL despite having DEFAULT
	countField := tables[0].Fields[3]
	if countField.Name != "count" {
		t.Errorf("Expected field name 'count', got '%s'", countField.Name)
	}
	if countField.Nullable != false {
		t.Errorf("count field: expected nullable=false (has NOT NULL), got %v", countField.Nullable)
	}
}
