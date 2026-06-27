import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/providers/auth_provider.dart';

// Auth
import 'package:jd_style_logistics/features/splash/splash_screen.dart';
import 'package:jd_style_logistics/features/onboarding/onboarding_screen.dart';
import 'package:jd_style_logistics/features/auth/service_selection_screen.dart';
import 'package:jd_style_logistics/features/auth/login_screen.dart';
import 'package:jd_style_logistics/features/auth/otp_screen.dart';
import 'package:jd_style_logistics/features/auth/profile_setup_screen.dart';
import 'package:jd_style_logistics/features/auth/role_selection_screen.dart';

// Customer (Courier)
import 'package:jd_style_logistics/features/customer/customer_shell.dart';
import 'package:jd_style_logistics/features/customer/customer_home_screen.dart';
import 'package:jd_style_logistics/features/customer/book_shipment_screen.dart';
import 'package:jd_style_logistics/features/customer/track_shipment_screen.dart';
import 'package:jd_style_logistics/features/customer/orders_screen.dart';
import 'package:jd_style_logistics/features/customer/payments_screen.dart';
import 'package:jd_style_logistics/features/customer/rewards_screen.dart';
import 'package:jd_style_logistics/features/customer/notifications_screen.dart';
import 'package:jd_style_logistics/features/customer/customer_profile_screen.dart';
import 'package:jd_style_logistics/features/customer/support_screen.dart';

// Customer — shipment flow
import 'package:jd_style_logistics/features/customer/shipment_type_screen.dart';
import 'package:jd_style_logistics/features/customer/package_details_screen.dart';
import 'package:jd_style_logistics/features/customer/partner_selection_screen.dart';
import 'package:jd_style_logistics/features/customer/price_estimate_screen.dart';
import 'package:jd_style_logistics/features/customer/order_confirmation_screen.dart';
import 'package:jd_style_logistics/features/customer/delivery_success_screen.dart';
import 'package:jd_style_logistics/features/customer/shipment_timeline_screen.dart';
import 'package:jd_style_logistics/features/customer/shipment_details_screen.dart';
import 'package:jd_style_logistics/features/customer/shipment_history_screen.dart';
import 'package:jd_style_logistics/features/customer/saved_addresses_screen.dart';
import 'package:jd_style_logistics/features/customer/share_tracking_screen.dart';
import 'package:jd_style_logistics/features/customer/live_shipment_map_screen.dart';
import 'package:jd_style_logistics/features/customer/address_picker_screen.dart';
import 'package:jd_style_logistics/features/customer/delivery_rating_screen.dart';
import 'package:jd_style_logistics/features/customer/rebook_shipment_screen.dart';
import 'package:jd_style_logistics/features/customer/shipment_insurance_screen.dart';
import 'package:jd_style_logistics/features/customer/customer_chat_support_screen.dart';

// Driver (Courier)
import 'package:jd_style_logistics/features/driver/driver_shell.dart';
import 'package:jd_style_logistics/features/driver/driver_home_screen.dart';
import 'package:jd_style_logistics/features/driver/available_orders_screen.dart';
import 'package:jd_style_logistics/features/driver/active_delivery_screen.dart';
import 'package:jd_style_logistics/features/driver/navigation_screen.dart';
import 'package:jd_style_logistics/features/driver/proof_of_delivery_screen.dart';
import 'package:jd_style_logistics/features/driver/driver_earnings_screen.dart';
import 'package:jd_style_logistics/features/driver/driver_wallet_screen.dart';
import 'package:jd_style_logistics/features/driver/driver_profile_screen.dart';
import 'package:jd_style_logistics/features/driver/delivery_history_screen.dart';

// Logistics Customer
import 'package:jd_style_logistics/features/logistics/logistics_shell.dart';
import 'package:jd_style_logistics/features/logistics/logistics_home_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_shipments_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_cargo_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_documents_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_profile_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_order_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_freight_quote_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_import_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_export_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_warehouse_storage_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_analytics_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_network_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_tracking_screen.dart';
import 'package:jd_style_logistics/features/logistics/logistics_payment_screen.dart';
import 'package:jd_style_logistics/features/customer/courier_payment_screen.dart';

