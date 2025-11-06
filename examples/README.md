# Test Files

This directory contains example files to test the DB Importer application.

## SQL Schema Files

### mysql_customers.sql
- **Database Type:** MySQL/MariaDB
- **Tables:** customers, orders, products
- **Use Case:** E-commerce database schema

### postgres_users.sql
- **Database Type:** PostgreSQL
- **Tables:** users, posts, comments
- **Use Case:** Blog/social platform database schema

## Data Files

### customers_data.csv
- **Format:** CSV
- **Columns:** Email, First Name, Last Name, Phone
- **Rows:** 10 sample customer records
- **Target Table:** customers (from mysql_customers.sql)

### products_data.csv
- **Format:** CSV
- **Columns:** Name, Description, Price, Stock
- **Rows:** 10 sample product records
- **Target Table:** products (from mysql_customers.sql)

## How to Test

1. Start the application with Docker:
   ```bash
   docker-compose up
   ```

2. Open your browser to http://localhost:5173

3. **Step 1:** Upload `mysql_customers.sql` or `postgres_users.sql`

4. **Step 2:** Select the target table (e.g., `customers` or `products`)

5. **Step 3:** Upload the corresponding CSV file (e.g., `customers_data.csv`)

6. **Step 4:** Review and adjust the column mapping, then download the generated SQL file

7. The generated SQL file will contain INSERT statements ready to execute in your database
