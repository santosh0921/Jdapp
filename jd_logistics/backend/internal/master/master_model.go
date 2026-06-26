package master

import "jd_logistics/utils"

// ── Roles ──────────────────────────────────────────────────────────────────────

type Role struct {
	utils.Model
	Name        string `gorm:"uniqueIndex;not null" json:"name"`
	Description string `json:"description"`
	IsActive    bool   `gorm:"default:true" json:"is_active"`
}

func (Role) TableName() string { return "jd_logistics.roles" }

// ── Goods Categories ───────────────────────────────────────────────────────────

type GoodsCategory struct {
	utils.Model
	Name                    string  `gorm:"uniqueIndex;not null" json:"name"`
	Description             string  `json:"description"`
	RiskLevel               string  `gorm:"default:'low'" json:"risk_level"`
	RequiresSpecialHandling bool    `gorm:"default:false" json:"requires_special_handling"`
	RequiresInsurance       bool    `gorm:"default:false" json:"requires_insurance"`
	MaxWeightKg             float64 `json:"max_weight_kg"`
	IsActive                bool    `gorm:"default:true" json:"is_active"`
}

func (GoodsCategory) TableName() string { return "jd_logistics.goods_categories" }

// ── Vehicle Types ──────────────────────────────────────────────────────────────

type VehicleType struct {
	utils.Model
	Name        string  `gorm:"uniqueIndex;not null" json:"name"`
	Description string  `json:"description"`
	CapacityKg  float64 `json:"capacity_kg"`
	VolumeCbm   float64 `json:"volume_cbm"`
	IsActive    bool    `gorm:"default:true" json:"is_active"`
}

func (VehicleType) TableName() string { return "jd_logistics.vehicle_types" }

// ── Countries ──────────────────────────────────────────────────────────────────

type Country struct {
	utils.Model
	Name      string `gorm:"uniqueIndex;not null" json:"name"`
	Code      string `gorm:"uniqueIndex;size:4;not null" json:"code"`
	PhoneCode string `json:"phone_code"`
	Currency  string `json:"currency"`
	IsActive  bool   `gorm:"default:true" json:"is_active"`
}

func (Country) TableName() string { return "jd_logistics.countries" }

// ── States ─────────────────────────────────────────────────────────────────────

type State struct {
	utils.Model
	Name      string `gorm:"not null" json:"name"`
	Code      string `gorm:"uniqueIndex;not null" json:"code"`
	CountryID uint   `gorm:"not null;index" json:"country_id"`
	IsActive  bool   `gorm:"default:true" json:"is_active"`
}

func (State) TableName() string { return "jd_logistics.states" }

// ── Cities ─────────────────────────────────────────────────────────────────────

type City struct {
	utils.Model
	Name       string  `gorm:"not null" json:"name"`
	State      string  `json:"state"`
	CountryID  uint    `gorm:"not null;index" json:"country_id"`
	IsHub      bool    `gorm:"default:false" json:"is_hub"`
	IsPortCity bool    `gorm:"default:false" json:"is_port_city"`
	Latitude   float64 `json:"latitude"`
	Longitude  float64 `json:"longitude"`
	IsActive   bool    `gorm:"default:true" json:"is_active"`
}

func (City) TableName() string { return "jd_logistics.cities" }

// ── Ports ──────────────────────────────────────────────────────────────────────

type Port struct {
	utils.Model
	Name      string `gorm:"not null" json:"name"`
	Code      string `gorm:"uniqueIndex;not null" json:"code"`
	CityID    *uint  `gorm:"index" json:"city_id"`
	CountryID uint   `gorm:"not null;index" json:"country_id"`
	Type      string `gorm:"not null" json:"type"` // sea/air/land/rail
	IsActive  bool   `gorm:"default:true" json:"is_active"`
}

func (Port) TableName() string { return "jd_logistics.ports" }

// ── Transport Modes ────────────────────────────────────────────────────────────

type TransportMode struct {
	utils.Model
	Name        string `gorm:"uniqueIndex;not null" json:"name"`
	Description string `json:"description"`
	IconCode    string `json:"icon_code"`
	IsActive    bool   `gorm:"default:true" json:"is_active"`
}

func (TransportMode) TableName() string { return "jd_logistics.transport_modes" }

// ── Shipment Statuses ──────────────────────────────────────────────────────────

type ShipmentStatus struct {
	utils.Model
	Code        string `gorm:"uniqueIndex;not null" json:"code"`
	Label       string `gorm:"not null" json:"label"`
	Description string `json:"description"`
	Sequence    int    `json:"sequence"`
	Color       string `json:"color"`
	IsTerminal  bool   `gorm:"default:false" json:"is_terminal"`
}

