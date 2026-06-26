package seed

import (
	"log"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"jd_logistics/internal/master"
)

// Run seeds all master data. Safe to call on every startup (idempotent).
func Run(db *gorm.DB) {
	log.Println("Seeding master data...")
	seedRoles(db)
	seedTransportModes(db)
	seedShipmentStatuses(db)
	seedPaymentMethods(db)
	seedGoodsCategories(db)
	seedVehicleTypes(db)
	seedWarehouseTypes(db)
	seedGSTRates(db)
	seedCountries(db)
	seedStates(db)
	seedCities(db)
	seedPorts(db)
	seedHSNCodes(db)
	seedPricingRules(db)
	seedFuelRates(db)
	seedInsuranceRates(db)
	log.Println("Master data seeded")
}

func seedRoles(db *gorm.DB) {
	rows := []master.Role{
		{Name: "customer", Description: "End customer booking shipments"},
		{Name: "driver", Description: "Delivery / transport driver"},
		{Name: "warehouse", Description: "Warehouse operator"},
		{Name: "admin", Description: "Platform administrator"},
		{Name: "superadmin", Description: "Super administrator with full access"},
	}
	for i := range rows {
		db.Where(master.Role{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedTransportModes(db *gorm.DB) {
	rows := []master.TransportMode{
		{Name: "road", Description: "Road / truck transport", IconCode: "local_shipping"},
		{Name: "air", Description: "Air cargo", IconCode: "flight"},
		{Name: "sea", Description: "Ocean / sea freight", IconCode: "directions_boat"},
		{Name: "rail", Description: "Rail / train transport", IconCode: "train"},
		{Name: "courier", Description: "Express courier", IconCode: "delivery_dining"},
		{Name: "multi-modal", Description: "Multi-modal transport", IconCode: "route"},
	}
	for i := range rows {
		db.Where(master.TransportMode{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedShipmentStatuses(db *gorm.DB) {
	rows := []master.ShipmentStatus{
		{Code: "draft", Label: "Draft", Sequence: 0, Color: "#9E9E9E", IsTerminal: false},
		{Code: "booked", Label: "Booked", Sequence: 1, Color: "#2196F3", IsTerminal: false},
		{Code: "pickup_scheduled", Label: "Pickup Scheduled", Sequence: 2, Color: "#03A9F4", IsTerminal: false},
		{Code: "picked_up", Label: "Picked Up", Sequence: 3, Color: "#00BCD4", IsTerminal: false},
		{Code: "at_warehouse", Label: "At Warehouse", Sequence: 4, Color: "#009688", IsTerminal: false},
		{Code: "in_transit", Label: "In Transit", Sequence: 5, Color: "#FF9800", IsTerminal: false},
		{Code: "customs_clearance", Label: "Customs Clearance", Sequence: 5, Color: "#9C27B0", IsTerminal: false},
		{Code: "out_for_delivery", Label: "Out for Delivery", Sequence: 6, Color: "#FF5722", IsTerminal: false},
		{Code: "delivered", Label: "Delivered", Sequence: 7, Color: "#4CAF50", IsTerminal: true},
		{Code: "delayed", Label: "Delayed", Sequence: 0, Color: "#F44336", IsTerminal: false},
		{Code: "cancelled", Label: "Cancelled", Sequence: 0, Color: "#607D8B", IsTerminal: true},
		{Code: "returned", Label: "Returned", Sequence: 0, Color: "#795548", IsTerminal: true},
	}
	for i := range rows {
		db.Where(master.ShipmentStatus{Code: rows[i].Code}).FirstOrCreate(&rows[i])
	}
}

func seedPaymentMethods(db *gorm.DB) {
	rows := []master.PaymentMethod{
		{Code: "upi", Label: "UPI"},
		{Code: "card", Label: "Credit / Debit Card"},
		{Code: "net_banking", Label: "Net Banking"},
		{Code: "wallet", Label: "JD Wallet"},
		{Code: "cod", Label: "Cash on Delivery"},
		{Code: "pay_later", Label: "Pay Later / Business Credit"},
		{Code: "bank_transfer", Label: "Bank Transfer (NEFT/RTGS)"},
		{Code: "cheque", Label: "Cheque"},
	}
	for i := range rows {
		db.Where(master.PaymentMethod{Code: rows[i].Code}).FirstOrCreate(&rows[i])
	}
}

func seedGoodsCategories(db *gorm.DB) {
	rows := []master.GoodsCategory{
		{Name: "Steel", RiskLevel: "medium", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Iron", RiskLevel: "medium", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Copper", RiskLevel: "medium", RequiresSpecialHandling: false, RequiresInsurance: true},
		{Name: "Machinery", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Electronics", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Furniture", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Medicine", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Chemicals", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Petroleum", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "LPG", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "CNG", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Coal", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Cement", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Tiles", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Granite", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Marble", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Textiles", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Garments", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Food", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Vegetables", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Fruits", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Frozen Goods", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Milk", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Flowers", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: false},
		{Name: "Livestock", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Automobile", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Construction Material", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Industrial Equipment", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Hazardous Goods", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "High Value Goods", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Fragile Goods", RiskLevel: "medium", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Temperature Controlled", RiskLevel: "high", RequiresSpecialHandling: true, RequiresInsurance: true},
		{Name: "Documents", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "General Merchandise", RiskLevel: "low", RequiresSpecialHandling: false, RequiresInsurance: false},
	}
	for i := range rows {
		db.Where(master.GoodsCategory{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedVehicleTypes(db *gorm.DB) {
	rows := []master.VehicleType{
		{Name: "Bike", CapacityKg: 20, VolumeCbm: 0.1, Description: "Two-wheeler for small parcels"},
		{Name: "Tempo", CapacityKg: 750, VolumeCbm: 3.5, Description: "Mini truck (Tata Ace)"},
		{Name: "Mini Truck", CapacityKg: 1500, VolumeCbm: 7.0, Description: "Mini cargo truck"},
		{Name: "Pickup", CapacityKg: 1000, VolumeCbm: 4.0, Description: "Pickup / flatbed"},
		{Name: "Bolero Pickup", CapacityKg: 1200, VolumeCbm: 5.0, Description: "Bolero Camper"},
		{Name: "14 Ft Truck", CapacityKg: 5000, VolumeCbm: 20.0, Description: "14 ft enclosed truck"},
		{Name: "17 Ft Truck", CapacityKg: 8000, VolumeCbm: 32.0, Description: "17 ft truck"},
		{Name: "20 Ft Truck", CapacityKg: 10000, VolumeCbm: 42.0, Description: "20 ft truck"},
		{Name: "32 Ft Truck", CapacityKg: 21000, VolumeCbm: 72.0, Description: "32 ft truck"},
		{Name: "Trailer", CapacityKg: 30000, VolumeCbm: 90.0, Description: "Multi-axle trailer"},
		{Name: "Container Truck", CapacityKg: 28000, VolumeCbm: 67.0, Description: "Container truck 40ft"},
		{Name: "Reefer", CapacityKg: 20000, VolumeCbm: 55.0, Description: "Refrigerated truck"},
		{Name: "Tanker", CapacityKg: 35000, VolumeCbm: 35.0, Description: "Liquid tanker"},
		{Name: "Train Wagon", CapacityKg: 60000, VolumeCbm: 120.0, Description: "Rail wagon"},
		{Name: "Cargo Aircraft", CapacityKg: 100000, VolumeCbm: 400.0, Description: "Air freighter"},
		{Name: "Cargo Ship", CapacityKg: 20000000, VolumeCbm: 50000.0, Description: "Ocean vessel"},
	}
	for i := range rows {
		db.Where(master.VehicleType{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedWarehouseTypes(db *gorm.DB) {
	rows := []master.WarehouseType{
		{Name: "General", Description: "General purpose warehouse"},
		{Name: "Cold Storage", Description: "Temperature-controlled for perishables"},
		{Name: "Bonded", Description: "Customs bonded warehouse"},
		{Name: "Distribution", Description: "Distribution / fulfillment center"},
		{Name: "Hazmat", Description: "Hazardous materials storage"},
		{Name: "Port Facility", Description: "Port / terminal warehouse"},
		{Name: "Dark Store", Description: "Quick commerce dark store"},
	}
	for i := range rows {
		db.Where(master.WarehouseType{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedGSTRates(db *gorm.DB) {
	rows := []master.GSTRate{
		{CategoryName: "Exempt", Rate: 0, Description: "GST exempt goods and services"},
		{CategoryName: "5% GST", Rate: 5, Description: "Essential goods and services"},
		{CategoryName: "12% GST", Rate: 12, Description: "Standard goods and services"},
		{CategoryName: "18% GST", Rate: 18, Description: "Transport and logistics services"},
		{CategoryName: "28% GST", Rate: 28, Description: "Luxury goods"},
	}
	for i := range rows {
		db.Where(master.GSTRate{CategoryName: rows[i].CategoryName}).FirstOrCreate(&rows[i])
	}
}

func seedCountries(db *gorm.DB) {
	rows := []master.Country{
		{Name: "India", Code: "IN", PhoneCode: "+91", Currency: "INR"},
		{Name: "United Arab Emirates", Code: "AE", PhoneCode: "+971", Currency: "AED"},
		{Name: "United States", Code: "US", PhoneCode: "+1", Currency: "USD"},
		{Name: "United Kingdom", Code: "GB", PhoneCode: "+44", Currency: "GBP"},
		{Name: "Singapore", Code: "SG", PhoneCode: "+65", Currency: "SGD"},
		{Name: "China", Code: "CN", PhoneCode: "+86", Currency: "CNY"},
		{Name: "Germany", Code: "DE", PhoneCode: "+49", Currency: "EUR"},
		{Name: "Japan", Code: "JP", PhoneCode: "+81", Currency: "JPY"},
		{Name: "Australia", Code: "AU", PhoneCode: "+61", Currency: "AUD"},
		{Name: "Canada", Code: "CA", PhoneCode: "+1", Currency: "CAD"},
		{Name: "Netherlands", Code: "NL", PhoneCode: "+31", Currency: "EUR"},
		{Name: "Malaysia", Code: "MY", PhoneCode: "+60", Currency: "MYR"},
		{Name: "Sri Lanka", Code: "LK", PhoneCode: "+94", Currency: "LKR"},
		{Name: "Bangladesh", Code: "BD", PhoneCode: "+880", Currency: "BDT"},
		{Name: "Nepal", Code: "NP", PhoneCode: "+977", Currency: "NPR"},
		{Name: "Saudi Arabia", Code: "SA", PhoneCode: "+966", Currency: "SAR"},
		{Name: "France", Code: "FR", PhoneCode: "+33", Currency: "EUR"},
	}
	for i := range rows {
		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&rows[i])
	}
}

func seedStates(db *gorm.DB) {
	// Get India country ID
	var india master.Country
	if err := db.Where("code = ?", "IN").First(&india).Error; err != nil {
		return
	}
	states := []master.State{
		{Name: "Maharashtra", Code: "MH", CountryID: india.ID},
		{Name: "Delhi", Code: "DL", CountryID: india.ID},
		{Name: "Karnataka", Code: "KA", CountryID: india.ID},
		{Name: "Tamil Nadu", Code: "TN", CountryID: india.ID},
		{Name: "Telangana", Code: "TS", CountryID: india.ID},
		{Name: "West Bengal", Code: "WB", CountryID: india.ID},
		{Name: "Gujarat", Code: "GJ", CountryID: india.ID},
		{Name: "Rajasthan", Code: "RJ", CountryID: india.ID},
		{Name: "Uttar Pradesh", Code: "UP", CountryID: india.ID},
		{Name: "Punjab", Code: "PB", CountryID: india.ID},
		{Name: "Haryana", Code: "HR", CountryID: india.ID},
		{Name: "Madhya Pradesh", Code: "MP", CountryID: india.ID},
		{Name: "Andhra Pradesh", Code: "AP", CountryID: india.ID},
		{Name: "Bihar", Code: "BR", CountryID: india.ID},
		{Name: "Odisha", Code: "OD", CountryID: india.ID},
		{Name: "Assam", Code: "AS", CountryID: india.ID},
		{Name: "Kerala", Code: "KL", CountryID: india.ID},
		{Name: "Jharkhand", Code: "JH", CountryID: india.ID},
		{Name: "Chhattisgarh", Code: "CG", CountryID: india.ID},
		{Name: "Uttarakhand", Code: "UK", CountryID: india.ID},
		{Name: "Chandigarh", Code: "CH", CountryID: india.ID},
		{Name: "Goa", Code: "GA", CountryID: india.ID},
	}
	for i := range states {
		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&states[i])
	}
}

func seedCities(db *gorm.DB) {
	var india master.Country
	if err := db.Where("code = ?", "IN").First(&india).Error; err != nil {
		return
	}
	cities := []master.City{
		{Name: "Mumbai", State: "Maharashtra", CountryID: india.ID, IsHub: true, IsPortCity: true, Latitude: 19.0760, Longitude: 72.8777},
		{Name: "Delhi", State: "Delhi", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 28.6139, Longitude: 77.2090},
		{Name: "Bengaluru", State: "Karnataka", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 12.9716, Longitude: 77.5946},
		{Name: "Chennai", State: "Tamil Nadu", CountryID: india.ID, IsHub: true, IsPortCity: true, Latitude: 13.0827, Longitude: 80.2707},
		{Name: "Hyderabad", State: "Telangana", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 17.3850, Longitude: 78.4867},
		{Name: "Kolkata", State: "West Bengal", CountryID: india.ID, IsHub: true, IsPortCity: true, Latitude: 22.5726, Longitude: 88.3639},
		{Name: "Pune", State: "Maharashtra", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 18.5204, Longitude: 73.8567},
		{Name: "Ahmedabad", State: "Gujarat", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 23.0225, Longitude: 72.5714},
		{Name: "Jaipur", State: "Rajasthan", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 26.9124, Longitude: 75.7873},
		{Name: "Surat", State: "Gujarat", CountryID: india.ID, IsHub: false, IsPortCity: true, Latitude: 21.1702, Longitude: 72.8311},
		{Name: "Lucknow", State: "Uttar Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 26.8467, Longitude: 80.9462},
		{Name: "Nagpur", State: "Maharashtra", CountryID: india.ID, IsHub: true, IsPortCity: false, Latitude: 21.1458, Longitude: 79.0882},
		{Name: "Indore", State: "Madhya Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 22.7196, Longitude: 75.8577},
		{Name: "Bhopal", State: "Madhya Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 23.2599, Longitude: 77.4126},
		{Name: "Visakhapatnam", State: "Andhra Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: true, Latitude: 17.6868, Longitude: 83.2185},
		{Name: "Vadodara", State: "Gujarat", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 22.3072, Longitude: 73.1812},
		{Name: "Ludhiana", State: "Punjab", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 30.9010, Longitude: 75.8573},
		{Name: "Agra", State: "Uttar Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 27.1767, Longitude: 78.0081},
		{Name: "Nashik", State: "Maharashtra", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 19.9975, Longitude: 73.7898},
		{Name: "Rajkot", State: "Gujarat", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 22.3039, Longitude: 70.8022},
		{Name: "Varanasi", State: "Uttar Pradesh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 25.3176, Longitude: 82.9739},
		{Name: "Patna", State: "Bihar", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 25.5941, Longitude: 85.1376},
		{Name: "Chandigarh", State: "Chandigarh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 30.7333, Longitude: 76.7794},
		{Name: "Kochi", State: "Kerala", CountryID: india.ID, IsHub: true, IsPortCity: true, Latitude: 9.9312, Longitude: 76.2673},
		{Name: "Coimbatore", State: "Tamil Nadu", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 11.0168, Longitude: 76.9558},
		{Name: "Bhubaneswar", State: "Odisha", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 20.2961, Longitude: 85.8245},
		{Name: "Ranchi", State: "Jharkhand", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 23.3441, Longitude: 85.3096},
		{Name: "Guwahati", State: "Assam", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 26.1445, Longitude: 91.7362},
		{Name: "Amritsar", State: "Punjab", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 31.6340, Longitude: 74.8723},
		{Name: "Thiruvananthapuram", State: "Kerala", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 8.5241, Longitude: 76.9366},
		{Name: "Madurai", State: "Tamil Nadu", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 9.9252, Longitude: 78.1198},
		{Name: "Raipur", State: "Chhattisgarh", CountryID: india.ID, IsHub: false, IsPortCity: false, Latitude: 21.2514, Longitude: 81.6296},
		{Name: "Goa", State: "Goa", CountryID: india.ID, IsHub: false, IsPortCity: true, Latitude: 15.2993, Longitude: 74.1240},
	}
	for i := range cities {
		db.Where(master.City{Name: cities[i].Name, State: cities[i].State, CountryID: india.ID}).
			FirstOrCreate(&cities[i])
	}
}

func seedPorts(db *gorm.DB) {
	var india master.Country
	if err := db.Where("code = ?", "IN").First(&india).Error; err != nil {
		return
	}
	ports := []master.Port{
		{Name: "Jawaharlal Nehru Port (JNPT)", Code: "INJNP", CountryID: india.ID, Type: "sea"},
		{Name: "Chennai Port", Code: "INMAA", CountryID: india.ID, Type: "sea"},
		{Name: "Kolkata Port", Code: "INCCU", CountryID: india.ID, Type: "sea"},
		{Name: "Mundra Port", Code: "INMUN", CountryID: india.ID, Type: "sea"},
		{Name: "Visakhapatnam Port", Code: "INVTZ", CountryID: india.ID, Type: "sea"},
		{Name: "Kochi Port", Code: "INCOK", CountryID: india.ID, Type: "sea"},
		{Name: "Chhatrapati Shivaji Airport (BOM)", Code: "INBOM", CountryID: india.ID, Type: "air"},
		{Name: "Indira Gandhi International Airport (DEL)", Code: "INDEL", CountryID: india.ID, Type: "air"},
		{Name: "Kempegowda International Airport (BLR)", Code: "INBLR", CountryID: india.ID, Type: "air"},
		{Name: "Chennai International Airport (MAA)", Code: "INMAA2", CountryID: india.ID, Type: "air"},
		{Name: "Hyderabad Rajiv Gandhi Airport (HYD)", Code: "INHYD", CountryID: india.ID, Type: "air"},
		{Name: "Netaji Subhas Chandra Bose Airport (CCU)", Code: "INCCU2", CountryID: india.ID, Type: "air"},
	}

	var uae master.Country
	db.Where("code = ?", "AE").First(&uae)
	if uae.ID > 0 {
		ports = append(ports,
			master.Port{Name: "Jebel Ali Port", Code: "AEJEA", CountryID: uae.ID, Type: "sea"},
			master.Port{Name: "Dubai International Airport", Code: "AEDXB", CountryID: uae.ID, Type: "air"},
		)
	}

	for i := range ports {
		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&ports[i])
	}
}

func seedHSNCodes(db *gorm.DB) {
	rows := []master.HSNCode{
		{Code: "7208", Description: "Flat-rolled products of iron or non-alloy steel", Chapter: "72", UnitOfMeasure: "Tonnes"},
		{Code: "7403", Description: "Refined copper and copper alloys, unwrought", Chapter: "74", UnitOfMeasure: "Tonnes"},
		{Code: "8471", Description: "Automatic data processing machines and units", Chapter: "84", UnitOfMeasure: "Units"},
		{Code: "8517", Description: "Telephone sets including smartphones", Chapter: "85", UnitOfMeasure: "Units"},
		{Code: "9403", Description: "Furniture and parts thereof", Chapter: "94", UnitOfMeasure: "Units"},
		{Code: "3004", Description: "Medicaments for therapeutic or prophylactic use", Chapter: "30", UnitOfMeasure: "Kg"},
		{Code: "2710", Description: "Petroleum oils and oils obtained from bituminous materials", Chapter: "27", UnitOfMeasure: "KL"},
		{Code: "5208", Description: "Woven fabrics of cotton", Chapter: "52", UnitOfMeasure: "Metres"},
		{Code: "6203", Description: "Men's suits, jackets, trousers", Chapter: "62", UnitOfMeasure: "Units"},
		{Code: "0901", Description: "Coffee, whether or not roasted or decaffeinated", Chapter: "09", UnitOfMeasure: "Kg"},
		{Code: "1006", Description: "Rice", Chapter: "10", UnitOfMeasure: "Tonnes"},
		{Code: "1001", Description: "Wheat and meslin", Chapter: "10", UnitOfMeasure: "Tonnes"},
		{Code: "2523", Description: "Portland cement, aluminous cement", Chapter: "25", UnitOfMeasure: "Tonnes"},
		{Code: "8703", Description: "Motor cars and other motor vehicles", Chapter: "87", UnitOfMeasure: "Units"},
		{Code: "8800", Description: "Aircraft, spacecraft and parts thereof", Chapter: "88", UnitOfMeasure: "Units"},
		{Code: "7113", Description: "Jewellery and parts thereof, of precious metal", Chapter: "71", UnitOfMeasure: "Grams"},
		{Code: "2902", Description: "Cyclic hydrocarbons (Chemicals)", Chapter: "29", UnitOfMeasure: "Kg"},
		{Code: "0401", Description: "Milk and cream, not concentrated", Chapter: "04", UnitOfMeasure: "Litres"},
		{Code: "0602", Description: "Other live plants, including trees", Chapter: "06", UnitOfMeasure: "Units"},
		{Code: "4901", Description: "Printed books, brochures and similar printed matter", Chapter: "49", UnitOfMeasure: "Units"},
	}
	for i := range rows {
		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&rows[i])
	}
}

func seedPricingRules(db *gorm.DB) {
	rows := []master.PricingRule{
		{Name: "Road Domestic — Base", BaseRate: 99, PerKgRate: 5, PerCbmRate: 500, MinCharge: 99, SurchargePct: 8},
		{Name: "Air Domestic — Base", BaseRate: 999, PerKgRate: 180, PerCbmRate: 0, MinCharge: 999, SurchargePct: 8},
		{Name: "Sea Export — Base", BaseRate: 5000, PerKgRate: 12, PerCbmRate: 10000, MinCharge: 5000, SurchargePct: 8},
		{Name: "Rail Domestic — Base", BaseRate: 500, PerKgRate: 2, PerCbmRate: 200, MinCharge: 500, SurchargePct: 5},
	}
	for i := range rows {
		db.Where(master.PricingRule{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedFuelRates(db *gorm.DB) {
	rows := []master.FuelRate{
		{FuelType: "diesel", PricePerLtr: 89.62, EffectiveOn: "2024-01-01", State: "Maharashtra"},
		{FuelType: "petrol", PricePerLtr: 104.21, EffectiveOn: "2024-01-01", State: "Maharashtra"},
		{FuelType: "cng", PricePerLtr: 72.50, EffectiveOn: "2024-01-01", State: "Maharashtra"},
		{FuelType: "diesel", PricePerLtr: 87.62, EffectiveOn: "2024-01-01", State: "Delhi"},
		{FuelType: "petrol", PricePerLtr: 94.72, EffectiveOn: "2024-01-01", State: "Delhi"},
	}
	for i := range rows {
		db.Where(master.FuelRate{FuelType: rows[i].FuelType, State: rows[i].State}).FirstOrCreate(&rows[i])
	}
}

func seedInsuranceRates(db *gorm.DB) {
	rows := []master.InsuranceRate{
		{CategoryName: "General", RatePct: 0.5, MinPremium: 50, MaxCoverage: 500000},
		{CategoryName: "Electronics", RatePct: 0.8, MinPremium: 100, MaxCoverage: 1000000},
		{CategoryName: "High Value Goods", RatePct: 1.0, MinPremium: 250, MaxCoverage: 5000000},
		{CategoryName: "Hazardous Goods", RatePct: 1.5, MinPremium: 500, MaxCoverage: 2000000},
		{CategoryName: "Fragile Goods", RatePct: 0.8, MinPremium: 100, MaxCoverage: 500000},
		{CategoryName: "Perishables", RatePct: 0.6, MinPremium: 75, MaxCoverage: 200000},
	}
	for i := range rows {
		db.Where(master.InsuranceRate{CategoryName: rows[i].CategoryName}).FirstOrCreate(&rows[i])
	}
}
