package master

import (
	"github.com/gin-gonic/gin"
	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

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
	data, err := h.svc.GetHSNCodes()
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
