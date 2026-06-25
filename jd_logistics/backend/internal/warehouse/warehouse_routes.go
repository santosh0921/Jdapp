package warehouse

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"jd_logistics/middleware"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/warehouse")
	g.Use(middleware.RequireRole("warehouse", "admin"))
	{
		g.GET("/profile", h.GetProfile)
		g.GET("/stats", h.GetStats)
		g.POST("/scan", h.Scan)
		g.POST("/dispatch", h.Dispatch)
		g.GET("/inventory", h.GetInventory)
		g.GET("/inbound", h.GetInbound)
		g.GET("/returns", h.GetReturns)
	}
}
