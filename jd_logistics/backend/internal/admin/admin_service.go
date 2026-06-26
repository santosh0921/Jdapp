package admin

import (
	"time"

	"gorm.io/gorm"

	"jd_logistics/internal/auth"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/shipments"
	"jd_logistics/internal/warehouse"
)

// Service provides admin-level data access.
type Service struct{ db *gorm.DB }

// NewService creates an admin Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

// GetDashboard returns the high-level summary.
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

	s.db.Model(&shipments.Shipment{}).Where("DATE(created_at) = CURRENT_DATE").Count(&stats.TodayShipments)
	s.db.Raw(`SELECT COALESCE(SUM(amount), 0) AS total FROM jd_logistics.shipments WHERE DATE(created_at) = CURRENT_DATE AND deleted_at IS NULL`).Scan(&rev)
	stats.TodayRevenue = rev.Total

	return stats, nil
}

// GetPlatformStats returns a flat map of KPIs.
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

// GetAnalytics returns time-series and breakdown data for the analytics screen.
func (s *Service) GetAnalytics(rangeStr string) (*AnalyticsData, error) {
	data := &AnalyticsData{
		DailyShipments: make([]float64, 7),
		DailyRevenue:   make([]float64, 7),
	}

	// MTD shipments
	s.db.Model(&shipments.Shipment{}).
		Where("DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)").
		Count(&data.ShipmentsMTD)

	// MTD revenue (courier + logistics)
	type revRow struct{ Total float64 }
	var r revRow
	s.db.Raw(`SELECT COALESCE(SUM(total_amount), 0) AS total FROM jd_logistics.courier_orders
		WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE) AND deleted_at IS NULL`).Scan(&r)
	data.RevenueMTD = r.Total
	var r2 revRow
	s.db.Raw(`SELECT COALESCE(SUM(total_amount), 0) AS total FROM jd_logistics.logistics_orders
		WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE) AND deleted_at IS NULL`).Scan(&r2)
	data.RevenueMTD += r2.Total

	// Active drivers
	s.db.Model(&driver.DriverProfile{}).Where("is_online = ?", true).Count(&data.ActiveDrivers)

	// On-time delivery rate (delivered out of all terminal)
	var delivered, total int64
	s.db.Model(&shipments.CourierOrder{}).Where("status = 'delivered'").Count(&delivered)
	s.db.Model(&shipments.CourierOrder{}).Where("status IN ('delivered','cancelled','returned')").Count(&total)
	if total > 0 {
		data.OnTimeDelivery = float64(delivered) / float64(total)
	} else {
		data.OnTimeDelivery = 0
	}

	// Daily shipments last 7 days (courier orders)
	type dayRow struct {
		DayOffset int
		Count     float64
	}
	var days []dayRow
	s.db.Raw(`
		SELECT (CURRENT_DATE - DATE(created_at)) AS day_offset, COUNT(*) AS count
		FROM jd_logistics.courier_orders
		WHERE created_at >= CURRENT_DATE - INTERVAL '6 days' AND deleted_at IS NULL
		GROUP BY day_offset ORDER BY day_offset DESC
	`).Scan(&days)
	for _, d := range days {
		if d.DayOffset >= 0 && d.DayOffset < 7 {
			data.DailyShipments[6-d.DayOffset] = d.Count
		}
	}

	// Daily revenue last 7 days
	type revDayRow struct {
		DayOffset int
		Total     float64
	}
	var revDays []revDayRow
	s.db.Raw(`
		SELECT (CURRENT_DATE - DATE(created_at)) AS day_offset, COALESCE(SUM(total_amount), 0) AS total
		FROM jd_logistics.courier_orders
		WHERE created_at >= CURRENT_DATE - INTERVAL '6 days' AND deleted_at IS NULL
		GROUP BY day_offset ORDER BY day_offset DESC
	`).Scan(&revDays)
	for _, d := range revDays {
		if d.DayOffset >= 0 && d.DayOffset < 7 {
			data.DailyRevenue[6-d.DayOffset] = d.Total
		}
	}

	// Mode split — count courier (road) vs logistics modes
	var roadCount, airCount, oceanCount int64
	s.db.Model(&shipments.CourierOrder{}).Count(&roadCount)
	s.db.Model(&shipments.LogisticsOrder{}).Where("transport_mode_id IN (SELECT id FROM jd_logistics.transport_modes WHERE name='air')").Count(&airCount)
	s.db.Model(&shipments.LogisticsOrder{}).Where("transport_mode_id IN (SELECT id FROM jd_logistics.transport_modes WHERE name='ocean')").Count(&oceanCount)
	modeTotal := float64(roadCount + airCount + oceanCount)
	if modeTotal > 0 {
		data.ModeRoad = float64(roadCount) / modeTotal
		data.ModeAir = float64(airCount) / modeTotal
		data.ModeOcean = float64(oceanCount) / modeTotal
	}

	// Top routes placeholder — courier orders by city pairs
	type routeRow struct {
		FromAddr string
		ToAddr   string
		Count    int
	}
	var routes []routeRow
	s.db.Raw(`
		SELECT from_address AS from_addr, to_address AS to_addr, COUNT(*) AS count
		FROM jd_logistics.courier_orders
		WHERE deleted_at IS NULL
		GROUP BY from_address, to_address
		ORDER BY count DESC
		LIMIT 4
	`).Scan(&routes)
	for _, r := range routes {
		from := r.FromAddr
		to := r.ToAddr
		if len(from) > 20 {
			from = from[:20]
		}
		if len(to) > 20 {
			to = to[:20]
		}
		data.TopRoutes = append(data.TopRoutes, RouteStats{From: from, To: to, Count: r.Count})
	}

	return data, nil
}

