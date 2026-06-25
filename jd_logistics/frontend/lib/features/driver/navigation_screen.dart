import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _routeController;
  late final AnimationController _pulseController;

  static const List<_Stop> _stops = [
    _Stop(
      label: 'Warehouse A',
      address: '12 Industrial Area, Andheri East',
      isOrigin: true,
      completed: true,
    ),
    _Stop(
      label: 'In Transit',
      address: 'Western Express Highway',
      isOrigin: false,
      completed: true,
    ),
    _Stop(
      label: 'Rajesh Kumar',
      address: 'Koramangala 5th Block, Bengaluru',
      isOrigin: false,
      completed: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _routeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bg(BuildContext context) =>
      _dark(context) ? AppColors.darkBg1 : const Color(0xFFFFFFFF);

  Color _surface(BuildContext context) =>
      _dark(context) ? AppColors.darkCard : const Color(0xFFF8FAFF);

  Color _text(BuildContext context) =>
      _dark(context) ? Colors.white : const Color(0xFF0F172A);

  Color _sub(BuildContext context) =>
      _dark(context) ? Colors.white70 : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      body: SafeArea(
        child: Stack(
          children: [
            const _NavigationBackground(),
            Column(
              children: [
                _Header(
                  title: 'Live Navigation',
                  subtitle: 'Order #JD-2024-003',
                  textColor: _text(context),
                  subTextColor: _sub(context),
                  surfaceColor: _surface(context),
                  onBack: () {
                    HapticFeedback.lightImpact();
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
                    child: Column(
                      children: [
                        _MapCard(
                          routeController: _routeController,
                          pulseController: _pulseController,
                          surfaceColor: _surface(context),
                          textColor: _text(context),
                          subTextColor: _sub(context),
                        ),
                        const SizedBox(height: 14),
                        _TripMetricsGrid(
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 14),
                        _DeliveryProgressCard(
                          stops: _stops,
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 14),
                        _CustomerCard(
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 14),
                        _ObcRewardCard(
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 18),
                        _BottomActions(
                          surfaceColor: _surface(context),
                          textColor: _text(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          _ClayButton(
            icon: Icons.arrow_back_rounded,
            color: const Color(0xFF0B5FFF),
            surfaceColor: surfaceColor,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ClayButton(
            icon: Icons.my_location_rounded,
            color: AppColors.success,
            surfaceColor: surfaceColor,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final AnimationController routeController;
  final AnimationController pulseController;
  final Color surfaceColor;
  final Color textColor;
  final Color subTextColor;

  const _MapCard({
    required this.routeController,
    required this.pulseController,
    required this.surfaceColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = math.max(300.0, MediaQuery.of(context).size.height * 0.42);

    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: height.clamp(300.0, 420.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: AnimatedBuilder(
            animation: Listenable.merge([routeController, pulseController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _PremiumMapPainter(
                  routeProgress: routeController.value,
                  pulse: pulseController.value,
                  dark: Theme.of(context).brightness == Brightness.dark,
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: _MapInfoChip(
                        title: '18 min',
                        subtitle: '12.4 km left',
                        icon: Icons.timer_rounded,
                        color: Color(0xFF0B5FFF),
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: _MapInfoChip(
                        title: 'Light',
                        subtitle: 'Traffic',
                        icon: Icons.traffic_rounded,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    Positioned(
                      left: 24 + (routeController.value * 210),
                      top: 136 +
                          math.sin(routeController.value * math.pi * 2) * 44,
                      child: _MovingTruck(pulse: pulseController.value),
                    ),
                    const Positioned(
                      right: 48,
                      bottom: 78,
                      child: _DestinationPin(),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _MapBottomPanel(
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PremiumMapPainter extends CustomPainter {
  final double routeProgress;
  final double pulse;
  final bool dark;

  const _PremiumMapPainter({
    required this.routeProgress,
    required this.pulse,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [const Color(0xFF172033), const Color(0xFF101820)]
            : [const Color(0xFFEAF6FF), const Color(0xFFF8FAFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: dark ? 0.08 : 0.10)
      ..strokeWidth = 1;

    for (double x = 24; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 24; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFBFD8FF).withValues(alpha: 0.72)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final roads = [
      Path()
        ..moveTo(-20, size.height * .30)
        ..cubicTo(size.width * .26, size.height * .22, size.width * .56,
            size.height * .44, size.width + 20, size.height * .30),
      Path()
        ..moveTo(size.width * .18, -20)
        ..cubicTo(size.width * .24, size.height * .35, size.width * .16,
            size.height * .64, size.width * .30, size.height + 20),
      Path()
        ..moveTo(size.width + 20, size.height * .74)
        ..cubicTo(size.width * .68, size.height * .64, size.width * .44,
            size.height * .88, -20, size.height * .74),
    ];

    for (final path in roads) {
      canvas.drawPath(path, roadPaint);
    }

    final blockPaint = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.72);

    final blocks = [
      const Rect.fromLTWH(24, 70, 74, 48),
      Rect.fromLTWH(size.width - 118, 82, 78, 52),
      Rect.fromLTWH(32, size.height - 145, 92, 54),
      Rect.fromLTWH(size.width - 150, size.height - 156, 100, 60),
      Rect.fromLTWH(size.width * .38, size.height * .18, 88, 58),
      Rect.fromLTWH(size.width * .46, size.height * .62, 96, 56),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(14)),
        blockPaint,
      );
    }

    final start = Offset(size.width * .18, size.height * .54);
    final end = Offset(size.width * .78, size.height * .42);
    final c1 = Offset(size.width * .34, size.height * .20);
    final c2 = Offset(size.width * .58, size.height * .74);

    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF0B5FFF).withValues(alpha: 0.13 + pulse * .07)
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF0B5FFF).withValues(alpha: .34)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final metric = route.computeMetrics().first;
    final active = metric.extractPath(0, metric.length * routeProgress);

    canvas.drawPath(
      active,
      Paint()
        ..color = const Color(0xFFFF8A00)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final startPin = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(start, 9, startPin);
    canvas.drawCircle(start, 16, startPin..color = const Color(0xFF22C55E).withValues(alpha: .18));
  }

  @override
  bool shouldRepaint(covariant _PremiumMapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.dark != dark;
  }
}

class _MapInfoChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MapInfoChip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
}

class _MovingTruck extends StatelessWidget {
  final double pulse;

  const _MovingTruck({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + pulse * .04,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0B5FFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5FFF).withValues(alpha: .25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.local_shipping_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

class _MapBottomPanel extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;

  const _MapBottomPanel({
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A00).withValues(alpha: .13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Color(0xFFFF8A00),
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clear Sky • 31°C',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Good driving conditions',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const _PercentBadge(value: '72%'),
        ],
      ),
    );
  }
}

class _TripMetricsGrid extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _TripMetricsGrid({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;

    final items = [
      _MetricData('ETA', '18 min', Icons.timer_rounded, const Color(0xFF0B5FFF)),
      _MetricData('Distance', '12.4 km', Icons.route_rounded, AppColors.success),
      _MetricData('OBC Reward', '+15', Icons.monetization_on_rounded, const Color(0xFFFF8A00)),
      _MetricData('Score', '96%', Icons.speed_rounded, AppColors.warning),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: width,
              child: _ClayCard(
                surfaceColor: surfaceColor,
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    _SoftIcon(icon: item.icon, color: item.color),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.value,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DeliveryProgressCard extends StatelessWidget {
  final List<_Stop> stops;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _DeliveryProgressCard({
    required this.stops,
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Delivery Progress',
            trailing: '72% Complete',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: .72,
              minHeight: 9,
              backgroundColor: const Color(0xFF0B5FFF).withValues(alpha: .10),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8A00)),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stops.length, (index) {
            final stop = stops[index];
            return Column(
              children: [
                _StopRow(
                  stop: stop,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
                if (index != stops.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 20,
                        color: const Color(0xFF0B5FFF).withValues(alpha: .18),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final _Stop stop;
  final Color textColor;
  final Color subTextColor;

  const _StopRow({
    required this.stop,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = stop.completed
        ? AppColors.success
        : stop.isOrigin
            ? const Color(0xFF0B5FFF)
            : AppColors.warning;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          stop.completed
              ? Icons.check_circle_rounded
              : stop.isOrigin
                  ? Icons.circle
                  : Icons.location_on_rounded,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  stop.address,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _CustomerCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'Customer',
            trailing: 'COD ₹2,499',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF0B5FFF).withValues(alpha: .12),
                child: const Text(
                  'RK',
                  style: TextStyle(
                    color: Color(0xFF0B5FFF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rajesh Kumar',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '+91 98765 43210',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoundAction(
                icon: Icons.call_rounded,
                color: AppColors.success,
                onTap: () => HapticFeedback.mediumImpact(),
              ),
              const SizedBox(width: 8),
              _RoundAction(
                icon: Icons.chat_bubble_rounded,
                color: const Color(0xFF0B5FFF),
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Instruction: Ring bell twice. Building 3, 2nd floor. Handle fragile package carefully.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObcRewardCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ObcRewardCard({
    required this.textColor,
    required this.subTextColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CardTitle(
            title: 'One Bharat Coin',
            trailing: 'Driver Rewards',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _RewardMini(label: 'Trip', value: '+15 OBC', color: const Color(0xFFFF8A00)),
              _RewardMini(label: 'Weekly', value: '+120 OBC', color: const Color(0xFF0B5FFF)),
              _RewardMini(label: 'Monthly', value: '+480 OBC', color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RewardMini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 58) / 3,
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: .75),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final Color surfaceColor;
  final Color textColor;

  const _BottomActions({
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Emergency',
            icon: Icons.sos_rounded,
            color: AppColors.error,
            filled: false,
            onTap: () => HapticFeedback.heavyImpact(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Proof',
            icon: Icons.fact_check_rounded,
            color: AppColors.warning,
            filled: false,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: 'Start Navigation',
            icon: Icons.navigation_rounded,
            color: const Color(0xFF0B5FFF),
            filled: true,
            onTap: () => HapticFeedback.mediumImpact(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: filled ? Colors.white : color, size: 20),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: filled ? Colors.white : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color surfaceColor;

  const _ClayCard({
    required this.child,
    required this.surfaceColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .05)
              : const Color(0xFFDFEAFF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .24 : .075),
            blurRadius: 22,
            offset: const Offset(10, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: dark ? .03 : .92),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ClayButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _ClayButton({
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: color.withValues(alpha: .14)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SoftIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 42,
          width: 42,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String trailing;
  final Color textColor;
  final Color subTextColor;

  const _CardTitle({
    required this.title,
    required this.trailing,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: subTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final String value;

  const _PercentBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A00).withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFFFF8A00),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NavigationBackground extends StatelessWidget {
  const _NavigationBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _NavigationBackgroundPainter(
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _NavigationBackgroundPainter extends CustomPainter {
  final bool dark;

  const _NavigationBackgroundPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: dark ? .08 : .06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(-20, size.height * .17)
      ..cubicTo(size.width * .28, size.height * .08, size.width * .56,
          size.height * .32, size.width + 20, size.height * .20);

    final p2 = Path()
      ..moveTo(size.width + 20, size.height * .64)
      ..cubicTo(size.width * .70, size.height * .52, size.width * .42,
          size.height * .78, -20, size.height * .72);

    canvas.drawPath(p1, routePaint);
    canvas.drawPath(p2, routePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: dark ? .10 : .15);

    for (int i = 0; i < 18; i++) {
      final x = ((i * 53) % size.width).toDouble();
      final y = (55 + ((i * 97) % size.height)).toDouble();
      canvas.drawCircle(Offset(x, y), 2.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NavigationBackgroundPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _Stop {
  final String label;
  final String address;
  final bool isOrigin;
  final bool completed;

  const _Stop({
    required this.label,
    required this.address,
    required this.isOrigin,
    required this.completed,
  });
}