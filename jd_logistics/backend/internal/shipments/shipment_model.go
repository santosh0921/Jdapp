package shipments

import "jd_logistics/utils"

// ── Core Shipment ──────────────────────────────────────────────────────────────

type Shipment struct {
	utils.Model
	TrackingID      string  `gorm:"uniqueIndex;not null" json:"tracking_id"`
	CustomerID      uint    `gorm:"not null;index" json:"customer_id"`
	DriverID        *uint   `gorm:"index" json:"driver_id"`
	WarehouseID     *uint   `gorm:"index" json:"warehouse_id"`
	Status          string  `gorm:"default:'pending'" json:"status"`
	PickupAddress   string  `json:"pickup_address"`
	DeliveryAddress string  `json:"delivery_address"`
	PackageType     string  `json:"package_type"`
	Weight          float64 `json:"weight"`
	Amount          float64 `json:"amount"`
	Notes           string  `json:"notes"`
}

func (Shipment) TableName() string { return "jd_logistics.shipments" }

// ── Courier Order ──────────────────────────────────────────────────────────────

type CourierOrder struct {
	utils.Model
	TrackingID        string  `gorm:"uniqueIndex;not null" json:"tracking_id"`
	CustomerID        uint    `gorm:"not null;index" json:"customer_id"`
	DriverID          *uint   `gorm:"index" json:"driver_id"`
	FromAddress       string  `json:"from_address"`
	ToAddress         string  `json:"to_address"`
	FromCityID        *uint   `gorm:"index" json:"from_city_id"`
	ToCityID          *uint   `gorm:"index" json:"to_city_id"`
	PackageType       string  `json:"package_type"`
	WeightKg          float64 `json:"weight_kg"`
	DeclaredValue     float64 `json:"declared_value"`
	GoodsCategoryID   *uint   `gorm:"index" json:"goods_category_id"`
	VehicleTypeID     *uint   `gorm:"index" json:"vehicle_type_id"`
	PaymentMethodCode string  `json:"payment_method_code"`
	Status            string  `gorm:"default:'booked'" json:"status"`
	Amount            float64 `json:"amount"`
	GSTAmount         float64 `json:"gst_amount"`
	TotalAmount       float64 `json:"total_amount"`
	IsFragile         bool    `gorm:"default:false" json:"is_fragile"`
	IsInsured         bool    `gorm:"default:false" json:"is_insured"`
	InsuranceValue    float64 `json:"insurance_value"`
	PartnerName       string  `json:"partner_name"`
	PickupTime        *string `json:"pickup_time"`
	EstimatedDelivery *string `json:"estimated_delivery"`
	ActualDelivery    *string `json:"actual_delivery"`
	Notes             string  `json:"notes"`
}

func (CourierOrder) TableName() string { return "jd_logistics.courier_orders" }

// ── Logistics Order ────────────────────────────────────────────────────────────

type LogisticsOrder struct {
	utils.Model
	TrackingID      string  `gorm:"uniqueIndex;not null" json:"tracking_id"`
	CustomerID      uint    `gorm:"not null;index" json:"customer_id"`
	FromPortID      *uint   `gorm:"index" json:"from_port_id"`
	ToPortID        *uint   `gorm:"index" json:"to_port_id"`
	FromCountryID   *uint   `gorm:"index" json:"from_country_id"`
	ToCountryID     *uint   `gorm:"index" json:"to_country_id"`
	TransportModeID *uint   `gorm:"index" json:"transport_mode_id"`
	GoodsCategoryID *uint   `gorm:"index" json:"goods_category_id"`
	GoodsName       string  `json:"goods_name"`
	ContainerType   string  `json:"container_type"`
	WeightKg        float64 `json:"weight_kg"`
	VolumeCbm       float64 `json:"volume_cbm"`
	DeclaredValue   float64 `json:"declared_value"`
	HSNCodeValue    string  `json:"hsn_code"`
	Status          string  `gorm:"default:'draft'" json:"status"`
	Amount          float64 `json:"amount"`
	GSTAmount       float64 `json:"gst_amount"`
	TotalAmount     float64 `json:"total_amount"`
	ETD             *string `json:"etd"`
	ETA             *string `json:"eta"`
	IsInsured       bool    `gorm:"default:false" json:"is_insured"`
	Notes           string  `json:"notes"`
}

func (LogisticsOrder) TableName() string { return "jd_logistics.logistics_orders" }

// ── Container ──────────────────────────────────────────────────────────────────

type Container struct {
	utils.Model
	ContainerNumber  string `gorm:"uniqueIndex;not null" json:"container_number"`
	Type             string `json:"type"`
	Status           string `gorm:"default:'available'" json:"status"`
	CurrentLocation  string `json:"current_location"`
	LogisticsOrderID *uint  `gorm:"index" json:"logistics_order_id"`
}

func (Container) TableName() string { return "jd_logistics.containers" }

// ── Document ───────────────────────────────────────────────────────────────────

type Document struct {
	utils.Model
	ShipmentType     string `gorm:"not null" json:"shipment_type"`
	OrderID          uint   `gorm:"not null;index" json:"order_id"`
	Type             string `gorm:"not null" json:"type"`
	FileURL          string `json:"file_url"`
	FileName         string `json:"file_name"`
	FileSizeBytes    int64  `json:"file_size_bytes"`
	UploadedByUserID uint   `gorm:"index" json:"uploaded_by_user_id"`
	IsVerified       bool   `gorm:"default:false" json:"is_verified"`
	VerifiedByUserID *uint  `json:"verified_by_user_id"`
}

func (Document) TableName() string { return "jd_logistics.documents" }

// ── DTOs ───────────────────────────────────────────────────────────────────────

type CreateShipmentRequest struct {
	PickupAddress   string  `json:"pickup_address" binding:"required"`
	DeliveryAddress string  `json:"delivery_address" binding:"required"`
	PackageType     string  `json:"package_type" binding:"required"`
	Weight          float64 `json:"weight"`
	Notes           string  `json:"notes"`
}

type QuoteRequest struct {
	PickupAddress   string  `json:"pickup_address" binding:"required"`
	DeliveryAddress string  `json:"delivery_address" binding:"required"`
	PackageType     string  `json:"package_type"`
	Weight          float64 `json:"weight"`
}
