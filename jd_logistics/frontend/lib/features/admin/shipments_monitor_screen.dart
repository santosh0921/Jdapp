import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class ShipmentsMonitorScreen extends StatefulWidget {
  const ShipmentsMonitorScreen({super.key});

  @override
  State<ShipmentsMonitorScreen> createState() =>
      _ShipmentsMonitorScreenState();
}

class _ShipmentData {
  final String id;
  final String origin;
  final String destination;
  final String status;
  final String mode;
  final String eta;
  final String customer;
  final double progress;

  const _ShipmentData({
    required this.id,
    required this.origin,
    required this.destination,
    required this.status,
    required this.mode,
    required this.eta,
    required this.customer,
    required this.progress,
  });
}

class _ShipmentsMonitorScreenState extends State<ShipmentsMonitorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';

  bool _isLoading = true;
  String? _loadError;

  List<_ShipmentData> _shipments = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    setState(() { _isLoading = true; _loadError = null; });
    try {
      final data = await AdminService.instance.getShipments();
      if (!mounted) return;
      setState(() {
        _shipments = data.map((s) {
          final rawStatus = (s['status'] as String? ?? 'pending');
          final status = rawStatus == 'in_transit'   ? 'In Transit'
              : rawStatus == 'delivered'              ? 'Delivered'
              : rawStatus == 'customs'                ? 'Customs'
              : rawStatus == 'customs_clearance'      ? 'Customs'
              : rawStatus == 'pickup_scheduled'       ? 'Picked Up'
              : 'Booked';
          final rawType = (s['type'] as String? ?? 'courier');
          final mode = rawType == 'logistics' ? 'Ocean' : 'Road';
          final progress = rawStatus == 'delivered' ? 1.0
              : rawStatus == 'in_transit' ? 0.6
              : rawStatus == 'customs' || rawStatus == 'customs_clearance' ? 0.75
              : rawStatus == 'pickup_scheduled' ? 0.2 : 0.0;
          return _ShipmentData(
            id:          s['id'] as String? ?? '',
            origin:      s['from'] as String? ?? 'Origin',
            destination: s['to']   as String? ?? 'Destination',
            status:      status,
            mode:        mode,
            eta:         s['created_at'] as String? ?? 'TBD',
            customer:    'Customer',
            progress:    progress,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loadError = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<_ShipmentData> _filtered(String statusFilter) {
    final base = statusFilter == 'All'
        ? _shipments
        : statusFilter == 'Active'
            ? _shipments.where((s) =>
                s.status == 'In Transit' ||
                s.status == 'Picked Up' ||
                s.status == 'Customs').toList()
            : statusFilter == 'Pending'
                ? _shipments
                    .where((s) =>
                        s.status == 'Booked' || s.status == 'Delayed')
                    .toList()
                : _shipments
                    .where((s) => s.status == 'Delivered')
                    .toList();

    if (_search.isEmpty) return base;
    final q = _search.toLowerCase();
    return base
        .where((s) =>
            s.id.toLowerCase().contains(q) ||
            s.origin.toLowerCase().contains(q) ||
            s.destination.toLowerCase().contains(q) ||
            s.customer.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Load failed', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadShipments, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Shipments Monitor',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search ID, origin, customer…',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.white38, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabs,
                  indicatorColor: AppColors.adminColor,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Delivered'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _ShipmentList(items: _filtered('All')),
            _ShipmentList(items: _filtered('Active')),
            _ShipmentList(items: _filtered('Pending')),
            _ShipmentList(items: _filtered('Delivered')),
          ],
        ),
      ),
    );
  }
}

class _ShipmentList extends StatelessWidget {
  final List<_ShipmentData> items;
  const _ShipmentList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_rounded, size: 56, color: Colors.white24),
            SizedBox(height: 12),
            Text('No shipments',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ShipmentCard(s: items[i]),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final _ShipmentData s;
  const _ShipmentCard({required this.s});

  static Color _modeColor(String mode) {
    switch (mode) {
      case 'Air':
        return AppColors.airColor;
      case 'Ocean':
        return AppColors.oceanColor;
      default:
        return AppColors.roadColor;
    }
  }

  static IconData _modeIcon(String mode) {
    switch (mode) {
      case 'Air':
        return Icons.flight_rounded;
      case 'Ocean':
        return Icons.directions_boat_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeColor = _modeColor(s.mode);
    final statusColor = AppColors.shipmentStatusColor(s.status);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_modeIcon(s.mode), color: modeColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.id,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                    Text(s.customer,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(s.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 7, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(s.origin,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 11, color: Colors.white38),
              ),
              const Icon(Icons.location_on_rounded,
                  size: 11, color: AppColors.driverColor),
              const SizedBox(width: 4),
              Text(s.destination,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.schedule_rounded,
                  size: 11, color: Colors.white38),
              const SizedBox(width: 4),
              Text(s.eta,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ),
          if (s.progress > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.progress,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: modeColor,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
