import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/logistics_service.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsCargoScreen extends StatefulWidget {
  const LogisticsCargoScreen({super.key});
  @override
  State<LogisticsCargoScreen> createState() => _LogisticsCargoScreenState();
}

class _LogisticsCargoScreenState extends State<LogisticsCargoScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await LogisticsService.instance.getOrders();
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
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
        title: Text('Cargo & Containers', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight calculator card
            GestureDetector(
              onTap: () => context.push('/logistics/freight-quote'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF162233), _kLogisticsColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cargo Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                          Text('Calculate freight & container requirements', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Active Cargo', style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
                    const SizedBox(height: 8),
                    Text('Failed to load cargo', style: TextStyle(color: text, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_error!, style: TextStyle(color: sub, fontSize: 12), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadOrders(); }, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_boat_outlined, color: sub, size: 40),
                      const SizedBox(height: 12),
                      Text('No active cargo', style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Your shipment orders will appear here', style: TextStyle(color: sub, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ..._orders.map((o) {
                final id = o['id']?.toString() ?? '—';
                final status = o['status'] as String? ?? 'pending';
                final cargoType = o['cargo_type'] as String? ?? o['goods_description'] as String? ?? '—';
                final origin = o['origin_city'] as String? ?? o['pickup_address'] as String? ?? '—';
                final statusColor = _statusColor(status);
                final displayStatus = _displayStatus(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: _kLogisticsColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.directions_boat_rounded, color: _kLogisticsColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(id, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13)),
                            Text('$cargoType  ·  $origin', style: TextStyle(color: sub, fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(displayStatus, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
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
