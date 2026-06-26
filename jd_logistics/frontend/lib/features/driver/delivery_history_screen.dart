import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/driver_service.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Delivered', 'Failed', 'Returned'];

  static const _deliveries = [
    _Delivery(
      id: 'JD-DL-4821',
      recipient: 'Priya Sharma',
      address: '12, MG Road, Bengaluru, KA 560001',
      date: '18 Jun 2025',
      time: '11:42 AM',
      status: 'delivered',
      distance: '8.4 km',
      earnings: 128.0,
      obc: 12,
      weight: '2.3 kg',
      payMode: 'Prepaid',
    ),
    _Delivery(
      id: 'JD-DL-4820',
      recipient: 'Rahul Verma',
      address: '7, Link Road, Andheri West, Mumbai, MH',
      date: '18 Jun 2025',
      time: '09:15 AM',
      status: 'delivered',
      distance: '5.2 km',
      earnings: 96.0,
      obc: 9,
      weight: '1.1 kg',
      payMode: 'COD',
    ),
    _Delivery(
      id: 'JD-DL-4819',
      recipient: 'Sonal Mehta',
      address: '34B, Sector 18, Noida, UP 201301',
      date: '17 Jun 2025',
      time: '04:30 PM',
      status: 'failed',
      distance: '3.7 km',
      earnings: 0.0,
      obc: 0,
      weight: '0.8 kg',
      payMode: 'Prepaid',
    ),
    _Delivery(
      id: 'JD-DL-4818',
      recipient: 'Ankit Gupta',
      address: '5, Race Course Road, Chennai, TN 600006',
      date: '17 Jun 2025',
      time: '02:10 PM',
      status: 'delivered',
      distance: '11.8 km',
      earnings: 172.0,
      obc: 17,
      weight: '4.5 kg',
      payMode: 'Prepaid',
    ),
    _Delivery(
      id: 'JD-DL-4817',
      recipient: 'Kavya Nair',
      address: 'Kalathipady, Kottayam, Kerala 686001',
      date: '16 Jun 2025',
      time: '12:55 PM',
      status: 'returned',
      distance: '6.1 km',
      earnings: 48.0,
      obc: 4,
      weight: '1.8 kg',
      payMode: 'COD',
    ),
    _Delivery(
      id: 'JD-DL-4816',
      recipient: 'Deepak Singh',
      address: '9, Ashok Nagar, Jaipur, RJ 302001',
      date: '16 Jun 2025',
      time: '10:20 AM',
      status: 'delivered',
      distance: '4.9 km',
      earnings: 84.0,
      obc: 8,
      weight: '1.5 kg',
      payMode: 'Prepaid',
    ),
    _Delivery(
      id: 'JD-DL-4815',
      recipient: 'Neha Patel',
      address: '22, CG Road, Ahmedabad, GJ 380009',
      date: '15 Jun 2025',
      time: '05:05 PM',
      status: 'delivered',
      distance: '7.3 km',
      earnings: 115.0,
      obc: 11,
      weight: '3.2 kg',
      payMode: 'Prepaid',
    ),
    _Delivery(
      id: 'JD-DL-4814',
      recipient: 'Ravi Kumar',
      address: '18, Ring Road, Hyderabad, TS 500001',
      date: '15 Jun 2025',
      time: '11:30 AM',
      status: 'failed',
      distance: '9.0 km',
      earnings: 0.0,
      obc: 0,
      weight: '2.0 kg',
      payMode: 'COD',
    ),
  ];

  List<_Delivery>? _liveDeliveries;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DriverService.instance.getHistory();
    if (!mounted || data.isEmpty) return;
    setState(() {
      _liveDeliveries = data.map((m) {
        final raw = m['status']?.toString() ?? 'delivered';
        final dt = m['created_at']?.toString() ?? '';
        return _Delivery(
          id: m['id']?.toString() ?? m['tracking_id']?.toString() ?? '—',
          recipient: m['customer_name']?.toString() ?? m['recipient']?.toString() ?? '—',
          address: m['delivery_address']?.toString() ?? '—',
          date: dt.length >= 10 ? dt.substring(0, 10) : '—',
          time: dt.length >= 16 ? dt.substring(11, 16) : '—',
          status: raw.toLowerCase(),
          distance: m['distance']?.toString() ?? '—',
          earnings: (m['driver_earnings'] as num? ?? m['amount'] as num? ?? 0).toDouble(),
          obc: (m['obc_points'] as num? ?? 0).toInt(),
          weight: '${m['weight'] ?? '—'} kg',
          payMode: m['payment_method']?.toString() ?? '—',
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Delivery> get _source => _liveDeliveries ?? _deliveries;

  List<_Delivery> get _filtered {
    if (_selectedFilter == 'All') return _source;
    return _source.where((d) => d.status == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final p = _Palette.of(dark);
    final src = _source;
    final totalEarnings = src.fold(0.0, (s, d) => s + d.earnings);
    final totalObc = src.fold(0, (s, d) => s + d.obc);
    final delivered = src.where((d) => d.status == 'delivered').length;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, dark, p),
            _buildSummary(dark, p, totalEarnings, totalObc, delivered),
            _buildFilters(dark, p),
            Expanded(child: _buildList(dark, p)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark, _Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: p.card,
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _ClayIcon(
            onTap: () => context.pop(),
            dark: dark,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    )),
                Text('Last 30 days • ${_deliveries.length} trips',
                    style: TextStyle(fontSize: 12, color: p.sub)),
              ],
            ),
          ),
          _ClayIcon(
            onTap: () {},
            dark: dark,
            child: Icon(Icons.filter_list_rounded, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool dark, _Palette p, double totalEarnings, int totalObc, int delivered) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryTile(
            icon: Icons.currency_rupee_rounded,
            label: 'Total Earned',
            value: '₹${totalEarnings.toStringAsFixed(0)}',
          ),
          _vDivider(),
          _SummaryTile(
            icon: Icons.local_shipping_rounded,
            label: 'Delivered',
            value: '$delivered',
          ),
          _vDivider(),
          _SummaryTile(
            icon: Icons.toll_rounded,
            label: 'OBC Earned',
            value: '$totalObc',
            valueSuffix: ' OBC',
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.3),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _buildFilters(bool dark, _Palette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = _filters[i];
            final active = _selectedFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : p.card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(color: p.shadow, blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : p.sub,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(bool dark, _Palette p) {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: p.sub),
            const SizedBox(height: 12),
            Text('No deliveries found', style: TextStyle(color: p.sub, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _DeliveryCard(delivery: items[i], dark: dark, p: p),
    );
  }
}

// ─── Delivery Card ───────────────────────────────────────────────────────────

class _DeliveryCard extends StatelessWidget {
  final _Delivery delivery;
  final bool dark;
  final _Palette p;

  const _DeliveryCard({required this.delivery, required this.dark, required this.p});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(delivery.status);

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: p.highlight, blurRadius: 4, offset: const Offset(-2, -2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon(delivery.status), color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery.id,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          )),
                      Text('${delivery.date} · ${delivery.time}',
                          style: TextStyle(fontSize: 11, color: p.sub)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    delivery.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_rounded, size: 15, color: p.sub),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(delivery.recipient,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: p.text)),
                    ),
                    Text(delivery.payMode,
                        style: TextStyle(fontSize: 11, color: p.sub)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded, size: 15, color: p.sub),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(delivery.address,
                          style: TextStyle(fontSize: 12, color: p.sub),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(icon: Icons.route_rounded, label: delivery.distance, p: p),
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.scale_rounded, label: delivery.weight, p: p),
                    const Spacer(),
                    if (delivery.obc > 0) ...[
                      Icon(Icons.toll_rounded, size: 14, color: AppColors.saffron),
                      const SizedBox(width: 4),
                      Text('+${delivery.obc} OBC',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.saffron,
                          )),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      delivery.earnings > 0 ? '₹${delivery.earnings.toStringAsFixed(0)}' : '₹0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: delivery.earnings > 0 ? AppColors.success : p.sub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'returned':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'failed':
        return Icons.cancel_rounded;
      case 'returned':
        return Icons.keyboard_return_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Palette p;

  const _InfoChip({required this.icon, required this.label, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: p.sub),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: p.sub)),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String valueSuffix;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
              if (valueSuffix.isNotEmpty)
                Text(valueSuffix,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    )),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.75),
              )),
        ],
      ),
    );
  }
}

