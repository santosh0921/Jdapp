package tracking

import "gorm.io/gorm"

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetEventsByShipmentID(shipmentID uint) ([]TrackingEvent, error) {
	var events []TrackingEvent
	s.db.Where("shipment_id = ?", shipmentID).Order("created_at asc").Find(&events)
	return events, nil
}

func (s *Service) GetEventsByTrackingID(trackingID string) ([]TrackingEvent, error) {
	type idRow struct{ ID uint }
	var sh idRow
	if err := s.db.Table("shipments").Select("id").
		Where("tracking_id = ? AND deleted_at IS NULL", trackingID).
		First(&sh).Error; err != nil {
		return nil, err
	}
	return s.GetEventsByShipmentID(sh.ID)
}

func (s *Service) AddEvent(actorID uint, actorRole string, req AddEventRequest) (*TrackingEvent, error) {
	ev := TrackingEvent{
		ShipmentID: req.ShipmentID,
		Status:     req.Status,
		Location:   req.Location,
		Latitude:   req.Latitude,
		Longitude:  req.Longitude,
		Note:       req.Note,
		ActorID:    actorID,
		ActorRole:  actorRole,
	}
	if err := s.db.Create(&ev).Error; err != nil {
		return nil, err
	}
	return &ev, nil
}
