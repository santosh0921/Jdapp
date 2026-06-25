package auth

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	"jd_logistics/config"
	"jd_logistics/utils"
)

type Service struct {
	db  *gorm.DB
	rdb *redis.Client
	cfg *config.Config
}

func NewService(db *gorm.DB, rdb *redis.Client, cfg *config.Config) *Service {
	return &Service{db: db, rdb: rdb, cfg: cfg}
}

func (s *Service) SendOTP(phone string) error {
	if !utils.ValidatePhone(phone) {
		return errors.New("invalid phone number")
	}

	otp := fmt.Sprintf("%06d", rand.Intn(1000000))

	// Store OTP in Redis with expiry
	key := "otp:" + phone
	ctx := context.Background()
	if err := s.rdb.Set(ctx, key, otp, time.Duration(s.cfg.OTPExpiry)*time.Second).Err(); err != nil {
		// Fallback: store in DB
		s.db.Where("phone = ? AND used = false", phone).Delete(&OTPRecord{})
		record := OTPRecord{
			Phone:     phone,
			OTP:       otp,
			ExpiresAt: time.Now().Add(time.Duration(s.cfg.OTPExpiry) * time.Second),
		}
		s.db.Create(&record)
	}

	// TODO: integrate SMS provider (Twilio / MSG91 / Fast2SMS)
	fmt.Printf("[DEV] OTP for %s: %s\n", phone, otp)
	return nil
}

func (s *Service) VerifyOTP(phone, otp string) (*User, string, error) {
	if !utils.ValidatePhone(phone) {
		return nil, "", errors.New("invalid phone number")
	}
	if !utils.ValidateOTP(otp) {
		return nil, "", errors.New("invalid OTP format")
	}

	ctx := context.Background()
	key := "otp:" + phone

	stored, err := s.rdb.Get(ctx, key).Result()
	if err != nil {
		// Fallback: check DB
		var record OTPRecord
		if dbErr := s.db.Where("phone = ? AND used = false AND expires_at > ?", phone, time.Now()).
			Order("created_at desc").First(&record).Error; dbErr != nil {
			return nil, "", errors.New("OTP not found or expired")
		}
		if record.OTP != otp {
			return nil, "", errors.New("incorrect OTP")
		}
		s.db.Model(&record).Update("used", true)
	} else {
		if stored != otp {
			return nil, "", errors.New("incorrect OTP")
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

	token, err := utils.GenerateToken(fmt.Sprint(user.ID), user.Role, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", err
	}

	return &user, token, nil
}

func (s *Service) SetupProfile(userID uint, name, email string) (*User, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, errors.New("user not found")
	}
	s.db.Model(&user).Updates(User{Name: name, Email: email})
	return &user, nil
}

func (s *Service) SelectRole(userID uint, role string) (*User, string, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, "", errors.New("user not found")
	}
	s.db.Model(&user).Update("role", role)
	user.Role = role

	token, err := utils.GenerateToken(fmt.Sprint(user.ID), role, s.cfg.JWTSecret)
	if err != nil {
		return nil, "", err
	}
	return &user, token, nil
}

func (s *Service) GetProfile(userID uint) (*User, error) {
	var user User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, errors.New("user not found")
	}
	return &user, nil
}
