package driver

import "jd_logistics/utils"

type DriverProfile struct {
	utils.Model
	UserID          uint    `gorm:"uniqueIndex;not null" json:"user_id"`
	IsOnline        bool    `gorm:"default:false" json:"is_online"`
	IsVerified      bool    `gorm:"default:false" json:"is_verified"`
	Rating          float64 `gorm:"default:0" json:"rating"`
	TotalDeliveries int     `gorm:"default:0" json:"total_deliveries"`
	TotalEarnings   float64 `gorm:"default:0" json:"total_earnings"`
	VehicleType     string  `json:"vehicle_type"`
	VehicleNumber   string  `json:"vehicle_number"`
	LicenseNumber   string  `json:"license_number"`
	BankAccount     string  `json:"bank_account"`
	IFSC            string  `json:"ifsc"`
	CurrentLat      float64 `json:"current_lat"`
	CurrentLng      float64 `json:"current_lng"`
}

type EarningRecord struct {
	utils.Model
	DriverID   uint    `gorm:"not null;index" json:"driver_id"`
	ShipmentID uint    `json:"shipment_id"`
	Amount     float64 `json:"amount"`
	Date       string  `json:"date"`
}

type UpdateLocationRequest struct {
	Latitude  float64 `json:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" binding:"required"`
}

type ToggleOnlineRequest struct {
	IsOnline bool `json:"is_online"`
}
