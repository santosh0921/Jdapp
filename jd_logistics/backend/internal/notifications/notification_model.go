package notifications

import "jd_logistics/utils"

type Notification struct {
	utils.Model
	UserID  uint   `gorm:"not null;index" json:"user_id"`
	Title   string `gorm:"not null" json:"title"`
	Body    string `json:"body"`
	Type    string `json:"type"`
	IsRead  bool   `gorm:"default:false" json:"is_read"`
	RefID   *uint  `json:"ref_id"`
	RefType string `json:"ref_type"`
}

func (Notification) TableName() string { return "jd_logistics.notifications" }

type PushRequest struct {
	UserID uint   `json:"user_id" binding:"required"`
	Title  string `json:"title" binding:"required"`
	Body   string `json:"body" binding:"required"`
	Type   string `json:"type"`
}
