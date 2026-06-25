package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

	"jd_logistics/config"
	"jd_logistics/internal/admin"
	"jd_logistics/internal/auth"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/notifications"
	"jd_logistics/internal/payments"
	"jd_logistics/internal/shipments"
	"jd_logistics/internal/tracking"
	"jd_logistics/internal/users"
	"jd_logistics/internal/warehouse"
	"jd_logistics/middleware"
)

func main() {
	cfg := config.LoadEnv()

	db := config.ConnectDatabase(cfg)

	if err := db.AutoMigrate(
		&auth.User{},
		&auth.OTPRecord{},
		&shipments.Shipment{},
		&tracking.TrackingEvent{},
		&driver.DriverProfile{},
		&driver.EarningRecord{},
		&warehouse.WarehouseProfile{},
		&payments.Transaction{},
		&payments.WalletBalance{},
		&notifications.Notification{},
	); err != nil {
		log.Fatalf("AutoMigrate failed: %v", err)
	}
	log.Println("Database migrated")

	rdb := config.ConnectRedis(cfg)

	r := gin.Default()
	r.Use(middleware.CORS())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	api := r.Group("/api/v1")

	auth.RegisterRoutes(api, db, rdb, cfg)

	protected := api.Group("")
	protected.Use(middleware.Auth(cfg.JWTSecret))

	users.RegisterRoutes(protected, db)
	shipments.RegisterRoutes(protected, db)
	tracking.RegisterRoutes(protected, db)
	driver.RegisterRoutes(protected, db)
	warehouse.RegisterRoutes(protected, db)
	payments.RegisterRoutes(protected, db)
	notifications.RegisterRoutes(protected, db)

	adminGroup := protected.Group("/admin")
	adminGroup.Use(middleware.RequireRole("admin"))
	admin.RegisterRoutes(adminGroup, db)

	log.Printf("Server running on :%s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
