package auth

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

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
	utils.OK(c, gin.H{"message": "OTP sent"})
}

func (h *Handler) VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	phone := utils.SanitizePhone(req.Phone)
	user, token, err := h.svc.VerifyOTP(phone, req.OTP)
	if err != nil {
		utils.Unauthorized(c, err.Error())
		return
	}
	utils.OK(c, AuthResponse{Token: token, User: user})
}

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

func (h *Handler) SelectRole(c *gin.Context) {
	var req SelectRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	userIDStr, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDStr.(string), 10, 64)

	user, token, err := h.svc.SelectRole(uint(userID), req.Role)
	if err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, AuthResponse{Token: token, User: user})
}

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
