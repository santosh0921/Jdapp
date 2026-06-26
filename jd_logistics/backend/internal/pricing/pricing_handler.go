package pricing

import (
	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the pricing service.
type Handler struct{ svc *Service }

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

// Estimate handles POST /pricing/estimate
func (h *Handler) Estimate(c *gin.Context) {
	var req EstimateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	if req.WeightKg <= 0 {
		utils.BadRequest(c, "weight_kg must be greater than 0")
		return
	}
	result, err := h.svc.Estimate(req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, result)
}

// MultiModal handles POST /pricing/multi-modal
func (h *Handler) MultiModal(c *gin.Context) {
	var req MultiModalRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	if len(req.Segments) == 0 {
		utils.BadRequest(c, "at least one segment is required")
		return
	}
	if req.WeightKg <= 0 {
		utils.BadRequest(c, "weight_kg must be greater than 0")
		return
	}
	result, err := h.svc.EstimateMultiModal(req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, result)
}
