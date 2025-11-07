#!/bin/bash
set -e

# Create the database if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    SELECT 'CREATE DATABASE dbimporter_dev'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dbimporter_dev')\gexec
EOSQL

echo "Database 'dbimporter_dev' is ready!"
