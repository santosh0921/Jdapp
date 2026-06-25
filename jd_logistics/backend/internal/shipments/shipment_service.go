package shipments

import (
	"crypto/rand"
	"fmt"
	"math/big"

	"gorm.io/gorm"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func generateTrackingID() string {
	n, _ := rand.Int(rand.Reader, big.NewInt(10000000000))
	return fmt.Sprintf("JD%010d", n.Int64())
}

func (s *Service) Create(customerID uint, req CreateShipmentRequest) (*Shipment, error) {
	sh := Shipment{
		TrackingID:      generateTrackingID(),
		CustomerID:      customerID,
		PickupAddress:   req.PickupAddress,
		DeliveryAddress: req.DeliveryAddress,
		PackageType:     req.PackageType,
		Weight:          req.Weight,
		Notes:           req.Notes,
		Amount:          s.calculateAmount(req.Weight, req.PackageType),
	}
	if err := s.db.Create(&sh).Error; err != nil {
		return nil, err
	}
	return &sh, nil
}

func (s *Service) ListForCustomer(customerID uint) ([]Shipment, error) {
	var list []Shipment
	s.db.Where("customer_id = ?", customerID).Order("created_at desc").Find(&list)
	return list, nil
}

func (s *Service) GetByID(id uint) (*Shipment, error) {
	var sh Shipment
	if err := s.db.First(&sh, id).Error; err != nil {
		return nil, err
	}
	return &sh, nil
}

func (s *Service) GetByTrackingID(trackingID string) (*Shipment, error) {
	var sh Shipment
	if err := s.db.Where("tracking_id = ?", trackingID).First(&sh).Error; err != nil {
		return nil, err
	}
	return &sh, nil
}

func (s *Service) UpdateStatus(id uint, status string) (*Shipment, error) {
	var sh Shipment
	if err := s.db.First(&sh, id).Error; err != nil {
		return nil, err
	}
	s.db.Model(&sh).Update("status", status)
	return &sh, nil
}

func (s *Service) Cancel(id uint, customerID uint) (*Shipment, error) {
	var sh Shipment
	if err := s.db.Where("id = ? AND customer_id = ?", id, customerID).First(&sh).Error; err != nil {
		return nil, err
	}
	s.db.Model(&sh).Update("status", "cancelled")
	sh.Status = "cancelled"
	return &sh, nil
}

func (s *Service) Quote(req QuoteRequest) map[string]interface{} {
	amount := s.calculateAmount(req.Weight, req.PackageType)
	return map[string]interface{}{
		"estimated_amount": amount,
		"currency":         "INR",
		"pickup_address":   req.PickupAddress,
		"delivery_address": req.DeliveryAddress,
		"package_type":     req.PackageType,
		"weight":           req.Weight,
		"estimated_days":   2,
	}
}

func (s *Service) calculateAmount(weight float64, pkgType string) float64 {
	base := 50.0
	if weight > 0 {
		base += weight * 10
	}
	if pkgType == "fragile" {
		base += 20
	}
	return base
}

func (s *Service) AssignDriver(shipmentID, driverID uint) error {
	return s.db.Model(&Shipment{}).Where("id = ?", shipmentID).
		Updates(map[string]interface{}{"driver_id": driverID, "status": "assigned"}).Error
}
