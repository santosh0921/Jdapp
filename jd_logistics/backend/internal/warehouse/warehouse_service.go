package warehouse

import (
	"gorm.io/gorm"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetOrCreate(userID uint) (*WarehouseProfile, error) {
	var p WarehouseProfile
	s.db.Where("user_id = ?", userID).FirstOrCreate(&p, WarehouseProfile{UserID: userID})
	return &p, nil
}

func (s *Service) Scan(operatorID uint, req ScanRequest) (map[string]interface{}, error) {
	type shipmentRow struct {
		ID     uint
		Status string
	}
	var sh shipmentRow
	if err := s.db.Table("shipments").Select("id, status").
		Where("tracking_id = ? AND deleted_at IS NULL", req.TrackingID).
		First(&sh).Error; err != nil {
		return nil, err
	}

	newStatus := req.Action
	if req.Action == "inbound" {
		newStatus = "at_warehouse"
	} else if req.Action == "outbound" || req.Action == "dispatch" {
		newStatus = "out_for_delivery"
	}

	s.db.Table("shipments").Where("id = ?", sh.ID).Update("status", newStatus)

	return map[string]interface{}{
		"tracking_id": req.TrackingID,
		"action":      req.Action,
		"new_status":  newStatus,
		"success":     true,
		"message":     req.Action + " recorded for " + req.TrackingID,
	}, nil
}

func (s *Service) GetStats(userID uint) (map[string]interface{}, error) {
	var pending, dispatched, returns int64
	s.db.Table("shipments").Where("status = ? AND deleted_at IS NULL", "at_warehouse").Count(&pending)
	s.db.Table("shipments").Where("status = ? AND deleted_at IS NULL", "out_for_delivery").Count(&dispatched)
	s.db.Table("shipments").Where("status = ? AND deleted_at IS NULL", "return").Count(&returns)
	return map[string]interface{}{
		"pending":    pending,
		"dispatched": dispatched,
		"returns":    returns,
	}, nil
}

func (s *Service) GetInventory() ([]map[string]interface{}, error) {
	return s.listShipmentsByStatus("at_warehouse")
}

func (s *Service) GetInbound() ([]map[string]interface{}, error) {
	return s.listShipmentsByStatus("pending")
}

func (s *Service) GetReturns() ([]map[string]interface{}, error) {
	return s.listShipmentsByStatus("return")
}

func (s *Service) Dispatch(shipmentID uint) error {
	return s.db.Table("shipments").Where("id = ?", shipmentID).
		Update("status", "out_for_delivery").Error
}

func (s *Service) listShipmentsByStatus(status string) ([]map[string]interface{}, error) {
	type row struct {
		ID              uint    `json:"id"`
		TrackingID      string  `json:"tracking_id"`
		Status          string  `json:"status"`
		PickupAddress   string  `json:"pickup_address"`
		DeliveryAddress string  `json:"delivery_address"`
		PackageType     string  `json:"package_type"`
		Weight          float64 `json:"weight"`
		Amount          float64 `json:"amount"`
	}
	var rows []row
	s.db.Table("shipments").
		Select("id, tracking_id, status, pickup_address, delivery_address, package_type, weight, amount").
		Where("status = ? AND deleted_at IS NULL", status).
		Order("created_at desc").Limit(50).Scan(&rows)

	result := make([]map[string]interface{}, len(rows))
	for i, r := range rows {
		result[i] = map[string]interface{}{
			"id":               r.ID,
			"tracking_id":      r.TrackingID,
			"status":           r.Status,
			"pickup_address":   r.PickupAddress,
			"delivery_address": r.DeliveryAddress,
			"package_type":     r.PackageType,
			"weight":           r.Weight,
			"amount":           r.Amount,
		}
	}
	return result, nil
}
