# SQL Data Importer

A web application for importing data from Excel/CSV files into SQL databases. This tool helps you:
- Parse SQL schema dumps (MySQL/MariaDB and PostgreSQL)
- Upload Excel or CSV data files
- Map columns between your data and database schema
- Generate SQL INSERT statements for safe execution

**No database connection required** - You execute the generated SQL yourself in your own environment.

## Features

- Support for MySQL/MariaDB and PostgreSQL schemas
- Excel (.xlsx, .xls) and CSV file import
- Automatic column mapping suggestions
- Manual mapping adjustment
- Validation for NOT NULL fields
- Clean SQL INSERT statement generation
- No direct database access for security

## Tech Stack

### Backend
- Go (standard library `net/http`)
- SQL schema parsing (regex-based)
- Zero external dependencies

### Frontend
- Vue.js 3
- Vite
- PrimeVue (UI components)
- TailwindCSS
- Pinia (state management)
- SheetJS (Excel parsing)

## Quick Start

### Prerequisites
- Docker
- Docker Compose

### Installation & Running

1. Clone the repository
```bash
git clone <your-repo-url>
cd db-importer
```

2. Start the application
```bash
docker-compose up
```

3. Access the application
- Frontend: http://localhost:5173
- Backend API: http://localhost:8080

## Usage

### Step 1: Upload SQL Schema
Upload your database dump file (.sql) containing CREATE TABLE statements.

### Step 2: Select Target Table
Choose the table where you want to import data.

### Step 3: Upload Data File
Upload an Excel (.xlsx, .xls) or CSV file with your data.

### Step 4: Map Columns
- Review the automatic column mapping suggestions
- Adjust mappings as needed
- Check for validation warnings (e.g., missing NOT NULL fields)
- Click "Generate & Download SQL"

### Step 5: Execute SQL
Run the generated SQL file in your database environment.

## Examples

Test files are provided in the [`examples/`](examples/) directory:

- `mysql_customers.sql` - MySQL schema with customers, orders, products tables
- `postgres_users.sql` - PostgreSQL schema with users, posts, comments tables
- `customers_data.csv` - Sample customer data
- `products_data.csv` - Sample product data

## API Endpoints

### POST /parse-schema
Parses a SQL dump file and returns table structures.

**Request:** Multipart form with SQL file

**Response:**
```json
{
  "tables": [
    {
      "name": "customers",
      "fields": [
        { "name": "id", "type": "int", "nullable": false },
        { "name": "email", "type": "varchar", "nullable": false }
      ]
    }
  ]
}
```

### POST /generate-sql
Generates INSERT statements from mapped data.

**Request:**
```json
{
  "table": "customers",
  "mapping": { "Email": "email", "Name": "first_name" },
  "rows": [
    ["john@test.com", "John"],
    ["sarah@test.com", "Sarah"]
  ]
}
```

**Response:** Plain text SQL
```sql
INSERT INTO customers (email, first_name) VALUES
('john@test.com', 'John'),
('sarah@test.com', 'Sarah');
```

## Development

### Backend Development
```bash
cd backend
go run main.go
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

## Project Structure

```
db-importer/
├── backend/
│   ├── main.go           # HTTP server & API endpoints
│   ├── parser/
│   │   ├── mysql.go      # MySQL schema parser
│   │   └── postgres.go   # PostgreSQL schema parser
│   ├── generator/
│   │   └── insert.go     # SQL INSERT generator
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── pages/        # Vue page components
│   │   ├── store/        # Pinia state management
│   │   ├── router/       # Vue Router config
│   │   └── App.vue
│   ├── package.json
│   └── Dockerfile
├── examples/             # Test files
├── docker-compose.yml
└── README.md
```

## Security

- No database credentials required
- No direct database connections
- User executes SQL in their own environment
- Input sanitization in SQL generation (escapes single quotes)

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
