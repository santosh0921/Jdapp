package notifications

import "gorm.io/gorm"

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetForUser(userID uint) ([]Notification, error) {
	var list []Notification
	s.db.Where("user_id = ?", userID).Order("created_at desc").Limit(50).Find(&list)
	return list, nil
}

func (s *Service) MarkAllRead(userID uint) error {
	return s.db.Model(&Notification{}).Where("user_id = ? AND is_read = false", userID).
		Update("is_read", true).Error
}

func (s *Service) MarkRead(id uint) error {
	return s.db.Model(&Notification{}).Where("id = ?", id).Update("is_read", true).Error
}

func (s *Service) Push(req PushRequest) (*Notification, error) {
	n := Notification{
		UserID: req.UserID,
		Title:  req.Title,
		Body:   req.Body,
		Type:   req.Type,
	}
	// TODO: send via FCM / APNs
	if err := s.db.Create(&n).Error; err != nil {
		return nil, err
	}
	return &n, nil
}