// Admin
import 'package:jd_style_logistics/features/admin/admin_shell.dart';
import 'package:jd_style_logistics/features/admin/admin_dashboard_screen.dart';
import 'package:jd_style_logistics/features/admin/users_screen.dart';
import 'package:jd_style_logistics/features/admin/drivers_screen.dart';
import 'package:jd_style_logistics/features/admin/warehouses_screen.dart';
import 'package:jd_style_logistics/features/admin/fleet_screen.dart';
import 'package:jd_style_logistics/features/admin/shipments_monitor_screen.dart';
import 'package:jd_style_logistics/features/admin/admin_payments_screen.dart';
import 'package:jd_style_logistics/features/admin/analytics_screen.dart';
import 'package:jd_style_logistics/features/admin/reports_screen.dart';
import 'package:jd_style_logistics/features/admin/admin_settings_screen.dart';
import 'package:jd_style_logistics/features/admin/security_screen.dart';
import 'package:jd_style_logistics/features/admin/audit_logs_screen.dart';

// Warehouse screens (accessible via admin — not a login role)
import 'package:jd_style_logistics/features/warehouse/warehouse_home_screen.dart';
import 'package:jd_style_logistics/features/warehouse/parcel_scan_screen.dart';
import 'package:jd_style_logistics/features/warehouse/inventory_screen.dart';
import 'package:jd_style_logistics/features/warehouse/dispatch_screen.dart';
import 'package:jd_style_logistics/features/warehouse/returns_screen.dart';
import 'package:jd_style_logistics/features/warehouse/inbound_screen.dart';
import 'package:jd_style_logistics/features/warehouse/outbound_screen.dart';
import 'package:jd_style_logistics/features/warehouse/warehouse_reports_screen.dart';
import 'package:jd_style_logistics/features/warehouse/warehouse_profile_screen.dart';

