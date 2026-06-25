import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _anim;
  int _rangeIndex = 0;
  Map<String, dynamic> _apiData = {};

  static const _ranges = ['This Week', 'This Month', 'This Year'];
  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _shipmentData = [12.0, 19.0, 14.0, 24.0, 21.0, 28.0, 16.0];
  static const _revenueData = [4800.0, 9200.0, 6400.0, 13500.0, 11000.0, 17200.0, 8100.0];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await AdminService.instance.getAnalytics();
      if (mounted) setState(() => _apiData = data);
    } catch (_) {}
  }

  String _kpiShipments() {
    final v = (_apiData['shipments_mtd'] as num?)?.toInt();
    if (v == null) return '144';
    return v > 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
  }

  String _kpiRevenue() {
    final v = (_apiData['revenue_mtd'] as num?)?.toDouble();
    if (v == null) return '₹70.2k';
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)}Cr';
    if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹${(v / 1000).toStringAsFixed(1)}k';
  }

  String _kpiDrivers() {
    final v = (_apiData['active_drivers'] as num?)?.toInt();
    return v != null ? '$v' : '18';
  }

  String _kpiOnTime() {
    final v = (_apiData['on_time_delivery'] as num?)?.toDouble();
    return v != null ? '${(v * 100).round()}%' : '92%';
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
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
          title: Text('Analytics',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _rangeIndex,
                  dropdownColor: AppColors.darkBg2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70, size: 18),
                  items: List.generate(
                    _ranges.length,
                    (i) => DropdownMenuItem(
                        value: i,
                        child: Text(_ranges[i],
                            style: const TextStyle(color: Colors.white))),
                  ),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _rangeIndex = v);
                      _animCtrl.forward(from: 0);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // KPI row
                Row(children: [
                  _KpiCard(label: 'Total Shipments', value: _kpiShipments(), icon: Icons.local_shipping_rounded, color: AppColors.primary, anim: _anim),
                  const SizedBox(width: 10),
                  _KpiCard(label: 'Revenue', value: _kpiRevenue(), icon: Icons.currency_rupee_rounded, color: AppColors.success, anim: _anim),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _KpiCard(label: 'Active Drivers', value: _kpiDrivers(), icon: Icons.motorcycle_rounded, color: AppColors.driverColor, anim: _anim),
                  const SizedBox(width: 10),
                  _KpiCard(label: 'On-Time %', value: _kpiOnTime(), icon: Icons.timer_rounded, color: AppColors.warehouseColor, anim: _anim),
                ]),
                const SizedBox(height: 16),

                // Shipments Bar Chart
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.bar_chart_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Shipments Overview',
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        const Text('Total: 144',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ]),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => _BarChart(
                          values: _shipmentData,
                          labels: _weekDays,
                          barColor: AppColors.primary,
                          progress: _anim.value,
                          height: 130,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Revenue Trend
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.trending_up_rounded,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text('Revenue Trend',
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        const Text('₹70.2k',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ]),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => _BarChart(
                          values: _revenueData,
                          labels: _weekDays,
                          barColor: AppColors.success,
                          progress: _anim.value,
                          height: 110,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Shipment mode split
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.pie_chart_rounded,
                            color: AppColors.driverColor, size: 18),
                        const SizedBox(width: 8),
                        Text('Mode Split',
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 18),
                      const _ModeSplitBar(label: 'Road', percent: 0.62, color: AppColors.roadColor),
                      const SizedBox(height: 10),
                      const _ModeSplitBar(label: 'Air', percent: 0.25, color: AppColors.airColor),
                      const SizedBox(height: 10),
                      const _ModeSplitBar(label: 'Ocean', percent: 0.13, color: AppColors.oceanColor),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Top routes
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.route_rounded,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Text('Top Routes',
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 14),
                      const _RouteRow(from: 'Mumbai', to: 'Delhi', count: 32, color: AppColors.primary),
                      const _RouteRow(from: 'Bengaluru', to: 'Chennai', count: 24, color: AppColors.driverColor),
                      const _RouteRow(from: 'Delhi', to: 'Kolkata', count: 19, color: AppColors.warehouseColor),
                      const _RouteRow(from: 'Mumbai', to: 'Dubai', count: 14, color: AppColors.airColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final Animation<double> anim;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Opacity(
          opacity: anim.value,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final double progress;
  final double height;

  const _BarChart({
    required this.values,
    required this.labels,
    required this.barColor,
    required this.progress,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        final barH = (values[i] / maxVal) * height * progress;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 28,
              height: barH.clamp(2, height),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [barColor, barColor.withValues(alpha: 0.4)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Text(labels[i],
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10)),
          ],
        );
      }),
    );
  }
}

class _ModeSplitBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _ModeSplitBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${(percent * 100).round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String from, to;
  final int count;
  final Color color;

  const _RouteRow({
    required this.from,
    required this.to,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(from,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward_rounded,
                size: 12, color: Colors.white38),
          ),
          Text(to,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
