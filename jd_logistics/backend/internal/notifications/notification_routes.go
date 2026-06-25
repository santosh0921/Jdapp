package notifications

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/notifications")
	{
		g.GET("", h.List)
		g.POST("/read-all", h.MarkAllRead)
		g.PATCH("/:id/read", h.MarkRead)
	}
}
