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
// DB is always the source of truth; Redis is an optional cache.
func (s *Service) SendOTP(phone string) error {
	phone = utils.SanitizePhone(phone)
	if !utils.ValidatePhone(phone) {
		return errors.New("invalid phone number")
	}

	otp := fmt.Sprintf("%06d", mathrand.Intn(1000000))
	expiry := time.Duration(s.cfg.OTPExpiry) * time.Second

	// Invalidate any previous unused OTPs for this phone
	s.db.Where("phone = ? AND used = false", phone).Delete(&OTPRecord{})

	// Always persist to DB — this is the source of truth
	record := OTPRecord{
		Phone:     phone,
		OTP:       otp,
		ExpiresAt: time.Now().Add(expiry),
	}
	if err := s.db.Create(&record).Error; err != nil {
		return fmt.Errorf("save OTP: %w", err)
	}

	// Best-effort Redis cache — failure does NOT block OTP delivery
	ctx := context.Background()
	s.rdb.Set(ctx, "otp:"+phone, otp, expiry)

	// TODO: integrate SMS provider (MSG91 / Fast2SMS / Twilio)
	fmt.Printf("[DEV] OTP for %s: %s\n", phone, otp)
	return nil
}

// VerifyOTP validates the OTP and returns the user + tokens.
// DB is always the source of truth. OTP is only consumed after all downstream
// steps succeed inside a single transaction.
func (s *Service) VerifyOTP(phone, otp string) (*User, string, string, error) {
	phone = utils.SanitizePhone(phone)
	if !utils.ValidatePhone(phone) {
		return nil, "", "", errors.New("invalid phone number")
	}
	if !utils.ValidateOTP(otp) {
		return nil, "", "", errors.New("invalid OTP format")
	}

	fmt.Printf("[AUTH] VerifyOTP: phone=%s\n", phone)

	// DB is the source of truth — always query it regardless of Redis state
	var record OTPRecord
	if err := s.db.Where(
		"phone = ? AND otp = ? AND used = false AND expires_at > ?",
		phone, otp, time.Now(),
	).Order("created_at desc").First(&record).Error; err != nil {
		// Distinguish "already used" so the client gets a clear message
		var used OTPRecord
		if s.db.Where("phone = ? AND otp = ? AND used = true", phone, otp).
			First(&used).Error == nil {
			fmt.Printf("[AUTH] VerifyOTP: OTP already used phone=%s record_id=%d\n", phone, used.ID)
			return nil, "", "", errors.New("OTP already used. Please request a new OTP")
		}
		fmt.Printf("[AUTH] VerifyOTP: OTP not found or expired phone=%s\n", phone)
		return nil, "", "", errors.New("OTP not found or expired. Please request a new OTP")
	}
	fmt.Printf("[AUTH] VerifyOTP: OTP found in DB phone=%s record_id=%d\n", phone, record.ID)

	// Single atomic transaction: mark OTP used + find/create user + issue tokens.
	// If any step fails the transaction rolls back, leaving the OTP reusable.
	var user User
	var accessToken, refreshToken string

	txErr := s.db.Transaction(func(tx *gorm.DB) error {
		fmt.Printf("[AUTH] VerifyOTP: marking OTP used record_id=%d\n", record.ID)
		if err := tx.Model(&record).Update("used", true).Error; err != nil {
			return fmt.Errorf("mark OTP used: %w", err)
		}

		// Find or create user
		result := tx.Where("phone = ?", phone).First(&user)
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			fmt.Printf("[AUTH] VerifyOTP: creating new user phone=%s\n", phone)
			user = User{Phone: phone}
			if err := tx.Create(&user).Error; err != nil {
				return fmt.Errorf("create user: %w", err)
			}
		} else if result.Error != nil {
			return fmt.Errorf("find user: %w", result.Error)
		} else {
			fmt.Printf("[AUTH] VerifyOTP: existing user id=%d phone=%s\n", user.ID, phone)
		}

		now := time.Now()
		tx.Model(&user).Update("last_login", now)

		fmt.Printf("[AUTH] VerifyOTP: generating tokens user_id=%d role=%s\n", user.ID, user.Role)
		var err error
		accessToken, err = utils.GenerateToken(fmt.Sprint(user.ID), user.Role, s.cfg.JWTSecret)
		if err != nil {
			return fmt.Errorf("generate access token: %w", err)
		}

		refreshToken, err = s.issueRefreshTokenTx(tx, user.ID)
		if err != nil {
			return fmt.Errorf("issue refresh token: %w", err)
		}

		return nil
	})

	if txErr != nil {
		fmt.Printf("[AUTH] VerifyOTP: transaction failed phone=%s: %v\n", phone, txErr)
		return nil, "", "", txErr
	}

	// Best-effort: evict Redis cache entry after successful tx
	ctx := context.Background()
	s.rdb.Del(ctx, "otp:"+phone)

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
