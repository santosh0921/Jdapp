import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class JdBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<JdNavItem> items;
  final void Function(int) onTap;
  final Color? activeColor;

  const JdBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final active = activeColor ?? (isDark ? AppColors.oceanBlue : AppColors.primary);

    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.skyBorder;
    final shadow = isDark ? AppColors.clayShadowDark : AppColors.clayShadowLight;
    final highlight =
        isDark ? AppColors.clayHighlightDark : AppColors.clayHighlightLight;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: border.withValues(alpha: 0.92), width: 1.15),
          boxShadow: [
            BoxShadow(
              color: highlight.withValues(alpha: isDark ? 0.22 : 0.95),
              offset: const Offset(-7, -7),
              blurRadius: 18,
              spreadRadius: -7,
            ),
            BoxShadow(
              color: shadow.withValues(alpha: isDark ? 0.85 : 0.42),
              offset: const Offset(9, 10),
              blurRadius: 24,
              spreadRadius: -8,
            ),
          ],
        ),
        child: SizedBox(
          height: 58,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: _NavTile(
                  item: item,
                  isActive: isActive,
                  activeColor: active,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final JdNavItem item;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final inactiveColor =
        isDark ? AppColors.darkMuted : AppColors.textDarkSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.16 : 0.11)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isActive
              ? Border.all(
                  color: activeColor.withValues(alpha: isDark ? 0.34 : 0.22),
                  width: 1,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.clayHighlightDark
                            : AppColors.white)
                        .withValues(alpha: isDark ? 0.16 : 0.85),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: (isDark
                            ? AppColors.clayShadowDark
                            : AppColors.clayShadowLight)
                        .withValues(alpha: isDark ? 0.45 : 0.35),
                    offset: const Offset(5, 5),
                    blurRadius: 12,
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              scale: isActive ? 1.08 : 1,
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JdNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const JdNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}