package driver

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"jd_logistics/middleware"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/driver")
	g.Use(middleware.RequireRole("driver", "admin"))
	{
		g.GET("/profile", h.GetProfile)
		g.POST("/toggle-online", h.ToggleOnline)
		g.POST("/location", h.UpdateLocation)
		g.GET("/available-orders", h.AvailableOrders)
		g.POST("/orders/:id/accept", h.AcceptOrder)
		g.POST("/orders/:id/reject", h.RejectOrder)
		g.GET("/earnings", h.GetEarnings)
	}
}
