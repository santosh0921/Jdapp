class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (value.trim().length != 6) return 'Enter the 6-digit OTP';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Card number is required';
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (digits.length != 16) return 'Enter a valid 16-digit card number';
    return null;
  }

  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) return 'CVV is required';
    if (value.trim().length < 3 || value.trim().length > 4) {
      return 'Enter a valid CVV';
    }
    return null;
  }

  static String? expiryDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Expiry date is required';
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(value.trim())) return 'Enter expiry as MM/YY';
    return null;
  }

  static String? upiId(String? value) {
    if (value == null || value.trim().isEmpty) return 'UPI ID is required';
    final regex = RegExp(r'^[\w.\-]+@[\w]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid UPI ID';
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Pincode is required';
    if (value.trim().length != 6) return 'Enter a valid 6-digit pincode';
    return null;
  }
}