func (ShipmentStatus) TableName() string { return "jd_logistics.shipment_statuses" }

// ── Payment Methods ────────────────────────────────────────────────────────────

type PaymentMethod struct {
	utils.Model
	Code        string `gorm:"uniqueIndex;not null" json:"code"`
	Label       string `gorm:"not null" json:"label"`
	Description string `json:"description"`
	IsActive    bool   `gorm:"default:true" json:"is_active"`
}

func (PaymentMethod) TableName() string { return "jd_logistics.payment_methods" }

// ── Warehouse Types ────────────────────────────────────────────────────────────

type WarehouseType struct {
	utils.Model
	Name        string `gorm:"uniqueIndex;not null" json:"name"`
	Description string `json:"description"`
	IsActive    bool   `gorm:"default:true" json:"is_active"`
}

func (WarehouseType) TableName() string { return "jd_logistics.warehouse_types" }

// ── GST Rates ──────────────────────────────────────────────────────────────────

type GSTRate struct {
	utils.Model
	CategoryName string  `gorm:"uniqueIndex;not null" json:"category_name"`
	Rate         float64 `gorm:"not null" json:"rate"`
	Description  string  `json:"description"`
	IsActive     bool    `gorm:"default:true" json:"is_active"`
}

func (GSTRate) TableName() string { return "jd_logistics.gst_rates" }

// ── HSN Codes ──────────────────────────────────────────────────────────────────

type HSNCode struct {
	utils.Model
	Code          string `gorm:"uniqueIndex;not null" json:"code"`
	Description   string `gorm:"not null" json:"description"`
	GSTRateID     *uint  `gorm:"index" json:"gst_rate_id"`
	Chapter       string `json:"chapter"`
	UnitOfMeasure string `json:"unit_of_measure"`
	IsActive      bool   `gorm:"default:true" json:"is_active"`
}

func (HSNCode) TableName() string { return "jd_logistics.hsn_codes" }

// ── Pricing Rules ──────────────────────────────────────────────────────────────

type PricingRule struct {
	utils.Model
	Name            string  `gorm:"not null" json:"name"`
	TransportModeID *uint   `gorm:"index" json:"transport_mode_id"`
	GoodsCategoryID *uint   `gorm:"index" json:"goods_category_id"`
	FromCityID      *uint   `gorm:"index" json:"from_city_id"`
	ToCityID        *uint   `gorm:"index" json:"to_city_id"`
	FromCountryID   *uint   `gorm:"index" json:"from_country_id"`
	ToCountryID     *uint   `gorm:"index" json:"to_country_id"`
	BaseRate        float64 `gorm:"not null;default:0" json:"base_rate"`
	PerKgRate       float64 `gorm:"default:0" json:"per_kg_rate"`
	PerCbmRate      float64 `gorm:"default:0" json:"per_cbm_rate"`
	MinCharge       float64 `gorm:"default:0" json:"min_charge"`
	SurchargePct    float64 `gorm:"default:0" json:"surcharge_pct"`
	IsActive        bool    `gorm:"default:true" json:"is_active"`
	ValidFrom       *string `json:"valid_from"`
	ValidTo         *string `json:"valid_to"`
}

func (PricingRule) TableName() string { return "jd_logistics.pricing_rules" }

// ── Fuel Rates ─────────────────────────────────────────────────────────────────

type FuelRate struct {
	utils.Model
	FuelType    string  `gorm:"not null" json:"fuel_type"` // diesel|petrol|cng|electric
	PricePerLtr float64 `gorm:"not null" json:"price_per_ltr"`
	EffectiveOn string  `gorm:"not null" json:"effective_on"`
	State       string  `json:"state"`
	IsActive    bool    `gorm:"default:true" json:"is_active"`
}

func (FuelRate) TableName() string { return "jd_logistics.fuel_rates" }

// ── Insurance Rates ────────────────────────────────────────────────────────────

type InsuranceRate struct {
	utils.Model
	GoodsCategoryID *uint   `gorm:"index" json:"goods_category_id"`
	CategoryName    string  `json:"category_name"`
	RatePct         float64 `gorm:"not null" json:"rate_pct"` // percentage of declared value
	MinPremium      float64 `gorm:"default:50" json:"min_premium"`
	MaxCoverage     float64 `json:"max_coverage"`
	IsActive        bool    `gorm:"default:true" json:"is_active"`
}

func (InsuranceRate) TableName() string { return "jd_logistics.insurance_rates" }