class _ClayIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool dark;

  const _ClayIcon({required this.onTap, required this.child, required this.dark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: dark ? AppColors.darkBg3 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: dark
                  ? AppColors.darkBg1.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.9),
              blurRadius: 4,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: dark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
              size: 18,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Delivery {
  final String id;
  final String recipient;
  final String address;
  final String date;
  final String time;
  final String status;
  final String distance;
  final double earnings;
  final int obc;
  final String weight;
  final String payMode;

  const _Delivery({
    required this.id,
    required this.recipient,
    required this.address,
    required this.date,
    required this.time,
    required this.status,
    required this.distance,
    required this.earnings,
    required this.obc,
    required this.weight,
    required this.payMode,
  });
}

// ─── Palette ─────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, card, highlight, shadow, text, sub, inner;

  const _Palette({
    required this.bg,
    required this.card,
    required this.highlight,
    required this.shadow,
    required this.text,
    required this.sub,
    required this.inner,
  });

  factory _Palette.of(bool dark) => dark
      ? _Palette(
          bg: AppColors.darkBg1,
          card: AppColors.darkCard,
          highlight: AppColors.clayHighlightDark,
          shadow: AppColors.clayShadowDark,
          text: Colors.white,
          sub: AppColors.darkSubtext,
          inner: AppColors.darkBg3,
        )
      : _Palette(
          bg: const Color(0xFFF5F6FA),
          card: Colors.white,
          highlight: AppColors.clayHighlight,
          shadow: AppColors.clayShadow,
          text: AppColors.textDark,
          sub: AppColors.textDarkSecondary,
          inner: const Color(0xFFF0F2F8),
        );
}
