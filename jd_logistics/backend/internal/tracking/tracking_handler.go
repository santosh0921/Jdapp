package tracking

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

// GetEvents resolves /:id — supports both integer shipment ID and
// string tracking ID (e.g. "JD0012345678").
func (h *Handler) GetEvents(c *gin.Context) {
	param := c.Param("id")
	// Try parsing as integer shipment ID first
	if numID, err := strconv.ParseUint(param, 10, 64); err == nil {
		events, err := h.svc.GetEventsByShipmentID(uint(numID))
		if err != nil {
			utils.InternalError(c, err)
			return
		}
		utils.OK(c, events)
		return
	}
	// Fall back to string tracking ID
	events, err := h.svc.GetEventsByTrackingID(param)
	if err != nil {
		utils.NotFound(c, "tracking ID not found")
		return
	}
	utils.OK(c, events)
}

func (h *Handler) AddEvent(c *gin.Context) {
	var req AddEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	v, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(v.(string), 10, 64)
	role, _ := c.Get("role")

	ev, err := h.svc.AddEvent(uint(uid), role.(string), req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.Created(c, ev)
}
