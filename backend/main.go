package main

import (
	"db-importer/generator"
	"db-importer/parser"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

// Response structures
type ParseSchemaResponse struct {
	Tables []parser.Table `json:"tables"`
}

type GenerateSQLRequest struct {
	Table   string            `json:"table"`
	Mapping map[string]string `json:"mapping"`
	Rows    [][]interface{}   `json:"rows"`
}

// CORS middleware
func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// Handler for /parse-schema
func parseSchemaHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse multipart form
	err := r.ParseMultipartForm(10 << 20) // 10 MB max
	if err != nil {
		http.Error(w, "Failed to parse form", http.StatusBadRequest)
		return
	}

	file, _, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Failed to get file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Read file content
	content, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, "Failed to read file", http.StatusInternalServerError)
		return
	}

	sqlContent := string(content)

	// Try Vitess parser first (works well for MySQL)
	tables := parser.ParseWithVitess(sqlContent)

	// If no tables found, fallback to regex parsers for PostgreSQL and others
	if len(tables) == 0 {
		// Try PostgreSQL
		tables = parser.ParsePostgreSQL(sqlContent)

		// If still nothing, try MySQL regex parser
		if len(tables) == 0 {
			tables = parser.ParseMySQL(sqlContent)
		}
	}

	// Return response
	response := ParseSchemaResponse{
		Tables: tables,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Handler for /generate-sql
func generateSQLHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse JSON body
	var req GenerateSQLRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Generate SQL
	sql := generator.GenerateInsertSQL(req.Table, req.Mapping, req.Rows)

	// Return plain text SQL
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte(sql))
}

// Health check handler
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"status":"ok"}`))
}

func main() {
	// Register handlers
	http.HandleFunc("/health", enableCORS(healthHandler))
	http.HandleFunc("/parse-schema", enableCORS(parseSchemaHandler))
	http.HandleFunc("/generate-sql", enableCORS(generateSQLHandler))

	// Start server
	port := "8080"
	fmt.Printf("Server starting on port %s...\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
