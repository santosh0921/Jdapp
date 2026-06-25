import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsCargoScreen extends StatelessWidget {
  const LogisticsCargoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final bg = dark ? AppColors.darkBg1 : const Color(0xFFF5F6FA);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? Colors.white : AppColors.textDark;
    final sub = dark ? AppColors.darkSubtext : AppColors.textDarkSecondary;

    final containers = [
      _Container('CNT-4501', '40ft HC', '28,000 kg', 'Mumbai Port', 'Loaded', AppColors.success),
      _Container('CNT-3892', '20ft STD', '14,500 kg', 'JNPT', 'In Transit', AppColors.primary),
      _Container('CNT-5103', 'LCL Slot', '3,200 kg', 'Chennai', 'Pending', AppColors.warning),
      _Container('CNT-2744', 'Bulk Pallet', '6,800 kg', 'Delhi ICD', 'Customs', _kLogisticsColor),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => context.pop(),
        ),
        title: Text('Cargo & Containers', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight calculator card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF162233), _kLogisticsColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cargo Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('Calculate freight & container requirements', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Active Containers', style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...containers.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: _kLogisticsColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.directions_boat_rounded, color: _kLogisticsColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.id, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13)),
                        Text('${c.type}  ·  ${c.weight}  ·  ${c.port}', style: TextStyle(color: sub, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: c.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(c.status, style: TextStyle(color: c.statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Container {
  final String id, type, weight, port, status;
  final Color statusColor;
  const _Container(this.id, this.type, this.weight, this.port, this.status, this.statusColor);
}
