package admin

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) Dashboard(c *gin.Context) {
	stats, err := h.svc.GetDashboard()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, stats)
}

func (h *Handler) ListUsers(c *gin.Context) {
	role := c.Query("role")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	users, err := h.svc.ListUsers(role, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, users)
}

func (h *Handler) PlatformStats(c *gin.Context) {
	stats, err := h.svc.GetPlatformStats()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, stats)
}
