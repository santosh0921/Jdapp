package logistics

// CreateOrderRequest is the body for POST /logistics/orders.
type CreateOrderRequest struct {
	FromPortID      *uint   `json:"from_port_id"`
	ToPortID        *uint   `json:"to_port_id"`
	FromCountryID   *uint   `json:"from_country_id"`
	ToCountryID     *uint   `json:"to_country_id"`
	TransportModeID *uint   `json:"transport_mode_id"`
	TransportMode   string  `json:"transport_mode"` // road|air|sea|rail
	GoodsCategoryID *uint   `json:"goods_category_id"`
	GoodsName       string  `json:"goods_name" binding:"required"`
	ContainerType   string  `json:"container_type"`
	WeightKg        float64 `json:"weight_kg" binding:"required,gt=0"`
	VolumeCbm       float64 `json:"volume_cbm"`
	DeclaredValue   float64 `json:"declared_value"`
	HSNCode         string  `json:"hsn_code"`
	IsInsured       bool    `json:"is_insured"`
	Notes           string  `json:"notes"`
	ETD             *string `json:"etd"`
}

// EstimateRequest is the body for POST /logistics/estimate.
type EstimateRequest struct {
	FromPortID      uint    `json:"from_port_id"`
	ToPortID        uint    `json:"to_port_id"`
	FromCountryID   uint    `json:"from_country_id"`
	ToCountryID     uint    `json:"to_country_id"`
	TransportModeID uint    `json:"transport_mode_id"`
	TransportMode   string  `json:"transport_mode"` // road|air|sea|rail
	GoodsCategoryID uint    `json:"goods_category_id"`
	WeightKg        float64 `json:"weight_kg" binding:"required,gt=0"`
	VolumeCbm       float64 `json:"volume_cbm"`
	DeclaredValue   float64 `json:"declared_value"`
	IsInsured       bool    `json:"is_insured"`
}
