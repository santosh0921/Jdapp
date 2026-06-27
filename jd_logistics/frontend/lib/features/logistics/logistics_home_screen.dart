import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/services/logistics_service.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);

class LogisticsHomeScreen extends StatefulWidget {
  const LogisticsHomeScreen({super.key});
  @override
  State<LogisticsHomeScreen> createState() => _LogisticsHomeScreenState();
}

class _LogisticsHomeScreenState extends State<LogisticsHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _routeCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _routeAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;

  List<Map<String, dynamic>> _orders = [];
  bool _ordersLoading = true;

  @override
  void initState() {
    super.initState();
    _routeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _routeAnim = CurvedAnimation(parent: _routeCtrl, curve: Curves.linear);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await LogisticsService.instance.getOrders();
      if (mounted) setState(() { _orders = orders; _ordersLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _ordersLoading = false);
    }
  }

  @override
  void dispose() {
    _routeCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;
    final bg = isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8);
    final card = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.textWhite : _kNavy;
    final textSub = isDark ? AppColors.darkSubtext : const Color(0xFF64748B);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(isDark, textPrimary, textSub),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  _buildGlobalRouteCard(isDark),
                  const SizedBox(height: 20),
                  _buildKpiRow(isDark, card, textPrimary, textSub),
                  const SizedBox(height: 24),
                  _buildAiStrip(isDark, card, textPrimary, textSub),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Quick Actions', textPrimary),
                  const SizedBox(height: 12),
                  _buildActionGrid(isDark, card),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Active Shipments', textPrimary),
                  const SizedBox(height: 12),
                  _buildActiveShipments(isDark, card, textPrimary, textSub),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Network Highlights', textPrimary),
                  const SizedBox(height: 12),
                  _buildNetworkHighlights(isDark, card, textPrimary, textSub),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(bool isDark, Color textPrimary, Color textSub) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _kTeal,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: _kTeal.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5))),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JD LOGISTICS', style: TextStyle(color: _kTeal, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2)),
                      Text('Enterprise Freight Platform', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const Spacer(),
                  _NotifBell(isDark: isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Global Route Card ──────────────────────────────────────────────────────

  Widget _buildGlobalRouteCard(bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_kNavy, Color(0xFF1A3F6F), _kTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _routeAnim,
                builder: (_, __) => CustomPaint(
                  painter: _GlobalRoutePainter(progress: _routeAnim.value),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.public, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('GLOBAL NETWORK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: _pulseAnim.value * 0.8), blurRadius: 6, spreadRadius: 2)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('LIVE', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ],
                  ),
                  const Spacer(),
                  const Text('Active Route', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Mumbai → Dubai → Rotterdam', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/logistics/network'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View Map', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _RouteChip(label: '🚢  Sea', active: true),
                      const SizedBox(width: 6),
                      _RouteChip(label: '28 days'),
                      const SizedBox(width: 6),
                      _RouteChip(label: '12,500 km'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI Row ────────────────────────────────────────────────────────────────

  Widget _buildKpiRow(bool isDark, Color card, Color textPrimary, Color textSub) {
    final active = _orders.where((o) => !['delivered', 'cancelled'].contains(o['status'] as String? ?? '')).length;
    final inTransit = _orders.where((o) => (o['status'] as String? ?? '') == 'in_transit').length;
    final delivered = _orders.where((o) => (o['status'] as String? ?? '') == 'delivered').length;
    final customs = _orders.where((o) => ['customs', 'customs_hold'].contains(o['status'] as String? ?? '')).length;

    final kpis = [
      {'label': 'Active', 'value': _ordersLoading ? '—' : '$active', 'icon': Icons.local_shipping_outlined, 'color': _kTeal},
      {'label': 'In Transit', 'value': _ordersLoading ? '—' : '$inTransit', 'icon': Icons.directions_boat_outlined, 'color': const Color(0xFF3B82F6)},
      {'label': 'Delivered', 'value': _ordersLoading ? '—' : '$delivered', 'icon': Icons.check_circle_outline, 'color': const Color(0xFF22C55E)},
      {'label': 'Customs', 'value': _ordersLoading ? '—' : '$customs', 'icon': Icons.gavel_outlined, 'color': _kSaffron},
    ];
    return Row(
      children: kpis.asMap().entries.map((entry) {
        final i = entry.key;
        final k = entry.value;
        final color = k['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < kpis.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.18)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Icon(k['icon'] as IconData, color: color, size: 20),
                const SizedBox(height: 6),
                Text(k['value'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 2),
                Text(k['label'] as String, style: TextStyle(color: textSub, fontSize: 9.5, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── AI Strip ───────────────────────────────────────────────────────────────

  Widget _buildAiStrip(bool isDark, Color card, Color textPrimary, Color textSub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kTeal.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_kTeal, _kTeal.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _kTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('AI Recommendation', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(6)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 3),
                Text('Rail freight via CONCOR saves ₹18,400 on your next steel coil shipment.', style: TextStyle(color: textSub, fontSize: 11.5, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: textSub),
        ],
      ),
    );
  }

  // ── Action Grid ────────────────────────────────────────────────────────────

  Widget _buildActionGrid(bool isDark, Color card) {
    final actions = [
      {'label': 'Import', 'icon': Icons.south_west_rounded, 'color': const Color(0xFF3B82F6), 'route': '/logistics/import'},
      {'label': 'Export', 'icon': Icons.north_east_rounded, 'color': const Color(0xFF22C55E), 'route': '/logistics/export'},
      {'label': 'Container', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFF8B5CF6), 'route': '/logistics/container'},
      {'label': 'Freight\nQuote', 'icon': Icons.calculate_outlined, 'color': _kSaffron, 'route': '/logistics/freight-quote'},
      {'label': 'Create\nOrder', 'icon': Icons.add_circle_outline, 'color': _kTeal, 'route': '/logistics/create-order'},
      {'label': 'Warehouse', 'icon': Icons.warehouse_outlined, 'color': const Color(0xFF06B6D4), 'route': '/logistics/warehouse-storage'},
      {'label': 'Analytics', 'icon': Icons.bar_chart_outlined, 'color': const Color(0xFFEC4899), 'route': '/logistics/analytics'},
      {'label': 'Network', 'icon': Icons.public_outlined, 'color': _kNavy, 'route': '/logistics/network'},
      {'label': 'Track', 'icon': Icons.gps_fixed_outlined, 'color': const Color(0xFFF59E0B), 'route': '/logistics/tracking'},
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: actions.map((a) => _ActionCard(
        label: a['label'] as String,
        icon: a['icon'] as IconData,
        color: a['color'] as Color,
        isDark: isDark,
        card: card,
        onTap: () => context.push(a['route'] as String),
      )).toList(),
    );
  }

  Widget _buildSectionLabel(String label, Color textPrimary) {
    return Row(
      children: [
        Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
      ],
    );
  }

  // ── Active Shipments ───────────────────────────────────────────────────────

  Widget _buildActiveShipments(bool isDark, Color card, Color textPrimary, Color textSub) {
    if (_ordersLoading) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
    }
    if (_orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.local_shipping_outlined, color: textSub, size: 36),
              const SizedBox(height: 8),
              Text('No active shipments', style: TextStyle(color: textSub, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _orders.take(5).map((o) {
        final id = o['id']?.toString() ?? '—';
        final status = o['status'] as String? ?? 'pending';
        final origin = o['origin_city'] as String? ?? o['pickup_address'] as String? ?? '—';
        final dest = o['destination_city'] as String? ?? o['delivery_address'] as String? ?? '—';
        final goods = o['goods_description'] as String? ?? o['cargo_type'] as String? ?? '—';
        final eta = o['estimated_delivery'] as String? ?? o['delivery_eta'] as String? ?? '—';
        final statusColor = _kpiStatusColor(status);
        final displayStatus = _kpiDisplayStatus(status);

        return GestureDetector(
          onTap: () => context.push('/logistics/tracking'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(id, style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text('$origin → $dest', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(goods, style: TextStyle(color: textSub, fontSize: 11.5), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(displayStatus, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    Text('ETA: $eta', style: TextStyle(color: textSub, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _kpiStatusColor(String status) {
    switch (status) {
      case 'delivered': return const Color(0xFF22C55E);
      case 'in_transit': return const Color(0xFF3B82F6);
      case 'customs': case 'customs_hold': return _kSaffron;
      case 'cancelled': return const Color(0xFFEF4444);
      default: return _kTeal;
    }
  }

  String _kpiDisplayStatus(String status) {
    switch (status) {
      case 'in_transit': return 'In Transit';
      case 'delivered': return 'Delivered';
      case 'customs_hold': return 'Customs Hold';
      case 'cancelled': return 'Cancelled';
      case 'pending': return 'Pending';
      default: return status.replaceAll('_', ' ');
    }
  }

  // ── Network Highlights ─────────────────────────────────────────────────────

  Widget _buildNetworkHighlights(bool isDark, Color card, Color textPrimary, Color textSub) {
    final highlights = [
      {'port': 'JNPT Mumbai', 'country': '🇮🇳', 'vessels': '14', 'status': 'Operational'},
      {'port': 'Jebel Ali', 'country': '🇦🇪', 'vessels': '8', 'status': 'Congested'},
      {'port': 'Rotterdam', 'country': '🇳🇱', 'vessels': '22', 'status': 'Operational'},
      {'port': 'Singapore', 'country': '🇸🇬', 'vessels': '31', 'status': 'Operational'},
      {'port': 'Shanghai', 'country': '🇨🇳', 'vessels': '47', 'status': 'Operational'},
    ];
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: highlights.map((h) {
          final isOp = h['status'] == 'Operational';
          final statusColor = isOp ? const Color(0xFF22C55E) : _kSaffron;
          return Container(
            width: 148,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kTeal.withValues(alpha: 0.12)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(h['country'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  const Icon(Icons.anchor, size: 13, color: _kTeal),
                ]),
                const SizedBox(height: 6),
                Text(h['port'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${h['vessels']} vessels', style: TextStyle(color: textSub, fontSize: 11)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(h['status'] as String, style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Color card;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.icon, required this.color, required this.isDark, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06), blurRadius: 10, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.9), blurRadius: 1, offset: const Offset(0, -1)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isDark ? AppColors.textWhite : _kNavy, fontWeight: FontWeight.w700, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final String label;
  final bool active;
  const _RouteChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: active ? 0.5 : 0.2)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _NotifBell extends StatelessWidget {
  final bool isDark;
  const _NotifBell({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Icon(Icons.notifications_outlined, size: 20, color: isDark ? AppColors.textWhite : _kNavy),
        ),
        Positioned(
          top: -2, right: -2,
          child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: _kSaffron, shape: BoxShape.circle)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Route Painter
// ─────────────────────────────────────────────────────────────────────────────

class _GlobalRoutePainter extends CustomPainter {
  final double progress;
  const _GlobalRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = 0; y <= size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Sea route
    final seaPath = Path();
    seaPath.moveTo(size.width * 0.13, size.height * 0.68);
    seaPath.quadraticBezierTo(size.width * 0.38, size.height * 0.25, size.width * 0.6, size.height * 0.48);
    seaPath.quadraticBezierTo(size.width * 0.78, size.height * 0.62, size.width * 0.94, size.height * 0.22);

    final metrics = seaPath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final m = metrics.first;
      final len = m.length;
      final trailStart = (progress - 0.28).clamp(0.0, 1.0);
      final trailPaint = Paint()
        ..color = const Color(0xFF4ADE80).withValues(alpha: 0.55)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(m.extractPath(trailStart * len, progress * len), trailPaint);

      final tang = m.getTangentForOffset(progress * len);
      if (tang != null) {
        canvas.drawCircle(tang.position, 5, Paint()..color = Colors.white);
        canvas.drawCircle(tang.position, 3.5, Paint()..color = const Color(0xFF4ADE80));
      }
    }

    // Port dots
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.7)..style = PaintingStyle.fill;
    final ringPaint = Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.fill;
    for (final pt in [
      Offset(size.width * 0.13, size.height * 0.68),
      Offset(size.width * 0.6, size.height * 0.48),
      Offset(size.width * 0.94, size.height * 0.22),
    ]) {
      canvas.drawCircle(pt, 7, ringPaint);
      canvas.drawCircle(pt, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GlobalRoutePainter old) => old.progress != progress;
}
