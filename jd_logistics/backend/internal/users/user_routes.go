package users

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/users")
	{
		g.GET("/profile", h.GetProfile)
		g.PUT("/profile", h.UpdateProfile)
	}
}
