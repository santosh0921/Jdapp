package fleet

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up the /fleet group (admin-only in main.go).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/fleet")
	{
		g.GET("/summary", h.GetSummary)
		g.GET("/vehicles", h.ListVehicles)
		g.POST("/vehicles", h.CreateVehicle)
		g.GET("/vehicles/:id", h.GetVehicle)
		g.PUT("/vehicles/:id", h.UpdateVehicle)
		g.GET("/maintenance", h.ListMaintenance)
		g.POST("/maintenance", h.CreateMaintenance)
	}
}
