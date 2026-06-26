package admin

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the admin service.
type Handler struct{ svc *Service }

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

// Dashboard handles GET /admin/dashboard
func (h *Handler) Dashboard(c *gin.Context) {
	stats, err := h.svc.GetDashboard()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, stats)
}

// ListUsers handles GET /admin/users
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

// PlatformStats handles GET /admin/stats
func (h *Handler) PlatformStats(c *gin.Context) {
	stats, err := h.svc.GetPlatformStats()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, stats)
}

// Analytics handles GET /admin/analytics
func (h *Handler) Analytics(c *gin.Context) {
	rangeStr := c.DefaultQuery("range", "week")
	data, err := h.svc.GetAnalytics(rangeStr)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

// ListDrivers handles GET /admin/drivers
func (h *Handler) ListDrivers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	var isOnline *bool
	if v := c.Query("is_online"); v != "" {
		b := v == "true"
		isOnline = &b
	}
	drivers, err := h.svc.ListDrivers(isOnline, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, drivers)
}

// ListShipments handles GET /admin/shipments
func (h *Handler) ListShipments(c *gin.Context) {
	status := c.Query("status")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	rows, total, err := h.svc.ListShipmentsAdmin(status, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"shipments": rows, "total": total, "page": page, "limit": limit})
}

// ListAuditLogs handles GET /admin/audit-logs
func (h *Handler) ListAuditLogs(c *gin.Context) {
	action := c.Query("action")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	rows, total, err := h.svc.ListAuditLogs(action, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"logs": rows, "total": total, "page": page, "limit": limit})
}
