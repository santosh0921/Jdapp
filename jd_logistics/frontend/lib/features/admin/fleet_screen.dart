import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  int _filter = 0;
  bool _isLoading = true;
  String? _error;

  static const _filters = ['All', 'Active', 'Idle', 'Maintenance'];

  List<Map<String, dynamic>> _vehicles = [];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 0) return _vehicles;
    final label = _filters[_filter];
    return _vehicles.where((v) => v['status'] == label).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFleet();
  }

  Future<void> _loadFleet() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await AdminService.instance.getFleet();
      if (!mounted) return;
      setState(() {
        _vehicles = data.map((v) {
          final rawType   = (v['type'] as String? ?? 'bike');
          final typeLabel = rawType == 'truck' || rawType == 'container_truck' ? 'Truck'
              : rawType == 'mini_truck' ? 'Tempo' : 'Bike';
          final rawStatus = (v['status'] as String? ?? 'active');
          final status    = rawStatus == 'maintenance' ? 'Maintenance'
              : rawStatus == 'idle' ? 'Idle' : 'Active';
          return <String, dynamic>{
            'reg':    v['number'] as String? ?? v['id'] as String? ?? '',
            'type':   typeLabel,
            'make':   rawType,
            'driver': v['driver'] as String? ?? 'Unassigned',
            'km':     (v['odometer_km'] as num?)?.toInt() ?? 0,
            'fuel':   75,
            'status': status,
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
              ElevatedButton(onPressed: _loadFleet, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero ─────────────────────────────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                          child: Text('Fleet Management',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Summary chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _StatChip(label: 'Total', value: '${_vehicles.length}'),
                          const SizedBox(width: 8),
                          _StatChip(
                              label: 'Active',
                              value: '${_vehicles.where((v) => v['status'] == 'Active').length}',
                              color: AppColors.warehouseColor),
                          const SizedBox(width: 8),
                          _StatChip(
                              label: 'Idle',
                              value: '${_vehicles.where((v) => v['status'] == 'Idle').length}',
                              color: AppColors.saffron),
                          const SizedBox(width: 8),
                          _StatChip(
                              label: 'Maintenance',
                              value: '${_vehicles.where((v) => v['status'] == 'Maintenance').length}',
                              color: AppColors.error),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_filters.length, (i) {
                          final sel = _filter == i;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _filter = i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_filters[i],
                                  style: TextStyle(
                                      color: sel
                                          ? AppColors.primary
                                          : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w500)),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No vehicles',
                        style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : AppColors.textDarkSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _VehicleCard(data: _filtered[i], isDark: isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label,
      required this.value,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 5),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _VehicleCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String;
    final statusColor = status == 'Active'
        ? AppColors.warehouseColor
        : status == 'Idle'
            ? AppColors.saffron
            : AppColors.error;

    final typeIcon = _typeIcon(data['type'] as String);
    final fuel = data['fuel'] as int;
    final fuelColor = fuel < 20
        ? AppColors.error
        : fuel < 50
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          data['reg'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(data['type'] as String,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    Text(
                      data['make'] as String,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppColors.textDarkSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.person_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : AppColors.textDarkSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data['driver'] as String,
                  style: TextStyle(
                    color:
                        isDark ? Colors.white60 : AppColors.textDarkSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(Icons.speed_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : AppColors.textDarkSecondary),
              const SizedBox(width: 4),
              Text(
                '${data['km']} km',
                style: TextStyle(
                    color:
                        isDark ? Colors.white60 : AppColors.textDarkSecondary,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Fuel',
                style: TextStyle(
                  color:
                      isDark ? Colors.white54 : AppColors.textDarkSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fuel / 100,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : fuelColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(fuelColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$fuel%',
                style: TextStyle(
                    color: fuelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (status == 'Maintenance') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_rounded, color: AppColors.error, size: 13),
                  SizedBox(width: 5),
                  Text('Under maintenance — estimated 2 days',
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Bike':
        return Icons.two_wheeler_rounded;
      case 'Tempo':
        return Icons.airport_shuttle_rounded;
      case 'Van':
        return Icons.directions_car_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }
}
