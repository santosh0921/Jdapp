package tracking

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/tracking")
	{
		g.GET("/:id", h.GetEvents) // accepts integer shipment ID or string tracking ID
		g.POST("/event", h.AddEvent)
	}
}
