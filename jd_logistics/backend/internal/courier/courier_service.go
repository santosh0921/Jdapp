package courier

import (
	"errors"
	"fmt"
	"math/rand"
	"time"

	"gorm.io/gorm"

	"jd_logistics/internal/pricing"
	"jd_logistics/internal/shipments"
)

// Service handles courier order business logic.
type Service struct{ db *gorm.DB }

// NewService constructs a courier Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

// ListOrders returns paginated courier orders for a customer.
func (s *Service) ListOrders(customerID uint, status string, page, limit int) ([]shipments.CourierOrder, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var orders []shipments.CourierOrder
	var total int64
	q := s.db.Model(&shipments.CourierOrder{}).Where("customer_id = ?", customerID)
	if status != "" {
		q = q.Where("status = ?", status)
	}
	q.Count(&total)
	err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&orders).Error
	return orders, total, err
}

// GetOrder returns one courier order, scoped to the customer.
func (s *Service) GetOrder(id, customerID uint) (*shipments.CourierOrder, error) {
	var order shipments.CourierOrder
	if err := s.db.Where("id = ? AND customer_id = ?", id, customerID).First(&order).Error; err != nil {
		return nil, errors.New("order not found")
	}
	return &order, nil
}

// CreateOrder books a new courier order and auto-prices it.
func (s *Service) CreateOrder(customerID uint, req CreateOrderRequest) (*shipments.CourierOrder, error) {
	fromCityID := uint(0)
	toCityID := uint(0)
	gcID := uint(0)
	vtID := uint(0)
	if req.FromCityID != nil {
		fromCityID = *req.FromCityID
	}
	if req.ToCityID != nil {
		toCityID = *req.ToCityID
	}
	if req.GoodsCategoryID != nil {
		gcID = *req.GoodsCategoryID
	}
	if req.VehicleTypeID != nil {
		vtID = *req.VehicleTypeID
	}

	order := shipments.CourierOrder{
		TrackingID:        newTrackingID("JDC"),
		CustomerID:        customerID,
		FromAddress:       req.FromAddress,
		ToAddress:         req.ToAddress,
		FromCityID:        req.FromCityID,
		ToCityID:          req.ToCityID,
		PackageType:       req.PackageType,
		WeightKg:          req.WeightKg,
		DeclaredValue:     req.DeclaredValue,
		GoodsCategoryID:   req.GoodsCategoryID,
		VehicleTypeID:     req.VehicleTypeID,
		PaymentMethodCode: req.PaymentMethodCode,
		IsFragile:         req.IsFragile,
		IsInsured:         req.IsInsured,
		InsuranceValue:    req.InsuranceValue,
		Notes:             req.Notes,
		Status:            "booked",
	}

	// Auto-price via pricing engine
	priceSvc := pricing.NewService(s.db)
	if est, err := priceSvc.Estimate(pricing.EstimateRequest{
		FromCityID:      fromCityID,
		ToCityID:        toCityID,
		WeightKg:        req.WeightKg,
		TransportMode:   "road",
		GoodsCategoryID: gcID,
		VehicleTypeID:   vtID,
		DeclaredValue:   req.DeclaredValue,
		IsInsured:       req.IsInsured,
		IsFragile:       req.IsFragile,
	}); err == nil {
		order.Amount = est.TotalAmount - est.GSTAmount
		order.GSTAmount = est.GSTAmount
		order.TotalAmount = est.TotalAmount
	}

	if err := s.db.Create(&order).Error; err != nil {
		return nil, err
	}
	return &order, nil
}

// CancelOrder cancels an order that belongs to the customer.
func (s *Service) CancelOrder(id, customerID uint) error {
	var order shipments.CourierOrder
	if err := s.db.Where("id = ? AND customer_id = ?", id, customerID).First(&order).Error; err != nil {
		return errors.New("order not found")
	}
	if order.Status == "delivered" || order.Status == "cancelled" {
		return fmt.Errorf("cannot cancel order with status '%s'", order.Status)
	}
	return s.db.Model(&order).Update("status", "cancelled").Error
}

// Estimate returns a price quote without persisting anything.
func (s *Service) Estimate(req EstimateRequest) (*pricing.EstimateResponse, error) {
	priceSvc := pricing.NewService(s.db)
	return priceSvc.Estimate(pricing.EstimateRequest{
		FromCityID:      req.FromCityID,
		ToCityID:        req.ToCityID,
		WeightKg:        req.WeightKg,
		TransportMode:   "road",
		GoodsCategoryID: req.GoodsCategoryID,
		VehicleTypeID:   req.VehicleTypeID,
		DeclaredValue:   req.DeclaredValue,
		IsInsured:       req.IsInsured,
		IsExpress:       req.IsExpress,
		IsFragile:       req.IsFragile,
	})
}

func newTrackingID(prefix string) string {
	return fmt.Sprintf("%s-%d-%04d", prefix, time.Now().Year(), rand.Intn(10000))
}
