package driver

import "jd_logistics/utils"

// ── Driver Profile ─────────────────────────────────────────────────────────────

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

func (DriverProfile) TableName() string { return "jd_logistics.driver_profiles" }

// ── Vehicle ────────────────────────────────────────────────────────────────────

type Vehicle struct {
	utils.Model
	VehicleTypeID      *uint   `gorm:"index" json:"vehicle_type_id"`
	RegistrationNumber string  `gorm:"uniqueIndex;not null" json:"registration_number"`
	DriverID           *uint   `gorm:"index" json:"driver_id"`
	Make               string  `json:"make"`
	ModelName          string  `json:"model"`
	Year               int     `json:"year"`
	Color              string  `json:"color"`
	CapacityKg         float64 `json:"capacity_kg"`
	VolumeCbm          float64 `json:"volume_cbm"`
	FuelType           string  `json:"fuel_type"`
	InsuranceExpiry    *string `json:"insurance_expiry"`
	FitnessExpiry      *string `json:"fitness_expiry"`
	LastServiceDate    *string `json:"last_service_date"`
	IsActive           bool    `gorm:"default:true" json:"is_active"`
	CurrentLat         float64 `json:"current_lat"`
	CurrentLng         float64 `json:"current_lng"`
}

func (Vehicle) TableName() string { return "jd_logistics.vehicles" }

// ── Driver Wallet ──────────────────────────────────────────────────────────────

type DriverWallet struct {
	utils.Model
	DriverID       uint    `gorm:"uniqueIndex;not null" json:"driver_id"`
	Balance        float64 `gorm:"default:0" json:"balance"`
	PendingBalance float64 `gorm:"default:0" json:"pending_balance"`
	TotalEarned    float64 `gorm:"default:0" json:"total_earned"`
	TotalWithdrawn float64 `gorm:"default:0" json:"total_withdrawn"`
}

func (DriverWallet) TableName() string { return "jd_logistics.driver_wallet" }

// ── Earning Record ─────────────────────────────────────────────────────────────

type EarningRecord struct {
	utils.Model
	DriverID      uint    `gorm:"not null;index" json:"driver_id"`
	ShipmentID    uint    `gorm:"index" json:"shipment_id"`
	OrderID       *uint   `gorm:"index" json:"order_id"`
	OrderType     string  `gorm:"default:'courier'" json:"order_type"`
	Amount        float64 `json:"amount"`
	CommissionPct float64 `json:"commission_pct"`
	NetAmount     float64 `json:"net_amount"`
	Status        string  `gorm:"default:'pending'" json:"status"`
	Date          string  `json:"date"`
	PaidAt        *string `json:"paid_at"`
}

func (EarningRecord) TableName() string { return "jd_logistics.driver_earnings" }

// ── DTOs ───────────────────────────────────────────────────────────────────────

type UpdateLocationRequest struct {
	Latitude  float64 `json:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" binding:"required"`
}

type ToggleOnlineRequest struct {
	IsOnline bool `json:"is_online"`
}
