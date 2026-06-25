package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

	"jd_logistics/config"
	"jd_logistics/internal/admin"
	"jd_logistics/internal/auth"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/master"
	"jd_logistics/internal/migrations"
	"jd_logistics/internal/notifications"
	"jd_logistics/internal/payments"
	"jd_logistics/internal/seed"
	"jd_logistics/internal/shipments"
	"jd_logistics/internal/tracking"
	"jd_logistics/internal/users"
	"jd_logistics/internal/warehouse"
	"jd_logistics/middleware"
)

func main() {
	cfg := config.LoadEnv()
	db := config.ConnectDatabase(cfg)
	rdb := config.ConnectRedis(cfg)

	// Idempotent migrations — creates missing tables/columns only, never drops
	if err := migrations.Run(db); err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	// Seed master reference data — safe to run on every startup
	seed.Run(db)

	r := gin.Default()
	r.Use(middleware.CORS())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "schema": "jd_logistics", "db": "crednova_db"})
	})

	api := r.Group("/api/v1")

	// Public routes — no auth required
	auth.RegisterRoutes(api, db, rdb, cfg)
	master.RegisterRoutes(api, db)

	// Protected routes — JWT required
	protected := api.Group("")
	protected.Use(middleware.Auth(cfg.JWTSecret))

	users.RegisterRoutes(protected, db)
	shipments.RegisterRoutes(protected, db)
	tracking.RegisterRoutes(protected, db)
	driver.RegisterRoutes(protected, db)
	warehouse.RegisterRoutes(protected, db)
	payments.RegisterRoutes(protected, db)
	notifications.RegisterRoutes(protected, db)

	// Admin-only routes
	adminGroup := protected.Group("/admin")
	adminGroup.Use(middleware.RequireRole("admin", "superadmin"))
	admin.RegisterRoutes(adminGroup, db)

	log.Printf("Server running on :%s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
