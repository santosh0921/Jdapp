import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _routeCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _pulse;

  // ── API state ─────────────────────────────────────────────────────────────
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _routeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _heroCtrl.forward();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() { _isLoading = true; _loadError = null; });
    try {
      final result = await AdminService.instance.getDashboard();
      if (mounted) setState(() { _data = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _loadError = e.toString(); _isLoading = false; });
    }
  }

  // ── Safe data accessors with fallbacks ────────────────────────────────────

  double _d(String key, double fallback) {
    final v = _data[key];
    if (v == null) return fallback;
    return (v as num).toDouble();
  }

  int _i(String key, int fallback) {
    final v = _data[key];
    if (v == null) return fallback;
    return (v as num).toInt();
  }

  String _fmtCurrency(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)}Cr';
    if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final auth = context.watch<AuthProvider>();
    final p = _Palette.of(dark);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: p.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text)),
                const SizedBox(height: 8),
                Text(_loadError!, style: TextStyle(fontSize: 12, color: p.sub), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context, dark, p, auth)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildKpiGrid(dark, p),
                  const SizedBox(height: 20),
                  _buildShipmentBreakdown(dark, p),
                  const SizedBox(height: 20),
                  _buildFleetStatus(dark, p),
                  const SizedBox(height: 20),
                  _buildWarehouseStatus(dark, p),
                  const SizedBox(height: 20),
                  _buildLiveActivity(dark, p),
                  const SizedBox(height: 20),
                  _buildQuickActions(context, dark, p),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, bool dark, _Palette p, AuthProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
        ),
      ),
      child: Stack(
        children: [
          // Animated network lines background
          Positioned.fill(child: _NetworkBackground(ctrl: _routeCtrl)),
          // Content
          FadeTransition(
            opacity: _heroFade,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.adminColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.adminColor.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: AppColors.adminColor, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('JD Logistics Control Tower',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              auth.user?.name ?? 'Admin',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _HeroIconBtn(
                        icon: context.read<ThemeProvider>().isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      ),
                      const SizedBox(width: 8),
                      _HeroIconBtn(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                        badge: '7',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Status row
                  Row(
                    children: [
                      _StatusPill(label: 'LIVE', color: AppColors.success, dot: true),
                      const SizedBox(width: 8),
                      _StatusPill(label: '${_i('warehouses_online', 0)} Warehouses Online', color: Colors.white54),
                      const SizedBox(width: 8),
                      _StatusPill(label: '${_i('online_drivers', 0)} Drivers Active', color: Colors.white54),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Revenue highlight
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today\'s Revenue',
                                style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(_fmtCurrency(_d('today_revenue', 0)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                )),
                            Row(
                              children: [
                                const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14),
                                const SizedBox(width: 4),
                                Text('+${_d('revenue_trend', 0).toStringAsFixed(1)}% vs yesterday',
                                    style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Shipments Today',
                              style: TextStyle(color: Colors.white60, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text('${_i('today_shipments', 0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('+${_d('shipments_trend', 0).toStringAsFixed(1)}%',
                                style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KPI Grid ─────────────────────────────────────────────────────────────

  Widget _buildKpiGrid(bool dark, _Palette p) {
    final totalShipments = _i('today_shipments', 0);
    final revenueRaw = _d('revenue', 0);
    final activeDrivers = _i('active_drivers', 0);
    final warehousesOnline = _i('warehouses_online', 0);
    final totalWarehouses = _i('warehouses_total', 0);
    final totalCustomers = _i('total_users', 0);
    final obcCirculating = _d('obc_circulating', 0);
    final shipmentTrend = _d('shipments_trend', 0);
    final revenueTrend = _d('mtd_revenue_trend', 0);
    final newCustomers = _i('new_customers_today', 0);

    final kpis = [
      _Kpi(label: 'Shipments Today', value: '$totalShipments', icon: Icons.local_shipping_rounded, color: 0xFF5EA2FF, trend: '+${shipmentTrend.toStringAsFixed(1)}%', up: true),
      _Kpi(label: 'Revenue (MTD)', value: _fmtCurrency(revenueRaw), icon: Icons.currency_rupee_rounded, color: 0xFF22C55E, trend: '+${revenueTrend.toStringAsFixed(1)}%', up: true),
      _Kpi(label: 'Active Drivers', value: '$activeDrivers', icon: Icons.delivery_dining_rounded, color: 0xFFFF9F2F, trend: '+12', up: true),
      _Kpi(label: 'Warehouses', value: '$warehousesOnline / $totalWarehouses', icon: Icons.warehouse_rounded, color: 0xFF8B5CF6, trend: '${totalWarehouses - warehousesOnline} offline', up: warehousesOnline == totalWarehouses),
      _Kpi(label: 'Customers', value: '$totalCustomers', icon: Icons.people_rounded, color: 0xFF06B6D4, trend: '+$newCustomers today', up: true),
      _Kpi(label: 'OBC Circulating', value: _fmtCurrency(obcCirculating), icon: Icons.toll_rounded, color: 0xFFFF9F2F, trend: '+1,840', up: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionHeader('Key Metrics', Icons.insights_rounded, p),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          children: kpis.map((k) => _KpiCard(kpi: k, dark: dark, p: p)).toList(),
        ),
      ],
    );
  }

  // ── Shipment Breakdown ────────────────────────────────────────────────────

  Widget _buildShipmentBreakdown(bool dark, _Palette p) {
    final total   = _i('total_shipments', 0);
    final today   = _i('today_shipments', 0);
    final pending = _i('pending_orders', 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader('Shipment Breakdown', Icons.donut_large_rounded, p)),
            GestureDetector(
              onTap: () => context.push('/admin/analytics'),
              child: Text('Full Analytics', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _BreakdownStat(label: 'Total', value: '$total', color: const Color(0xFF5EA2FF), icon: Icons.local_shipping_rounded, p: p)),
              Container(width: 1, height: 48, color: p.border),
              Expanded(child: _BreakdownStat(label: 'Today', value: '$today', color: AppColors.success, icon: Icons.today_rounded, p: p)),
              Container(width: 1, height: 48, color: p.border),
              Expanded(child: _BreakdownStat(label: 'Pending', value: '$pending', color: AppColors.warning, icon: Icons.hourglass_empty_rounded, p: p)),
            ],
          ),
        )),
      ],
    );
  }

  // ── Fleet Status ──────────────────────────────────────────────────────────

  Widget _buildFleetStatus(bool dark, _Palette p) {
    final onlineDrivers = _i('online_drivers', 0);
    final totalDrivers  = _i('total_drivers', 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader('Fleet Status', Icons.directions_car_rounded, p)),
            GestureDetector(
              onTap: () => context.push('/admin/fleet'),
              child: Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.local_shipping_rounded, color: AppColors.success, size: 20),
                          const SizedBox(height: 6),
                          Text('$onlineDrivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                          Text('Online', style: TextStyle(fontSize: 10, color: p.sub)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5EA2FF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.hourglass_empty_rounded, color: Color(0xFF5EA2FF), size: 20),
                          const SizedBox(height: 6),
                          Text('${totalDrivers - onlineDrivers}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                          Text('Offline', style: TextStyle(fontSize: 10, color: p.sub)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F2F).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.people_rounded, color: Color(0xFFFF9F2F), size: 20),
                          const SizedBox(height: 6),
                          Text('$totalDrivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                          Text('Total', style: TextStyle(fontSize: 10, color: p.sub)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (totalDrivers > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: onlineDrivers / totalDrivers,
                    backgroundColor: const Color(0xFF5EA2FF).withValues(alpha: 0.2),
                    color: AppColors.success,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$totalDrivers registered drivers', style: TextStyle(fontSize: 11, color: p.sub)),
                    Text('${totalDrivers > 0 ? (onlineDrivers / totalDrivers * 100).round() : 0}% online',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ],
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  // ── Warehouse Status ──────────────────────────────────────────────────────

  Widget _buildWarehouseStatus(bool dark, _Palette p) {
    final online = _i('warehouses_online', 0);
    final total  = _i('total_warehouses', 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader('Warehouse Status', Icons.warehouse_rounded, p)),
            GestureDetector(
              onTap: () => context.push('/admin/warehouses'),
              child: Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warehouse_rounded, color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$online Online', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                      Text(total > 0 ? 'of $total warehouses' : 'warehouses active', style: TextStyle(fontSize: 12, color: p.sub)),
                    ],
                  ),
                  const Spacer(),
                  if (total > 0) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${(online / total * 100).round()}% online',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Tap "View All" to see individual warehouse details.',
                  style: TextStyle(fontSize: 11, color: p.sub)),
            ],
          ),
        )),
      ],
    );
  }

  // ── Live Activity ─────────────────────────────────────────────────────────

  Widget _buildLiveActivity(bool dark, _Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Live Activity', Icons.bolt_rounded, p),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: p.sub, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No recent activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text)),
                    const SizedBox(height: 4),
                    Text('Activity feed requires a live event stream from the backend.',
                        style: TextStyle(fontSize: 11, color: p.sub)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, bool dark, _Palette p) {
    final actions = [
      _Action(icon: Icons.group_rounded, label: 'Users', color: AppColors.primary, route: '/admin/users'),
      _Action(icon: Icons.delivery_dining_rounded, label: 'Drivers', color: AppColors.driverColor, route: '/admin/drivers'),
      _Action(icon: Icons.warehouse_rounded, label: 'Warehouses', color: AppColors.warehouseColor, route: '/admin/warehouses'),
      _Action(icon: Icons.directions_car_rounded, label: 'Fleet', color: const Color(0xFF8B5CF6), route: '/admin/fleet'),
      _Action(icon: Icons.local_shipping_rounded, label: 'Shipments', color: AppColors.success, route: '/admin/shipments'),
      _Action(icon: Icons.payments_rounded, label: 'Payments', color: AppColors.saffron, route: '/admin/payments'),
      _Action(icon: Icons.shield_rounded, label: 'Security', color: AppColors.error, route: '/admin/security'),
      _Action(icon: Icons.history_rounded, label: 'Audit Log', color: AppColors.primary, route: '/admin/audit-logs'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Actions', Icons.grid_view_rounded, p),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions.map((a) => GestureDetector(
            onTap: () => context.push(a.route),
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(2, 2)),
                  BoxShadow(color: p.highlight, blurRadius: 3, offset: const Offset(-1, -1)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.icon, color: a.color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(a.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: p.sub),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, _Palette p) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.text)),
      ],
    );
  }
}

