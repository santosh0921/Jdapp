import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

/// Clay-style sun/moon theme toggle. Works in AppBar and as standalone.
class ThemeToggleButton extends StatelessWidget {
  final bool mini;

  const ThemeToggleButton({super.key, this.mini = false});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = mini ? 38.0 : 44.0;
    final iconSize = mini ? 18.0 : 20.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<ThemeProvider>().toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(mini ? 12 : 14),
          border: Border.all(
            color: isDark ? AppColors.clayBorderDark : AppColors.clayBorderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.clayHighlightLight
                  .withValues(alpha: isDark ? 0.0 : 0.80),
              offset: const Offset(-3, -3),
              blurRadius: 8,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: (isDark
                      ? AppColors.clayShadowDark
                      : AppColors.clayShadowLight)
                  .withValues(alpha: isDark ? 0.40 : 0.38),
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              size: iconSize,
              color: isDark ? AppColors.saffronDark : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
