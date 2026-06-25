package payments

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	g := rg.Group("/payments")
	{
		g.GET("/balance", h.GetBalance)
		g.POST("/add-money", h.AddMoney)
		g.GET("/history", h.GetHistory)
		g.POST("/withdraw", h.Withdraw)
	}
}
