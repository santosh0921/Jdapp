import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsProfileScreen extends StatelessWidget {
  const LogisticsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final theme = context.read<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final bg = dark ? AppColors.darkBg1 : const Color(0xFFF5F6FA);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? Colors.white : AppColors.textDark;
    final sub = dark ? AppColors.darkSubtext : AppColors.textDarkSecondary;

    final name = auth.user?.name ?? 'Logistics User';
    final phone = auth.user?.phone ?? '+91 98765 43210';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: text),
            onPressed: () => theme.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            // Avatar card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF162233), _kLogisticsColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'L',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(phone, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Logistics Customer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _tile(card, text, sub, dark, Icons.business_rounded, 'Company', 'ABC Trading Co. Ltd.'),
            _tile(card, text, sub, dark, Icons.public_rounded, 'Country', 'India'),
            _tile(card, text, sub, dark, Icons.swap_horiz_rounded, 'Business Type', 'Import & Export'),
            _tile(card, text, sub, dark, Icons.inventory_2_rounded, 'Cargo Type', 'General Cargo'),
            _tile(card, text, sub, dark, Icons.location_city_rounded, 'Preferred Port', 'Mumbai JNPT'),
            const SizedBox(height: 8),
            // Logout
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                onPressed: () async {
                  await auth.logoutAndChooseRole();
                  if (context.mounted) context.go('/service-selection');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(Color card, Color text, Color sub, bool dark, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: _kLogisticsColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: sub, fontSize: 12)),
          const Spacer(),
          Text(value, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
