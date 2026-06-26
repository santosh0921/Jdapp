package admin

import "jd_logistics/utils"

// DashboardStats is the high-level summary for the admin dashboard.
type DashboardStats struct {
	TotalUsers       int64   `json:"total_users"`
	TotalDrivers     int64   `json:"total_drivers"`
	TotalShipments   int64   `json:"total_shipments"`
	Revenue          float64 `json:"revenue"`
	ActiveDrivers    int64   `json:"active_drivers"`
	PendingOrders    int64   `json:"pending_orders"`
	TodayRevenue     float64 `json:"today_revenue"`
	TodayShipments   int64   `json:"today_shipments"`
	OnlineDrivers    int64   `json:"online_drivers"`
	WarehousesOnline int64   `json:"warehouses_online"`
}

// AnalyticsData is returned by GET /admin/analytics.
// Keys match Flutter's AdminService.getAnalytics() parser.
type AnalyticsData struct {
	ShipmentsMTD   int64        `json:"shipments_mtd"`
	RevenueMTD     float64      `json:"revenue_mtd"`
	ActiveDrivers  int64        `json:"active_drivers"`
	OnTimeDelivery float64      `json:"on_time_delivery"`
	DailyShipments []float64    `json:"daily_shipments"`
	DailyRevenue   []float64    `json:"daily_revenue"`
	ModeRoad       float64      `json:"mode_road"`
	ModeAir        float64      `json:"mode_air"`
	ModeOcean      float64      `json:"mode_ocean"`
	TopRoutes      []RouteStats `json:"top_routes"`
}

// RouteStats is a top-route entry.
type RouteStats struct {
	From  string `json:"from"`
	To    string `json:"to"`
	Count int    `json:"count"`
}

// AuditLog records every significant platform action.
type AuditLog struct {
	utils.Model
	UserID     *uint  `gorm:"index" json:"user_id"`
	Action     string `gorm:"not null" json:"action"`
	EntityType string `json:"entity_type"`
	EntityID   *uint  `json:"entity_id"`
	OldValues  string `gorm:"type:text" json:"old_values"`
	NewValues  string `gorm:"type:text" json:"new_values"`
	IPAddress  string `json:"ip_address"`
	UserAgent  string `json:"user_agent"`
}

func (AuditLog) TableName() string { return "jd_logistics.audit_logs" }

// Report stores generated report metadata and download links.
type Report struct {
	utils.Model
	Type              string  `gorm:"not null" json:"type"`
	Parameters        string  `gorm:"type:text" json:"parameters"`
	GeneratedByUserID *uint   `gorm:"index" json:"generated_by_user_id"`
	FileURL           string  `json:"file_url"`
	Status            string  `gorm:"default:'pending'" json:"status"`
	DateFrom          *string `json:"date_from"`
	DateTo            *string `json:"date_to"`
	CompletedAt       *string `json:"completed_at"`
}

func (Report) TableName() string { return "jd_logistics.reports" }
