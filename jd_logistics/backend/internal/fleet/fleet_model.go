package fleet

import "jd_logistics/utils"

// VehicleMaintenance records maintenance/service events.
type VehicleMaintenance struct {
	utils.Model
	VehicleID   uint    `gorm:"not null;index" json:"vehicle_id"`
	Type        string  `gorm:"not null" json:"type"` // service|repair|inspection|tyre
	Description string  `json:"description"`
	Cost        float64 `json:"cost"`
	OdometerKm  float64 `json:"odometer_km"`
	PerformedBy string  `json:"performed_by"`
	PerformedAt string  `gorm:"not null" json:"performed_at"`
	NextDueAt   string  `json:"next_due_at"`
	Notes       string  `json:"notes"`
	Status      string  `gorm:"default:'completed'" json:"status"`
}

func (VehicleMaintenance) TableName() string { return "jd_logistics.vehicle_maintenance" }

// VehicleDocument stores RC, insurance, fitness, PUC, permit docs.
type VehicleDocument struct {
	utils.Model
	VehicleID  uint    `gorm:"not null;index" json:"vehicle_id"`
	Type       string  `gorm:"not null" json:"type"` // rc|insurance|fitness|puc|permit
	FileURL    string  `json:"file_url"`
	ExpiryDate *string `json:"expiry_date"`
	IsVerified bool    `gorm:"default:false" json:"is_verified"`
	Notes      string  `json:"notes"`
}

func (VehicleDocument) TableName() string { return "jd_logistics.vehicle_documents" }

// ── DTOs ─────────────────────────────────────────────────────────────────────

type CreateVehicleRequest struct {
	VehicleTypeID      *uint   `json:"vehicle_type_id"`
	RegistrationNumber string  `json:"registration_number" binding:"required"`
	DriverID           *uint   `json:"driver_id"`
	Make               string  `json:"make"`
	ModelName          string  `json:"model"`
	Year               int     `json:"year"`
	Color              string  `json:"color"`
	CapacityKg         float64 `json:"capacity_kg"`
	VolumeCbm          float64 `json:"volume_cbm"`
	FuelType           string  `json:"fuel_type"`
	InsuranceExpiry    *string `json:"insurance_expiry"`
	FitnessExpiry      *string `json:"fitness_expiry"`
}

type UpdateVehicleRequest struct {
	DriverID        *uint   `json:"driver_id"`
	IsActive        *bool   `json:"is_active"`
	InsuranceExpiry *string `json:"insurance_expiry"`
	FitnessExpiry   *string `json:"fitness_expiry"`
	LastServiceDate *string `json:"last_service_date"`
	CurrentLat      *float64 `json:"current_lat"`
	CurrentLng      *float64 `json:"current_lng"`
}

type CreateMaintenanceRequest struct {
	VehicleID   uint    `json:"vehicle_id" binding:"required"`
	Type        string  `json:"type" binding:"required"`
	Description string  `json:"description"`
	Cost        float64 `json:"cost"`
	OdometerKm  float64 `json:"odometer_km"`
	PerformedBy string  `json:"performed_by"`
	PerformedAt string  `json:"performed_at" binding:"required"`
	NextDueAt   string  `json:"next_due_at"`
	Notes       string  `json:"notes"`
}
