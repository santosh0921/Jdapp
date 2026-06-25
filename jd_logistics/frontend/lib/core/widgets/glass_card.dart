import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double blurAmount;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 28,
    this.color,
    this.borderColor,
    this.blurAmount = 0,
    this.onTap,
    this.boxShadow,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final cardColor =
        widget.color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);

    final borderColor =
        widget.borderColor ?? AppColors.clayBorderColor(context);

    final shadows = widget.boxShadow ?? _buildClayShadows(isDark);

    final card = AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.975 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(18),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.95 : 0.85),
            width: 1.15,
          ),
          boxShadow: shadows,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius - 4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.clayHighlightDark.withValues(alpha: 0.22),
                      cardColor.withValues(alpha: 0.98),
                      AppColors.darkShadow.withValues(alpha: 0.20),
                    ]
                  : [
                      AppColors.white.withValues(alpha: 0.96),
                      cardColor,
                      AppColors.lightBg2.withValues(alpha: 0.70),
                    ],
            ),
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: card,
      ),
    );
  }

  List<BoxShadow> _buildClayShadows(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: AppColors.clayHighlightDark.withValues(alpha: 0.28),
          offset: const Offset(-7, -7),
          blurRadius: 18,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: AppColors.clayShadowDark.withValues(alpha: 0.90),
          offset: const Offset(10, 12),
          blurRadius: 28,
          spreadRadius: -8,
        ),
        BoxShadow(
          color: AppColors.oceanBlue.withValues(alpha: 0.045),
          offset: const Offset(-2, -2),
          blurRadius: 10,
          spreadRadius: -4,
        ),
      ];
    }

    return [
      BoxShadow(
        color: AppColors.clayHighlightLight.withValues(alpha: 0.95),
        offset: const Offset(-7, -7),
        blurRadius: 18,
        spreadRadius: -6,
      ),
      BoxShadow(
        color: AppColors.clayShadowLight.withValues(alpha: 0.48),
        offset: const Offset(10, 12),
        blurRadius: 28,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.035),
        offset: const Offset(0, 6),
        blurRadius: 18,
        spreadRadius: -8,
      ),
    ];
  }
}