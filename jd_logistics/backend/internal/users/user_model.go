package users

import "jd_logistics/utils"

type Profile struct {
	utils.Model
	UserID    uint    `gorm:"uniqueIndex;not null" json:"user_id"`
	Address   string  `json:"address"`
	City      string  `json:"city"`
	PinCode   string  `json:"pin_code"`
	State     string  `json:"state"`
	Country   string  `gorm:"default:'India'" json:"country"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

func (Profile) TableName() string { return "jd_logistics.profiles" }

type UpdateProfileRequest struct {
	Name      string  `json:"name"`
	Email     string  `json:"email"`
	Address   string  `json:"address"`
	City      string  `json:"city"`
	PinCode   string  `json:"pin_code"`
	State     string  `json:"state"`
	Country   string  `json:"country"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}
