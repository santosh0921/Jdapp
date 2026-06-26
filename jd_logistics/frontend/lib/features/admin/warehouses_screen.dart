import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _warehouses = [];

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await AdminService.instance.getWarehouses();
      if (!mounted) return;
      setState(() {
        _warehouses = data.map((w) {
          final pct    = (w['capacity_pct'] as num?)?.toDouble() ?? 0.6;
          final sqFt   = (w['total_sq_ft'] as num?)?.toInt() ?? 50000;
          final cap    = sqFt ~/ 10;
          final used   = (cap * pct).round();
          final status = w['status'] == 'maintenance' ? 'Under Maintenance'
              : pct > 0.85 ? 'Near Capacity' : 'Operational';
          return <String, dynamic>{
            'id':       w['code'] ?? w['id'] ?? '',
            'name':     w['name'] ?? '',
            'location': w['city'] ?? '',
            'capacity': cap,
            'used':     used,
            'staff':    12,
            'status':   status,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCount = _warehouses.where((w) => w['status'] != 'Under Maintenance').length;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Load failed', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textDark)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadWarehouses, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final totalCap  = _warehouses.fold(0, (s, w) => s + (w['capacity'] as int));
    final totalUsed = _warehouses.fold(0, (s, w) => s + (w['used'] as int));
    final utilPct   = totalCap > 0 ? '${(totalUsed / totalCap * 100).round()}%' : '0%';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Warehouses',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('$activeCount Active',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ChipStat(label: 'Total Capacity', value: '$totalCap units'),
                        const SizedBox(width: 10),
                        _ChipStat(label: 'Utilization', value: utilPct),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _warehouses.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _WarehouseCard(data: _warehouses[i], isDark: isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  final bool warn;

  const _ChipStat(
      {required this.label, required this.value, this.warn = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: warn ? AppColors.saffron : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _WarehouseCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final used = data['used'] as int;
    final cap = data['capacity'] as int;
    final pct = used / cap;
    final status = data['status'] as String;
    final statusColor = status == 'Operational'
        ? AppColors.warehouseColor
        : status == 'Near Capacity'
            ? AppColors.saffron
            : AppColors.error;
    final barColor = pct > 0.9
        ? AppColors.error
        : pct > 0.75
            ? AppColors.saffron
            : AppColors.warehouseColor;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warehouseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warehouse_rounded,
                    color: AppColors.warehouseColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          data['id'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    Text(
                      data['name'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data['location'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Capacity bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Capacity',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.textDarkSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$used / $cap  (${(pct * 100).round()}%)',
                          style: TextStyle(
                            color: barColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : barColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.group_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : AppColors.textDarkSecondary),
              const SizedBox(width: 4),
              Text(
                '${data['staff']} staff',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
