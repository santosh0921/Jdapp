import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/services/logistics_service.dart';

const Color _kTeal = Color(0xFF0D9488);
const Color _kNavy = Color(0xFF0F2D5A);
const Color _kSaffron = Color(0xFFFF6B00);

class LogisticsTrackingScreen extends StatefulWidget {
  const LogisticsTrackingScreen({super.key});
  @override
  State<LogisticsTrackingScreen> createState() => _LogisticsTrackingScreenState();
}

class _LogisticsTrackingScreenState extends State<LogisticsTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _userOrders = [];
  String? _activeId;
  Map<String, dynamic>? _selectedOrder;
  List<Map<String, dynamic>> _trackingEvents = [];
  bool _isTracking = false;
  String? _trackingError;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _loadUserOrders();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserOrders() async {
    try {
      final orders = await LogisticsService.instance.getOrders();
      if (mounted) setState(() => _userOrders = orders);
    } catch (_) {}
  }

  Future<void> _trackOrder(String id) async {
    if (id.trim().isEmpty) return;
    setState(() { _isTracking = true; _trackingError = null; _selectedOrder = null; _trackingEvents = []; });
    try {
      final order = await LogisticsService.instance.getOrderById(id.trim());
      final events = await LogisticsService.instance.getTracking(id.trim());
      if (mounted) {
        setState(() {
          _activeId = id.trim();
          _selectedOrder = order;
          _trackingEvents = events;
          _isTracking = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isTracking = false; _trackingError = 'Order not found: ${e.toString()}'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8);
    final card = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.textWhite : _kNavy;
    final textSub = isDark ? AppColors.darkSubtext : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textPrimary), onPressed: () => context.pop()),
        title: Text('Shipment Tracker', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: _kTeal, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Order ID to track',
                        hintStyle: TextStyle(color: textSub, fontSize: 13),
                      ),
                      onSubmitted: (v) => _trackOrder(v),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _trackOrder(_searchCtrl.text),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Track', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick select — My Active Shipments
            if (_userOrders.isNotEmpty) ...[
              _sectionLabel('My Active Shipments', textPrimary),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: _userOrders.take(10).map((o) {
                    final id = o['id']?.toString() ?? '';
                    final isActive = _activeId == id;
                    return GestureDetector(
                      onTap: () {
                        _searchCtrl.text = id;
                        _trackOrder(id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? _kTeal : card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Text(id, style: TextStyle(color: isActive ? Colors.white : textSub, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Loading / error / result
            if (_isTracking)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_trackingError != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.red.shade400, size: 36),
                    const SizedBox(height: 8),
                    Text(_trackingError!, style: TextStyle(color: textSub, fontSize: 13), textAlign: TextAlign.center),
                  ],
                ),
              )
            else if (_selectedOrder != null) ...[
              _buildOrderCard(_selectedOrder!, isDark, textPrimary, textSub),
              const SizedBox(height: 20),
              if (_trackingEvents.isNotEmpty) ...[
                _sectionLabel('Tracking Timeline', textPrimary),
                const SizedBox(height: 12),
                _buildTimeline(isDark, card, textPrimary, textSub),
              ] else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('No tracking events yet', style: TextStyle(color: textSub, fontSize: 13))),
                ),
            ] else
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.gps_fixed_outlined, color: textSub, size: 40),
                      const SizedBox(height: 12),
                      Text('Enter an order ID above to track', style: TextStyle(color: textSub, fontSize: 13), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark, Color textPrimary, Color textSub) {
    final id = order['id']?.toString() ?? '—';
    final status = order['status'] as String? ?? 'pending';
    final origin = order['origin_city'] as String? ?? order['pickup_address'] as String? ?? '—';
    final dest = order['destination_city'] as String? ?? order['delivery_address'] as String? ?? '—';
    final goods = order['goods_description'] as String? ?? order['cargo_type'] as String? ?? '—';
    final eta = order['estimated_delivery'] as String? ?? order['delivery_eta'] as String? ?? '—';
    final displayStatus = _displayStatus(status);
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kNavy, Color(0xFF1A3F6F), _kTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📦', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    Text(goods, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor, width: 1)),
                child: Text(displayStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FROM', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(origin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white54, size: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TO', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(dest, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.end),
                  ],
                ),
              ),
            ],
          ),
          if (eta != '—') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
              child: Text('📅 ETA: $eta', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isDark, Color card, Color textPrimary, Color textSub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: _trackingEvents.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isLast = i == _trackingEvents.length - 1;
          final isLatest = i == _trackingEvents.length - 1;
          final eventName = item['event'] as String? ?? item['status'] as String? ?? item['description'] as String? ?? '—';
          final dateStr = item['timestamp'] as String? ?? item['date'] as String? ?? item['created_at'] as String? ?? '—';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Container(
                        width: isLatest ? 16 + _pulseAnim.value * 4 : 14,
                        height: isLatest ? 16 + _pulseAnim.value * 4 : 14,
                        decoration: BoxDecoration(
                          color: isLatest ? _kSaffron : _kTeal,
                          shape: BoxShape.circle,
                          boxShadow: isLatest ? [BoxShadow(color: _kSaffron.withValues(alpha: 0.4 * _pulseAnim.value), blurRadius: 8, spreadRadius: 2)] : null,
                        ),
                        child: isLatest ? null : const Icon(Icons.check, size: 9, color: Colors.white),
                      ),
                    ),
                    if (!isLast)
                      Container(width: 2, height: 32, color: _kTeal.withValues(alpha: 0.4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventName, style: TextStyle(color: isLatest ? _kSaffron : textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(dateStr, style: TextStyle(color: isLatest ? _kSaffron.withValues(alpha: 0.7) : textSub, fontSize: 11.5)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return const Color(0xFF22C55E);
      case 'in_transit': return const Color(0xFF3B82F6);
      case 'customs': case 'customs_hold': return _kSaffron;
      case 'cancelled': return const Color(0xFFEF4444);
      default: return _kTeal;
    }
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'in_transit': return 'In Transit';
      case 'delivered': return 'Delivered';
      case 'customs_hold': return 'Customs Hold';
      case 'cancelled': return 'Cancelled';
      case 'pending': return 'Pending';
      default: return status.replaceAll('_', ' ');
    }
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }
}
