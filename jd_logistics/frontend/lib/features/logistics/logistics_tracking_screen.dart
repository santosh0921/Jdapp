import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

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
  String _activeId = 'JDL-2024-001';

  static const _shipments = [
    {
      'id': 'JDL-2024-001',
      'goods': 'Steel Coils (25 MT)',
      'origin': 'Mumbai, India',
      'dest': 'Rotterdam, Netherlands',
      'mode': '🚢',
      'status': 'In Transit',
      'statusColor': Color(0xFF3B82F6),
      'vessel': 'MSC GÜLSÜN',
      'eta': '28 Dec 2024',
      'progress': 0.62,
      'timeline': [
        {'event': 'Order Placed', 'date': '01 Dec 10:30', 'done': true},
        {'event': 'Pickup Completed', 'date': '02 Dec 14:15', 'done': true},
        {'event': 'Port Entry (JNPT)', 'date': '03 Dec 09:00', 'done': true},
        {'event': 'Customs Cleared', 'date': '04 Dec 16:45', 'done': true},
        {'event': 'Vessel Loading', 'date': '05 Dec 08:00', 'done': true},
        {'event': 'Departed Mumbai', 'date': '06 Dec 22:00', 'done': true},
        {'event': 'In Transit — Arabian Sea', 'date': 'Current', 'done': false, 'active': true},
        {'event': 'Jebel Ali Transhipment', 'date': 'Est. 14 Dec', 'done': false},
        {'event': 'Arrived Rotterdam', 'date': 'Est. 28 Dec', 'done': false},
        {'event': 'Customs Clearance (NL)', 'date': 'Est. 29 Dec', 'done': false},
        {'event': 'Delivered', 'date': 'Est. 30 Dec', 'done': false},
      ],
    },
    {
      'id': 'JDL-2024-002',
      'goods': 'Medicines (500 KG)',
      'origin': 'Delhi, India',
      'dest': 'Dubai, UAE',
      'mode': '✈️',
      'status': 'Customs Hold',
      'statusColor': Color(0xFFFF6B00),
      'vessel': 'Air India Cargo',
      'eta': '23 Dec 2024',
      'progress': 0.78,
      'timeline': [
        {'event': 'Order Placed', 'date': '18 Dec 09:00', 'done': true},
        {'event': 'Pickup Completed', 'date': '18 Dec 14:00', 'done': true},
        {'event': 'Air Waybill Issued', 'date': '19 Dec 10:30', 'done': true},
        {'event': 'Departed Delhi (DEL)', 'date': '20 Dec 01:15', 'done': true},
        {'event': 'Arrived Dubai (DXB)', 'date': '20 Dec 05:30', 'done': true},
        {'event': 'Customs Hold — MOHAP Review', 'date': 'Current', 'done': false, 'active': true},
        {'event': 'Customs Cleared', 'date': 'Est. 23 Dec', 'done': false},
        {'event': 'Last Mile Delivery', 'date': 'Est. 23 Dec', 'done': false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _activeShipment {
    try {
      return _shipments.firstWhere((s) => s['id'] == _activeId) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.darkBg1 : const Color(0xFFF0F4F8);
    final card = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.textWhite : _kNavy;
    final textSub = isDark ? AppColors.darkSubtext : const Color(0xFF64748B);
    final shipment = _activeShipment;

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
                        hintText: 'Enter Shipment ID (e.g. JDL-2024-001)',
                        hintStyle: TextStyle(color: textSub, fontSize: 13),
                      ),
                      onSubmitted: (v) => setState(() {
                        _activeId = v.trim().isEmpty ? _activeId : v.trim();
                      }),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _activeId = _searchCtrl.text.trim().isEmpty ? _activeId : _searchCtrl.text.trim();
                    }),
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

            // Quick select buttons
            _sectionLabel('My Active Shipments', textPrimary),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: _shipments.map((s) {
                  final isActive = _activeId == s['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _activeId = s['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? _kTeal : card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Text(s['id'] as String, style: TextStyle(color: isActive ? Colors.white : textSub, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            if (shipment != null) ...[
              // Shipment header card
              _buildShipmentCard(shipment, isDark, textPrimary, textSub),
              const SizedBox(height: 20),

              // Progress bar
              _buildProgressBar(shipment, isDark, card, textPrimary, textSub),
              const SizedBox(height: 20),

              // Timeline
              _sectionLabel('Tracking Timeline', textPrimary),
              const SizedBox(height: 12),
              _buildTimeline(shipment, isDark, card, textPrimary, textSub),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> s, bool isDark, Color textPrimary, Color textSub) {
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
              Text(s['mode'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['id'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    Text(s['goods'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: (s['statusColor'] as Color).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20), border: Border.all(color: s['statusColor'] as Color, width: 1)),
                child: Text(s['status'] as String, style: TextStyle(color: s['statusColor'] as Color, fontWeight: FontWeight.w800, fontSize: 11)),
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
                    Text(s['origin'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
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
                    Text(s['dest'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.end),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('🚢 ${s['vessel']}'),
              const SizedBox(width: 8),
              _infoChip('📅 ETA: ${s['eta']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> s, bool isDark, Color card, Color textPrimary, Color textSub) {
    final progress = s['progress'] as double;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Journey Progress', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(_kTeal),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(s['origin'] as String, style: TextStyle(color: textSub, fontSize: 11)),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kTeal.withValues(alpha: 0.1 + _pulseAnim.value * 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 12, color: _kTeal),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: _kTeal, fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(s['dest'] as String, style: TextStyle(color: textSub, fontSize: 11), textAlign: TextAlign.end),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> s, bool isDark, Color card, Color textPrimary, Color textSub) {
    final timeline = s['timeline'] as List;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: timeline.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value as Map;
          final done = item['done'] == true;
          final active = item['active'] == true;
          final isLast = i == timeline.length - 1;

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
                        width: active ? 16 + _pulseAnim.value * 4 : 14,
                        height: active ? 16 + _pulseAnim.value * 4 : 14,
                        decoration: BoxDecoration(
                          color: done ? _kTeal : active ? _kSaffron : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: done ? _kTeal : active ? _kSaffron : const Color(0xFFCBD5E1),
                            width: done ? 0 : 2,
                          ),
                          boxShadow: active ? [BoxShadow(color: _kSaffron.withValues(alpha: 0.4 * _pulseAnim.value), blurRadius: 8, spreadRadius: 2)] : null,
                        ),
                        child: done ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: done ? _kTeal.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                      ),
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
                      Text(
                        item['event'] as String,
                        style: TextStyle(
                          color: active ? _kSaffron : done ? textPrimary : textSub,
                          fontWeight: active || done ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['date'] as String,
                        style: TextStyle(color: active ? _kSaffron.withValues(alpha: 0.7) : textSub, fontSize: 11.5),
                      ),
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

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sectionLabel(String label, Color textPrimary) {
    return Row(children: [
      Container(width: 3, height: 18, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
    ]);
  }
}
