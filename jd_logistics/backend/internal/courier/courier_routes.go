package courier

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up the /courier group (JWT-protected in main.go).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/courier")
	{
		g.GET("/orders", h.ListOrders)
		g.POST("/orders", h.CreateOrder)
		g.GET("/orders/:id", h.GetOrder)
		g.POST("/orders/:id/cancel", h.CancelOrder)
		g.POST("/estimate", h.Estimate)
	}
}
