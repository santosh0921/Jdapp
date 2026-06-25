// frontend/lib/features/customer/presentation/live_shipment_map_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';

class LiveShipmentMapScreen extends StatefulWidget {
  final String id;
  final String mode;

  const LiveShipmentMapScreen({
    super.key,
    this.id = 'JDIN240001',
    this.mode = 'road',
  });

  @override
  State<LiveShipmentMapScreen> createState() => _LiveShipmentMapScreenState();
}

class _LiveShipmentMapScreenState extends State<LiveShipmentMapScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _vehicleCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _vehiclePos;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.86, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _vehicleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _vehiclePos = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _vehicleCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _vehicleCtrl.dispose();
    super.dispose();
  }

  Color get _modeColor {
    switch (widget.mode.toLowerCase()) {
      case 'air':
        return AppColors.airColor;
      case 'ocean':
        return AppColors.oceanColor;
      default:
        return AppColors.roadColor;
    }
  }

  IconData get _vehicleIcon {
    switch (widget.mode.toLowerCase()) {
      case 'air':
        return Icons.flight_takeoff_rounded;
      case 'ocean':
        return Icons.directions_boat_filled_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  String get _modeLabel {
    switch (widget.mode.toLowerCase()) {
      case 'air':
        return 'Air Cargo';
      case 'ocean':
        return 'Ocean Freight';
      default:
        return 'Road Freight';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: JdAppBar(
        title: 'Live Tracking',
        onBack: () => context.pop(),
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Tracking',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            Text(
              '${widget.id} • $_modeLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: AppColors.text(context),
            ),
            onPressed: () => context.push(
              '/shipment/share-tracking?id=${widget.id}',
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _vehiclePos,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _ShipmentMapPainter(
                      isDark: AppColors.isDark(context),
                      modeColor: _modeColor,
                      vehicleProgress: _vehiclePos.value,
                      mode: widget.mode.toLowerCase(),
                    ),
                  );
                },
              ),
            ),

            AnimatedBuilder(
              animation: Listenable.merge([_pulse, _vehiclePos]),
              builder: (_, __) {
                final size = MediaQuery.sizeOf(context);
                final pos = _routePoint(_vehiclePos.value, size);

                return Positioned(
                  left: pos.dx - 22,
                  top: pos.dy - 22,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _modeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.78),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _modeColor.withValues(alpha: 0.38),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        _vehicleIcon,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: _FloatingMapStatus(
                id: widget.id,
                modeLabel: _modeLabel,
                modeColor: _modeColor,
                vehicleIcon: _vehicleIcon,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomTrackingPanel(
                modeColor: _modeColor,
                vehicleIcon: _vehicleIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _routePoint(double t, Size size) {
    final mapHeight = size.height * 0.62;

    final p0 = Offset(size.width * 0.12, mapHeight * 0.78);
    final p1 = Offset(size.width * 0.55, mapHeight * 0.35);
    final p2 = Offset(size.width * 0.88, mapHeight * 0.18);

    final mt = 1 - t;

    return Offset(
      mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
      mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
    );
  }
}
class _FloatingMapStatus extends StatelessWidget {
  final String id;
  final String modeLabel;
  final Color modeColor;
  final IconData vehicleIcon;

  const _FloatingMapStatus({
    required this.id,
    required this.modeLabel,
    required this.modeColor,
    required this.vehicleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _MapIcon(icon: vehicleIcon, color: modeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$modeLabel • Mumbai → New Delhi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const _LivePill(),
        ],
      ),
    );
  }
}

class _BottomTrackingPanel extends StatelessWidget {
  final Color modeColor;
  final IconData vehicleIcon;

  const _BottomTrackingPanel({
    required this.modeColor,
    required this.vehicleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 34,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Row(
              children: [
                _MapIcon(icon: vehicleIcon, color: modeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Transit — En Route',
                        style: TextStyle(
                          color: AppColors.text(context),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Near Vadodara, Gujarat · NH-48',
                        style: TextStyle(
                          color: AppColors.subtext(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const _LivePill(),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'ETA',
                    value: 'Today 7:30 PM',
                    icon: Icons.schedule_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Distance Left',
                    value: '386 km',
                    icon: Icons.route_rounded,
                    color: modeColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Speed',
                    value: '72 km/h',
                    icon: Icons.speed_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _RouteStopsCard(modeColor: modeColor),
          ],
        ),
      ),
    );
  }
}

class _RouteStopsCard extends StatelessWidget {
  final Color modeColor;

  const _RouteStopsCard({
    required this.modeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StopRow(
                label: 'Mumbai',
                icon: Icons.circle,
                color: AppColors.success,
                bold: true,
              ),
              _StopLine(),
              _StopRow(
                label: 'Vadodara now',
                icon: Icons.location_on_rounded,
                color: modeColor,
                bold: true,
              ),
              _StopLine(),
              const _StopRow(
                label: 'New Delhi',
                icon: Icons.location_on_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '1,418 km total',
                style: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 106,
                  child: LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 7,
                    backgroundColor: AppColors.surface(context),
                    valueColor: AlwaysStoppedAnimation(modeColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '68% complete',
                style: TextStyle(
                  color: modeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool bold;

  const _StopRow({
    required this.label,
    required this.icon,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: bold ? color : AppColors.subtext(context),
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StopLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        width: 2,
        height: 18,
        color: AppColors.border(context),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(
          alpha: AppColors.isDark(context) ? 0.16 : 0.11,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.24),
        ),
      ),
      child: const Text(
        'Live',
        style: TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MapIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MapIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 46,
      height: 46,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
      borderColor: color.withValues(alpha: 0.24),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
class _ShipmentMapPainter extends CustomPainter {
  final bool isDark;
  final Color modeColor;
  final double vehicleProgress;
  final String mode;

  _ShipmentMapPainter({
    required this.isDark,
    required this.modeColor,
    required this.vehicleProgress,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackgroundGrid(canvas, size);
    _drawNodes(canvas, size);
    _drawRoute(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawBackgroundGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark
              ? Colors.white.withValues(alpha: 0.04)
              : AppColors.primary.withValues(alpha: 0.04))
          .withValues(alpha: isDark ? 0.04 : 0.03)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.12, size.height * 0.78);
    final middle = Offset(size.width * 0.52, size.height * 0.42);
    final end = Offset(size.width * 0.88, size.height * 0.18);

    _node(
      canvas,
      start,
      AppColors.success,
      radius: 12,
    );

    _node(
      canvas,
      middle,
      modeColor,
      radius: 10,
    );

    _node(
      canvas,
      end,
      AppColors.error,
      radius: 12,
    );
  }

  void _node(
    Canvas canvas,
    Offset center,
    Color color, {
    double radius = 10,
  }) {
    canvas.drawCircle(
      center,
      radius + 6,
      Paint()
        ..color = color.withValues(alpha: 0.12),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color,
    );
  }

  void _drawRoute(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.12, size.height * 0.78);
    final control = Offset(size.width * 0.55, size.height * 0.35);
    final end = Offset(size.width * 0.88, size.height * 0.18);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        control.dx,
        control.dy,
        end.dx,
        end.dy,
      );

    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = modeColor.withValues(alpha: 0.28)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, routePaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = modeColor
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(
          0,
          metric.length * vehicleProgress,
        ),
        progressPaint,
      );
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    _drawText(
      canvas,
      'Mumbai',
      Offset(size.width * 0.08, size.height * 0.83),
    );

    _drawText(
      canvas,
      'Vadodara',
      Offset(size.width * 0.47, size.height * 0.47),
    );

    _drawText(
      canvas,
      'New Delhi',
      Offset(size.width * 0.80, size.height * 0.12),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isDark
              ? Colors.white70
              : AppColors.textDarkSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ShipmentMapPainter oldDelegate) {
    return oldDelegate.vehicleProgress != vehicleProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.mode != mode;
  }
}