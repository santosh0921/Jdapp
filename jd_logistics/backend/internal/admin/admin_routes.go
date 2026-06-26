package admin

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up the admin group (already guarded by admin/superadmin role in main.go).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	{
		rg.GET("/dashboard", h.Dashboard)
		rg.GET("/stats", h.PlatformStats)
		rg.GET("/analytics", h.Analytics)
		rg.GET("/users", h.ListUsers)
		rg.GET("/drivers", h.ListDrivers)
		rg.GET("/shipments", h.ListShipments)
		rg.GET("/audit-logs", h.ListAuditLogs)
	}
}
