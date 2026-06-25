package warehouse

import "jd_logistics/utils"

// ── Warehouse Entity ───────────────────────────────────────────────────────────

type Warehouse struct {
	utils.Model
	Name           string  `gorm:"not null" json:"name"`
	Code           string  `gorm:"uniqueIndex;not null" json:"code"`
	TypeID         *uint   `gorm:"index" json:"type_id"`
	Address        string  `json:"address"`
	CityID         *uint   `gorm:"index" json:"city_id"`
	CountryID      *uint   `gorm:"index" json:"country_id"`
	TotalAreaSqft  float64 `json:"total_area_sqft"`
	CapacityUnits  int     `json:"capacity_units"`
	ManagerUserID  *uint   `gorm:"index" json:"manager_user_id"`
	IsActive       bool    `gorm:"default:true" json:"is_active"`
	IsRefrigerated bool    `gorm:"default:false" json:"is_refrigerated"`
	IsBonded       bool    `gorm:"default:false" json:"is_bonded"`
	Phone          string  `json:"phone"`
	Email          string  `json:"email"`
	Latitude       float64 `json:"latitude"`
	Longitude      float64 `json:"longitude"`
}

func (Warehouse) TableName() string { return "jd_logistics.warehouses" }

// ── Warehouse Profile (operator-facing) ───────────────────────────────────────

type WarehouseProfile struct {
	utils.Model
	UserID   uint   `gorm:"uniqueIndex;not null" json:"user_id"`
	Name     string `json:"name"`
	Address  string `json:"address"`
	City     string `json:"city"`
	Capacity int    `json:"capacity"`
	IsActive bool   `gorm:"default:true" json:"is_active"`
}

func (WarehouseProfile) TableName() string { return "jd_logistics.warehouse_profiles" }

// ── DTOs ───────────────────────────────────────────────────────────────────────

type ScanRequest struct {
	TrackingID string `json:"tracking_id" binding:"required"`
	Action     string `json:"action" binding:"required,oneof=inbound outbound dispatch"`
	Note       string `json:"note"`
}

type DispatchRequest struct {
	ShipmentID uint   `json:"shipment_id" binding:"required"`
	Note       string `json:"note"`
}
