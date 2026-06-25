package admin

import (
	"gorm.io/gorm"

	"jd_logistics/internal/auth"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/shipments"
	"jd_logistics/internal/warehouse"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetDashboard() (*DashboardStats, error) {
	stats := &DashboardStats{}

	s.db.Model(&auth.User{}).Count(&stats.TotalUsers)
	s.db.Model(&auth.User{}).Where("role = ?", "driver").Count(&stats.TotalDrivers)
	s.db.Model(&shipments.Shipment{}).Count(&stats.TotalShipments)
	s.db.Model(&shipments.Shipment{}).Where("status = ?", "pending").Count(&stats.PendingOrders)
	s.db.Model(&driver.DriverProfile{}).Where("is_online = ?", true).Count(&stats.OnlineDrivers)
	s.db.Model(&driver.DriverProfile{}).Where("is_online = ?", true).Count(&stats.ActiveDrivers)
	s.db.Model(&warehouse.WarehouseProfile{}).Where("is_active = ?", true).Count(&stats.WarehousesOnline)

	var rev struct{ Total float64 }
	s.db.Raw(`SELECT COALESCE(SUM(amount), 0) AS total FROM jd_logistics.shipments WHERE deleted_at IS NULL`).Scan(&rev)
	stats.Revenue = rev.Total

	s.db.Model(&shipments.Shipment{}).
		Where("DATE(created_at) = CURRENT_DATE").
		Count(&stats.TodayShipments)
	s.db.Raw(`SELECT COALESCE(SUM(amount), 0) AS total FROM jd_logistics.shipments WHERE DATE(created_at) = CURRENT_DATE AND deleted_at IS NULL`).Scan(&rev)
	stats.TodayRevenue = rev.Total

	return stats, nil
}

func (s *Service) ListUsers(role string, page, limit int) ([]map[string]interface{}, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var users []auth.User
	q := s.db.Model(&auth.User{})
	if role != "" {
		q = q.Where("role = ?", role)
	}
	if err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&users).Error; err != nil {
		return nil, err
	}
	result := make([]map[string]interface{}, len(users))
	for i, u := range users {
		result[i] = map[string]interface{}{
			"id":         u.ID,
			"phone":      u.Phone,
			"name":       u.Name,
			"email":      u.Email,
			"role":       u.Role,
			"is_active":  u.IsActive,
			"last_login": u.LastLogin,
			"created_at": u.CreatedAt,
		}
	}
	return result, nil
}

func (s *Service) GetPlatformStats() (map[string]interface{}, error) {
	stats, err := s.GetDashboard()
	if err != nil {
		return nil, err
	}
	return map[string]interface{}{
		"revenue_today":     stats.TodayRevenue,
		"revenue_total":     stats.Revenue,
		"shipments_today":   stats.TodayShipments,
		"shipments_total":   stats.TotalShipments,
		"active_drivers":    stats.ActiveDrivers,
		"pending_shipments": stats.PendingOrders,
		"total_users":       stats.TotalUsers,
		"warehouses_online": stats.WarehousesOnline,
	}, nil
}
