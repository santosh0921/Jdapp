package admin

import "gorm.io/gorm"

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

type DashboardStats struct {
	TotalUsers     int64   `json:"total_users"`
	TotalDrivers   int64   `json:"total_drivers"`
	TotalShipments int64   `json:"total_shipments"`
	TotalRevenue   float64 `json:"total_revenue"`
	ActiveDrivers  int64   `json:"active_drivers"`
	PendingOrders  int64   `json:"pending_orders"`
}

func (s *Service) GetDashboard() (*DashboardStats, error) {
	stats := &DashboardStats{}
	// TODO: aggregate counts from respective tables
	return stats, nil
}

func (s *Service) ListUsers(role string, page, limit int) ([]map[string]interface{}, error) {
	// TODO: paginated user list with optional role filter
	return []map[string]interface{}{}, nil
}

func (s *Service) GetPlatformStats() (map[string]interface{}, error) {
	return map[string]interface{}{
		"revenue_today":    0,
		"revenue_month":    0,
		"shipments_today":  0,
		"shipments_month":  0,
		"active_drivers":   0,
		"pending_shipments": 0,
	}, nil
}
