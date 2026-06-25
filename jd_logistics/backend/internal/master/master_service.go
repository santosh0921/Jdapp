package master

import "gorm.io/gorm"

type Service struct{ db *gorm.DB }

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

func (s *Service) GetHSNCodes() ([]HSNCode, error) {
	var rows []HSNCode
	return rows, s.db.Where("is_active = ?", true).Order("code").Find(&rows).Error
}

func (s *Service) GetPricingRules() ([]PricingRule, error) {
	var rows []PricingRule
	return rows, s.db.Where("is_active = ?", true).Find(&rows).Error
}
