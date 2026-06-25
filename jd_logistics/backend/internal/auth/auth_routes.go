package auth

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	"jd_logistics/config"
	"jd_logistics/middleware"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB, rdb *redis.Client, cfg *config.Config) {
	svc := NewService(db, rdb, cfg)
	h := NewHandler(svc)

	auth := rg.Group("/auth")
	{
		auth.POST("/send-otp", h.SendOTP)
		auth.POST("/verify-otp", h.VerifyOTP)

		protected := auth.Group("")
		protected.Use(middleware.Auth(cfg.JWTSecret))
		{
			protected.POST("/setup-profile", h.SetupProfile)
			protected.POST("/select-role", h.SelectRole)
			protected.GET("/profile", h.GetProfile)
		}
	}
}
