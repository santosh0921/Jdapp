import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/custom_textfield.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/services/tracking_service.dart';

class TrackShipmentScreen extends StatefulWidget {
  final String? trackingId;

  const TrackShipmentScreen({super.key, this.trackingId});

  @override
  State<TrackShipmentScreen> createState() => _TrackShipmentScreenState();
}

class _TrackShipmentScreenState extends State<TrackShipmentScreen>
    with TickerProviderStateMixin {
  final _trackCtrl = TextEditingController();

  late final AnimationController _moveCtrl;
  late final AnimationController _pulseCtrl;

  bool _searched = false;
  bool _loadingTrack = false;
  List<_TrackingStepData>? _liveSteps;


  @override
  void initState() {
    super.initState();

    if (widget.trackingId != null && widget.trackingId!.trim().isNotEmpty) {
      _trackCtrl.text = widget.trackingId!;
      _searched = true;
    }

    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _trackCtrl.dispose();
    _moveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _trackShipment() async {
    FocusScope.of(context).unfocus();
    setState(() { _searched = true; _loadingTrack = true; _liveSteps = null; });

    final id = _trackingId;
    final events = await TrackingService.instance.getEvents(id);

    if (!mounted) return;

    List<_TrackingStepData>? live;
    if (events.isNotEmpty) {
      live = events.asMap().entries.map((e) {
        final ev = e.value;
        final isLast = e.key == events.length - 1;
        return _TrackingStepData(
          title: _statusLabel(ev.status),
          subtitle: ev.location + (ev.note != null ? ' · ${ev.note}' : ''),
          time: _fmtTime(ev.createdAt),
          icon: _statusIcon(ev.status),
          done: !isLast,
          active: isLast,
        );
      }).toList();
    }

    setState(() { _loadingTrack = false; _liveSteps = live; });
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'booked':        return 'Shipment Booked';
      case 'picked_up':     return 'Picked Up';
      case 'at_hub':        return 'Reached Hub';
      case 'in_transit':    return 'In Transit';
      case 'out_for_delivery': return 'Out for Delivery';
      case 'delivered':     return 'Delivered';
      case 'failed':        return 'Delivery Attempted';
      case 'returned':      return 'Returned to Sender';
      default: return s.replaceAll('_', ' ').split(' ').map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'booked':           return Icons.inventory_2_rounded;
      case 'picked_up':        return Icons.local_shipping_rounded;
      case 'at_hub':           return Icons.warehouse_rounded;
      case 'in_transit':       return Icons.local_shipping_rounded;
      case 'out_for_delivery': return Icons.delivery_dining_rounded;
      case 'delivered':        return Icons.verified_rounded;
      case 'failed':           return Icons.error_rounded;
      case 'returned':         return Icons.keyboard_return_rounded;
      default:                 return Icons.circle_outlined;
    }
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return 'Today · $h12:$m $ampm';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String get _trackingId =>
      _trackCtrl.text.trim().isEmpty ? 'JDIN240001' : _trackCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: JdAppBar(
        title: 'Track Shipment',
        onBack: () => context.pop(),
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return AnimatedBuilder(
                animation: Listenable.merge([_moveCtrl, _pulseCtrl]),
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 16,
                      16,
                      wide ? 28 : 16,
                      120,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SearchCard(
                              controller: _trackCtrl,
                              onTrack: _trackShipment,
                            ),
                            const SizedBox(height: 18),
                            if (_searched)
                              Flex(
                                direction:
                                    wide ? Axis.horizontal : Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: wide ? 3 : 0,
                                    fit: wide
                                        ? FlexFit.tight
                                        : FlexFit.loose,
                                    child: _LiveRouteCard(
                                      progress: _moveCtrl.value,
                                      pulse: _pulseCtrl.value,
                                      trackingId: _trackingId,
                                    ),
                                  ),
                                  SizedBox(
                                    width: wide ? 16 : 0,
                                    height: wide ? 0 : 16,
                                  ),
                                  Flexible(
                                    flex: wide ? 2 : 0,
                                    fit: wide
                                        ? FlexFit.tight
                                        : FlexFit.loose,
                                    child: _ShipmentInfoCard(
                                      trackingId: _trackingId,
                                    ),
                                  ),
                                ],
                              )
                            else
                              _EmptyTrackCard(pulse: _pulseCtrl.value),
                            const SizedBox(height: 18),
                            if (_searched)
                              _loadingTrack
                                  ? const Center(child: CircularProgressIndicator())
                                  : _liveSteps == null || _liveSteps!.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search_off_rounded, size: 48, color: Colors.white38),
                                        SizedBox(height: 12),
                                        Text('No tracking events found',
                                            style: TextStyle(color: Colors.white54, fontSize: 14)),
                                        SizedBox(height: 6),
                                        Text('Check your tracking ID and try again',
                                            style: TextStyle(color: Colors.white38, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                )
                              : _TimelineCard(steps: _liveSteps!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTrack;

  const _SearchCard({
    required this.controller,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Track Your Shipment',
            subtitle: 'Live route, hub status, ETA and delivery milestones',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller,
            label: 'Tracking ID',
            hint: 'Enter tracking number e.g. JDIN240001',
            prefixIcon: Icons.search_rounded,
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Track Shipment',
            onPressed: onTrack,
            icon: Icons.radar_rounded,
          ),
        ],
      ),
    );
  }
}

