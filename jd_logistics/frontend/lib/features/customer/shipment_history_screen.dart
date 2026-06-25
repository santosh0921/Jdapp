import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/logistics_status_chip.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class ShipmentHistoryScreen extends StatefulWidget {
  const ShipmentHistoryScreen({super.key});

  @override
  State<ShipmentHistoryScreen> createState() => _ShipmentHistoryScreenState();
}

class _HistoryItem {
  final String id;
  final String from;
  final String to;
  final String mode;
  final String status;
  final String date;
  final double amount;
  final String partner;

  const _HistoryItem({
    required this.id,
    required this.from,
    required this.to,
    required this.mode,
    required this.status,
    required this.date,
    required this.amount,
    required this.partner,
  });
}

class _ShipmentHistoryScreenState extends State<ShipmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';

  static const _items = [
    _HistoryItem(id: 'JD-IND-2048', from: 'Mumbai', to: 'Delhi',
        mode: 'Road', status: 'In Transit', date: 'Jun 18, 2026',
        amount: 1952, partner: 'Blue Dart'),
    _HistoryItem(id: 'JD-AIR-9172', from: 'Mumbai', to: 'Singapore',
        mode: 'Air', status: 'Customs', date: 'Jun 15, 2026',
        amount: 8420, partner: 'DHL Express'),
    _HistoryItem(id: 'JD-SEA-6021', from: 'JNPT', to: 'Dubai Port',
        mode: 'Ocean', status: 'In Transit', date: 'Jun 10, 2026',
        amount: 3280, partner: 'Maersk'),
    _HistoryItem(id: 'JD-IND-1987', from: 'Delhi', to: 'Bangalore',
        mode: 'Road', status: 'Delivered', date: 'Jun 5, 2026',
        amount: 1140, partner: 'Delhivery'),
    _HistoryItem(id: 'JD-AIR-8834', from: 'Chennai', to: 'London',
        mode: 'Air', status: 'Delivered', date: 'May 28, 2026',
        amount: 11200, partner: 'Emirates SkyCargo'),
    _HistoryItem(id: 'JD-IND-1765', from: 'Pune', to: 'Hyderabad',
        mode: 'Road', status: 'Delivered', date: 'May 20, 2026',
        amount: 680, partner: 'DTDC'),
    _HistoryItem(id: 'JD-SEA-5540', from: 'Kolkata', to: 'Shanghai',
        mode: 'Ocean', status: 'Delayed', date: 'May 15, 2026',
        amount: 4900, partner: 'MSC'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<_HistoryItem> _filtered(String? mode) {
    var list = _items.where((i) {
      if (_search.isNotEmpty &&
          !i.id.toLowerCase().contains(_search.toLowerCase()) &&
          !i.from.toLowerCase().contains(_search.toLowerCase()) &&
          !i.to.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (mode != null) return i.mode == mode;
      return true;
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Shipment History',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.skyBorder),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, city or route...',
                    hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkHint,
                        fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                        size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.darkSubtext
                  : AppColors.textDarkSecondary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Road'),
                Tab(text: 'Air'),
                Tab(text: 'Ocean'),
              ],
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _HistoryList(items: _filtered(null), isDark: isDark),
          _HistoryList(items: _filtered('Road'), isDark: isDark),
          _HistoryList(items: _filtered('Air'), isDark: isDark),
          _HistoryList(items: _filtered('Ocean'), isDark: isDark),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<_HistoryItem> items;
  final bool isDark;
  const _HistoryList({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded,
              size: 54,
              color: isDark ? AppColors.darkSubtext : AppColors.textDarkHint),
          const SizedBox(height: 12),
          Text('No shipments found',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _HistoryCard(item: items[i], isDark: isDark),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;
  final bool isDark;
  const _HistoryCard({required this.item, required this.isDark});

  Color get _modeColor {
    switch (item.mode) {
      case 'Air': return AppColors.airColor;
      case 'Ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  IconData get _modeIcon {
    switch (item.mode) {
      case 'Air': return Icons.flight_takeoff_rounded;
      case 'Ocean': return Icons.directions_boat_rounded;
      default: return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/shipment/details?id=${item.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _modeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_modeIcon, color: _modeColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(item.id,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.3)),
              ),
              LogisticsStatusChip(status: item.status, small: true),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              Text(item.from,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 12,
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary),
              ),
              Text(item.to,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text(item.partner,
                  style: TextStyle(
                      color: _modeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(item.date,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.textDarkSecondary,
                      fontSize: 11)),
              const SizedBox(width: 8),
              Text('₹${item.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ]),
          ]),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
            size: 18),
      ]),
    );
  }
}
