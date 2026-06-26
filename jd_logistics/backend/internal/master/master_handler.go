package master

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

// Handler holds the master service.
type Handler struct{ svc *Service }

// NewHandler creates a Handler.
func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) GetRoles(c *gin.Context) {
	data, err := h.svc.GetRoles()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetGoodsCategories(c *gin.Context) {
	data, err := h.svc.GetGoodsCategories()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetVehicleTypes(c *gin.Context) {
	data, err := h.svc.GetVehicleTypes()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetCountries(c *gin.Context) {
	data, err := h.svc.GetCountries()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetStates(c *gin.Context) {
	countryID, _ := strconv.ParseUint(c.Query("country_id"), 10, 64)
	data, err := h.svc.GetStates(uint(countryID))
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetCities(c *gin.Context) {
	countryID, _ := strconv.ParseUint(c.Query("country_id"), 10, 64)
	state := c.Query("state")
	var isHub *bool
	if v := c.Query("is_hub"); v != "" {
		b := v == "true"
		isHub = &b
	}
	data, err := h.svc.GetCities(uint(countryID), state, isHub)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetPorts(c *gin.Context) {
	data, err := h.svc.GetPorts()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetTransportModes(c *gin.Context) {
	data, err := h.svc.GetTransportModes()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetShipmentStatuses(c *gin.Context) {
	data, err := h.svc.GetShipmentStatuses()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetPaymentMethods(c *gin.Context) {
	data, err := h.svc.GetPaymentMethods()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetWarehouseTypes(c *gin.Context) {
	data, err := h.svc.GetWarehouseTypes()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetGSTRates(c *gin.Context) {
	data, err := h.svc.GetGSTRates()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetHSNCodes(c *gin.Context) {
	search := c.Query("search")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	data, err := h.svc.GetHSNCodes(search, limit)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetPricingRules(c *gin.Context) {
	data, err := h.svc.GetPricingRules()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetFuelRates(c *gin.Context) {
	data, err := h.svc.GetFuelRates()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}

func (h *Handler) GetInsuranceRates(c *gin.Context) {
	data, err := h.svc.GetInsuranceRates()
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, data)
}
