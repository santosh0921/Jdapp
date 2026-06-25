package shipments

import "jd_logistics/utils"

type Shipment struct {
	utils.Model
	TrackingID      string  `gorm:"uniqueIndex;not null" json:"tracking_id"`
	CustomerID      uint    `gorm:"not null;index" json:"customer_id"`
	DriverID        *uint   `json:"driver_id"`
	WarehouseID     *uint   `json:"warehouse_id"`
	Status          string  `gorm:"default:pending" json:"status"`
	PickupAddress   string  `json:"pickup_address"`
	DeliveryAddress string  `json:"delivery_address"`
	PackageType     string  `json:"package_type"`
	Weight          float64 `json:"weight"`
	Amount          float64 `json:"amount"`
	Notes           string  `json:"notes"`
}

type CreateShipmentRequest struct {
	PickupAddress   string  `json:"pickup_address" binding:"required"`
	DeliveryAddress string  `json:"delivery_address" binding:"required"`
	PackageType     string  `json:"package_type" binding:"required"`
	Weight          float64 `json:"weight"`
	Notes           string  `json:"notes"`
}

type QuoteRequest struct {
	PickupAddress   string  `json:"pickup_address" binding:"required"`
	DeliveryAddress string  `json:"delivery_address" binding:"required"`
	PackageType     string  `json:"package_type"`
	Weight          float64 `json:"weight"`
}
