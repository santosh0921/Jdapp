package pricing

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up the /pricing group (protected by JWT in main.go).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/pricing")
	{
		g.POST("/estimate", h.Estimate)
		g.POST("/multi-modal", h.MultiModal)
	}
}
