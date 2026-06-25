package utils

import (
	"time"

	"gorm.io/gorm"
)

// Model replaces gorm.Model with lowercase json tags so the Flutter
// client receives {"id":1,"created_at":"..."} instead of {"ID":1,...}.
type Model struct {
	ID        uint           `gorm:"primarykey" json:"id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
