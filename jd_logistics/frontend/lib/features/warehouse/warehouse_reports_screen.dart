import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class WarehouseReportsScreen extends StatelessWidget {
  const WarehouseReportsScreen({super.key});

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
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: Colors.white)),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Summary', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    const Row(children: [
                      _ReportCard(label: 'Total Received', value: '0', icon: Icons.move_to_inbox_rounded, color: AppColors.primary),
                      SizedBox(width: 12),
                      _ReportCard(label: 'Total Dispatched', value: '0', icon: Icons.outbox_rounded, color: AppColors.success),
                    ]),
                    const SizedBox(height: 12),
                    const Row(children: [
                      _ReportCard(label: 'Returns', value: '0', icon: Icons.assignment_return_rounded, color: AppColors.error),
                      SizedBox(width: 12),
                      _ReportCard(label: 'Pending', value: '0', icon: Icons.pending_rounded, color: AppColors.warning),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Activity Chart', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(height: 160, alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Chart data will appear here', style: TextStyle(color: Colors.white38))),
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

class _ReportCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ReportCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ]),
      ]),
    ));
  }
}
