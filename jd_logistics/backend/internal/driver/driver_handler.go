package driver

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) GetProfile(c *gin.Context) {
	uid := mustUID(c)
	p, err := h.svc.GetOrCreate(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, p)
}

func (h *Handler) ToggleOnline(c *gin.Context) {
	var req ToggleOnlineRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	p, err := h.svc.ToggleOnline(uid, req.IsOnline)
	if err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, p)
}

func (h *Handler) UpdateLocation(c *gin.Context) {
	var req UpdateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	if err := h.svc.UpdateLocation(uid, req.Latitude, req.Longitude); err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"updated": true})
}

func (h *Handler) AvailableOrders(c *gin.Context) {
	orders, err := h.svc.GetAvailableOrders()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, orders)
}

func (h *Handler) AcceptOrder(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	uid := mustUID(c)
	if err := h.svc.AcceptOrder(uid, uint(id)); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, gin.H{"accepted": true})
}

func (h *Handler) RejectOrder(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	if err := h.svc.RejectOrder(uint(id)); err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"rejected": true})
}

func (h *Handler) GetEarnings(c *gin.Context) {
	uid := mustUID(c)
	records, err := h.svc.GetEarnings(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, records)
}

func mustUID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
