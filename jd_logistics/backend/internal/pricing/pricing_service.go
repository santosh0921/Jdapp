package pricing

import (
	"math"

	"gorm.io/gorm"

	"jd_logistics/internal/master"
)

// Service is the pricing engine.
type Service struct{ db *gorm.DB }

// NewService constructs a pricing Service.
func NewService(db *gorm.DB) *Service { return &Service{db: db} }

// Estimate returns a full price breakdown for a single-mode shipment.
func (s *Service) Estimate(req EstimateRequest) (*EstimateResponse, error) {
	distKm := s.distanceKm(req.FromCityID, req.ToCityID)

	riskLevel := "normal"
	if req.GoodsCategoryID > 0 {
		var cat master.GoodsCategory
		if s.db.First(&cat, req.GoodsCategoryID).Error == nil {
			riskLevel = cat.RiskLevel
		}
	}

	vehicleName := s.recommendVehicle(req.WeightKg)
	if req.VehicleTypeID > 0 {
		var vt master.VehicleType
		if s.db.First(&vt, req.VehicleTypeID).Error == nil {
			vehicleName = vt.Name
		}
	}

	mode := req.TransportMode
	if mode == "" {
		mode = "road"
	}

	const gstRate = 18.0
	baseFreight := s.baseFreight(mode, req.WeightKg, req.VolumeCbm)
	distanceCost := s.distanceCost(mode, distKm, req.WeightKg)
	fuelSurcharge := r2(baseFreight * 0.08)
	loadingCharges := s.loadUnload(req.WeightKg)
	unloadingCharges := loadingCharges
	handlingCharges := 0.0
	if riskLevel == "high" || req.IsFragile {
		handlingCharges = r2(baseFreight * 0.05)
	}

	insuranceCost := 0.0
	insuranceCoverage := 0.0
	if req.IsInsured && req.DeclaredValue > 0 {
		insuranceCoverage = req.DeclaredValue
		insuranceCost = math.Max(50, r2(req.DeclaredValue*0.005))
	}

	if req.IsExpress {
		baseFreight = r2(baseFreight * 1.5)
		distanceCost = r2(distanceCost * 1.5)
		fuelSurcharge = r2(fuelSurcharge * 1.5)
	}

	subtotal := baseFreight + distanceCost + fuelSurcharge + loadingCharges + unloadingCharges + handlingCharges + insuranceCost
	gstAmount := r2(subtotal * gstRate / 100)
	total := r2(subtotal + gstAmount)
	days := s.estimateDays(mode, distKm)

	return &EstimateResponse{
		BaseFreight:        baseFreight,
		DistanceCost:       distanceCost,
		FuelSurcharge:      fuelSurcharge,
		LoadingCharges:     loadingCharges,
		UnloadingCharges:   unloadingCharges,
		GSTAmount:          gstAmount,
		InsuranceCost:      insuranceCost,
		HandlingCharges:    handlingCharges,
		TotalAmount:        total,
		VehicleRecommended: vehicleName,
		RiskLevel:          riskLevel,
		InsuranceCoverage:  insuranceCoverage,
		DistanceKm:         distKm,
		EstimatedDays:      days,
		TransportMode:      mode,
		GSTRate:            gstRate,
	}, nil
}

