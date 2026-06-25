package warehouse

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

func (h *Handler) Scan(c *gin.Context) {
	var req ScanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	result, err := h.svc.Scan(uid, req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, result)
}

func (h *Handler) GetStats(c *gin.Context) {
	uid := mustUID(c)
	stats, err := h.svc.GetStats(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, stats)
}

func (h *Handler) GetInventory(c *gin.Context) {
	items, err := h.svc.GetInventory()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, items)
}

func (h *Handler) GetInbound(c *gin.Context) {
	items, err := h.svc.GetInbound()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, items)
}

func (h *Handler) GetReturns(c *gin.Context) {
	items, err := h.svc.GetReturns()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, items)
}

func (h *Handler) Dispatch(c *gin.Context) {
	var req DispatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	if err := h.svc.Dispatch(req.ShipmentID); err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"dispatched": true})
}

func mustUID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
