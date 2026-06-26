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
// The OTP is only consumed AFTER user and token creation succeed in the same transaction.
func (s *Service) VerifyOTP(phone, otp string) (*User, string, string, error) {
	if !utils.ValidatePhone(phone) {
		return nil, "", "", errors.New("invalid phone number")
	}
	if !utils.ValidateOTP(otp) {
		return nil, "", "", errors.New("invalid OTP format")
	}

	phone = utils.SanitizePhone(phone)
	fmt.Printf("[AUTH] VerifyOTP: validating OTP for phone=%s\n", phone)

	ctx := context.Background()
	key := "otp:" + phone

	var useRedis bool
	var dbRecord *OTPRecord

	stored, redisErr := s.rdb.Get(ctx, key).Result()
	if redisErr == nil {
		// Redis has the OTP — validate but do NOT delete yet
		if stored != otp {
			fmt.Printf("[AUTH] VerifyOTP: incorrect OTP (Redis) for phone=%s\n", phone)
			return nil, "", "", errors.New("incorrect OTP")
		}
		useRedis = true
		fmt.Printf("[AUTH] VerifyOTP: OTP validated from Redis for phone=%s\n", phone)
	} else {
		// Redis miss — check DB
		fmt.Printf("[AUTH] VerifyOTP: Redis miss, checking DB for phone=%s\n", phone)
		var record OTPRecord
		if dbErr := s.db.Where("phone = ? AND expires_at > ?", phone, time.Now()).
			Order("created_at desc").First(&record).Error; dbErr != nil {
			return nil, "", "", errors.New("OTP not found or expired. Please request a new OTP")
		}
		if record.Used {
			fmt.Printf("[AUTH] VerifyOTP: OTP already used for phone=%s record_id=%d\n", phone, record.ID)
			return nil, "", "", errors.New("OTP already used. Please request a new OTP")
		}
		if record.OTP != otp {
			fmt.Printf("[AUTH] VerifyOTP: incorrect OTP (DB) for phone=%s\n", phone)
			return nil, "", "", errors.New("incorrect OTP")
		}
		dbRecord = &record
		fmt.Printf("[AUTH] VerifyOTP: OTP found in DB for phone=%s record_id=%d\n", phone, record.ID)
	}

	// Single atomic transaction: mark OTP used + find/create user + generate tokens.
	// If any step fails the transaction rolls back, leaving the OTP reusable.
	var user User
	var accessToken, refreshToken string

	txErr := s.db.Transaction(func(tx *gorm.DB) error {
		// Mark DB OTP used inside the transaction so rollback restores it
		if dbRecord != nil {
			fmt.Printf("[AUTH] VerifyOTP: marking OTP used in DB record_id=%d\n", dbRecord.ID)
			if err := tx.Model(dbRecord).Update("used", true).Error; err != nil {
				return fmt.Errorf("mark OTP used: %w", err)
			}
		}

		// Find or create user
		result := tx.Where("phone = ?", phone).First(&user)
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			fmt.Printf("[AUTH] VerifyOTP: creating new user for phone=%s\n", phone)
			user = User{Phone: phone}
			if err := tx.Create(&user).Error; err != nil {
				return fmt.Errorf("create user: %w", err)
			}
		} else if result.Error != nil {
			return fmt.Errorf("find user: %w", result.Error)
		} else {
			fmt.Printf("[AUTH] VerifyOTP: found existing user id=%d phone=%s\n", user.ID, phone)
		}

		// Update last_login (non-critical)
		now := time.Now()
		tx.Model(&user).Update("last_login", now)

		// Generate access token
		fmt.Printf("[AUTH] VerifyOTP: generating access token for user_id=%d role=%s\n", user.ID, user.Role)
		var err error
		accessToken, err = utils.GenerateToken(fmt.Sprint(user.ID), user.Role, s.cfg.JWTSecret)
		if err != nil {
			return fmt.Errorf("generate access token: %w", err)
		}

		// Issue refresh token inside the same transaction
		fmt.Printf("[AUTH] VerifyOTP: issuing refresh token for user_id=%d\n", user.ID)
		refreshToken, err = s.issueRefreshTokenTx(tx, user.ID)
		if err != nil {
			return fmt.Errorf("issue refresh token: %w", err)
		}

		return nil
	})

	if txErr != nil {
		fmt.Printf("[AUTH] VerifyOTP: transaction failed for phone=%s: %v\n", phone, txErr)
		return nil, "", "", txErr
	}

	// Delete Redis key only AFTER the DB transaction commits
	if useRedis {
		fmt.Printf("[AUTH] VerifyOTP: deleting Redis OTP key for phone=%s\n", phone)
		s.rdb.Del(ctx, key)
	}

	fmt.Printf("[AUTH] VerifyOTP: success user_id=%d phone=%s role=%s\n", user.ID, phone, user.Role)
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
	return s.issueRefreshTokenTx(s.db, userID)
}

// issueRefreshTokenTx creates a refresh token using the provided db handle (tx or plain db).
func (s *Service) issueRefreshTokenTx(db *gorm.DB, userID uint) (string, error) {
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
	if err := db.Create(&rt).Error; err != nil {
		return "", err
	}
	return token, nil
}
