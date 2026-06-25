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
	log.Println("Master data seeded")
}

func seedRoles(db *gorm.DB) {
	rows := []master.Role{
		{Name: "customer",   Description: "End customer booking shipments"},
		{Name: "driver",     Description: "Delivery / transport driver"},
		{Name: "warehouse",  Description: "Warehouse operator"},
		{Name: "admin",      Description: "Platform administrator"},
		{Name: "superadmin", Description: "Super administrator with full access"},
	}
	for i := range rows {
		db.Where(master.Role{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedTransportModes(db *gorm.DB) {
	rows := []master.TransportMode{
		{Name: "road",  Description: "Road / truck transport",  IconCode: "local_shipping"},
		{Name: "air",   Description: "Air cargo",              IconCode: "flight"},
		{Name: "ocean", Description: "Ocean / sea freight",    IconCode: "directions_boat"},
		{Name: "rail",  Description: "Rail / train transport", IconCode: "train"},
	}
	for i := range rows {
		db.Where(master.TransportMode{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedShipmentStatuses(db *gorm.DB) {
	rows := []master.ShipmentStatus{
		{Code: "draft",             Label: "Draft",             Sequence: 0,  Color: "#9E9E9E", IsTerminal: false},
		{Code: "booked",            Label: "Booked",            Sequence: 1,  Color: "#2196F3", IsTerminal: false},
		{Code: "pickup_scheduled",  Label: "Pickup Scheduled",  Sequence: 2,  Color: "#03A9F4", IsTerminal: false},
		{Code: "picked_up",         Label: "Picked Up",         Sequence: 3,  Color: "#00BCD4", IsTerminal: false},
		{Code: "at_warehouse",      Label: "At Warehouse",      Sequence: 4,  Color: "#009688", IsTerminal: false},
		{Code: "in_transit",        Label: "In Transit",        Sequence: 5,  Color: "#FF9800", IsTerminal: false},
		{Code: "customs_clearance", Label: "Customs Clearance", Sequence: 5,  Color: "#9C27B0", IsTerminal: false},
		{Code: "out_for_delivery",  Label: "Out for Delivery",  Sequence: 6,  Color: "#FF5722", IsTerminal: false},
		{Code: "delivered",         Label: "Delivered",         Sequence: 7,  Color: "#4CAF50", IsTerminal: true},
		{Code: "delayed",           Label: "Delayed",           Sequence: 0,  Color: "#F44336", IsTerminal: false},
		{Code: "cancelled",         Label: "Cancelled",         Sequence: 0,  Color: "#607D8B", IsTerminal: true},
		{Code: "returned",          Label: "Returned",          Sequence: 0,  Color: "#795548", IsTerminal: true},
	}
	for i := range rows {
		db.Where(master.ShipmentStatus{Code: rows[i].Code}).FirstOrCreate(&rows[i])
	}
}

func seedPaymentMethods(db *gorm.DB) {
	rows := []master.PaymentMethod{
		{Code: "upi",          Label: "UPI"},
		{Code: "card",         Label: "Credit / Debit Card"},
		{Code: "net_banking",  Label: "Net Banking"},
		{Code: "wallet",       Label: "JD Wallet"},
		{Code: "obc",          Label: "OBC Points"},
		{Code: "cod",          Label: "Cash on Delivery"},
		{Code: "pay_later",    Label: "Pay Later"},
		{Code: "bank_transfer",Label: "Bank Transfer (NEFT/RTGS)"},
	}
	for i := range rows {
		db.Where(master.PaymentMethod{Code: rows[i].Code}).FirstOrCreate(&rows[i])
	}
}

func seedGoodsCategories(db *gorm.DB) {
	rows := []master.GoodsCategory{
		{Name: "Documents",           RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Electronics",         RiskLevel: "medium", RequiresSpecialHandling: true,  RequiresInsurance: true},
		{Name: "Clothing & Apparel",  RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Food & Perishables",  RiskLevel: "high",   RequiresSpecialHandling: true,  RequiresInsurance: false},
		{Name: "Furniture",           RiskLevel: "medium", RequiresSpecialHandling: true,  RequiresInsurance: false},
		{Name: "Automotive Parts",    RiskLevel: "medium", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Medical Supplies",    RiskLevel: "high",   RequiresSpecialHandling: true,  RequiresInsurance: true},
		{Name: "Industrial Goods",    RiskLevel: "medium", RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Hazardous Materials", RiskLevel: "high",   RequiresSpecialHandling: true,  RequiresInsurance: true},
		{Name: "Jewelry & Valuables", RiskLevel: "high",   RequiresSpecialHandling: true,  RequiresInsurance: true},
		{Name: "Books & Stationery",  RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Toys & Games",        RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Sports Equipment",    RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
		{Name: "Agriculture",         RiskLevel: "medium", RequiresSpecialHandling: true,  RequiresInsurance: false},
		{Name: "Chemicals",           RiskLevel: "high",   RequiresSpecialHandling: true,  RequiresInsurance: true},
		{Name: "General Merchandise", RiskLevel: "low",    RequiresSpecialHandling: false, RequiresInsurance: false},
	}
	for i := range rows {
		db.Where(master.GoodsCategory{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedVehicleTypes(db *gorm.DB) {
	rows := []master.VehicleType{
		{Name: "Bike",            CapacityKg: 20,    VolumeCbm: 0.1,  Description: "Two-wheeler for small parcels"},
		{Name: "Auto Rickshaw",   CapacityKg: 150,   VolumeCbm: 0.5,  Description: "Three-wheeler for small loads"},
		{Name: "Tempo",           CapacityKg: 750,   VolumeCbm: 3.5,  Description: "Mini truck (Tata Ace)"},
		{Name: "Van",             CapacityKg: 1500,  VolumeCbm: 7.0,  Description: "Cargo van"},
		{Name: "Truck (Small)",   CapacityKg: 5000,  VolumeCbm: 20.0, Description: "Small truck (LCV)"},
		{Name: "Truck (Medium)",  CapacityKg: 12000, VolumeCbm: 50.0, Description: "Medium truck (MCV)"},
		{Name: "Truck (Large)",   CapacityKg: 25000, VolumeCbm: 80.0, Description: "Large truck (HCV)"},
		{Name: "Container 20ft",  CapacityKg: 28000, VolumeCbm: 33.2, Description: "20ft ISO container"},
		{Name: "Container 40ft",  CapacityKg: 28000, VolumeCbm: 67.7, Description: "40ft ISO container"},
	}
	for i := range rows {
		db.Where(master.VehicleType{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedWarehouseTypes(db *gorm.DB) {
	rows := []master.WarehouseType{
		{Name: "General",       Description: "General purpose warehouse"},
		{Name: "Cold Storage",  Description: "Temperature-controlled for perishables"},
		{Name: "Bonded",        Description: "Customs bonded warehouse"},
		{Name: "Distribution",  Description: "Distribution / fulfillment center"},
		{Name: "Hazmat",        Description: "Hazardous materials storage"},
		{Name: "Port Facility", Description: "Port / terminal warehouse"},
	}
	for i := range rows {
		db.Where(master.WarehouseType{Name: rows[i].Name}).FirstOrCreate(&rows[i])
	}
}

func seedGSTRates(db *gorm.DB) {
	rows := []master.GSTRate{
		{CategoryName: "Exempt", Rate: 0,  Description: "GST exempt goods and services"},
		{CategoryName: "5% GST", Rate: 5,  Description: "Essential goods and services"},
		{CategoryName: "12% GST",Rate: 12, Description: "Standard goods and services"},
		{CategoryName: "18% GST",Rate: 18, Description: "Transport and logistics services"},
		{CategoryName: "28% GST",Rate: 28, Description: "Luxury goods"},
	}
	for i := range rows {
		db.Where(master.GSTRate{CategoryName: rows[i].CategoryName}).FirstOrCreate(&rows[i])
	}
}

func seedCountries(db *gorm.DB) {
	rows := []master.Country{
		{Name: "India",                Code: "IN",  PhoneCode: "+91",  Currency: "INR"},
		{Name: "United Arab Emirates", Code: "AE",  PhoneCode: "+971", Currency: "AED"},
		{Name: "United States",        Code: "US",  PhoneCode: "+1",   Currency: "USD"},
		{Name: "United Kingdom",       Code: "GB",  PhoneCode: "+44",  Currency: "GBP"},
		{Name: "Singapore",            Code: "SG",  PhoneCode: "+65",  Currency: "SGD"},
		{Name: "China",                Code: "CN",  PhoneCode: "+86",  Currency: "CNY"},
		{Name: "Germany",              Code: "DE",  PhoneCode: "+49",  Currency: "EUR"},
		{Name: "Japan",                Code: "JP",  PhoneCode: "+81",  Currency: "JPY"},
		{Name: "Australia",            Code: "AU",  PhoneCode: "+61",  Currency: "AUD"},
		{Name: "Canada",               Code: "CA",  PhoneCode: "+1",   Currency: "CAD"},
		{Name: "Netherlands",          Code: "NL",  PhoneCode: "+31",  Currency: "EUR"},
		{Name: "Malaysia",             Code: "MY",  PhoneCode: "+60",  Currency: "MYR"},
		{Name: "Sri Lanka",            Code: "LK",  PhoneCode: "+94",  Currency: "LKR"},
		{Name: "Bangladesh",           Code: "BD",  PhoneCode: "+880", Currency: "BDT"},
		{Name: "Nepal",                Code: "NP",  PhoneCode: "+977", Currency: "NPR"},
	}
	for i := range rows {
		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&rows[i])
	}
}
