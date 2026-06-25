package config

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Port        string
	DatabaseURL string
	RedisAddr   string
	RedisPass   string
	JWTSecret   string
	OTPExpiry   int
}

func LoadEnv() *Config {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, reading from environment")
	}
	otpExpiry, _ := strconv.Atoi(getEnv("OTP_EXPIRY_SECONDS", "300"))
	return &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: buildDatabaseURL(),
		RedisAddr:   getEnv("REDIS_ADDR", "localhost:6379"),
		RedisPass:   getEnv("REDIS_PASS", ""),
		JWTSecret:   getEnv("JWT_SECRET", "change_me_in_production"),
		OTPExpiry:   otpExpiry,
	}
}

// buildDatabaseURL prefers DATABASE_URL; falls back to individual DB_* vars.
func buildDatabaseURL() string {
	if url := os.Getenv("DATABASE_URL"); url != "" {
		return url
	}
	host    := getEnv("DB_HOST",     "localhost")
	port    := getEnv("DB_PORT",     "5432")
	user    := getEnv("DB_USER",     "postgres")
	pass    := getEnv("DB_PASSWORD", "postgres")
	name    := getEnv("DB_NAME",     "crednova_db")
	sslMode := getEnv("DB_SSLMODE",  "require")
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s TimeZone=Asia/Kolkata",
		host, port, user, pass, name, sslMode,
	)
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
