package driver

import (
	"errors"
	"time"

	"gorm.io/gorm"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetOrCreate(userID uint) (*DriverProfile, error) {
	var p DriverProfile
	s.db.Where("user_id = ?", userID).FirstOrCreate(&p, DriverProfile{UserID: userID})
	return &p, nil
}

func (s *Service) ToggleOnline(userID uint, online bool) (*DriverProfile, error) {
	var p DriverProfile
	if err := s.db.Where("user_id = ?", userID).First(&p).Error; err != nil {
		return nil, errors.New("driver profile not found")
	}
	s.db.Model(&p).Update("is_online", online)
	p.IsOnline = online
	return &p, nil
}

func (s *Service) UpdateLocation(userID uint, lat, lng float64) error {
	return s.db.Model(&DriverProfile{}).Where("user_id = ?", userID).
		Updates(map[string]interface{}{"current_lat": lat, "current_lng": lng}).Error
}

func (s *Service) GetAvailableOrders() ([]map[string]interface{}, error) {
	type row struct {
		ID              uint   `json:"id"`
		TrackingID      string `json:"tracking_id"`
		PickupAddress   string `json:"pickup_address"`
		DeliveryAddress string `json:"delivery_address"`
		PackageType     string `json:"package_type"`
		Amount          float64 `json:"amount"`
	}
	var rows []row
	s.db.Table("shipments").
		Select("id, tracking_id, pickup_address, delivery_address, package_type, amount").
		Where("status = ? AND driver_id IS NULL AND deleted_at IS NULL", "pending").
		Limit(20).
		Scan(&rows)

	result := make([]map[string]interface{}, len(rows))
	for i, r := range rows {
		result[i] = map[string]interface{}{
			"id":               r.ID,
			"tracking_id":      r.TrackingID,
			"pickup_address":   r.PickupAddress,
			"delivery_address": r.DeliveryAddress,
			"package_type":     r.PackageType,
			"amount":           r.Amount,
		}
	}
	return result, nil
}

func (s *Service) AcceptOrder(driverUserID uint, shipmentID uint) error {
	var p DriverProfile
	if err := s.db.Where("user_id = ?", driverUserID).First(&p).Error; err != nil {
		return errors.New("driver profile not found")
	}
	return s.db.Table("shipments").
		Where("id = ? AND driver_id IS NULL", shipmentID).
		Updates(map[string]interface{}{"driver_id": p.ID, "status": "assigned"}).Error
}

func (s *Service) RejectOrder(shipmentID uint) error {
	// Record rejection — currently just a no-op placeholder
	return nil
}

func (s *Service) GetEarnings(userID uint) ([]EarningRecord, error) {
	var p DriverProfile
	if err := s.db.Where("user_id = ?", userID).First(&p).Error; err != nil {
		return []EarningRecord{}, nil
	}
	var records []EarningRecord
	s.db.Where("driver_id = ?", p.ID).Order("created_at desc").Limit(50).Find(&records)
	return records, nil
}

func (s *Service) AddEarning(driverProfileID, shipmentID uint, amount float64) error {
	e := EarningRecord{
		DriverID:   driverProfileID,
		ShipmentID: shipmentID,
		Amount:     amount,
		Date:       time.Now().Format("2006-01-02"),
	}
	return s.db.Create(&e).Error
}
