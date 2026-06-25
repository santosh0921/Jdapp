import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

class ParcelScanScreen extends StatefulWidget {
  const ParcelScanScreen({super.key});

  @override
  State<ParcelScanScreen> createState() => _ParcelScanScreenState();
}

class _ParcelScanScreenState extends State<ParcelScanScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late final AnimationController _pulseCtrl;
  bool _scanning = false;
  Map<String, String>? _scannedResult;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _scan() {
    final input = _ctrl.text.trim();
    if (input.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _scanning = true;
      _scannedResult = null;
      _errorMsg = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final found = _mockDb[input];
      setState(() {
        _scanning = false;
        if (found != null) {
          _scannedResult = found;
          HapticFeedback.mediumImpact();
        } else {
          _errorMsg = 'Parcel "$input" not found in system.';
        }
      });
    });
  }

  void _clear() {
    setState(() {
      _ctrl.clear();
      _scannedResult = null;
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero ─────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
              ),
            ),
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded,
                            color: AppColors.warehouseColor, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Scan Parcel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Enter parcel ID or scan QR code',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                children: [
                  // Scanner viewfinder mockup
                  GlassCard(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : AppColors.primary.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.warehouseColor.withValues(
                                    alpha:
                                        0.4 + 0.4 * _pulseCtrl.value),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Corner brackets
                                ..._corners(),
                                // Scanner line
                                Positioned(
                                  top: 16 + 160 * _pulseCtrl.value,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    height: 2,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.warehouseColor,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.qr_code_rounded,
                                        size: 64,
                                        color: AppColors.warehouseColor
                                            .withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Camera scanning — UI mock',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white38
                                              : AppColors.textDarkSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '— OR ENTER MANUALLY —',
                          style: TextStyle(
                            color: AppColors.textDarkSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                decoration: InputDecoration(
                                  hintText: 'e.g. IN-0041 or JD-2024-001',
                                  prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primary),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : const Color(0xFFEAF6FF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                ),
                                onSubmitted: (_) => _scan(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _scan,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.warehouseColor,
                                      Color(0xFF16A34A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _scanning
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.search_rounded,
                                        color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Result / error
                  if (_errorMsg != null)
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            onPressed: _clear,
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.error),
                          ),
                        ],
                      ),
                    ),

                  if (_scannedResult != null) _ResultCard(_scannedResult!, isDark, _clear),

                  const SizedBox(height: 20),

                  // Recent scans
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Scans',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._recentScans.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RecentScanRow(data: s, isDark: isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const size = 20.0;
    const thick = 3.0;
    const color = AppColors.warehouseColor;

    Widget corner(Alignment a) => Align(
          alignment: a,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _CornerPainter(
                  alignment: a,
                  color: color,
                  thickness: thick,
                ),
              ),
            ),
          ),
        );

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }

  static const _mockDb = {
    'IN-0041': {
      'id': 'IN-0041',
      'origin': 'Mumbai Hub',
      'destination': 'Bengaluru WH-001',
      'weight': '3.2 kg',
      'status': 'Arriving',
      'type': 'Electronics',
    },
    'IN-0042': {
      'id': 'IN-0042',
      'origin': 'Delhi Hub',
      'destination': 'Bengaluru WH-001',
      'weight': '1.5 kg',
      'status': 'Arrived',
      'type': 'Apparel',
    },
    'JD-2024-001': {
      'id': 'JD-2024-001',
      'origin': 'Mumbai',
      'destination': 'Bengaluru',
      'weight': '2.0 kg',
      'status': 'In Transit',
      'type': 'Documents',
    },
  };

  static const _recentScans = [
    {'id': 'IN-0040', 'type': 'Apparel', 'time': '1:10 PM', 'status': 'Stored'},
    {'id': 'IN-0039', 'type': 'Electronics', 'time': '11:45 AM', 'status': 'Dispatched'},
    {'id': 'OUT-0088', 'type': 'Documents', 'time': '10:00 AM', 'status': 'Dispatched'},
  ];
}

class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double thickness;

  const _CornerPainter(
      {required this.alignment,
      required this.color,
      required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    final dx = isLeft ? 0.0 : size.width;
    final dy = isTop ? 0.0 : size.height;
    final ex = isLeft ? size.width : 0.0;
    final ey = isTop ? size.height : 0.0;

    canvas.drawLine(Offset(dx, dy), Offset(ex, dy), paint);
    canvas.drawLine(Offset(dx, dy), Offset(dx, ey), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ResultCard extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;
  final VoidCallback onDismiss;

  const _ResultCard(this.data, this.isDark, this.onDismiss);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warehouseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.warehouseColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['id']!,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      data['type']!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppColors.textDarkSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close_rounded,
                    color: isDark ? Colors.white38 : Colors.black26),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Row('Origin', data['origin']!, isDark),
          _Row('Destination', data['destination']!, isDark),
          _Row('Weight', data['weight']!, isDark),
          _Row('Status', data['status']!, isDark),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Mark Received',
                  color: AppColors.warehouseColor,
                  icon: Icons.inbox_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Dispatch',
                  color: AppColors.primary,
                  icon: Icons.local_shipping_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _Row(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ActionBtn(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _RecentScanRow extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;

  const _RecentScanRow({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = data['status'] == 'Stored'
        ? AppColors.warehouseColor
        : AppColors.primary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.history_rounded,
              size: 18,
              color: isDark ? Colors.white38 : AppColors.textDarkSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${data['id']}  ·  ${data['type']}',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              data['status']!,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data['time']!,
            style: TextStyle(
              color: isDark ? Colors.white38 : AppColors.textDarkSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
