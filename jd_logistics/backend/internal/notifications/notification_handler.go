package notifications

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"jd_logistics/utils"
)

type Handler struct{ svc *Service }

func NewHandler(svc *Service) *Handler { return &Handler{svc: svc} }

func (h *Handler) List(c *gin.Context) {
	uid := mustUID(c)
	list, err := h.svc.GetForUser(uid)
	if err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, list)
}

func (h *Handler) MarkAllRead(c *gin.Context) {
	uid := mustUID(c)
	if err := h.svc.MarkAllRead(uid); err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"updated": true})
}

func (h *Handler) MarkRead(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)
	if err := h.svc.MarkRead(uint(id)); err != nil {
		utils.InternalError(c, err)
		return
	}
	utils.OK(c, gin.H{"updated": true})
}

func mustUID(c *gin.Context) uint {
	v, _ := c.Get("user_id")
	id, _ := strconv.ParseUint(v.(string), 10, 64)
	return uint(id)
}
