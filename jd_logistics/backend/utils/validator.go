package utils

import (
	"regexp"
	"strings"
)

var phoneRegex = regexp.MustCompile(`^[6-9]\d{9}$`)

func ValidatePhone(phone string) bool {
	return phoneRegex.MatchString(strings.TrimSpace(phone))
}

func ValidateOTP(otp string) bool {
	if len(otp) != 6 {
		return false
	}
	for _, c := range otp {
		if c < '0' || c > '9' {
			return false
		}
	}
	return true
}

func SanitizePhone(phone string) string {
	phone = strings.TrimSpace(phone)
	phone = strings.TrimPrefix(phone, "+91")
	phone = strings.TrimPrefix(phone, "91")
	return phone
}
