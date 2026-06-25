import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Settings', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(children: [
                    _SettingTile(icon: Icons.business_rounded, label: 'Company Profile', onTap: () {}),
                    _SettingTile(icon: Icons.location_on_rounded, label: 'Service Areas', onTap: () {}),
                    _SettingTile(icon: Icons.currency_rupee_rounded, label: 'Pricing Rules', onTap: () {}),
                    _SettingTile(icon: Icons.local_offer_rounded, label: 'Promotions', onTap: () {}),
                  ]),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(children: [
                    _SettingTile(icon: Icons.notifications_rounded, label: 'Notification Settings', onTap: () {}),
                    _SettingTile(icon: Icons.security_rounded, label: 'Security', onTap: () {}),
                    _SettingTile(icon: Icons.api_rounded, label: 'API Keys', onTap: () {}),
                    SwitchListTile(
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      secondary: const Icon(Icons.dark_mode_rounded, color: Colors.white70),
                      title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                      activeThumbColor: AppColors.adminColor,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(children: [
                    _SettingTile(icon: Icons.help_outline_rounded, label: 'Documentation', onTap: () {}),
                    _SettingTile(icon: Icons.info_outline_rounded, label: 'App Version', trailing: 'v1.0.0', onTap: () {}),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                      title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      onTap: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.label, required this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(label, style: const TextStyle(color: Colors.white)),
    trailing: trailing != null
        ? Text(trailing!, style: const TextStyle(color: Colors.white54))
        : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
    onTap: onTap,
  );
}
