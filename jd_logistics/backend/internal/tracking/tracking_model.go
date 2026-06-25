package tracking

import "jd_logistics/utils"

type TrackingEvent struct {
	utils.Model
	ShipmentID uint    `gorm:"not null;index" json:"shipment_id"`
	Status     string  `gorm:"not null" json:"status"`
	Location   string  `json:"location"`
	Latitude   float64 `json:"latitude"`
	Longitude  float64 `json:"longitude"`
	Note       string  `json:"note"`
	ActorID    uint    `gorm:"index" json:"actor_id"`
	ActorRole  string  `json:"actor_role"`
}

func (TrackingEvent) TableName() string { return "jd_logistics.tracking_events" }

type AddEventRequest struct {
	ShipmentID uint    `json:"shipment_id" binding:"required"`
	Status     string  `json:"status" binding:"required"`
	Location   string  `json:"location"`
	Latitude   float64 `json:"latitude"`
	Longitude  float64 `json:"longitude"`
	Note       string  `json:"note"`
}
