import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

export 'package:jd_style_logistics/core/widgets/gradient_button.dart'
    show GradientButton;

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 18,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final enabled = widget.onPressed != null && !widget.isLoading;

    final bg = widget.backgroundColor ?? (dark ? AppColors.oceanBlue : AppColors.primary);
    final fg = widget.textColor ?? Colors.white;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.975 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: enabled ? bg : bg.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: dark ? 0.12 : 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: (dark ? AppColors.clayHighlightDark : AppColors.white)
                      .withValues(alpha: dark ? 0.18 : 0.60),
                  offset: const Offset(-5, -5),
                  blurRadius: 14,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: (dark ? AppColors.clayShadowDark : AppColors.primary)
                      .withValues(alpha: dark ? 0.72 : 0.18),
                  offset: const Offset(7, 8),
                  blurRadius: 18,
                  spreadRadius: -6,
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
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20, color: fg),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
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

class OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 18,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final enabled = widget.onPressed != null;

    final border = widget.borderColor ?? (dark ? AppColors.darkBorder : AppColors.skyBorder);
    final text = widget.textColor ?? (dark ? AppColors.oceanBlue : AppColors.primary);
    final bg = dark ? AppColors.darkCard : AppColors.lightCard;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.975 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: border.withValues(alpha: enabled ? 0.95 : 0.45),
                width: 1.25,
              ),
              boxShadow: [
                BoxShadow(
                  color: (dark ? AppColors.clayHighlightDark : AppColors.white)
                      .withValues(alpha: dark ? 0.18 : 0.85),
                  offset: const Offset(-5, -5),
                  blurRadius: 14,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: (dark ? AppColors.clayShadowDark : AppColors.clayShadowLight)
                      .withValues(alpha: dark ? 0.68 : 0.38),
                  offset: const Offset(7, 8),
                  blurRadius: 18,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? text : text.withValues(alpha: 0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final c = color ?? (dark ? AppColors.oceanBlue : AppColors.primary);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}