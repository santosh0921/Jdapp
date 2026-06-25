import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _truckController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _truckController.dispose();
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
            const _RouteBackground(),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: Curves.easeOut,
              ),
              child: Column(
                children: [
                  _Header(
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
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                      child: Column(
                        children: [
                          _HeroDeliveryCard(
                            truckController: _truckController,
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _MetricGrid(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _RouteCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 14),
                          _PackageCard(
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
                          _ObcCard(
                            textColor: _text(context),
                            subTextColor: _sub(context),
                            surfaceColor: _surface(context),
                          ),
                          const SizedBox(height: 18),
                          _BottomActions(
                            onNavigate: () {
                              HapticFeedback.mediumImpact();
                              context.push('/driver/navigation');
                            },
                            onDelivered: () {
                              HapticFeedback.mediumImpact();
                              _showDeliveryConfirmDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkCard : const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Confirm Delivery',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Mark this order as delivered after collecting COD and completing proof of delivery.',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                dialogContext.pop();
                HapticFeedback.mediumImpact();
                context.push('/driver/proof-of-delivery');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;
  final VoidCallback onBack;

  const _Header({
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
                    'Order #JD-2024-003',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Active Delivery',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.success.withValues(alpha: .22)),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: AppColors.success, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'Live',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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

class _HeroDeliveryCard extends StatelessWidget {
  final AnimationController truckController;
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _HeroDeliveryCard({
    required this.truckController,
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
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StatusPill(),
                      const SizedBox(height: 12),
                      Text(
                        'Out for delivery',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Andheri East → Koramangala',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DeliveryAvatar(truckController: truckController),
            ],
          ),
          const SizedBox(height: 16),
          _AnimatedRouteStrip(truckController: truckController),
        ],
      ),
    );
  }
}

class _DeliveryAvatar extends StatelessWidget {
  final AnimationController truckController;

  const _DeliveryAvatar({required this.truckController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: truckController,
      builder: (context, _) {
        final lift = math.sin(truckController.value * math.pi * 2) * 4;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Container(
            height: 104,
            width: 94,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 18,
                  offset: const Offset(8, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: .90),
                  blurRadius: 18,
                  offset: const Offset(-8, -8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 14,
                  child: Container(
                    height: 32,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 17,
                  child: Container(
                    height: 40,
                    width: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedRouteStrip extends StatelessWidget {
  final AnimationController truckController;

  const _AnimatedRouteStrip({required this.truckController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: AnimatedBuilder(
        animation: truckController,
        builder: (context, _) {
          return CustomPaint(
            painter: _RouteStripPainter(progress: truckController.value),
            child: Stack(
              children: [
                const Positioned(
                  left: 18,
                  top: 34,
                  child: _SmallPin(color: AppColors.success),
                ),
                const Positioned(
                  right: 22,
                  bottom: 22,
                  child: _SmallPin(color: AppColors.warning),
                ),
                Positioned(
                  left: 30 + (truckController.value * 210),
                  top: 42 + math.sin(truckController.value * math.pi * 2) * 18,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RouteStripPainter extends CustomPainter {
  final double progress;

  const _RouteStripPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: .08)
      ..strokeWidth = 1;

    for (double x = 18; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 18; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()
      ..moveTo(34, 46)
      ..cubicTo(size.width * .28, 14, size.width * .58, size.height - 12,
          size.width - 42, size.height - 34);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0B5FFF).withValues(alpha: .26)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final metric = path.computeMetrics().first;
    final activePath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      activePath,
      Paint()
        ..color = const Color(0xFFFF8A00)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteStripPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _MetricGrid extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _MetricGrid({
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
      _MetricData('COD', '₹2,499', Icons.currency_rupee_rounded, AppColors.warning),
      _MetricData('Reward', '+12 OBC', Icons.monetization_on_rounded, const Color(0xFFFF8A00)),
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

class _RouteCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _RouteCard({
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
            title: 'Route Details',
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
          _RouteStep(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            label: 'PICKUP COMPLETED',
            address: '14, Andheri East, Mumbai — 400069',
            textColor: textColor,
            subTextColor: subTextColor,
            done: true,
          ),
          _ConnectorLine(color: const Color(0xFF0B5FFF).withValues(alpha: .18)),
          _RouteStep(
            icon: Icons.local_shipping_rounded,
            iconColor: const Color(0xFF0B5FFF),
            label: 'IN TRANSIT',
            address: 'Western Express Highway • Light traffic',
            textColor: textColor,
            subTextColor: subTextColor,
            done: true,
          ),
          _ConnectorLine(color: const Color(0xFF0B5FFF).withValues(alpha: .18)),
          _RouteStep(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.warning,
            label: 'DELIVERY',
            address: '8, Koramangala 5th Block, Bengaluru — 560095',
            textColor: textColor,
            subTextColor: subTextColor,
            done: false,
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _PackageCard({
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
            title: 'Package',
            trailing: 'Fragile',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SoftIcon(
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF0B5FFF),
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
                        'Electronics — Medium Box',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '2.5 kg • Handle with care • Insured',
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
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.warning.withValues(alpha: .20)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cash on delivery — Collect ₹2,499 from customer',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
            trailing: 'Priority Delivery',
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
              'Instruction: Ring bell twice. Building 3, 2nd floor. Call before reaching the gate.',
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

class _ObcCard extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color surfaceColor;

  const _ObcCard({
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
            trailing: 'Trip Reward',
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _RewardMini(
                label: 'Trip',
                value: '+12 OBC',
                color: Color(0xFFFF8A00),
              ),
              _RewardMini(
                label: 'Safe Delivery',
                value: '+5 OBC',
                color: Color(0xFF0B5FFF),
              ),
              _RewardMini(
                label: 'On Time',
                value: '+8 OBC',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onNavigate;
  final VoidCallback onDelivered;

  const _BottomActions({
    required this.onNavigate,
    required this.onDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Navigate',
            icon: Icons.navigation_rounded,
            color: const Color(0xFF0B5FFF),
            filled: false,
            onTap: onNavigate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: 'Mark Delivered',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            filled: true,
            onTap: onDelivered,
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
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
                    fontSize: 14,
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

class _RouteStep extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final Color textColor;
  final Color subTextColor;
  final bool done;

  const _RouteStep({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.textColor,
    required this.subTextColor,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: subTextColor,
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

class _ConnectorLine extends StatelessWidget {
  final Color color;

  const _ConnectorLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 11),
        child: Container(
          width: 2,
          height: 22,
          color: color,
        ),
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            trailing,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: .22)),
      ),
      child: const Text(
        'IN PROGRESS • LIVE',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _SmallPin extends StatelessWidget {
  final Color color;

  const _SmallPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on_rounded,
      color: color,
      size: 28,
    );
  }
}

class _RouteBackground extends StatelessWidget {
  const _RouteBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RouteBackgroundPainter(
          dark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _RouteBackgroundPainter extends CustomPainter {
  final bool dark;

  const _RouteBackgroundPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF0B5FFF).withValues(alpha: dark ? .08 : .06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(-20, size.height * .16)
      ..cubicTo(size.width * .25, size.height * .08, size.width * .60,
          size.height * .30, size.width + 20, size.height * .18);

    final p2 = Path()
      ..moveTo(size.width + 20, size.height * .64)
      ..cubicTo(size.width * .70, size.height * .52, size.width * .42,
          size.height * .80, -20, size.height * .72);

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
  bool shouldRepaint(covariant _RouteBackgroundPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.icon, this.color);
}