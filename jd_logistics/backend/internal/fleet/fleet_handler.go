package fleet

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the fleet service.
type Handler struct{ svc *Service }

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

// ListVehicles handles GET /fleet/vehicles
func (h *Handler) ListVehicles(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	var isActive *bool
	if v := c.Query("is_active"); v != "" {
		b := v == "true"
		isActive = &b
	}
	vehicles, total, err := h.svc.ListVehicles(isActive, page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"vehicles": vehicles, "total": total, "page": page, "limit": limit})
}

// GetVehicle handles GET /fleet/vehicles/:id
func (h *Handler) GetVehicle(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	v, err := h.svc.GetVehicle(uint(id))
	if err != nil {
		utils.NotFound(c, "vehicle not found")
		return
	}
	utils.OK(c, v)
}

// CreateVehicle handles POST /fleet/vehicles
func (h *Handler) CreateVehicle(c *gin.Context) {
	var req CreateVehicleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	v, err := h.svc.CreateVehicle(req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.Created(c, v)
}

// UpdateVehicle handles PUT /fleet/vehicles/:id
func (h *Handler) UpdateVehicle(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	var req UpdateVehicleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	v, err := h.svc.UpdateVehicle(uint(id), req)
	if err != nil {
		utils.NotFound(c, "vehicle not found")
		return
	}
	utils.OK(c, v)
}

// ListMaintenance handles GET /fleet/maintenance
func (h *Handler) ListMaintenance(c *gin.Context) {
	vehicleID, _ := strconv.ParseUint(c.Query("vehicle_id"), 10, 64)
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	rows, total, err := h.svc.ListMaintenance(uint(vehicleID), page, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"records": rows, "total": total, "page": page, "limit": limit})
}

// CreateMaintenance handles POST /fleet/maintenance
func (h *Handler) CreateMaintenance(c *gin.Context) {
	var req CreateMaintenanceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	m, err := h.svc.CreateMaintenance(req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.Created(c, m)
}

// GetSummary handles GET /fleet/summary
func (h *Handler) GetSummary(c *gin.Context) {
	summary, err := h.svc.GetFleetSummary()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, summary)
}
