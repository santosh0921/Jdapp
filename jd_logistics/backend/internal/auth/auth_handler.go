package auth

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the auth service.
type Handler struct {
	svc *Service
}

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// SendOTP handles POST /auth/send-otp
func (h *Handler) SendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	phone := utils.SanitizePhone(req.Phone)
	if err := h.svc.SendOTP(phone); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, gin.H{"message": "OTP sent successfully"})
}

// VerifyOTP handles POST /auth/verify-otp
func (h *Handler) VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	phone := utils.SanitizePhone(req.Phone)
	user, token, refreshToken, err := h.svc.VerifyOTP(phone, req.OTP)
	if err != nil {
		utils.Unauthorized(c, err.Error())
		return
	}
	utils.OK(c, AuthResponse{Token: token, RefreshToken: refreshToken, User: user})
}

// SetupProfile handles POST /auth/setup-profile  (JWT required)
func (h *Handler) SetupProfile(c *gin.Context) {
	var req SetupProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	userIDStr, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDStr.(string), 10, 64)

	user, err := h.svc.SetupProfile(uint(userID), req.Name, req.Email)
	if err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, user)
}

// SelectRole handles POST /auth/select-role  (JWT required)
func (h *Handler) SelectRole(c *gin.Context) {
	var req SelectRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	userIDStr, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDStr.(string), 10, 64)

	user, token, refreshToken, err := h.svc.SelectRole(uint(userID), req.Role)
	if err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, AuthResponse{Token: token, RefreshToken: refreshToken, User: user})
}

// GetProfile handles GET /auth/profile  (JWT required)
func (h *Handler) GetProfile(c *gin.Context) {
	userIDStr, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDStr.(string), 10, 64)

	user, err := h.svc.GetProfile(uint(userID))
	if err != nil {
		utils.NotFound(c, err.Error())
		return
	}
	utils.OK(c, user)
}

// RefreshToken handles POST /auth/refresh-token  (public)
func (h *Handler) RefreshToken(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	user, token, newRefresh, err := h.svc.RefreshAccessToken(req.RefreshToken)
	if err != nil {
		utils.Unauthorized(c, err.Error())
		return
	}
	utils.OK(c, AuthResponse{Token: token, RefreshToken: newRefresh, User: user})
}

// Logout handles POST /auth/logout  (public — best-effort)
func (h *Handler) Logout(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err == nil {
		h.svc.Logout(req.RefreshToken)
	}
	utils.OK(c, gin.H{"message": "logged out successfully"})
}
