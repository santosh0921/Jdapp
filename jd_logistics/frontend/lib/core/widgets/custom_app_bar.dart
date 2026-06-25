import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class JdAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final bool transparent;
  final Widget? titleWidget;
  final bool showThemeToggle;

  const JdAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.showBack = true,
    this.onBack,
    this.transparent = false,
    this.titleWidget,
    this.showThemeToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    final bg = dark ? AppColors.darkCard : AppColors.lightCard;
    final border = dark ? AppColors.darkBorder : AppColors.skyBorder;
    final shadow = dark ? AppColors.clayShadowDark : AppColors.clayShadowLight;
    final highlight =
        dark ? AppColors.clayHighlightDark : AppColors.clayHighlightLight;

    final appBarActions = <Widget>[
      if (showThemeToggle) const _MiniThemeToggle(),
      if (actions != null) ...actions!,
      const SizedBox(width: 6),
    ];

    return SafeArea(
      bottom: false,
      child: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: transparent
                ? Colors.transparent
                : border.withValues(alpha: dark ? 0.92 : 0.86),
            width: 1.15,
          ),
          boxShadow: transparent
              ? []
              : [
                  BoxShadow(
                    color: highlight.withValues(alpha: dark ? 0.22 : 0.95),
                    offset: const Offset(-7, -7),
                    blurRadius: 18,
                    spreadRadius: -7,
                  ),
                  BoxShadow(
                    color: shadow.withValues(alpha: dark ? 0.85 : 0.42),
                    offset: const Offset(9, 10),
                    blurRadius: 24,
                    spreadRadius: -8,
                  ),
                ],
        ),
        child: Row(
          children: [
            if (showBack)
              _ClayIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              )
            else
              const SizedBox(width: 8),
            const SizedBox(width: 10),
            Expanded(
              child: titleWidget ??
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
            ),
            ...appBarActions,
          ],
        ),
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool showThemeToggle;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.showThemeToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return JdAppBar(
      title: title,
      actions: actions,
      showBack: showBack,
      showThemeToggle: showThemeToggle,
    );
  }
}

class _MiniThemeToggle extends StatelessWidget {
  const _MiniThemeToggle();

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return _ClayIconButton(
      icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      iconColor: dark ? AppColors.portOrange : AppColors.primary,
      tooltip: dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
    );
  }
}

class _ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final String? tooltip;

  const _ClayIconButton({
    required this.icon,
    this.onTap,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    final bg = dark ? AppColors.darkCard : AppColors.lightCard;
    final border = dark ? AppColors.darkBorder : AppColors.skyBorder;
    final shadow = dark ? AppColors.clayShadowDark : AppColors.clayShadowLight;
    final highlight =
        dark ? AppColors.clayHighlightDark : AppColors.clayHighlightLight;

    final child = InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: border.withValues(alpha: dark ? 0.86 : 0.80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: highlight.withValues(alpha: dark ? 0.20 : 0.95),
              offset: const Offset(-5, -5),
              blurRadius: 12,
              spreadRadius: -5,
            ),
            BoxShadow(
              color: shadow.withValues(alpha: dark ? 0.76 : 0.40),
              offset: const Offset(6, 7),
              blurRadius: 16,
              spreadRadius: -6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? AppColors.text(context),
        ),
      ),
    );

    if (tooltip == null) return child;

    return Tooltip(
      message: tooltip!,
      child: child,
    );
  }
}