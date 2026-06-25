import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: AppColors.accentGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.saffron.withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'RS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.circle,
                              size: 8, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ramesh Sharma',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '+91 98700 12345  ·  Driver',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    // Stat row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const _HeroStat(label: 'Deliveries', value: '147'),
                        _Divider(),
                        const _HeroStat(label: 'Rating', value: '4.9★'),
                        _Divider(),
                        const _HeroStat(label: 'Earnings', value: '₹18.4k'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                children: [
                  // Vehicle & documents
                  _Section(
                    title: 'Vehicle & Documents',
                    isDark: isDark,
                    tiles: [
                      _Tile(
                        icon: Icons.two_wheeler_rounded,
                        label: 'Vehicle: Hero Splendor — MH12AB1234',
                        isDark: isDark,
                      ),
                      _Tile(
                        icon: Icons.badge_rounded,
                        label: 'Driver License: Verified',
                        isDark: isDark,
                        trailing: _VerifiedBadge(),
                      ),
                      _Tile(
                        icon: Icons.description_rounded,
                        label: 'RC Book: Verified',
                        isDark: isDark,
                        trailing: _VerifiedBadge(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Bank & payments
                  _Section(
                    title: 'Bank & Payments',
                    isDark: isDark,
                    tiles: [
                      _Tile(
                        icon: Icons.account_balance_rounded,
                        label: 'Bank Account: HDFC ••••4521',
                        isDark: isDark,
                      ),
                      _Tile(
                        icon: Icons.currency_rupee_rounded,
                        label: 'Auto Payout: Every Monday',
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Settings
                  _Section(
                    title: 'Settings',
                    isDark: isDark,
                    tiles: [
                      _SwitchTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark Mode',
                        value: themeProvider.isDark,
                        onChanged: (_) {
                          HapticFeedback.selectionClick();
                          themeProvider.toggleTheme();
                        },
                        isDark: isDark,
                      ),
                      _Tile(
                        icon: Icons.notifications_rounded,
                        label: 'Notifications',
                        isDark: isDark,
                      ),
                      _Tile(
                        icon: Icons.language_rounded,
                        label: 'Language: English',
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Support
                  _Section(
                    title: 'Support',
                    isDark: isDark,
                    tiles: [
                      _Tile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        isDark: isDark,
                      ),
                      _Tile(
                        icon: Icons.headset_mic_rounded,
                        label: 'Contact Support',
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Logout
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await auth.logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2));
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('Verified',
          style: TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> tiles;

  const _Section(
      {required this.title, required this.isDark, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color:
                  isDark ? Colors.white54 : AppColors.textDarkSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          ...tiles,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Widget? trailing;

  const _Tile(
      {required this.icon,
      required this.label,
      required this.isDark,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isDark ? Colors.white60 : AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? Colors.white30 : Colors.black26),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isDark ? Colors.white60 : AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
