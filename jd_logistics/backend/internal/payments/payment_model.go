package payments

import "jd_logistics/utils"

type Transaction struct {
	utils.Model
	UserID      uint    `gorm:"not null;index" json:"user_id"`
	ShipmentID  *uint   `gorm:"index" json:"shipment_id"`
	Amount      float64 `gorm:"not null" json:"amount"`
	Type        string  `gorm:"not null" json:"type"`
	Method      string  `json:"method"`
	Status      string  `gorm:"default:'pending'" json:"status"`
	Reference   string  `json:"reference"`
	Description string  `json:"description"`
}

func (Transaction) TableName() string { return "jd_logistics.transactions" }

type WalletBalance struct {
	utils.Model
	UserID  uint    `gorm:"uniqueIndex;not null" json:"user_id"`
	Balance float64 `gorm:"default:0" json:"balance"`
}

func (WalletBalance) TableName() string { return "jd_logistics.wallet_balances" }

type AddMoneyRequest struct {
	Amount float64 `json:"amount" binding:"required,gt=0"`
	Method string  `json:"method" binding:"required"`
}

type WithdrawRequest struct {
	Amount float64 `json:"amount" binding:"required,gt=0"`
}
