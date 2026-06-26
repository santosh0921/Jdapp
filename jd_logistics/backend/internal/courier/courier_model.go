package courier

// CreateOrderRequest is the body for POST /courier/orders.
type CreateOrderRequest struct {
	FromAddress       string  `json:"from_address" binding:"required"`
	ToAddress         string  `json:"to_address" binding:"required"`
	FromCityID        *uint   `json:"from_city_id"`
	ToCityID          *uint   `json:"to_city_id"`
	PackageType       string  `json:"package_type" binding:"required"`
	WeightKg          float64 `json:"weight_kg" binding:"required,gt=0"`
	DeclaredValue     float64 `json:"declared_value"`
	GoodsCategoryID   *uint   `json:"goods_category_id"`
	VehicleTypeID     *uint   `json:"vehicle_type_id"`
	PaymentMethodCode string  `json:"payment_method_code"`
	IsFragile         bool    `json:"is_fragile"`
	IsInsured         bool    `json:"is_insured"`
	InsuranceValue    float64 `json:"insurance_value"`
	Notes             string  `json:"notes"`
}

// EstimateRequest is the body for POST /courier/estimate.
type EstimateRequest struct {
	FromCityID      uint    `json:"from_city_id"`
	ToCityID        uint    `json:"to_city_id"`
	WeightKg        float64 `json:"weight_kg" binding:"required,gt=0"`
	GoodsCategoryID uint    `json:"goods_category_id"`
	VehicleTypeID   uint    `json:"vehicle_type_id"`
	DeclaredValue   float64 `json:"declared_value"`
	IsInsured       bool    `json:"is_insured"`
	IsExpress       bool    `json:"is_express"`
	IsFragile       bool    `json:"is_fragile"`
}

// UpdateStatusRequest is used by drivers/admins to advance an order.
type UpdateStatusRequest struct {
	Status string `json:"status" binding:"required"`
	Note   string `json:"note"`
}