// ── Network Background Painter ────────────────────────────────────────────────

class _NetworkBackground extends StatelessWidget {
  final AnimationController ctrl;
  const _NetworkBackground({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => CustomPaint(
          painter: _NetworkPainter(ctrl.value),
        ),
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final double t;
  _NetworkPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final nodes = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width * 0.95, size.height * 0.6),
    ];

    for (int i = 0; i < nodes.length - 1; i++) {
      canvas.drawLine(nodes[i], nodes[i + 1], paint);
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    for (final n in nodes) {
      canvas.drawCircle(n, 3, dotPaint);
    }

    // Moving dot along path
    final movingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final idx = (t * (nodes.length - 1)).floor().clamp(0, nodes.length - 2);
    final frac = (t * (nodes.length - 1)) - idx;
    final pos = Offset.lerp(nodes[idx], nodes[idx + 1], frac)!;
    canvas.drawCircle(pos, 4, movingPaint);
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.t != t;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BreakdownStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final _Palette p;

  const _BreakdownStat({required this.label, required this.value, required this.color, required this.icon, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
        Text(label, style: TextStyle(fontSize: 10, color: p.sub)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  final bool dark;
  final _Palette p;

  const _KpiCard({required this.kpi, required this.dark, required this.p});

  @override
  Widget build(BuildContext context) {
    final color = Color(kpi.color);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(3, 3)),
          BoxShadow(color: p.highlight, blurRadius: 5, offset: const Offset(-2, -2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kpi.icon, color: color, size: 17),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (kpi.up ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(kpi.trend,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: kpi.up ? AppColors.success : AppColors.error,
                    )),
              ),
            ],
          ),
          const Spacer(),
          Text(kpi.value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: p.text),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(kpi.label,
              style: TextStyle(fontSize: 10, color: p.sub),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _HeroIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  const _HeroIconBtn({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const _StatusPill({required this.label, required this.color, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ClayCard extends StatelessWidget {
  final bool dark;
  final _Palette p;
  final Widget child;

  const _ClayCard({required this.dark, required this.p, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 14, offset: const Offset(4, 4)),
          BoxShadow(color: p.highlight, blurRadius: 6, offset: const Offset(-2, -2)),
        ],
      ),
      child: child,
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _Kpi {
  final String label, value, trend;
  final IconData icon;
  final int color;
  final bool up;
  const _Kpi({required this.label, required this.value, required this.icon, required this.color, required this.trend, required this.up});
}



class _Action {
  final IconData icon;
  final String label, route;
  final Color color;
  const _Action({required this.icon, required this.label, required this.color, required this.route});
}

// ── Palette ───────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, inner, border;
  const _Palette({required this.bg, required this.card, required this.highlight, required this.shadow, required this.text, required this.sub, required this.inner, required this.border});

  factory _Palette.of(bool dark) => dark
      ? _Palette(bg: AppColors.darkBg1, card: AppColors.darkCard, highlight: AppColors.clayHighlightDark, shadow: AppColors.clayShadowDark, text: Colors.white, sub: AppColors.darkSubtext, inner: AppColors.darkBg3, border: AppColors.darkBorder)
      : _Palette(bg: const Color(0xFFF5F6FA), card: Colors.white, highlight: AppColors.clayHighlight, shadow: AppColors.clayShadow, text: AppColors.textDark, sub: AppColors.textDarkSecondary, inner: const Color(0xFFF0F2F8), border: const Color(0xFFE8EDF5));
}
