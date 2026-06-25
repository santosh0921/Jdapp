import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

/// Post-delivery celebration widget.
/// Shows mode-specific animation (truck / plane / ship) + confetti dots.
class ShipmentCelebration extends StatefulWidget {
  final String mode; // Road / Air / Ocean
  final String title;
  final String subtitle;
  final List<CelebAction> actions;

  const ShipmentCelebration({
    super.key,
    this.mode = 'Road',
    this.title = 'Delivered!',
    this.subtitle = 'Your shipment has been delivered successfully.',
    this.actions = const [],
  });

  @override
  State<ShipmentCelebration> createState() => _ShipmentCelebrationState();
}

class _ShipmentCelebrationState extends State<ShipmentCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5));
    _ctrl.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final modeColor = _modeColor(widget.mode);

    return Stack(
      children: [
        // Confetti layer
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(progress: _ctrl.value),
              ),
            ),
          ),
        ),

        // Content
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: modeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: modeColor.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          _modeIcon(widget.mode),
                          size: 48,
                          color: modeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.warehouseColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.actions.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: widget.actions
                            .map((a) => _ActionBtn(action: a))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Color _modeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'air':   return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default:      return AppColors.warehouseColor;
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

class _ActionBtn extends StatelessWidget {
  final CelebAction action;
  const _ActionBtn({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(action.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class CelebAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const CelebAction(
      {required this.label, required this.icon, required this.onTap});
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static const _count = 22;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (var i = 0; i < _count; i++) {
      final x = rng.nextDouble() * size.width;
      const startY = -20.0;
      final endY = size.height * 0.85;
      final y = startY + (endY - startY) * progress +
          math.sin(progress * math.pi * 2 + i) * 24;

      if (y < 0 || y > size.height) continue;

      final colors = [
        AppColors.primary,
        AppColors.saffron,
        AppColors.warehouseColor,
        AppColors.skyAccent,
      ];
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.75);
      final w = 5.0 + rng.nextDouble() * 6;
      final h = 3.0 + rng.nextDouble() * 4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * (rng.nextBool() ? 3 : -4) + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
