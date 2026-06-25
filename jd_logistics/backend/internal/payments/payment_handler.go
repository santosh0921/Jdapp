package payments

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) GetBalance(c *gin.Context) {
	uid := mustUID(c)
	w, err := h.svc.GetBalance(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, w)
}

func (h *Handler) AddMoney(c *gin.Context) {
	var req AddMoneyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	w, err := h.svc.AddMoney(uid, req)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, w)
}

func (h *Handler) GetHistory(c *gin.Context) {
	uid := mustUID(c)
	txns, err := h.svc.GetHistory(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, txns)
}

func (h *Handler) Withdraw(c *gin.Context) {
	var req WithdrawRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	uid := mustUID(c)
	w, err := h.svc.Withdraw(uid, req)
	if err != nil {
		utils.BadRequest(c, err.Error())
		return
	}
	utils.OK(c, w)
}

func mustUID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
