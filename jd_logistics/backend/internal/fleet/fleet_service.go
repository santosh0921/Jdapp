package fleet

import (
	"gorm.io/gorm"

	"jd_logistics/internal/driver"
)

// Service handles fleet management.
type Service struct{ db *gorm.DB }

// NewService constructs a fleet Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

// ListVehicles returns all vehicles with optional filters.
func (s *Service) ListVehicles(isActive *bool, page, limit int) ([]driver.Vehicle, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var rows []driver.Vehicle
	var total int64
	q := s.db.Model(&driver.Vehicle{})
	if isActive != nil {
		q = q.Where("is_active = ?", *isActive)
	}
	q.Count(&total)
	err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&rows).Error
	return rows, total, err
}

// GetVehicle returns one vehicle by ID.
func (s *Service) GetVehicle(id uint) (*driver.Vehicle, error) {
	var v driver.Vehicle
	if err := s.db.First(&v, id).Error; err != nil {
		return nil, err
	}
	return &v, nil
}

// CreateVehicle creates a new fleet vehicle.
func (s *Service) CreateVehicle(req CreateVehicleRequest) (*driver.Vehicle, error) {
	v := driver.Vehicle{
		VehicleTypeID:      req.VehicleTypeID,
		RegistrationNumber: req.RegistrationNumber,
		DriverID:           req.DriverID,
		Make:               req.Make,
		ModelName:          req.ModelName,
		Year:               req.Year,
		Color:              req.Color,
		CapacityKg:         req.CapacityKg,
		VolumeCbm:          req.VolumeCbm,
		FuelType:           req.FuelType,
		InsuranceExpiry:    req.InsuranceExpiry,
		FitnessExpiry:      req.FitnessExpiry,
		IsActive:           true,
	}
	if err := s.db.Create(&v).Error; err != nil {
		return nil, err
	}
	return &v, nil
}

// UpdateVehicle updates mutable fields on a vehicle.
func (s *Service) UpdateVehicle(id uint, req UpdateVehicleRequest) (*driver.Vehicle, error) {
	var v driver.Vehicle
	if err := s.db.First(&v, id).Error; err != nil {
		return nil, err
	}
	updates := map[string]interface{}{}
	if req.DriverID != nil {
		updates["driver_id"] = req.DriverID
	}
	if req.IsActive != nil {
		updates["is_active"] = *req.IsActive
	}
	if req.InsuranceExpiry != nil {
		updates["insurance_expiry"] = req.InsuranceExpiry
	}
	if req.FitnessExpiry != nil {
		updates["fitness_expiry"] = req.FitnessExpiry
	}
	if req.LastServiceDate != nil {
		updates["last_service_date"] = req.LastServiceDate
	}
	if req.CurrentLat != nil {
		updates["current_lat"] = *req.CurrentLat
	}
	if req.CurrentLng != nil {
		updates["current_lng"] = *req.CurrentLng
	}
	if len(updates) > 0 {
		s.db.Model(&v).Updates(updates)
	}
	return &v, nil
}

// ListMaintenance returns maintenance records, optionally filtered by vehicle.
func (s *Service) ListMaintenance(vehicleID uint, page, limit int) ([]VehicleMaintenance, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var rows []VehicleMaintenance
	var total int64
	q := s.db.Model(&VehicleMaintenance{})
	if vehicleID > 0 {
		q = q.Where("vehicle_id = ?", vehicleID)
	}
	q.Count(&total)
	err := q.Order("performed_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&rows).Error
	return rows, total, err
}

// CreateMaintenance logs a maintenance event.
func (s *Service) CreateMaintenance(req CreateMaintenanceRequest) (*VehicleMaintenance, error) {
	m := VehicleMaintenance{
		VehicleID:   req.VehicleID,
		Type:        req.Type,
		Description: req.Description,
		Cost:        req.Cost,
		OdometerKm:  req.OdometerKm,
		PerformedBy: req.PerformedBy,
		PerformedAt: req.PerformedAt,
		NextDueAt:   req.NextDueAt,
		Notes:       req.Notes,
		Status:      "completed",
	}
	if err := s.db.Create(&m).Error; err != nil {
		return nil, err
	}
	return &m, nil
}

// GetFleetSummary returns aggregate fleet statistics.
func (s *Service) GetFleetSummary() (map[string]interface{}, error) {
	var total, active, online int64
	s.db.Model(&driver.Vehicle{}).Count(&total)
	s.db.Model(&driver.Vehicle{}).Where("is_active = ?", true).Count(&active)
	s.db.Table("jd_logistics.driver_profiles").Where("is_online = ?", true).Count(&online)

	var maintenanceDue int64
	s.db.Model(&VehicleMaintenance{}).
		Where("next_due_at IS NOT NULL AND next_due_at != '' AND next_due_at <= CURRENT_DATE + INTERVAL '7 days'").
		Count(&maintenanceDue)

	return map[string]interface{}{
		"total_vehicles":    total,
		"active_vehicles":   active,
		"online_drivers":    online,
		"maintenance_due":   maintenanceDue,
	}, nil
}
