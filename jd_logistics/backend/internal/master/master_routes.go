package master

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	m := rg.Group("/master")
	{
		m.GET("/roles",             h.GetRoles)
		m.GET("/goods-categories",  h.GetGoodsCategories)
		m.GET("/vehicle-types",     h.GetVehicleTypes)
		m.GET("/countries",         h.GetCountries)
		m.GET("/ports",             h.GetPorts)
		m.GET("/transport-modes",   h.GetTransportModes)
		m.GET("/shipment-statuses", h.GetShipmentStatuses)
		m.GET("/payment-methods",   h.GetPaymentMethods)
		m.GET("/warehouse-types",   h.GetWarehouseTypes)
		m.GET("/gst-rates",         h.GetGSTRates)
		m.GET("/hsn-codes",         h.GetHSNCodes)
		m.GET("/pricing-rules",     h.GetPricingRules)
	}
}
