import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  int _filter = 0;
  bool _isLoading = false;
  String? _error;

  static const _filters = ['All', 'Online', 'Offline', 'Suspended'];

  List<Map<String, dynamic>> _drivers = const [
    {'name': 'Ramesh Sharma', 'phone': '+91 98700 12345', 'vehicle': 'Hero Splendor — MH12AB1234', 'deliveries': 147, 'rating': '4.9', 'earnings': '₹18,450', 'status': 'Online'},
    {'name': 'Suresh Kumar',  'phone': '+91 87600 23456', 'vehicle': 'Honda Activa — KA03CD5678', 'deliveries': 89,  'rating': '4.7', 'earnings': '₹11,200', 'status': 'Online'},
    {'name': 'Anil Rao',      'phone': '+91 76600 34567', 'vehicle': 'TVS Jupiter — TN09EF9012',  'deliveries': 212, 'rating': '4.8', 'earnings': '₹24,800', 'status': 'Offline'},
    {'name': 'Priya Devi',    'phone': '+91 65600 45678', 'vehicle': 'Bajaj Pulsar — DL07GH3456', 'deliveries': 54,  'rating': '4.6', 'earnings': '₹6,900',  'status': 'Online'},
    {'name': 'Karan Singh',   'phone': '+91 54600 56789', 'vehicle': 'Royal Enfield — UP32IJ7890','deliveries': 18,  'rating': '3.8', 'earnings': '₹2,100',  'status': 'Suspended'},
    {'name': 'Divya Menon',   'phone': '+91 43600 67890', 'vehicle': 'Ather 450X — KL07KL1234',   'deliveries': 76,  'rating': '4.9', 'earnings': '₹9,300',  'status': 'Offline'},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 0) return _drivers;
    final label = _filters[_filter];
    return _drivers.where((d) => d['status'] == label).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await AdminService.instance.getDrivers();
      if (!mounted) return;
      setState(() {
        _drivers = data.map((d) {
          final rawStatus = (d['status'] as String? ?? 'online');
          final status = rawStatus == 'online' ? 'Online'
              : rawStatus == 'offline' ? 'Offline'
              : 'Suspended';
          final vType = (d['vehicle_type'] as String? ?? 'bike');
          final vLabel = vType == 'truck' ? 'Truck'
              : vType == 'mini_truck' ? 'Mini Truck'
              : 'Bike';
          return <String, dynamic>{
            'name':       d['name']  as String? ?? 'Driver',
            'phone':      d['phone'] as String? ?? '',
            'vehicle':    '$vLabel — ${d['id'] ?? ''}',
            'deliveries': (d['deliveries_today'] as num?)?.toInt() ?? 0,
            'rating':     (d['rating'] as num?)?.toStringAsFixed(1) ?? '4.5',
            'earnings':   '₹${((d['earnings_today'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}',
            'status':     status,
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
              ElevatedButton(onPressed: _loadDrivers, child: const Text('Retry')),
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
                          child: Text('Driver Management',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('62 Total',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stats
                    const Row(
                      children: [
                        _HeroStat(label: 'Online', value: '47', color: AppColors.warehouseColor),
                        SizedBox(width: 10),
                        _HeroStat(label: 'Offline', value: '12', color: Colors.white60),
                        SizedBox(width: 10),
                        _HeroStat(label: 'Suspended', value: '3', color: AppColors.error),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Filter chips
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
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _filters[i],
                                style: TextStyle(
                                  color: sel
                                      ? AppColors.primary
                                      : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
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
                    child: Text(
                      'No drivers in this category',
                      style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : AppColors.textDarkSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DriverCard(data: _filtered[i], isDark: isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _DriverCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String;
    final statusColor = status == 'Online'
        ? AppColors.warehouseColor
        : status == 'Offline'
            ? AppColors.textDarkSecondary
            : AppColors.error;

    final initials = (data['name'] as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppColors.saffron.withValues(alpha: 0.15),
                    child: Text(initials,
                        style: const TextStyle(
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                isDark ? AppColors.darkCard : Colors.white,
                            width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data['phone'] as String,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['vehicle'] as String,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textDarkSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(label: 'Deliveries', value: '${data['deliveries']}', isDark: isDark),
              const SizedBox(width: 16),
              _Stat(label: 'Rating', value: '${data['rating']}★', isDark: isDark),
              const SizedBox(width: 16),
              _Stat(label: 'Earnings', value: data['earnings'] as String, isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Call',
                  icon: Icons.call_rounded,
                  color: AppColors.warehouseColor,
                  onTap: () => HapticFeedback.mediumImpact(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: 'Message',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: status == 'Suspended' ? 'Reinstate' : 'Suspend',
                  icon: status == 'Suspended'
                      ? Icons.check_circle_outline_rounded
                      : Icons.block_rounded,
                  color: status == 'Suspended'
                      ? AppColors.warehouseColor
                      : AppColors.error,
                  onTap: () => HapticFeedback.mediumImpact(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _Stat({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            )),
        Text(label,
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
              fontSize: 11,
            )),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
