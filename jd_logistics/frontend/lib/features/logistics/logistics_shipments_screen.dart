import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsShipmentsScreen extends StatelessWidget {
  const LogisticsShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final bg = dark ? AppColors.darkBg1 : const Color(0xFFF5F6FA);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? Colors.white : AppColors.textDark;
    final sub = dark ? AppColors.darkSubtext : AppColors.textDarkSecondary;

    final shipments = [
      _Shipment('JDL-IMP-1001', 'Import', 'Shanghai → Mumbai', '40ft Container', '24,000 kg', 'In Transit', AppColors.primary),
      _Shipment('JDL-EXP-2043', 'Export', 'Delhi → Dubai', 'Bulk Cargo', '8,500 kg', 'Customs Clearance', _kLogisticsColor),
      _Shipment('JDL-IMP-1098', 'Import', 'Rotterdam → Chennai', 'LCL Shipment', '3,200 kg', 'Port Arrival', AppColors.warning),
      _Shipment('JDL-EXP-2071', 'Export', 'Mumbai → Singapore', 'Air Cargo', '450 kg', 'Delivered', AppColors.success),
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
        title: Text('Shipments', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: _kLogisticsColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Import', 'Export', 'In Transit', 'Delivered']
                  .map((f) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: f == 'All' ? _kLogisticsColor : card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: f == 'All' ? _kLogisticsColor : (dark ? AppColors.darkBorder : AppColors.lightBorder)),
                        ),
                        child: Text(f, style: TextStyle(color: f == 'All' ? Colors.white : sub, fontSize: 12, fontWeight: FontWeight.w700)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: shipments.length,
              itemBuilder: (_, i) {
                final s = shipments[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.06), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (s.type == 'Import' ? AppColors.primary : _kLogisticsColor).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(s.type, style: TextStyle(color: s.type == 'Import' ? AppColors.primary : _kLogisticsColor, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.id, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: s.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(s.status, style: TextStyle(color: s.statusColor, fontSize: 9, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.route_rounded, size: 14, color: sub),
                          const SizedBox(width: 4),
                          Expanded(child: Text(s.route, style: TextStyle(color: sub, fontSize: 12), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 14, color: sub),
                          const SizedBox(width: 4),
                          Text(s.cargoType, style: TextStyle(color: sub, fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.scale_rounded, size: 14, color: sub),
                          const SizedBox(width: 4),
                          Text(s.weight, style: TextStyle(color: sub, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Shipment {
  final String id, type, route, cargoType, weight, status;
  final Color statusColor;
  const _Shipment(this.id, this.type, this.route, this.cargoType, this.weight, this.status, this.statusColor);
}
