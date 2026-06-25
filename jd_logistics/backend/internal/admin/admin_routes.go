package admin

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	{
		rg.GET("/dashboard", h.Dashboard)
		rg.GET("/users", h.ListUsers)
		rg.GET("/stats", h.PlatformStats)
	}
}
