package auth

import (
	"time"

	"jd_logistics/utils"
)

type User struct {
	utils.Model
	Phone     string     `gorm:"uniqueIndex;not null" json:"phone"`
	Name      string     `json:"name"`
	Email     string     `json:"email"`
	Role      string     `gorm:"default:customer" json:"role"`
	AvatarURL string     `json:"avatar_url"`
	IsActive  bool       `gorm:"default:true" json:"is_active"`
	LastLogin *time.Time `json:"last_login"`
}

type OTPRecord struct {
	utils.Model
	Phone     string    `gorm:"index;not null"`
	OTP       string    `gorm:"not null"`
	ExpiresAt time.Time `gorm:"not null"`
	Used      bool      `gorm:"default:false"`
}

type SendOTPRequest struct {
	Phone string `json:"phone" binding:"required"`
}

type VerifyOTPRequest struct {
	Phone string `json:"phone" binding:"required"`
	OTP   string `json:"otp" binding:"required,len=6"`
}

type SetupProfileRequest struct {
	Name  string `json:"name" binding:"required"`
	Email string `json:"email"`
}

type SelectRoleRequest struct {
	Role string `json:"role" binding:"required,oneof=customer driver warehouse admin"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  *User  `json:"user"`
}
