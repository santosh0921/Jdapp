package logistics

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up the /logistics group (JWT-protected in main.go).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/logistics")
	{
		g.GET("/orders", h.ListOrders)
		g.POST("/orders", h.CreateOrder)
		g.GET("/orders/:id", h.GetOrder)
		g.POST("/estimate", h.Estimate)
	}
}
