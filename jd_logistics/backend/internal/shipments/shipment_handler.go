package shipments

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) Create(c *gin.Context) {
	var req CreateShipmentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	sh, err := h.svc.Create(uid, req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.Created(c, sh)
}

func (h *Handler) List(c *gin.Context) {
	uid := mustUID(c)
	list, err := h.svc.ListForCustomer(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, list)
}

func (h *Handler) Get(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	sh, err := h.svc.GetByID(uint(id))
	if err != nil {
		utils.NotFound(c, "shipment not found")
		return
	}
	utils.OK(c, sh)
}

func (h *Handler) Cancel(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	uid := mustUID(c)
	sh, err := h.svc.Cancel(uint(id), uid)
	if err != nil {
		utils.NotFound(c, "shipment not found")
		return
	}
	utils.OK(c, sh)
}

func (h *Handler) Quote(c *gin.Context) {
	var req QuoteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, h.svc.Quote(req))
}

func mustUID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
