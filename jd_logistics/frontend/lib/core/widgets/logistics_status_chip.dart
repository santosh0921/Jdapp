import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

/// Unified shipment/order status chip with mode icon and color.
class LogisticsStatusChip extends StatelessWidget {
  final String status;
  final bool small;
  final bool showIcon;

  const LogisticsStatusChip({
    super.key,
    required this.status,
    this.small = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.shipmentStatusColor(status);
    final icon = _iconFor(status);
    final fs = small ? 10.0 : 12.0;
    final px = small ? 7.0 : 10.0;
    final py = small ? 3.0 : 5.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: fs + 1, color: color),
            SizedBox(width: small ? 3 : 4),
          ],
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: fs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':        return Icons.receipt_rounded;
      case 'picked up':     return Icons.inventory_2_rounded;
      case 'in transit':    return Icons.local_shipping_rounded;
      case 'customs':       return Icons.gavel_rounded;
      case 'delivered':     return Icons.check_circle_rounded;
      case 'delayed':       return Icons.warning_rounded;
      case 'returned':      return Icons.assignment_return_rounded;
      case 'out for delivery': return Icons.delivery_dining_rounded;
      default:              return Icons.circle_outlined;
    }
  }
}

/// Mode chip: Road / Air / Ocean.
class ShipmentModeChip extends StatelessWidget {
  final String mode;
  final bool small;

  const ShipmentModeChip({super.key, required this.mode, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = _modeColor(mode);
    final icon = _modeIcon(mode);
    final fs = small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fs + 1, color: color),
          SizedBox(width: small ? 3 : 4),
          Text(mode,
              style: TextStyle(
                  color: color,
                  fontSize: fs,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static Color _modeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'air':   return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default:      return AppColors.roadColor;
    }
  }

  static IconData _modeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'air':   return Icons.flight_rounded;
      case 'ocean': return Icons.directions_boat_rounded;
      default:      return Icons.local_shipping_rounded;
    }
  }
}
