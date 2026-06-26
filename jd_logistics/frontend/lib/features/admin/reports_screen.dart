import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _reports = [
    (title: 'Daily Shipment Report',       type: 'daily',      icon: Icons.local_shipping_rounded,    color: AppColors.primary),
    (title: 'Driver Performance Report',   type: 'driver',     icon: Icons.motorcycle_rounded,        color: AppColors.driverColor),
    (title: 'Revenue Report',              type: 'revenue',    icon: Icons.currency_rupee_rounded,    color: AppColors.success),
    (title: 'Customer Activity Report',    type: 'customer',   icon: Icons.group_rounded,             color: AppColors.secondary),
    (title: 'Warehouse Operations Report', type: 'warehouse',  icon: Icons.warehouse_rounded,         color: AppColors.warehouseColor),
    (title: 'Returns & Refunds Report',    type: 'refunds',    icon: Icons.assignment_return_rounded, color: AppColors.error),
  ];

  final Set<String> _loading = {};

  Future<void> _download(String type, String title) async {
    setState(() => _loading.add(type));
    try {
      await AdminService.instance.getReports(type: type);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$title generated'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: ${e.toString()}'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ));
    } finally {
      if (mounted) setState(() => _loading.remove(type));
    }
  }

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
              final isLoading = _loading.contains(r.type);
              return GlassCard(
                onTap: () => _download(r.type, r.title),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: r.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(r.icon, color: r.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(r.title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500))),
                  isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                      : IconButton(onPressed: () => _download(r.type, r.title), icon: const Icon(Icons.download_rounded, color: Colors.white54, size: 18)),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