// EstimateMultiModal returns a full price breakdown for a multi-leg shipment.
func (s *Service) EstimateMultiModal(req MultiModalRequest) (*EstimateResponse, error) {
	segments := make([]SegmentCost, 0, len(req.Segments))
	totalBase := 0.0
	totalDays := 0
	totalDist := 0.0

	for _, seg := range req.Segments {
		dist := s.distanceKm(seg.FromCityID, seg.ToCityID)
		if dist == 0 {
			dist = 500
		}
		segBase := s.baseFreight(seg.Mode, req.WeightKg, req.VolumeCbm)
		segDist := s.distanceCost(seg.Mode, dist, req.WeightKg)
		segCost := segBase + segDist
		days := s.estimateDays(seg.Mode, dist)
		segments = append(segments, SegmentCost{
			Mode: seg.Mode, DistanceKm: dist, Cost: r2(segCost), Days: days,
		})
		totalBase += segCost
		totalDays += days
		totalDist += dist
	}

	fuelSurcharge := r2(totalBase * 0.08)
	loadingCharges := s.loadUnload(req.WeightKg)
	unloadingCharges := loadingCharges

	insuranceCost := 0.0
	insuranceCoverage := 0.0
	if req.IsInsured && req.DeclaredValue > 0 {
		insuranceCoverage = req.DeclaredValue
		insuranceCost = math.Max(50, r2(req.DeclaredValue*0.005))
	}

	subtotal := totalBase + fuelSurcharge + loadingCharges + unloadingCharges + insuranceCost
	gstAmount := r2(subtotal * 18 / 100)
	total := r2(subtotal + gstAmount)

	return &EstimateResponse{
		BaseFreight:        r2(totalBase),
		DistanceCost:       0,
		FuelSurcharge:      fuelSurcharge,
		LoadingCharges:     loadingCharges,
		UnloadingCharges:   unloadingCharges,
		GSTAmount:          gstAmount,
		InsuranceCost:      insuranceCost,
		HandlingCharges:    0,
		TotalAmount:        total,
		VehicleRecommended: s.recommendVehicle(req.WeightKg),
		RiskLevel:          "normal",
		InsuranceCoverage:  insuranceCoverage,
		DistanceKm:         r2(totalDist),
		EstimatedDays:      totalDays,
		TransportMode:      "multi-modal",
		GSTRate:            18,
		Segments:           segments,
	}, nil
}

// ── internal helpers ──────────────────────────────────────────────────────────

func (s *Service) distanceKm(fromCityID, toCityID uint) float64 {
	if fromCityID == 0 || toCityID == 0 || fromCityID == toCityID {
		return 500
	}
	var from, to master.City
	if s.db.First(&from, fromCityID).Error != nil || s.db.First(&to, toCityID).Error != nil {
		return 500
	}
	if from.Latitude == 0 && from.Longitude == 0 {
		return 500
	}
	straight := haversineKm(from.Latitude, from.Longitude, to.Latitude, to.Longitude)
	return r2(straight * 1.3) // road ≈ 1.3× straight-line
}

// baseFreight calculates the weight/volume-based freight charge.
// Volumetric weight factors: air 1 CBM = 166 kg; sea/road 1 CBM = 1000 kg.
func (s *Service) baseFreight(mode string, weightKg, volumeCbm float64) float64 {
	w := weightKg
	switch mode {
	case "air":
		if vol := volumeCbm * 166; vol > w {
			w = vol
		}
		return math.Max(999, r2(w*180))
	case "sea":
		if volumeCbm > 0 {
			return math.Max(5000, r2(volumeCbm*10000))
		}
		return math.Max(5000, r2(w*12))
	case "rail":
		return math.Max(500, r2(w*2))
	default: // road/courier
		return math.Max(99, r2(w*5))
	}
}

// distanceCost adds a per-km surcharge for road and rail.
func (s *Service) distanceCost(mode string, distKm, weightKg float64) float64 {
	switch mode {
	case "air", "sea":
		return 0 // weight-only pricing
	case "rail":
		return r2(weightKg * distKm / 100 * 1.8)
	default: // road
		return r2(weightKg * distKm / 100 * 3.5)
	}
}

func (s *Service) loadUnload(weightKg float64) float64 {
	if weightKg > 500 {
		return r2(weightKg * 2)
	}
	return 100
}

func (s *Service) estimateDays(mode string, distKm float64) int {
	switch mode {
	case "air":
		return 2
	case "sea":
		return 30
	case "rail":
		d := int(math.Ceil(distKm / 600))
		if d < 1 {
			d = 1
		}
		return d
	default:
		d := int(math.Ceil(distKm / 400))
		if d < 1 {
			d = 1
		}
		return d
	}
}

func (s *Service) recommendVehicle(weightKg float64) string {
	switch {
	case weightKg <= 20:
		return "Bike"
	case weightKg <= 750:
		return "Tempo"
	case weightKg <= 5000:
		return "Truck (Small)"
	case weightKg <= 12000:
		return "Truck (Medium)"
	default:
		return "Truck (Large)"
	}
}

func haversineKm(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371.0
	dlat := (lat2 - lat1) * math.Pi / 180
	dlon := (lon2 - lon1) * math.Pi / 180
	a := math.Sin(dlat/2)*math.Sin(dlat/2) +
		math.Cos(lat1*math.Pi/180)*math.Cos(lat2*math.Pi/180)*
			math.Sin(dlon/2)*math.Sin(dlon/2)
	return R * 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
}

func r2(v float64) float64 { return math.Round(v*100) / 100 }
