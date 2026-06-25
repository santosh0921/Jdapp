import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _reports = [
    (title: 'Daily Shipment Report', icon: Icons.local_shipping_rounded, color: AppColors.primary),
    (title: 'Driver Performance Report', icon: Icons.motorcycle_rounded, color: AppColors.driverColor),
    (title: 'Revenue Report', icon: Icons.currency_rupee_rounded, color: AppColors.success),
    (title: 'Customer Activity Report', icon: Icons.group_rounded, color: AppColors.secondary),
    (title: 'Warehouse Operations Report', icon: Icons.warehouse_rounded, color: AppColors.warehouseColor),
    (title: 'Returns & Refunds Report', icon: Icons.assignment_return_rounded, color: AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Reports', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = _reports[i];
              return GlassCard(
                onTap: () {},
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: r.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(r.icon, color: r.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(r.title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: Colors.white54, size: 18)),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
