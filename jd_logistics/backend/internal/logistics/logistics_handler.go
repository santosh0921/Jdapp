package logistics

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the logistics service.
type Handler struct{ svc *Service }

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

// ListOrders handles GET /logistics/orders
func (h *Handler) ListOrders(c *gin.Context) {
	customerID := uidFrom(c)
	status := c.Query("status")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	orders, total, err := h.svc.ListOrders(customerID, status, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"orders": orders, "total": total, "page": page, "limit": limit})
}

// GetOrder handles GET /logistics/orders/:id
func (h *Handler) GetOrder(c *gin.Context) {
	customerID := uidFrom(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	order, err := h.svc.GetOrder(uint(id), customerID)
	if err != nil {
		utils.NotFound(c, err.Error())
		return
	}
	utils.OK(c, order)
}

// CreateOrder handles POST /logistics/orders
func (h *Handler) CreateOrder(c *gin.Context) {
	var req CreateOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	order, err := h.svc.CreateOrder(uidFrom(c), req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.Created(c, order)
}

// Estimate handles POST /logistics/estimate
func (h *Handler) Estimate(c *gin.Context) {
	var req EstimateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	result, err := h.svc.Estimate(req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, result)
}

func uidFrom(c *gin.Context) uint {
	raw, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(raw.(string), 10, 64)
	return uint(id)
}
