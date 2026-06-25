package payments

import (
	"errors"

	"gorm.io/gorm"
)

type Service struct{ db *gorm.DB }

func NewService(db *gorm.DB) *Service { return &Service{db: db} }

func (s *Service) GetBalance(userID uint) (*WalletBalance, error) {
	var w WalletBalance
	s.db.Where("user_id = ?", userID).FirstOrCreate(&w, WalletBalance{UserID: userID})
	return &w, nil
}

func (s *Service) AddMoney(userID uint, req AddMoneyRequest) (*WalletBalance, error) {
	var w WalletBalance
	s.db.Where("user_id = ?", userID).FirstOrCreate(&w, WalletBalance{UserID: userID})

	tx := Transaction{
		UserID:      userID,
		Amount:      req.Amount,
		Type:        "credit",
		Method:      req.Method,
		Status:      "success",
		Description: "Wallet top-up",
	}
	s.db.Create(&tx)
	s.db.Model(&w).Update("balance", w.Balance+req.Amount)
	w.Balance += req.Amount
	return &w, nil
}

func (s *Service) GetHistory(userID uint) ([]Transaction, error) {
	var txns []Transaction
	s.db.Where("user_id = ?", userID).Order("created_at desc").Find(&txns)
	return txns, nil
}

func (s *Service) Withdraw(userID uint, req WithdrawRequest) (*WalletBalance, error) {
	var w WalletBalance
	if err := s.db.Where("user_id = ?", userID).First(&w).Error; err != nil {
		return nil, errors.New("wallet not found")
	}
	if w.Balance < req.Amount {
		return nil, errors.New("insufficient balance")
	}
	tx := Transaction{
		UserID:      userID,
		Amount:      req.Amount,
		Type:        "debit",
		Method:      "bank_transfer",
		Status:      "pending",
		Description: "Withdrawal to bank",
	}
	s.db.Create(&tx)
	s.db.Model(&w).Update("balance", w.Balance-req.Amount)
	w.Balance -= req.Amount
	return &w, nil
}
