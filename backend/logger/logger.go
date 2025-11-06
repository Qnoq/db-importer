package logger

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"
)

// Level represents log level
type Level string

const (
	DEBUG Level = "DEBUG"
	INFO  Level = "INFO"
	WARN  Level = "WARN"
	ERROR Level = "ERROR"
)

// Logger handles structured logging
type Logger struct {
	debug bool
}

// LogEntry represents a structured log entry
type LogEntry struct {
	Timestamp string                 `json:"timestamp"`
	Level     Level                  `json:"level"`
	Message   string                 `json:"message"`
	Data      map[string]interface{} `json:"data,omitempty"`
}

var defaultLogger *Logger

// Init initializes the logger
func Init(debug bool) {
	defaultLogger = &Logger{
		debug: debug,
	}
}

// Debug logs a debug message
func Debug(message string, data ...map[string]interface{}) {
	if defaultLogger != nil && defaultLogger.debug {
		defaultLogger.log(DEBUG, message, mergeData(data...))
	}
}

// Info logs an info message
func Info(message string, data ...map[string]interface{}) {
	if defaultLogger != nil {
		defaultLogger.log(INFO, message, mergeData(data...))
	}
}

// Warn logs a warning message
func Warn(message string, data ...map[string]interface{}) {
	if defaultLogger != nil {
		defaultLogger.log(WARN, message, mergeData(data...))
	}
}

// Error logs an error message
func Error(message string, err error, data ...map[string]interface{}) {
	if defaultLogger != nil {
		logData := mergeData(data...)
		if err != nil {
			logData["error"] = err.Error()
		}
		defaultLogger.log(ERROR, message, logData)
	}
}

// log writes a log entry
func (l *Logger) log(level Level, message string, data map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Level:     level,
		Message:   message,
		Data:      data,
	}

	jsonBytes, err := json.Marshal(entry)
	if err != nil {
		// Fallback to simple logging
		log.Printf("[%s] %s - %v\n", level, message, data)
		return
	}

	// Write to stdout for containerized environments
	fmt.Fprintln(os.Stdout, string(jsonBytes))
}

// mergeData merges multiple data maps
func mergeData(data ...map[string]interface{}) map[string]interface{} {
	result := make(map[string]interface{})
	for _, d := range data {
		for k, v := range d {
			result[k] = v
		}
	}
	return result
}
