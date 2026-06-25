package shipments

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/shipments")
	{
		g.POST("", h.Create)
		g.GET("", h.List)
		g.POST("/quote", h.Quote)
		g.GET("/:id", h.Get)
		g.POST("/:id/cancel", h.Cancel)
	}
}