// ListUsers returns paginated users, optionally filtered by role.
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

// ListDrivers returns paginated driver profiles with user info.
func (s *Service) ListDrivers(isOnline *bool, page, limit int) ([]map[string]interface{}, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var profiles []driver.DriverProfile
	q := s.db.Model(&driver.DriverProfile{})
	if isOnline != nil {
		q = q.Where("is_online = ?", *isOnline)
	}
	if err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&profiles).Error; err != nil {
		return nil, err
	}

	result := make([]map[string]interface{}, 0, len(profiles))
	for _, dp := range profiles {
		var u auth.User
		s.db.First(&u, dp.UserID)
		result = append(result, map[string]interface{}{
			"id":               dp.ID,
			"user_id":          dp.UserID,
			"name":             u.Name,
			"phone":            u.Phone,
			"is_online":        dp.IsOnline,
			"is_verified":      dp.IsVerified,
			"rating":           dp.Rating,
			"total_deliveries": dp.TotalDeliveries,
			"total_earnings":   dp.TotalEarnings,
			"vehicle_type":     dp.VehicleType,
			"vehicle_number":   dp.VehicleNumber,
			"current_lat":      dp.CurrentLat,
			"current_lng":      dp.CurrentLng,
			"created_at":       dp.CreatedAt,
		})
	}
	return result, nil
}

// ListShipmentsAdmin returns all shipments (admin view) with pagination.
func (s *Service) ListShipmentsAdmin(status string, page, limit int) ([]shipments.Shipment, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	var rows []shipments.Shipment
	var total int64
	q := s.db.Model(&shipments.Shipment{})
	if status != "" {
		q = q.Where("status = ?", status)
	}
	q.Count(&total)
	err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&rows).Error
	return rows, total, err
}

// ListAuditLogs returns paginated audit log entries.
func (s *Service) ListAuditLogs(action string, page, limit int) ([]AuditLog, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 50
	}
	var rows []AuditLog
	var total int64
	q := s.db.Model(&AuditLog{})
	if action != "" {
		q = q.Where("action = ?", action)
	}
	q.Count(&total)
	err := q.Order("created_at DESC").Offset((page - 1) * limit).Limit(limit).Find(&rows).Error
	return rows, total, err
}

// WriteAuditLog is a fire-and-forget helper called from other services.
func (s *Service) WriteAuditLog(userID *uint, action, entityType string, entityID *uint, ip string) {
	log := AuditLog{
		UserID:     userID,
		Action:     action,
		EntityType: entityType,
		EntityID:   entityID,
		IPAddress:  ip,
		NewValues:  time.Now().Format(time.RFC3339),
	}
	s.db.Create(&log)
}
