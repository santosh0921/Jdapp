import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class GradientButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradient;
  final List<Color>? colors;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final double? width;

  const GradientButton({
    super.key,
    this.child,
    this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.colors,
    this.icon,
    this.height = 56,
    this.borderRadius = 18,
    this.width = double.infinity,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 130),
      vsync: this,
    );

    _scale = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Color> _colors(BuildContext context) {
    final dark = AppColors.isDark(context);

    return widget.gradient ??
        widget.colors ??
        (dark
            ? const [
                AppColors.oceanBlue,
                AppColors.routeBlue,
              ]
            : AppColors.primaryGradient);
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final enabled = widget.onPressed != null && !widget.isLoading;
    final colors = _colors(context);

    return GestureDetector(
      onTapDown: enabled ? (_) => _ctrl.forward() : null,
      onTapCancel: enabled ? () => _ctrl.reverse() : null,
      onTapUp: enabled
          ? (_) {
              _ctrl.reverse();
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: dark ? 0.13 : 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: (dark
                          ? AppColors.clayHighlightDark
                          : AppColors.white)
                      .withValues(alpha: dark ? 0.20 : 0.65),
                  offset: const Offset(-5, -5),
                  blurRadius: 14,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: (dark
                          ? AppColors.clayShadowDark
                          : AppColors.primary)
                      .withValues(alpha: dark ? 0.72 : 0.20),
                  offset: const Offset(8, 9),
                  blurRadius: 20,
                  spreadRadius: -7,
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : widget.child ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}