import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/shipment_celebration.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class DeliverySuccessScreen extends StatelessWidget {
  final String mode;
  final String orderId;
  const DeliverySuccessScreen(
      {super.key, this.mode = 'road', this.orderId = 'JD-2024-9182'});

  String get _title {
    switch (mode.toLowerCase()) {
      case 'air': return 'Air Cargo Booked!';
      case 'ocean': return 'Ocean Freight Ready!';
      default: return 'Truck Shipment On the Move!';
    }
  }

  String get _subtitle {
    switch (mode.toLowerCase()) {
      case 'air': return 'Your air cargo shipment has been booked.\nTrack it in real-time from your dashboard.';
      case 'ocean': return 'Your ocean freight shipment is ready.\nWe\'ll notify you at every port checkpoint.';
      default: return 'Your truck shipment is now on the move.\nExpected delivery in 2–3 business days.';
    }
  }

  Color get _modeColor {
    switch (mode.toLowerCase()) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ShipmentCelebration(
              mode: mode,
              title: _title,
              subtitle: _subtitle,
              actions: [
                CelebAction(
                  label: 'Track Shipment',
                  icon: Icons.my_location_rounded,
                  onTap: () => context.push(
                      '/shipment/timeline?id=$orderId&mode=$mode'),
                ),
                CelebAction(
                  label: 'View Invoice',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => context.push(
                      '/payments/invoice?id=$orderId'),
                ),
                CelebAction(
                  label: 'Share Tracking',
                  icon: Icons.share_rounded,
                  onTap: () => context.push(
                      '/shipment/share-tracking?id=$orderId'),
                ),
              ],
            ),
          ),

          // Order ID card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _modeColor.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _modeColor.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                Icon(Icons.confirmation_number_rounded,
                    color: _modeColor, size: 20),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order ID',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.textDarkSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  Text(orderId,
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _modeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Icon(Icons.copy_rounded,
                          color: _modeColor, size: 14),
                      const SizedBox(width: 4),
                      Text('Copy',
                          style: TextStyle(
                              color: _modeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go('/customer/home'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg3 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.skyBorder),
                    ),
                    child: const Center(
                      child: Text('Go Home',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => context.push(
                      '/shipment/timeline?id=$orderId&mode=$mode'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_modeColor,
                              _modeColor.withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: _modeColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.my_location_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Live Track',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
