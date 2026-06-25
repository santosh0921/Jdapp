package users

import "gorm.io/gorm"

type Profile struct {
	gorm.Model
	UserID    uint   `gorm:"uniqueIndex;not null" json:"user_id"`
	Address   string `json:"address"`
	City      string `json:"city"`
	PinCode   string `json:"pin_code"`
	State     string `json:"state"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type UpdateProfileRequest struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Address string `json:"address"`
	City    string `json:"city"`
	PinCode string `json:"pin_code"`
	State   string `json:"state"`
}
