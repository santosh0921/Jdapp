class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String setupProfile = '/auth/setup-profile';
  static const String selectRole = '/auth/select-role';
  static const String authProfile = '/auth/profile';

  // Users
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Shipments
  static const String shipments = '/shipments';
  static const String shipmentById = '/shipments/{id}';
  static const String shipmentQuote = '/shipments/quote';
  static const String cancelShipment = '/shipments/{id}/cancel';

  // Tracking
  static const String trackShipment = '/tracking/{trackingId}';

  // Driver
  static const String driverProfile = '/driver/profile';
  static const String driverToggleOnline = '/driver/toggle-online';
  static const String driverLocation = '/driver/location';
  static const String driverAvailableOrders = '/driver/available-orders';
  static const String driverAcceptOrder = '/driver/orders/{id}/accept';
  static const String driverRejectOrder = '/driver/orders/{id}/reject';
  static const String driverEarnings = '/driver/earnings';
  static const String driverWallet = '/driver/wallet';
  static const String podUpload = '/driver/orders/{id}/pod';

  // Warehouse
  static const String warehouseProfile = '/warehouse/profile';
  static const String warehouseInventory = '/warehouse/inventory';
  static const String scanParcel = '/warehouse/scan';
  static const String warehouseDispatch = '/warehouse/dispatch';
  static const String inbound = '/warehouse/inbound';
  static const String outbound = '/warehouse/outbound';
  static const String warehouseReturns = '/warehouse/returns';
  static const String warehouseStats = '/warehouse/stats';
  static const String warehouseReports = '/warehouse/reports';

  // Payments
  static const String paymentBalance = '/payments/balance';
  static const String addMoney = '/payments/add-money';
  static const String paymentHistory = '/payments/history';
  static const String withdrawMoney = '/payments/withdraw';
  static const String paymentMethods = '/payments/methods';
  static const String addPaymentMethod = '/payments/methods';
  static const String deletePaymentMethod = '/payments/methods/{id}';
  static const String initiatePayment = '/payments/initiate';
  static const String walletTopup = '/payments/add-money';
  static const String wallet = '/payments/balance';
  static const String downloadInvoice = '/payments/invoice/{id}';

  // Notifications
  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static const String markRead = '/notifications/{id}/read';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminStats = '/admin/stats';
  static const String adminDrivers = '/admin/drivers';
  static const String adminWarehouses = '/admin/warehouses';
  static const String adminFleet = '/admin/fleet';
  static const String adminAnalytics = '/admin/analytics';
}
