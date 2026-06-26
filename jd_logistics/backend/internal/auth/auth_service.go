package auth

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	mathrand "math/rand"
	"time"

	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	"jd_logistics/config"
	"jd_logistics/utils"
)

// Service handles all authentication operations.
type Service struct {
	db  *gorm.DB
	rdb *redis.Client
	cfg *config.Config
}

// NewService creates an auth Service.
func NewService(db *gorm.DB, rdb *redis.Client, cfg *config.Config) *Service {
	return &Service{db: db, rdb: rdb, cfg: cfg}
}

// SendOTP generates and stores a 6-digit OTP for the given phone number.
func (s *Service) SendOTP(phone string) error {
	if !utils.ValidatePhone(phone) {
		return errors.New("invalid phone number")
	}

	otp := fmt.Sprintf("%06d", mathrand.Intn(1000000))

	ctx := context.Background()
	key := "otp:" + phone
	if err := s.rdb.Set(ctx, key, otp, time.Duration(s.cfg.OTPExpiry)*time.Second).Err(); err != nil {
		// Redis unavailable: fallback to DB
		s.db.Where("phone = ? AND used = false", phone).Delete(&OTPRecord{})
		record := OTPRecord{
			Phone:     phone,
			OTP:       otp,
			ExpiresAt: time.Now().Add(time.Duration(s.cfg.OTPExpiry) * time.Second),
		}
		s.db.Create(&record)
	}

	// TODO: integrate SMS provider (MSG91 / Fast2SMS / Twilio)
	fmt.Printf("[DEV] OTP for %s: %s\n", phone, otp)
	return nil
}

// VerifyOTP validates the OTP and returns the user + tokens.
func (s *Service) VerifyOTP(phone, otp string) (*User, string, string, error) {
	if !utils.ValidatePhone(phone) {
		return nil, "", "", errors.New("invalid phone number")
	}
	if !utils.ValidateOTP(otp) {
		return nil, "", "", errors.New("invalid OTP format")
	}

	ctx := context.Background()
	key := "otp:" + phone

	stored, err := s.rdb.Get(ctx, key).Result()
	if err != nil {
		// Fallback to DB OTP
		var record OTPRecord
		if dbErr := s.db.Where("phone = ? AND used = false AND expires_at > ?", phone, time.Now()).
			Order("created_at desc").First(&record).Error; dbErr != nil {
			return nil, "", "", errors.New("OTP not found or expired")
		}
		if record.OTP != otp {
			return nil, "", "", errors.New("incorrect OTP")
		}
		s.db.Model(&record).Update("used", true)
	} else {
		if stored != otp {
			return nil, "", "", errors.New("incorrect OTP")
		}
		s.rdb.Del(ctx, key)
	}

	var user User
	result := s.db.Where("phone = ?", phone).First(&user)
	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		user = User{Phone: phone}
		s.db.Create(&user)
	}

	now := time.Now()
	s.db.Model(&user).Update("last_login", now)

	accessToken, err := utils.GenerateToken(fmt.Sprint(user.ID), user.Role, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", err
	}

	refreshToken, err := s.issueRefreshToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	return &user, accessToken, refreshToken, nil
}

// SetupProfile updates the user's name and email.
func (s *Service) SetupProfile(userID uint, name, email string) (*User, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, errors.New("user not found")
	}
	s.db.Model(&user).Updates(User{Name: name, Email: email})
	return &user, nil
}

// SelectRole updates the user's role and issues new tokens.
func (s *Service) SelectRole(userID uint, role string) (*User, string, string, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, "", "", errors.New("user not found")
	}
	s.db.Model(&user).Update("role", role)
	user.Role = role

	accessToken, err := utils.GenerateToken(fmt.Sprint(user.ID), role, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", err
	}

	refreshToken, err := s.issueRefreshToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	return &user, accessToken, refreshToken, nil
}

// GetProfile returns the user record.
func (s *Service) GetProfile(userID uint) (*User, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, errors.New("user not found")
	}
	return &user, nil
}

// RefreshAccessToken validates a refresh token and issues a new access token.
func (s *Service) RefreshAccessToken(refreshTokenStr string) (*User, string, string, error) {
	var rt RefreshToken
	if err := s.db.Where("token = ? AND used = false AND expires_at > ?", refreshTokenStr, time.Now()).
		First(&rt).Error; err != nil {
		return nil, "", "", errors.New("invalid or expired refresh token")
	}

	var user User
	if err := s.db.First(&user, rt.UserID).Error; err != nil {
		return nil, "", "", errors.New("user not found")
	}

	// Rotate: mark old token used
	s.db.Model(&rt).Update("used", true)

	accessToken, err := utils.GenerateToken(fmt.Sprint(user.ID), user.Role, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", "", err
	}

	newRefresh, err := s.issueRefreshToken(user.ID)
	if err != nil {
		return nil, "", "", err
	}

	return &user, accessToken, newRefresh, nil
}

// Logout invalidates the given refresh token.
func (s *Service) Logout(refreshTokenStr string) {
	s.db.Where("token = ?", refreshTokenStr).Delete(&RefreshToken{})
}

// ── helpers ───────────────────────────────────────────────────────────────────

func (s *Service) issueRefreshToken(userID uint) (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	token := hex.EncodeToString(b)

	rt := RefreshToken{
		UserID:    userID,
		Token:     token,
		ExpiresAt: time.Now().Add(30 * 24 * time.Hour),
	}
	if err := s.db.Create(&rt).Error; err != nil {
		return "", err
	}
	return token, nil
}
