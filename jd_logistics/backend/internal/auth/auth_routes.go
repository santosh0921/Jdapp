package auth

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	"jd_logistics/config"
	"jd_logistics/middleware"
)

// RegisterRoutes wires up all /auth endpoints.
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB, rdb *redis.Client, cfg *config.Config) {
	svc := NewService(db, rdb, cfg)
	h := NewHandler(svc)

	a := rg.Group("/auth")
	{
		// Public — no JWT
		a.POST("/send-otp", h.SendOTP)
		a.POST("/verify-otp", h.VerifyOTP)
		a.POST("/refresh-token", h.RefreshToken)
		a.POST("/logout", h.Logout)

		// JWT-protected
		protected := a.Group("")
		protected.Use(middleware.Auth(cfg.JWTSecret))
		{
			protected.POST("/setup-profile", h.SetupProfile)
			protected.POST("/select-role", h.SelectRole)
			protected.GET("/profile", h.GetProfile)
		}
	}
}
