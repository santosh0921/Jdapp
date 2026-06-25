package users

import (
	"errors"

	"gorm.io/gorm"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetProfile(userID uint) (*Profile, error) {
	var p Profile
	if err := s.db.Where("user_id = ?", userID).First(&p).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			p = Profile{UserID: userID}
			s.db.Create(&p)
			return &p, nil
		}
		return nil, err
	}
	return &p, nil
}

func (s *Service) UpdateProfile(userID uint, req UpdateProfileRequest) (*Profile, error) {
	var p Profile
	s.db.Where("user_id = ?", userID).FirstOrCreate(&p, Profile{UserID: userID})
	s.db.Model(&p).Updates(map[string]interface{}{
		"address":  req.Address,
		"city":     req.City,
		"pin_code": req.PinCode,
		"state":    req.State,
	})
	return &p, nil
}
