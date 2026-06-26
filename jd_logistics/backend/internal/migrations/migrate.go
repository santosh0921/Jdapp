package migrations

import (
	"fmt"
	"log"

	"gorm.io/gorm"

	"jd_logistics/internal/admin"
	"jd_logistics/internal/auth"
	"jd_logistics/internal/driver"
	"jd_logistics/internal/fleet"
	"jd_logistics/internal/master"
	"jd_logistics/internal/notifications"
	"jd_logistics/internal/payments"
	"jd_logistics/internal/shipments"
	"jd_logistics/internal/tracking"
	"jd_logistics/internal/users"
	"jd_logistics/internal/warehouse"
)

// Run executes all migrations idempotently.
// AutoMigrate only creates missing tables / columns — never drops anything.
func Run(db *gorm.DB) error {
	log.Println("Running database migrations...")

	if err := db.Exec("CREATE SCHEMA IF NOT EXISTS jd_logistics").Error; err != nil {
		return fmt.Errorf("schema creation: %w", err)
	}

	err := db.AutoMigrate(
		// ── Master / Reference Data ──────────────────────────────────────────
		&master.Role{},
		&master.GoodsCategory{},
		&master.VehicleType{},
		&master.Country{},
		&master.State{},
		&master.City{},
		&master.Port{},
		&master.TransportMode{},
		&master.ShipmentStatus{},
		&master.PaymentMethod{},
		&master.WarehouseType{},
		&master.GSTRate{},
		&master.HSNCode{},
		&master.PricingRule{},
		&master.FuelRate{},
		&master.InsuranceRate{},

		// ── Auth & Users ─────────────────────────────────────────────────────
		&auth.User{},
		&auth.OTPRecord{},
		&auth.RefreshToken{},
		&users.Profile{},

		// ── Shipments ────────────────────────────────────────────────────────
		&shipments.Shipment{},
		&shipments.CourierOrder{},
		&shipments.LogisticsOrder{},
		&shipments.Container{},
		&shipments.Document{},

		// ── Tracking ─────────────────────────────────────────────────────────
		&tracking.TrackingEvent{},

		// ── Driver ───────────────────────────────────────────────────────────
		&driver.DriverProfile{},
		&driver.Vehicle{},
		&driver.DriverWallet{},
		&driver.EarningRecord{},

		// ── Fleet ────────────────────────────────────────────────────────────
		&fleet.VehicleMaintenance{},
		&fleet.VehicleDocument{},

		// ── Warehouse ────────────────────────────────────────────────────────
		&warehouse.Warehouse{},
		&warehouse.WarehouseProfile{},

		// ── Payments ─────────────────────────────────────────────────────────
		&payments.Transaction{},
		&payments.WalletBalance{},

		// ── Notifications ─────────────────────────────────────────────────────
		&notifications.Notification{},

		// ── Admin / Audit ─────────────────────────────────────────────────────
		&admin.AuditLog{},
		&admin.Report{},
	)
	if err != nil {
		return fmt.Errorf("auto migrate: %w", err)
	}

	log.Println("Migrations completed successfully")
	return nil
}
