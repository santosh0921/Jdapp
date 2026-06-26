package pricing

// EstimateRequest is the unified input for any pricing estimate.
type EstimateRequest struct {
	FromCityID      uint    `json:"from_city_id"`
	ToCityID        uint    `json:"to_city_id"`
	FromCountryID   uint    `json:"from_country_id"`
	ToCountryID     uint    `json:"to_country_id"`
	WeightKg        float64 `json:"weight_kg"`
	VolumeCbm       float64 `json:"volume_cbm"`
	TransportMode   string  `json:"transport_mode"` // road|air|sea|rail|courier
	GoodsCategoryID uint    `json:"goods_category_id"`
	VehicleTypeID   uint    `json:"vehicle_type_id"`
	DeclaredValue   float64 `json:"declared_value"`
	IsInsured       bool    `json:"is_insured"`
	IsExpress       bool    `json:"is_express"`
	IsFragile       bool    `json:"is_fragile"`
}

// MultiModalRequest describes a multi-leg shipment.
type MultiModalRequest struct {
	WeightKg      float64             `json:"weight_kg"`
	VolumeCbm     float64             `json:"volume_cbm"`
	DeclaredValue float64             `json:"declared_value"`
	IsInsured     bool                `json:"is_insured"`
	Segments      []MultiModalSegment `json:"segments"`
}

// MultiModalSegment is one leg of a multi-modal shipment.
type MultiModalSegment struct {
	Mode       string `json:"mode"` // road|rail|air|sea
	FromCityID uint   `json:"from_city_id"`
	ToCityID   uint   `json:"to_city_id"`
	FromPortID *uint  `json:"from_port_id"`
	ToPortID   *uint  `json:"to_port_id"`
}

// EstimateResponse matches Flutter's LPricingResult.fromMap() keys exactly.
type EstimateResponse struct {
	BaseFreight        float64       `json:"base_freight"`
	DistanceCost       float64       `json:"distance_cost"`
	FuelSurcharge      float64       `json:"fuel_surcharge"`
	LoadingCharges     float64       `json:"loading_charges"`
	UnloadingCharges   float64       `json:"unloading_charges"`
	GSTAmount          float64       `json:"gst_amount"`
	InsuranceCost      float64       `json:"insurance_cost"`
	HandlingCharges    float64       `json:"handling_charges"`
	TotalAmount        float64       `json:"total_amount"`
	VehicleRecommended string        `json:"recommended_vehicle"`
	RiskLevel          string        `json:"risk_level"`
	InsuranceCoverage  float64       `json:"insurance_coverage"`
	DistanceKm         float64       `json:"distance_km"`
	EstimatedDays      int           `json:"estimated_days"`
	TransportMode      string        `json:"transport_mode"`
	GSTRate            float64       `json:"gst_rate"`
	Segments           []SegmentCost `json:"segments,omitempty"`
}

// SegmentCost represents one leg's cost in a multi-modal quote.
type SegmentCost struct {
	Mode       string  `json:"mode"`
	DistanceKm float64 `json:"distance_km"`
	Cost       float64 `json:"cost"`
	Days       int     `json:"days"`
}
