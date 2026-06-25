class ApiEndpoints {
  ApiEndpoints._();

  // Toggle for production: 'https://api.jdlogistics.in/v1'
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String sendOtp        = '/auth/send-otp';
  static const String verifyOtp      = '/auth/verify-otp';
  static const String adminLogin     = '/auth/admin-login';
  static const String adminVerifyOtp = '/auth/admin-verify-otp';
  static const String refreshToken   = '/auth/refresh-token';
  static const String logout         = '/auth/logout';
  static const String authProfile    = '/auth/profile';
  static const String setupProfile   = '/auth/setup-profile';

  // ── Services ──────────────────────────────────────────────────────────────
  static const String getServices   = '/services';
  static const String selectService = '/services/select';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String userProfile   = '/users/profile';
  static const String updateProfile = '/users/profile';

  // ── Courier Orders ────────────────────────────────────────────────────────
  static const String courierEstimate = '/courier/orders/estimate';
  static const String courierOrders   = '/courier/orders';
  static String courierOrderById(String id)     => '/courier/orders/$id';
  static String cancelCourierOrder(String id)   => '/courier/orders/$id/cancel';
  static String courierTracking(String id)      => '/courier/orders/$id/tracking';

  // ── Driver ────────────────────────────────────────────────────────────────
  static const String driverAvailableOrders = '/driver/orders/available';
  static String driverAcceptOrder(String id)   => '/driver/orders/$id/accept';
  static String driverRejectOrder(String id)   => '/driver/orders/$id/reject';
  static const String driverActiveOrders    = '/driver/orders/active';
  static String driverPickup(String id)        => '/driver/orders/$id/pickup';
  static String driverDelivered(String id)     => '/driver/orders/$id/delivered';
  static String driverNavigation(String id)    => '/driver/navigation/$id';
  static const String driverEarnings        = '/driver/earnings';
  static const String driverWallet          = '/driver/wallet';
  static const String driverHistory         = '/driver/history';
  static const String driverProfile         = '/driver/profile';
  static const String driverToggleOnline    = '/driver/toggle-online';
  static const String driverLocation        = '/driver/location';

  // ── Logistics Orders ──────────────────────────────────────────────────────
  static const String logisticsEstimate = '/logistics/orders/estimate';
  static const String logisticsOrders   = '/logistics/orders';
  static String logisticsOrderById(String id)    => '/logistics/orders/$id';
  static String cancelLogisticsOrder(String id)  => '/logistics/orders/$id/cancel';
  static String logisticsTracking(String id)     => '/logistics/orders/$id/tracking';

  // ── Pricing Engine ────────────────────────────────────────────────────────
  static const String pricingCourierEstimate   = '/pricing/courier-estimate';
  static const String pricingLogisticsEstimate = '/pricing/logistics-estimate';
  static const String pricingMultiModal        = '/pricing/multi-modal-estimate';
  static const String pricingGoodsCategories   = '/pricing/goods-categories';
  static const String pricingVehicleTypes      = '/pricing/vehicle-types';
  static const String pricingTransportModes    = '/pricing/transport-modes';
  static const String pricingGstRates          = '/pricing/gst-rates';
  static const String pricingHsnCodes          = '/pricing/hsn-codes';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String createPaymentOrder = '/payments/create-order';
  static const String verifyPayment      = '/payments/verify';
  static const String paymentMethods     = '/payments/methods';
  static const String paymentHistory     = '/payments/history';
  static const String paymentBalance     = '/payments/balance';
  static const String addMoney           = '/payments/add-money';
  static const String withdrawMoney      = '/payments/withdraw';
  static String paymentInvoice(String id) => '/payments/invoice/$id';

  // ── Tracking ──────────────────────────────────────────────────────────────
  static String trackOrder(String id)      => '/tracking/$id';
  static const String updateDriverLocation = '/tracking/driver-location';
  static const String mapsDistance         = '/maps/distance';
  static const String mapsRoute            = '/maps/route';

  // ── Admin Dashboard & Lists ───────────────────────────────────────────────
  static const String adminDashboard       = '/admin/dashboard';
  static const String adminShipments       = '/admin/shipments';
  static const String adminCourierOrders   = '/admin/courier-orders';
  static const String adminLogisticsOrders = '/admin/logistics-orders';
  static const String adminUsers           = '/admin/users';
  static const String adminDrivers         = '/admin/drivers';
  static const String adminFleet           = '/admin/fleet';
  static const String adminPayments        = '/admin/payments';
  static const String adminAnalytics       = '/admin/analytics';
  static const String adminReports         = '/admin/reports';
  static const String adminSecurity        = '/admin/security';
  static const String adminAuditLogs       = '/admin/audit-logs';

  // ── Admin Warehouses ──────────────────────────────────────────────────────
  static const String adminWarehouses                      = '/admin/warehouses';
  static String adminWarehouseById(String id)              => '/admin/warehouses/$id';
  static String adminWarehouseInventory(String id)         => '/admin/warehouses/$id/inventory';
  static String adminWarehouseOrders(String id)            => '/admin/warehouses/$id/orders';
  static String adminWarehouseInbound(String id)           => '/admin/warehouses/$id/inbound';
  static String adminWarehouseOutbound(String id)          => '/admin/warehouses/$id/outbound';

  // ── Warehouse (operator) ──────────────────────────────────────────────────
  static const String warehouseProfile   = '/warehouse/profile';
  static const String warehouseInventory = '/warehouse/inventory';
  static const String warehouseInbound   = '/warehouse/inbound';
  static const String warehouseOutbound  = '/warehouse/outbound';
  static const String warehouseDispatch  = '/warehouse/dispatch';
  static const String warehouseReturns   = '/warehouse/returns';
  static const String warehouseStats     = '/warehouse/stats';
  static const String warehouseReports   = '/warehouse/reports';
  static const String scanParcel         = '/warehouse/scan';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String markAllRead   = '/notifications/read-all';
  static String markRead(String id) => '/notifications/$id/read';
}
