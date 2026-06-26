package logistics

import (
	"errors"
	"fmt"
	"math/rand"
	"time"

	"gorm.io/gorm"

	"jd_logistics/internal/pricing"
	"jd_logistics/internal/shipments"
)

// Service handles logistics order business logic.
type Service struct{ db *gorm.DB }

// NewService constructs a logistics Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

// ListOrders returns paginated logistics orders for a customer.
func (s *Service) ListOrders(customerID uint, status string, page, limit int) ([]shipments.LogisticsOrder, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var orders []shipments.LogisticsOrder
	var total int64
	q := s.db.Model(&shipments.LogisticsOrder{}).Where("customer_id = ?", customerID)
	if status != "" {
		q = q.Where("status = ?", status)
	}
	q.Count(&total)
	err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&orders).Error
	return orders, total, err
}

// GetOrder returns one logistics order, scoped to the customer.
func (s *Service) GetOrder(id, customerID uint) (*shipments.LogisticsOrder, error) {
	var order shipments.LogisticsOrder
	if err := s.db.Where("id = ? AND customer_id = ?", id, customerID).First(&order).Error; err != nil {
		return nil, errors.New("order not found")
	}
	return &order, nil
}

// CreateOrder books a new logistics order and auto-prices it.
func (s *Service) CreateOrder(customerID uint, req CreateOrderRequest) (*shipments.LogisticsOrder, error) {
	fromCID := uint(0)
	toCID := uint(0)
	gcID := uint(0)
	if req.FromCountryID != nil {
		fromCID = *req.FromCountryID
	}
	if req.ToCountryID != nil {
		toCID = *req.ToCountryID
	}
	if req.GoodsCategoryID != nil {
		gcID = *req.GoodsCategoryID
	}

	mode := req.TransportMode
	if mode == "" {
		mode = "sea"
	}

	order := shipments.LogisticsOrder{
		TrackingID:      fmt.Sprintf("JDL-%d-%04d", time.Now().Year(), rand.Intn(10000)),
		CustomerID:      customerID,
		FromPortID:      req.FromPortID,
		ToPortID:        req.ToPortID,
		FromCountryID:   req.FromCountryID,
		ToCountryID:     req.ToCountryID,
		TransportModeID: req.TransportModeID,
		GoodsCategoryID: req.GoodsCategoryID,
		GoodsName:       req.GoodsName,
		ContainerType:   req.ContainerType,
		WeightKg:        req.WeightKg,
		VolumeCbm:       req.VolumeCbm,
		DeclaredValue:   req.DeclaredValue,
		HSNCodeValue:    req.HSNCode,
		IsInsured:       req.IsInsured,
		Notes:           req.Notes,
		ETD:             req.ETD,
		Status:          "draft",
	}

	priceSvc := pricing.NewService(s.db)
	if est, err := priceSvc.Estimate(pricing.EstimateRequest{
		FromCountryID:   fromCID,
		ToCountryID:     toCID,
		WeightKg:        req.WeightKg,
		VolumeCbm:       req.VolumeCbm,
		TransportMode:   mode,
		GoodsCategoryID: gcID,
		DeclaredValue:   req.DeclaredValue,
		IsInsured:       req.IsInsured,
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

// Estimate returns a price quote without persisting anything.
func (s *Service) Estimate(req EstimateRequest) (*pricing.EstimateResponse, error) {
	mode := req.TransportMode
	if mode == "" {
		mode = "sea"
	}
	priceSvc := pricing.NewService(s.db)
	return priceSvc.Estimate(pricing.EstimateRequest{
		FromCityID:      req.FromPortID,
		ToCityID:        req.ToPortID,
		FromCountryID:   req.FromCountryID,
		ToCountryID:     req.ToCountryID,
		WeightKg:        req.WeightKg,
		VolumeCbm:       req.VolumeCbm,
		TransportMode:   mode,
		GoodsCategoryID: req.GoodsCategoryID,
		DeclaredValue:   req.DeclaredValue,
		IsInsured:       req.IsInsured,
	})
}
