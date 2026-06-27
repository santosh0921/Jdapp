import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/logistics_service.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsShipmentsScreen extends StatefulWidget {
  const LogisticsShipmentsScreen({super.key});
  @override
  State<LogisticsShipmentsScreen> createState() => _LogisticsShipmentsScreenState();
}

class _LogisticsShipmentsScreenState extends State<LogisticsShipmentsScreen> {
  List<Map<String, dynamic>> _shipments = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    try {
      final data = await LogisticsService.instance.getOrders();
      if (mounted) setState(() { _shipments = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _shipments;
    return _shipments.where((s) {
      final status = (s['status'] as String? ?? '').toLowerCase();
      final type = (s['shipment_type'] as String? ?? '').toLowerCase();
      if (_filter == 'Import') return type.contains('import');
      if (_filter == 'Export') return type.contains('export');
      if (_filter == 'In Transit') return status.contains('in_transit') || status.contains('transit');
      if (_filter == 'Delivered') return status == 'delivered';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final bg = dark ? AppColors.darkBg1 : const Color(0xFFF5F6FA);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? Colors.white : AppColors.textDark;
    final sub = dark ? AppColors.darkSubtext : AppColors.textDarkSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => context.pop(),
        ),
        title: Text('Shipments', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: _kLogisticsColor),
            onPressed: () => context.push('/logistics/create-order'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Import', 'Export', 'In Transit', 'Delivered']
                  .map((f) => GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: f == _filter ? _kLogisticsColor : card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: f == _filter ? _kLogisticsColor : (dark ? AppColors.darkBorder : AppColors.lightBorder)),
                          ),
                          child: Text(f, style: TextStyle(color: f == _filter ? Colors.white : sub, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
                            const SizedBox(height: 8),
                            Text(_error!, style: TextStyle(color: sub, fontSize: 13), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadShipments(); },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping_outlined, color: sub, size: 48),
                                const SizedBox(height: 12),
                                Text('No shipments found', style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text('Tap + to create your first order', style: TextStyle(color: sub, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final s = _filtered[i];
                              final id = s['id']?.toString() ?? '—';
                              final status = s['status'] as String? ?? 'pending';
                              final type = s['shipment_type'] as String? ?? '';
                              final origin = s['origin_city'] as String? ?? s['pickup_address'] as String? ?? '—';
                              final dest = s['destination_city'] as String? ?? s['delivery_address'] as String? ?? '—';
                              final cargoType = s['cargo_type'] as String? ?? s['goods_description'] as String? ?? '—';
                              final weight = s['weight_kg'] != null ? '${s['weight_kg']} kg' : '—';
                              final displayStatus = _displayStatus(status);
                              final statusColor = _statusColor(status);
                              final isImport = type.toLowerCase().contains('import');

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.06), blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (type.isNotEmpty) Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (isImport ? AppColors.primary : _kLogisticsColor).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(isImport ? 'Import' : 'Export', style: TextStyle(color: isImport ? AppColors.primary : _kLogisticsColor, fontSize: 10, fontWeight: FontWeight.w800)),
                                        ),
                                        if (type.isNotEmpty) const SizedBox(width: 8),
                                        Expanded(child: Text(id, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                          child: Text(displayStatus, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w800)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.route_rounded, size: 14, color: sub),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text('$origin → $dest', style: TextStyle(color: sub, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.inventory_2_rounded, size: 14, color: sub),
                                        const SizedBox(width: 4),
                                        Text(cargoType, style: TextStyle(color: sub, fontSize: 12)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.scale_rounded, size: 14, color: sub),
                                        const SizedBox(width: 4),
                                        Text(weight, style: TextStyle(color: sub, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return AppColors.success;
      case 'in_transit': return AppColors.primary;
      case 'customs': case 'customs_hold': return AppColors.warning;
      case 'cancelled': return Colors.red;
      default: return _kLogisticsColor;
    }
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'in_transit': return 'In Transit';
      case 'delivered': return 'Delivered';
      case 'customs_hold': return 'Customs';
      case 'cancelled': return 'Cancelled';
      case 'pending': return 'Pending';
      default: return status.replaceAll('_', ' ');
    }
  }
}
