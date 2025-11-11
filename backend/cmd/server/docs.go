// Package main DB Importer API
//
// @title           DB Importer API
// @version         1.0
// @description     A secure web application that generates type-safe SQL INSERT statements from Excel/CSV files without requiring direct database connections.
// @description     Upload your SQL schema, map your data, and generate validated SQL statements.
//
// @contact.name    API Support
// @contact.url     https://github.com/Qnoq/db-importer
//
// @license.name    MIT
// @license.url     https://opensource.org/licenses/MIT
//
// @host            localhost:3000
// @BasePath        /
//
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.
//
// @tag.name         Health
// @tag.description  Health check and server status endpoints
//
// @tag.name         Schema
// @tag.description  SQL schema parsing endpoints
//
// @tag.name         SQL
// @tag.description  SQL generation and validation endpoints
//
// @tag.name         Auth
// @tag.description  Authentication and user management
//
// @tag.name         Imports
// @tag.description  Import history and management (requires authentication)
package main
