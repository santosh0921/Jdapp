package config

import (
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func ConnectDatabase(cfg *Config) *gorm.DB {
	db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Create the jd_logistics schema — idempotent, safe on every start
	if err := db.Exec("CREATE SCHEMA IF NOT EXISTS jd_logistics").Error; err != nil {
		log.Fatalf("Failed to create jd_logistics schema: %v", err)
	}
	log.Println("Schema jd_logistics ready")
	log.Println("Database connected to crednova_db")
	return db
}
