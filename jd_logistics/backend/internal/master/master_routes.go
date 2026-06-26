package master

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// RegisterRoutes wires up all /master endpoints (public — no JWT required).
func RegisterRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	h := NewHandler(NewService(db))
	m := rg.Group("/master")
	{
		m.GET("/roles",             h.GetRoles)
		m.GET("/goods-categories",  h.GetGoodsCategories)
		m.GET("/vehicle-types",     h.GetVehicleTypes)
		m.GET("/countries",         h.GetCountries)
		m.GET("/states",            h.GetStates)
		m.GET("/cities",            h.GetCities)
		m.GET("/ports",             h.GetPorts)
		m.GET("/transport-modes",   h.GetTransportModes)
		m.GET("/shipment-statuses", h.GetShipmentStatuses)
		m.GET("/payment-methods",   h.GetPaymentMethods)
		m.GET("/warehouse-types",   h.GetWarehouseTypes)
		m.GET("/gst-rates",         h.GetGSTRates)
		m.GET("/hsn-codes",         h.GetHSNCodes)
		m.GET("/pricing-rules",     h.GetPricingRules)
		m.GET("/fuel-rates",        h.GetFuelRates)
		m.GET("/insurance-rates",   h.GetInsuranceRates)
	}
}