class _LiveRouteCard extends StatelessWidget {
  final double progress;
  final double pulse;
  final String trackingId;

  const _LiveRouteCard({
    required this.progress,
    required this.pulse,
    required this.trackingId,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 340,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LiveRoutePainter(
                  dark: dark,
                  progress: progress,
                  pulse: pulse,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Pill(
                    label: 'LIVE ROUTE',
                    icon: Icons.route_rounded,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trackingId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tracking shipment route',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 6,
              right: 0,
              child: _Sticker(
                icon: Icons.local_shipping_rounded,
                color: AppColors.roadColor,
              ),
            ),
            const Positioned(
              right: 42,
              top: 64,
              child: _Sticker(
                icon: Icons.flight_takeoff_rounded,
                color: AppColors.airColor,
              ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                children: const [
                  _RouteMetric(
                    icon: Icons.schedule_rounded,
                    label: 'ETA',
                    value: '—',
                  ),
                  _RouteMetric(
                    icon: Icons.speed_rounded,
                    label: 'Status',
                    value: 'Live',
                  ),
                  _RouteMetric(
                    icon: Icons.warehouse_rounded,
                    label: 'Hub',
                    value: '—',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentInfoCard extends StatelessWidget {
  final String trackingId;

  const _ShipmentInfoCard({required this.trackingId});

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Shipment Status',
            subtitle: 'Premium delivery intelligence',
          ),
          const SizedBox(height: 18),
          const Center(
            child: GlassCard(
              width: 92,
              height: 92,
              borderRadius: 30,
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.local_shipping_rounded,
                color: AppColors.roadColor,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Tracking ID', value: trackingId),
          const _InfoRow(label: 'Status', value: '—'),
          const _InfoRow(label: 'Origin', value: '—'),
          const _InfoRow(label: 'Destination', value: '—'),
          const _InfoRow(label: 'Service', value: '—'),
          const _InfoRow(label: 'Partner', value: '—'),
          const _InfoRow(label: 'Current Hub', value: '—'),
          Divider(color: AppColors.border(context), height: 28),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 13,
                    color: dark ? AppColors.darkSurface : AppColors.lightBg3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.82,
                        child: Container(
                          color: AppColors.primary.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '82%',
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.oceanBlue.withValues(alpha: dark ? 0.14 : 0.09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.oceanBlue.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.oceanBlue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Delivery partner is moving towards the destination zone.',
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<_TrackingStepData> steps;

  const _TimelineCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Shipment Timeline',
            subtitle: 'Every logistics milestone in one place',
          ),
          const SizedBox(height: 18),
          ...List.generate(
            steps.length,
            (index) => _TrackStep(
              data: steps[index],
              isLast: index == steps.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackStep extends StatelessWidget {
  final _TrackingStepData data;
  final bool isLast;

  const _TrackStep({
    required this.data,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    final color = data.done
        ? AppColors.success
        : data.active
            ? AppColors.portOrange
            : AppColors.textDarkHint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GlassCard(
                width: 42,
                height: 42,
                borderRadius: 21,
                padding: EdgeInsets.zero,
                child: Icon(data.icon, color: color, size: 21),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: data.done
                          ? AppColors.success.withValues(alpha: 0.35)
                          : AppColors.border(context),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: data.active
                      ? AppColors.portOrange.withValues(
                          alpha: dark ? 0.14 : 0.10,
                        )
                      : AppColors.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data.active
                        ? AppColors.portOrange.withValues(alpha: 0.35)
                        : AppColors.border(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (data.active)
                          const _Pill(
                            label: 'ACTIVE',
                            icon: Icons.bolt_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: AppColors.subtext(context),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      data.time,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTrackCard extends StatelessWidget {
  final double pulse;

  const _EmptyTrackCard({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 360,
        child: Center(
          child: Transform.scale(
            scale: 1 + (pulse * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlassCard(
                  width: 104,
                  height: 104,
                  borderRadius: 52,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.radar_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Track global shipments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your tracking ID to see live route,\nstatus, ETA and delivery timeline.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 142,
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Pill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.portOrange.withValues(alpha: dark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.portOrange.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.portOrange, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: dark ? AppColors.saffronLight : const Color(0xFFC2410C),
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Sticker({
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
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _LiveRoutePainter extends CustomPainter {
  final bool dark;
  final double progress;
  final double pulse;

  _LiveRoutePainter({
    required this.dark,
    required this.progress,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.30 : 0.36)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final completedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.82)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * .12, size.height * .55)
      ..cubicTo(
        size.width * .30,
        size.height * .22,
        size.width * .58,
        size.height * .70,
        size.width * .85,
        size.height * .34,
      );

    canvas.drawPath(path, routePaint);

    final metric = path.computeMetrics().first;
    final completed = metric.extractPath(0, metric.length * .82);
    canvas.drawPath(completed, completedPaint);

    final truckTangent = metric.getTangentForOffset(
      metric.length * (.12 + progress * .70),
    );

    if (truckTangent != null) {
      final point = truckTangent.position;

      canvas.drawCircle(
        point,
        15 + pulse * 7,
        Paint()..color = AppColors.portOrange.withValues(alpha: 0.12),
      );
      canvas.drawCircle(
        point,
        15,
        Paint()..color = AppColors.portOrange,
      );

      final iconPainter = TextPainter(
        text: const TextSpan(
          text: '🚚',
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(canvas, Offset(point.dx - 10, point.dy - 13));
    }

    final points = [
      Offset(size.width * .12, size.height * .55),
      Offset(size.width * .42, size.height * .37),
      Offset(size.width * .65, size.height * .56),
      Offset(size.width * .85, size.height * .34),
    ];

    for (var i = 0; i < points.length; i++) {
      final done = i < 3;

      canvas.drawCircle(
        points[i],
        10,
        Paint()..color = done ? AppColors.success : AppColors.portOrange,
      );
      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = dark ? AppColors.darkBg1 : Colors.white,
      );
    }

    _paintEmoji(canvas, '🏭', Offset(size.width * .07, size.height * .60));
    _paintEmoji(canvas, '📍', Offset(size.width * .82, size.height * .39));

    final containerPaint = Paint()
      ..color = AppColors.portOrange.withValues(alpha: dark ? 0.12 : 0.10);

    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * .53 + (i * 13),
            size.height * .72 - (i.isEven ? 0 : 10),
            34,
            12,
          ),
          const Radius.circular(4),
        ),
        containerPaint,
      );
    }
  }

  void _paintEmoji(Canvas canvas, String emoji, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 30)),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LiveRoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.dark != dark;
  }
}

class _TrackingStepData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool done;
  final bool active;

  const _TrackingStepData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.done,
    this.active = false,
  });
}