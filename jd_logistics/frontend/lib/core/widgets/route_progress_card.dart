import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

/// Route progress card — origin → current hub → destination.
/// Shows ETA, mode, and progress bar.
class RouteProgressCard extends StatelessWidget {
  final String shipmentId;
  final String origin;
  final String destination;
  final String? currentHub;
  final String mode; // Road / Air / Ocean
  final String status;
  final String? eta;
  final double progress; // 0.0 – 1.0
  final String? originFlag;
  final String? destFlag;
  final VoidCallback? onTap;

  const RouteProgressCard({
    super.key,
    required this.shipmentId,
    required this.origin,
    required this.destination,
    this.currentHub,
    this.mode = 'Road',
    this.status = 'In Transit',
    this.eta,
    this.progress = 0.5,
    this.originFlag,
    this.destFlag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final modeColor = _modeColor(mode);
    final modeIcon = _modeIcon(mode);
    final statusColor = AppColors.shipmentStatusColor(status);

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(modeIcon, color: modeColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipmentId,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      mode,
                      style: TextStyle(
                        color: modeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Origin → Destination
          Row(
            children: [
              _PointColumn(
                  flag: originFlag ?? '📍',
                  label: origin,
                  isDark: isDark,
                  align: CrossAxisAlignment.start),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: List.generate(7, (i) {
                        final filled = i / 7 < progress;
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: filled
                                  ? modeColor
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.skyBorder),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Icon(modeIcon,
                        size: 14,
                        color: modeColor.withValues(alpha: 0.7)),
                  ],
                ),
              ),
              _PointColumn(
                  flag: destFlag ?? '🏁',
                  label: destination,
                  isDark: isDark,
                  align: CrossAxisAlignment.end),
            ],
          ),

          if (currentHub != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.warehouse_rounded,
                    size: 13,
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary),
                const SizedBox(width: 4),
                Text(
                  'At: $currentHub',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary,
                    fontSize: 12,
                  ),
                ),
                if (eta != null) ...[
                  const Spacer(),
                  Icon(Icons.schedule_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'ETA: $eta',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
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

class _PointColumn extends StatelessWidget {
  final String flag;
  final String label;
  final bool isDark;
  final CrossAxisAlignment align;

  const _PointColumn({
    required this.flag,
    required this.label,
    required this.isDark,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: align == CrossAxisAlignment.end
                ? TextAlign.right
                : TextAlign.left,
          ),
        ],
      ),
    );
  }
}
