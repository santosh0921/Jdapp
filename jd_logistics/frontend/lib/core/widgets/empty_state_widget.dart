import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          borderRadius: 32,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EmptyIcon(icon: icon, iconSize: iconSize),
              const SizedBox(height: 22),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _RouteHint(dark: dark),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  width: 190,
                  height: 52,
                  borderRadius: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _EmptyIcon({
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Container(
      height: iconSize + 26,
      width: iconSize + 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? AppColors.darkSurface : AppColors.lightBg2,
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.skyBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? AppColors.clayHighlightDark : AppColors.white)
                .withValues(alpha: dark ? 0.20 : 0.95),
            offset: const Offset(-7, -7),
            blurRadius: 18,
            spreadRadius: -7,
          ),
          BoxShadow(
            color: (dark ? AppColors.clayShadowDark : AppColors.clayShadowLight)
                .withValues(alpha: dark ? 0.75 : 0.42),
            offset: const Offset(8, 9),
            blurRadius: 22,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: dark ? AppColors.oceanBlue : AppColors.primary,
      ),
    );
  }
}

class _RouteHint extends StatelessWidget {
  final bool dark;

  const _RouteHint({required this.dark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 150,
      child: CustomPaint(
        painter: _RouteHintPainter(dark: dark),
      ),
    );
  }
}

class _RouteHintPainter extends CustomPainter {
  final bool dark;

  const _RouteHintPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.34 : 0.55)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(8, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.42,
        2,
        size.width - 8,
        size.height * 0.42,
      );

    canvas.drawPath(path, line);

    final nodePaint = Paint()
      ..color = dark ? AppColors.oceanBlue : AppColors.primary;

    final endPaint = Paint()
      ..color = AppColors.portOrange;

    canvas.drawCircle(Offset(8, size.height * 0.62), 4, nodePaint);
    canvas.drawCircle(Offset(size.width - 8, size.height * 0.42), 4, endPaint);
  }

  @override
  bool shouldRepaint(covariant _RouteHintPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'Connection issue',
      subtitle: message,
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}