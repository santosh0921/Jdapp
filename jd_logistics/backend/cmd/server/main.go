package main

import (
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"jd_logistics/config"
	"jd_logistics/internal/admin"
	"jd_logistics/internal/auth"
	"jd_logistics/internal/courier"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/fleet"
	"jd_logistics/internal/logistics"
	"jd_logistics/internal/master"
	"jd_logistics/internal/migrations"
	"jd_logistics/internal/notifications"
	"jd_logistics/internal/payments"
	"jd_logistics/internal/pricing"
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

	// Global rate limit: 300 requests per minute per IP
	r.Use(middleware.RateLimit(300, time.Minute))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "ok",
			"schema": "jd_logistics",
			"db":     "crednova_db",
		})
	})

	api := r.Group("/api/v1")

	// ── Public routes — no JWT required ──────────────────────────────────────
	auth.RegisterRoutes(api, db, rdb, cfg)
	master.RegisterRoutes(api, db)

	// ── Protected routes — JWT required ──────────────────────────────────────
	protected := api.Group("")
	protected.Use(middleware.Auth(cfg.JWTSecret))

	users.RegisterRoutes(protected, db)
	shipments.RegisterRoutes(protected, db)
	tracking.RegisterRoutes(protected, db)
	driver.RegisterRoutes(protected, db)
	warehouse.RegisterRoutes(protected, db)
	payments.RegisterRoutes(protected, db)
	notifications.RegisterRoutes(protected, db)

	// Enterprise modules
	courier.RegisterRoutes(protected, db)
	logistics.RegisterRoutes(protected, db)
	pricing.RegisterRoutes(protected, db)

	// ── Admin-only routes — JWT + admin/superadmin role ───────────────────────
	adminGroup := protected.Group("/admin")
	adminGroup.Use(middleware.RequireRole("admin", "superadmin"))
	admin.RegisterRoutes(adminGroup, db)
	fleet.RegisterRoutes(adminGroup, db)

	log.Printf("JD Logistics backend running on :%s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
