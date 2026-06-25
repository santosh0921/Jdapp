package warehouse

import "jd_logistics/utils"

type WarehouseProfile struct {
	utils.Model
	UserID   uint   `gorm:"uniqueIndex;not null" json:"user_id"`
	Name     string `json:"name"`
	Address  string `json:"address"`
	City     string `json:"city"`
	Capacity int    `json:"capacity"`
	IsActive bool   `gorm:"default:true" json:"is_active"`
}

type ScanRequest struct {
	TrackingID string `json:"tracking_id" binding:"required"`
	Action     string `json:"action" binding:"required,oneof=inbound outbound dispatch"`
	Note       string `json:"note"`
}

type DispatchRequest struct {
	ShipmentID uint   `json:"shipment_id" binding:"required"`
	Note       string `json:"note"`
}