// Payments
import 'package:jd_style_logistics/features/payments/payment_methods_screen.dart';
import 'package:jd_style_logistics/features/payments/add_card_screen.dart';
import 'package:jd_style_logistics/features/payments/payment_history_screen.dart';
import 'package:jd_style_logistics/features/payments/invoice_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: _redirect,
    routes: [
      // ── Auth flow ──────────────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/service-selection', builder: (_, __) => const ServiceSelectionScreen()),
      GoRoute(path: '/role-selection', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupScreen()),

      // ── Courier Customer (bottom nav shell) ───────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => CustomerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/home', builder: (_, __) => const CustomerHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/orders', builder: (_, __) => const OrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/track', builder: (_, __) => const TrackShipmentScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/payments', builder: (_, __) => const CustomerPaymentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/profile', builder: (_, __) => const CustomerProfileScreen()),
          ]),
        ],
      ),

      // Customer push routes
      GoRoute(path: '/book-shipment', builder: (_, __) => const BookShipmentScreen()),
      GoRoute(path: '/wallet', builder: (_, __) => const CustomerPaymentsScreen()),
      GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const CustomerNotificationsScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),

      // ── Courier Driver (bottom nav shell) ─────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => DriverShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/driver/home', builder: (_, __) => const DriverHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/driver/orders', builder: (_, __) => const AvailableOrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/driver/earnings', builder: (_, __) => const DriverEarningsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/driver/profile', builder: (_, __) => const DriverProfileScreen()),
          ]),
        ],
      ),

      // Driver push routes
      GoRoute(path: '/driver/delivery', builder: (_, __) => const ActiveDeliveryScreen()),
      GoRoute(path: '/driver/navigation', builder: (_, __) => const NavigationScreen()),
      GoRoute(path: '/driver/proof', builder: (_, __) => const ProofOfDeliveryScreen()),
      GoRoute(path: '/driver/proof-of-delivery', builder: (_, __) => const ProofOfDeliveryScreen()),
      GoRoute(path: '/driver/wallet', builder: (_, __) => const DriverWalletScreen()),
      GoRoute(path: '/driver/history', builder: (_, __) => const DeliveryHistoryScreen()),
      GoRoute(path: '/driver/active', builder: (_, __) => const ActiveDeliveryScreen()),

      // ── Logistics Customer (bottom nav shell) ─────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => LogisticsShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/logistics/home', builder: (_, __) => const LogisticsHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/logistics/shipments', builder: (_, __) => const LogisticsShipmentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/logistics/cargo', builder: (_, __) => const LogisticsCargoScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/logistics/documents', builder: (_, __) => const LogisticsDocumentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/logistics/profile', builder: (_, __) => const LogisticsProfileScreen()),
          ]),
        ],
      ),

      // Logistics push routes — enterprise module
      GoRoute(path: '/logistics/import', builder: (_, __) => const LogisticsImportScreen()),
      GoRoute(path: '/logistics/export', builder: (_, __) => const LogisticsExportScreen()),
      GoRoute(path: '/logistics/container', builder: (_, __) => const LogisticsCargoScreen()),
      GoRoute(path: '/logistics/quotes', builder: (_, __) => const LogisticsFreightQuoteScreen()),
      GoRoute(path: '/logistics/tracking', builder: (_, __) => const LogisticsTrackingScreen()),
      GoRoute(path: '/logistics/create-order', builder: (_, __) => const LogisticsOrderScreen()),
      GoRoute(path: '/logistics/freight-quote', builder: (_, __) => const LogisticsFreightQuoteScreen()),
      GoRoute(path: '/logistics/warehouse-storage', builder: (_, __) => const LogisticsWarehouseStorageScreen()),
      GoRoute(path: '/logistics/analytics', builder: (_, __) => const LogisticsAnalyticsScreen()),
      GoRoute(path: '/logistics/network', builder: (_, __) => const LogisticsNetworkScreen()),
      GoRoute(
        path: '/logistics/payment',
        builder: (_, state) {
          final args = state.extra as LogisticsPaymentArgs;
          return LogisticsPaymentScreen(args: args);
        },
      ),
      GoRoute(
        path: '/courier/payment',
        builder: (_, state) {
          final args = state.extra as CourierPaymentArgs;
          return CourierPaymentScreen(args: args);
        },
      ),

      // ── Admin (bottom nav shell) ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/users', builder: (_, __) => const UsersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/shipments', builder: (_, __) => const ShipmentsMonitorScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/analytics', builder: (_, __) => const AnalyticsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
          ]),
        ],
      ),

      // Admin push routes
      GoRoute(path: '/admin/drivers', builder: (_, __) => const DriversScreen()),
      GoRoute(path: '/admin/warehouses', builder: (_, __) => const WarehousesScreen()),
      GoRoute(path: '/admin/fleet', builder: (_, __) => const FleetScreen()),
      GoRoute(path: '/admin/payments', builder: (_, __) => const AdminPaymentsScreen()),
      GoRoute(path: '/admin/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/admin/security', builder: (_, __) => const SecurityScreen()),
      GoRoute(path: '/admin/audit-logs', builder: (_, __) => const AuditLogsScreen()),

      // Admin → warehouse management (not a login role — admin only)
      GoRoute(path: '/admin/warehouse-home', builder: (_, __) => const WarehouseHomeScreen()),
      GoRoute(path: '/admin/warehouse-scan', builder: (_, __) => const ParcelScanScreen()),
      GoRoute(path: '/admin/warehouse-inventory', builder: (_, __) => const InventoryScreen()),
      GoRoute(path: '/admin/warehouse-dispatch', builder: (_, __) => const DispatchScreen()),
      GoRoute(path: '/admin/warehouse-returns', builder: (_, __) => const ReturnsScreen()),
      GoRoute(path: '/admin/inbound', builder: (_, __) => const InboundScreen()),
      GoRoute(path: '/admin/outbound', builder: (_, __) => const OutboundScreen()),
      GoRoute(path: '/admin/warehouse-reports', builder: (_, __) => const WarehouseReportsScreen()),
      GoRoute(path: '/admin/warehouse-profile', builder: (_, __) => const WarehouseProfileScreen()),

      // ── Shipment flow (shared) ────────────────────────────────────────────
      GoRoute(path: '/shipment/type', builder: (_, __) => const ShipmentTypeScreen()),
      GoRoute(
        path: '/shipment/package-details',
        builder: (_, state) => PackageDetailsScreen(
          mode: state.uri.queryParameters['mode'] ?? 'road',
        ),
      ),
      GoRoute(
        path: '/shipment/partners',
        builder: (_, state) => PartnerSelectionScreen(
          mode: state.uri.queryParameters['mode'] ?? 'road',
        ),
      ),
      GoRoute(
        path: '/shipment/price-estimate',
        builder: (_, state) => PriceEstimateScreen(
          mode: state.uri.queryParameters['mode'] ?? 'road',
          partner: state.uri.queryParameters['partner'] ?? 'bluedart',
        ),
      ),
      GoRoute(
        path: '/shipment/order-confirmation',
        builder: (_, state) => OrderConfirmationScreen(
          mode: state.uri.queryParameters['mode'] ?? 'road',
          total: state.uri.queryParameters['total'] ?? '1952',
        ),
      ),
      GoRoute(
        path: '/shipment/delivery-success',
        builder: (_, state) => DeliverySuccessScreen(
          mode: state.uri.queryParameters['mode'] ?? 'road',
          orderId: state.uri.queryParameters['id'] ?? 'JD-2024-9182',
        ),
      ),
      GoRoute(
        path: '/shipment/timeline',
        builder: (_, state) => ShipmentTimelineScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
          mode: state.uri.queryParameters['mode'] ?? 'road',
        ),
      ),
      GoRoute(
        path: '/shipment/details',
        builder: (_, state) => ShipmentDetailsScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
        ),
      ),
      GoRoute(path: '/shipment/history', builder: (_, __) => const ShipmentHistoryScreen()),
      GoRoute(path: '/shipment/saved-addresses', builder: (_, __) => const SavedAddressesScreen()),
      GoRoute(
        path: '/shipment/share-tracking',
        builder: (_, state) => ShareTrackingScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
        ),
      ),
      GoRoute(
        path: '/shipment/live-map',
        builder: (_, state) => LiveShipmentMapScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
          mode: state.uri.queryParameters['mode'] ?? 'road',
        ),
      ),
      GoRoute(
        path: '/shipment/rating',
        builder: (_, state) => DeliveryRatingScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
        ),
      ),
      GoRoute(
        path: '/shipment/rebook',
        builder: (_, state) => RebookShipmentScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-1987',
        ),
      ),
      GoRoute(
        path: '/shipment/insurance',
        builder: (_, state) => ShipmentInsuranceScreen(
          id: state.uri.queryParameters['id'] ?? 'JD-IND-2048',
        ),
      ),
      GoRoute(path: '/customer/chat-support', builder: (_, __) => const CustomerChatSupportScreen()),
      GoRoute(
        path: '/pick-address',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AddressPickerScreen(
            title: state.uri.queryParameters['title'] ?? 'Pick Location',
            initialAddress: extra?['address'] as String?,
            initialLat: extra?['lat'] as double?,
            initialLng: extra?['lng'] as double?,
          );
        },
      ),

      // ── Payments (shared) ─────────────────────────────────────────────────
      GoRoute(path: '/payments', builder: (_, __) => const PaymentMethodsScreen()),
      GoRoute(path: '/payments/add-card', builder: (_, __) => const AddCardScreen()),
      GoRoute(path: '/payments/history', builder: (_, __) => const PaymentHistoryScreen()),
      GoRoute(
        path: '/payments/invoice',
        builder: (_, state) => InvoiceScreen(
          orderId: state.uri.queryParameters['id'],
        ),
      ),
    ],
  );

  // ── Redirect logic ─────────────────────────────────────────────────────────

  static String? _redirect(BuildContext context, GoRouterState state) {
    final auth = context.read<AuthProvider>();
    final location = state.uri.path;

    const openRoutes = [
      '/splash',
      '/onboarding',
      '/service-selection',
      '/role-selection',
      '/login',
      '/otp',
      '/profile-setup',
    ];

    final isOpenRoute = openRoutes.any((r) => location.startsWith(r));

    // Still initialising — stay at splash.
    if (auth.status == AuthStatus.unknown) {
      return location == '/splash' ? null : '/splash';
    }

    // Not authenticated and trying to access a protected route.
    if (!auth.isAuthenticated && !isOpenRoute) {
      return '/service-selection';
    }

    // Not authenticated, missing role, trying to access login/otp.
    if (!auth.isAuthenticated && !auth.hasSelectedRole) {
      if (location == '/login' || location.startsWith('/otp')) {
        return '/service-selection';
      }
    }

    // Already authenticated — redirect away from auth screens.
    if (auth.isAuthenticated &&
        (location == '/login' ||
            location.startsWith('/otp') ||
            location == '/role-selection' ||
            location == '/service-selection' ||
            location == '/onboarding')) {
      return _homeForRole(auth.userRole);
    }

    return null;
  }

  static String _homeForRole(String? role) {
    switch (role) {
      case 'courier_driver':
        return '/driver/home';
      case 'logistics_customer':
        return '/logistics/home';
      case 'admin':
        return '/admin/dashboard';
      case 'courier_customer':
      default:
        return '/customer/home';
    }
  }
}
