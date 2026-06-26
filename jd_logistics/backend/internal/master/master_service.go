package master

import "gorm.io/gorm"

// Service provides read-only access to all master/reference data.
type Service struct{ db *gorm.DB }

// NewService creates a master Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetRoles() ([]Role, error) {
	var rows []Role
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetGoodsCategories() ([]GoodsCategory, error) {
	var rows []GoodsCategory
	return rows, s.db.Where("is_active = ?", true).Order("name").Find(&rows).Error
}

func (s *Service) GetVehicleTypes() ([]VehicleType, error) {
	var rows []VehicleType
	return rows, s.db.Where("is_active = ?", true).Order("capacity_kg").Find(&rows).Error
}

func (s *Service) GetCountries() ([]Country, error) {
	var rows []Country
	return rows, s.db.Where("is_active = ?", true).Order("name").Find(&rows).Error
}

func (s *Service) GetStates(countryID uint) ([]State, error) {
	var rows []State
	q := s.db.Where("is_active = ?", true)
	if countryID > 0 {
		q = q.Where("country_id = ?", countryID)
	}
	return rows, q.Order("name").Find(&rows).Error
}

func (s *Service) GetCities(countryID uint, state string, isHub *bool) ([]City, error) {
	var rows []City
	q := s.db.Where("is_active = ?", true)
	if countryID > 0 {
		q = q.Where("country_id = ?", countryID)
	}
	if state != "" {
		q = q.Where("state = ?", state)
	}
	if isHub != nil {
		q = q.Where("is_hub = ?", *isHub)
	}
	return rows, q.Order("name").Find(&rows).Error
}

func (s *Service) GetPorts() ([]Port, error) {
	var rows []Port
	return rows, s.db.Where("is_active = ?", true).Order("name").Find(&rows).Error
}

func (s *Service) GetTransportModes() ([]TransportMode, error) {
	var rows []TransportMode
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetShipmentStatuses() ([]ShipmentStatus, error) {
	var rows []ShipmentStatus
	return rows, s.db.Order("sequence").Find(&rows).Error
}

func (s *Service) GetPaymentMethods() ([]PaymentMethod, error) {
	var rows []PaymentMethod
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetWarehouseTypes() ([]WarehouseType, error) {
	var rows []WarehouseType
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetGSTRates() ([]GSTRate, error) {
	var rows []GSTRate
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetHSNCodes(search string, limit int) ([]HSNCode, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	var rows []HSNCode
	q := s.db.Where("is_active = ?", true)
	if search != "" {
		like := "%" + search + "%"
		q = q.Where("code ILIKE ? OR description ILIKE ?", like, like)
	}
	return rows, q.Order("code").Limit(limit).Find(&rows).Error
}

func (s *Service) GetPricingRules() ([]PricingRule, error) {
	var rows []PricingRule
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}

func (s *Service) GetFuelRates() ([]FuelRate, error) {
	var rows []FuelRate
	return rows, s.db.Where("is_active = ?", true).Order("fuel_type, effective_on DESC").Find(&rows).Error
}

func (s *Service) GetInsuranceRates() ([]InsuranceRate, error) {
	var rows []InsuranceRate
	return rows, s.db.Where("is_active = ?", true).Order("category_name").Find(&rows).Error
}
