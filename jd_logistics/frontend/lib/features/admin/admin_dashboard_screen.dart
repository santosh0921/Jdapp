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
                      _StatusPill(label: '${_i('warehouses_online', 18)} Warehouses Online', color: Colors.white54),
                      const SizedBox(width: 8),
                      _StatusPill(label: '${_i('drivers_online', 284)} Drivers Active', color: Colors.white54),
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
                            Text(_fmtCurrency(_d('today_revenue', 284750.0)),
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
                                Text('+${_d('revenue_trend', 14.2).toStringAsFixed(1)}% vs yesterday',
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
                          Text('${_i('total_shipments_today', 1842)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('+${_d('shipments_trend', 8.7).toStringAsFixed(1)}%',
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
    final totalShipments = _i('total_shipments_today', 1842);
    final revenueRaw = _d('mtd_revenue', 28400000);
    final activeDrivers = _i('active_drivers', 342);
    final warehousesOnline = _i('warehouses_online', 18);
    final totalWarehouses = _i('warehouses_total', 20);
    final totalCustomers = _i('total_customers', 48291);
    final obcCirculating = _d('obc_circulating', 1284000);
    final shipmentTrend = _d('shipments_trend', 8.7);
    final revenueTrend = _d('mtd_revenue_trend', 14.2);
    final newCustomers = _i('new_customers_today', 214);

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
    const modes = [
      _Mode(label: 'Road', icon: Icons.local_shipping_rounded, value: '28,420', pct: 0.59, color: 0xFF5EA2FF),
      _Mode(label: 'Air', icon: Icons.flight_rounded, value: '8,142', pct: 0.17, color: 0xFF22C55E),
      _Mode(label: 'Sea', icon: Icons.directions_boat_rounded, value: '4,821', pct: 0.10, color: 0xFF8B5CF6),
      _Mode(label: 'Bike', icon: Icons.delivery_dining_rounded, value: '6,908', pct: 0.14, color: 0xFFFF9F2F),
    ];
    const intl = [
      _Segment(label: 'Domestic', value: 0.73, color: 0xFF5EA2FF),
      _Segment(label: 'International', value: 0.27, color: 0xFF22C55E),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Shipment Breakdown', Icons.donut_large_rounded, p),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Domestic vs International
              Row(
                children: intl.map((s) => Expanded(
                  flex: (s.value * 100).round(),
                  child: Container(
                    height: 8,
                    margin: EdgeInsets.only(right: s == intl.last ? 0 : 4),
                    decoration: BoxDecoration(
                      color: Color(s.color),
                      borderRadius: s == intl.first
                          ? const BorderRadius.horizontal(left: Radius.circular(4))
                          : const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: intl.map((s) => Expanded(
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(s.color), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('${s.label} ${(s.value * 100).round()}%',
                          style: TextStyle(fontSize: 11, color: p.sub)),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              // Mode breakdown
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: modes.map((m) {
                  final color = Color(m.color);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(m.icon, color: color, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(m.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.text), overflow: TextOverflow.ellipsis),
                              Text(m.label, style: TextStyle(fontSize: 10, color: p.sub)),
                            ],
                          ),
                        ),
                        Text('${(m.pct * 100).round()}%',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Fleet Status ──────────────────────────────────────────────────────────

  Widget _buildFleetStatus(bool dark, _Palette p) {
    const statuses = [
      _FleetStatus(label: 'Active', count: 71, color: 0xFF22C55E, icon: Icons.local_shipping_rounded),
      _FleetStatus(label: 'Idle', count: 8, color: 0xFF5EA2FF, icon: Icons.hourglass_empty_rounded),
      _FleetStatus(label: 'Maintenance', count: 5, color: 0xFFFF9F2F, icon: Icons.build_rounded),
    ];

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
                children: statuses.map((s) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: s == statuses.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Color(s.color).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(s.icon, color: Color(s.color), size: 20),
                        const SizedBox(height: 6),
                        Text('${s.count}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.text)),
                        Text(s.label, style: TextStyle(fontSize: 10, color: p.sub)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 14),
              // Fleet bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: statuses.map((s) => Flexible(
                    flex: s.count,
                    child: Container(height: 6, color: Color(s.color)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('84 total vehicles', style: TextStyle(fontSize: 11, color: p.sub)),
                  Text('${(71 / 84 * 100).round()}% utilization',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Warehouse Status ──────────────────────────────────────────────────────

  Widget _buildWarehouseStatus(bool dark, _Palette p) {
    const warehouses = [
      _WarehouseStatus(name: 'Bengaluru East', code: 'WH-007', pct: 0.74, status: 'active'),
      _WarehouseStatus(name: 'Mumbai North', code: 'WH-003', pct: 0.88, status: 'active'),
      _WarehouseStatus(name: 'Delhi West', code: 'WH-001', pct: 0.61, status: 'active'),
      _WarehouseStatus(name: 'Chennai South', code: 'WH-009', pct: 0.40, status: 'maintenance'),
    ];

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
        _ClayCard(dark: dark, p: p, child: Column(
          children: warehouses.asMap().entries.map((e) {
            final i = e.key;
            final w = e.value;
            final isMaint = w.status == 'maintenance';
            final color = isMaint ? AppColors.warning : (w.pct > 0.85 ? AppColors.error : AppColors.success);
            return Column(
              children: [
                if (i > 0) Divider(height: 1, thickness: 1, color: p.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.warehouse_rounded, color: color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.text), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: w.pct,
                                backgroundColor: p.inner,
                                color: color,
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(w.pct * 100).round()}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                          Text(w.code, style: TextStyle(fontSize: 10, color: p.sub)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        )),
      ],
    );
  }

  // ── Live Activity ─────────────────────────────────────────────────────────

  Widget _buildLiveActivity(bool dark, _Palette p) {
    const events = [
      _Activity(icon: Icons.check_circle_rounded, color: 0xFF22C55E, text: 'JD-IND-4822 delivered in Mumbai', time: '2m ago'),
      _Activity(icon: Icons.warning_rounded, color: 0xFFFF9F2F, text: 'JD-IND-4801 delayed — Pune Hub', time: '8m ago'),
      _Activity(icon: Icons.person_add_rounded, color: 0xFF5EA2FF, text: 'New driver onboarded: Rajesh K.', time: '15m ago'),
      _Activity(icon: Icons.local_shipping_rounded, color: 0xFF8B5CF6, text: 'Air cargo JD-AIR-091 departed DEL', time: '32m ago'),
      _Activity(icon: Icons.currency_rupee_rounded, color: 0xFF22C55E, text: 'Driver payout ₹12,400 processed', time: '1h ago'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Live Activity', Icons.bolt_rounded, p),
        const SizedBox(height: 12),
        _ClayCard(dark: dark, p: p, child: Column(
          children: events.asMap().entries.map((e) {
            final i = e.key;
            final act = e.value;
            return Column(
              children: [
                if (i > 0) Divider(height: 1, thickness: 1, color: p.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(act.color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(act.icon, color: Color(act.color), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(act.text,
                            style: TextStyle(fontSize: 12, color: p.text, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(act.time, style: TextStyle(fontSize: 10, color: p.sub)),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
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

class _Mode {
  final String label, value;
  final IconData icon;
  final double pct;
  final int color;
  const _Mode({required this.label, required this.icon, required this.value, required this.pct, required this.color});
}

class _Segment {
  final String label;
  final double value;
  final int color;
  const _Segment({required this.label, required this.value, required this.color});
}

class _FleetStatus {
  final String label;
  final int count, color;
  final IconData icon;
  const _FleetStatus({required this.label, required this.count, required this.color, required this.icon});
}

class _WarehouseStatus {
  final String name, code, status;
  final double pct;
  const _WarehouseStatus({required this.name, required this.code, required this.pct, required this.status});
}

class _Activity {
  final IconData icon;
  final int color;
  final String text, time;
  const _Activity({required this.icon, required this.color, required this.text, required this.time});
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
