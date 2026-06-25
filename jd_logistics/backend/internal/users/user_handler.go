package users

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) GetProfile(c *gin.Context) {
	uid := mustUserID(c)
	p, err := h.svc.GetProfile(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, p)
}

func (h *Handler) UpdateProfile(c *gin.Context) {
	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUserID(c)
	p, err := h.svc.UpdateProfile(uid, req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, p)
}

func mustUserID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
