package auth

import (
	"time"

	"jd_logistics/utils"
)

// User is the platform-wide user record.
type User struct {
	utils.Model
	Phone     string     `gorm:"uniqueIndex;not null" json:"phone"`
	Name      string     `json:"name"`
	Email     string     `json:"email"`
	Role      string     `gorm:"default:'customer'" json:"role"`
	AvatarURL string     `json:"avatar_url"`
	IsActive  bool       `gorm:"default:true" json:"is_active"`
	LastLogin *time.Time `json:"last_login"`
}

func (User) TableName() string { return "jd_logistics.users" }

// OTPRecord stores OTPs when Redis is unavailable.
type OTPRecord struct {
	utils.Model
	Phone     string    `gorm:"index;not null" json:"phone"`
	OTP       string    `gorm:"not null" json:"otp"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
	Used      bool      `gorm:"default:false" json:"used"`
}

func (OTPRecord) TableName() string { return "jd_logistics.otp_records" }

// RefreshToken stores long-lived refresh tokens for silent re-auth.
type RefreshToken struct {
	utils.Model
	UserID    uint      `gorm:"not null;index" json:"user_id"`
	Token     string    `gorm:"uniqueIndex;not null" json:"token"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
	Used      bool      `gorm:"default:false" json:"used"`
}

func (RefreshToken) TableName() string { return "jd_logistics.refresh_tokens" }

// ── Request / Response DTOs ──────────────────────────────────────────────────

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

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

type AuthResponse struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refresh_token,omitempty"`
	User         *User  `json:"user"`
}
