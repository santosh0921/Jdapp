// lib/features/splash/splash_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _float;
  late final AnimationController _orbit;

  bool _animDone = false;

  @override
  void initState() {
    super.initState();

    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat();

    // Wait for animation, then check session.
    Future.delayed(const Duration(milliseconds: 4700), () {
      _animDone = true;
      _tryNavigate();
    });
  }

  /// Navigate once the animation is done AND auth status is known.
  /// GoRouter's redirect logic handles sending authenticated users to their
  /// correct dashboard — we always push to /onboarding as the next stop.
  void _tryNavigate() {
    if (!mounted || !_animDone) return;

    final auth = context.read<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      // Auth provider is still initialising (slow network). Wait for it.
      auth.addListener(_onAuthResolved);
    } else {
      // Status is known. GoRouter redirect will send authenticated users
      // to their dashboard; unauthenticated users land on onboarding.
      context.go('/onboarding');
    }
  }

  void _onAuthResolved() {
    final auth = context.read<AuthProvider>();
    if (auth.status != AuthStatus.unknown) {
      auth.removeListener(_onAuthResolved);
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    // Remove listener if we were waiting
    try {
      final auth = context.read<AuthProvider>();
      auth.removeListener(_onAuthResolved);
    } catch (_) {}
    _main.dispose();
    _float.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );

    final titleFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.25, 0.62, curve: Curves.easeOut),
    );

    final panelFade = CurvedAnimation(
      parent: _main,
      curve: const Interval(0.48, 0.95, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      body: AnimatedBuilder(
        animation: Listenable.merge([_main, _float, _orbit]),
        builder: (context, _) {
          final floatY = (_float.value - 0.5) * 18;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDDF2FF),
                  Color(0xFFEAF6FF),
                  Color(0xFFF8FBFF),
                ],
              ),
            ),
            child: Stack(
              children: [
                const _WorldRouteBackground(),

                Positioned(
                  top: -90,
                  right: -90,
                  child: _SoftCircle(
                    size: 280,
                    color: AppColors.primary.withValues(alpha: 0.11),
                  ),
                ),

                Positioned(
                  bottom: -120,
                  left: -110,
                  child: _SoftCircle(
                    size: 330,
                    color: AppColors.saffron.withValues(alpha: 0.13),
                  ),
                ),

                Positioned(
                  top: 90 + floatY,
                  left: 26,
                  child: const _FloatingClaySticker(
                    icon: Icons.flight_takeoff_rounded,
                    color: AppColors.primary,
                  ),
                ),

                Positioned(
                  top: 135 - floatY,
                  right: 26,
                  child: const _FloatingClaySticker(
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.saffron,
                  ),
                ),

                Positioned(
                  bottom: 185 + floatY,
                  left: 30,
                  child: const _FloatingClaySticker(
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),

                Positioned(
                  bottom: 145 - floatY,
                  right: 30,
                  child: const _FloatingClaySticker(
                    icon: Icons.warehouse_rounded,
                    color: AppColors.success,
                  ),
                ),

                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth =
                          constraints.maxWidth > 520 ? 460.0 : constraints.maxWidth;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 22),

                                FadeTransition(
                                  opacity: logoFade,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.76, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _main,
                                        curve: const Interval(
                                          0.0,
                                          0.36,
                                          curve: Curves.elasticOut,
                                        ),
                                      ),
                                    ),
                                    child: _EarthShipmentHero(
                                      orbit: _orbit.value,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                FadeTransition(
                                  opacity: titleFade,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(-1.5, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: _main,
                                              curve: const Interval(
                                                0.25,
                                                0.56,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'JD',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 42,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1.5, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: _main,
                                              curve: const Interval(
                                                0.25,
                                                0.56,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'Logistics',
                                            style: TextStyle(
                                              color: AppColors.textDark,
                                              fontSize: 42,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                FadeTransition(
                                  opacity: titleFade,
                                  child: const Text(
                                    'Delivering Beyond Boundaries',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                FadeTransition(
                                  opacity: panelFade,
                                  child: const _ClayLogisticsPanel(),
                                ),

                                const SizedBox(height: 28),

                                FadeTransition(
                                  opacity: panelFade,
                                  child: Column(
                                    children: [
                                      _ClayLoader(progress: _main.value),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'Connecting global shipment network...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class _EarthShipmentHero extends StatelessWidget {
  final double orbit;

  const _EarthShipmentHero({required this.orbit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEAF6FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.95),
                  offset: const Offset(-12, -12),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  offset: const Offset(14, 18),
                  blurRadius: 34,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(170, 170),
            painter: _EarthPainter(orbit: orbit),
          ),
          Transform.rotate(
            angle: orbit * math.pi * 2,
            child: const SizedBox(
              width: 205,
              height: 205,
              child: Stack(
                children: [
                  Positioned(
                    top: 6,
                    left: 86,
                    child: _OrbitIcon(
                      icon: Icons.flight_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 18,
                    child: _OrbitIcon(
                      icon: Icons.local_shipping_rounded,
                      color: AppColors.saffron,
                    ),
                  ),
                  Positioned(
                    right: 9,
                    bottom: 48,
                    child: _OrbitIcon(
                      icon: Icons.inventory_2_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.public_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _OrbitIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.96),
              offset: const Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              offset: const Offset(6, 7),
              blurRadius: 14,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _EarthPainter extends CustomPainter {
  final double orbit;

  const _EarthPainter({required this.orbit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0B5FFF),
          Color(0xFF4AB3FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, oceanPaint);

    final landPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.86)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 30, center.dy - 18),
        width: 48,
        height: 30,
      ),
      landPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 25, center.dy + 8),
        width: 58,
        height: 36,
      ),
      landPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 10, center.dy + 34),
        width: 38,
        height: 22,
      ),
      landPaint,
    );

    final routePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: center,
        width: size.width - (i * 30),
        height: 38 + (i * 28),
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((orbit * math.pi * 2) + i * 0.7);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawArc(rect, 0.2, math.pi * 1.45, false, routePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EarthPainter oldDelegate) {
    return oldDelegate.orbit != orbit;
  }
}

class _ClayLogisticsPanel extends StatelessWidget {
  const _ClayLogisticsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.96),
            offset: const Offset(-10, -10),
            blurRadius: 24,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            offset: const Offset(12, 16),
            blurRadius: 34,
          ),
        ],
      ),
      child: const Column(
        children: [
          _ShipmentRouteStrip(),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ClayMetricTile(
                  icon: Icons.route_rounded,
                  label: 'Routes',
                  value: 'Global',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ClayMetricTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'Parcels',
                  value: 'Fast',
                  color: AppColors.saffron,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ClayMetricTile(
                  icon: Icons.warehouse_rounded,
                  label: 'Hubs',
                  value: 'Smart',
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ClayMetricTile(
                  icon: Icons.verified_rounded,
                  label: 'Delivery',
                  value: 'Secure',
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShipmentRouteStrip extends StatelessWidget {
  const _ShipmentRouteStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.98),
            offset: const Offset(-7, -7),
            blurRadius: 16,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            offset: const Offset(8, 10),
            blurRadius: 22,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: CustomPaint(
              painter: _DashedRoutePainter(),
              child: const SizedBox(height: 38),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.flag_rounded, color: AppColors.saffron),
        ],
      ),
    );
  }
}

class _DashedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.saffron,
          AppColors.success,
        ],
      ).createShader(Rect.fromLTWH(0, y - 3, size.width, 6))
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + 12, y), paint);
      x += 22;
    }

    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.34, y), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.68, y), 5, Paint()..color = AppColors.saffron);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClayMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ClayMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.98),
            offset: const Offset(-6, -6),
            blurRadius: 14,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            offset: const Offset(7, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClayLoader extends StatelessWidget {
  final double progress;

  const _ClayLoader({required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = (progress / 0.95).clamp(0.0, 1.0);

    return Container(
      width: 150,
      height: 14,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.98),
            offset: const Offset(-5, -5),
            blurRadius: 12,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            offset: const Offset(6, 7),
            blurRadius: 14,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: p,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldRouteBackground extends StatelessWidget {
  const _WorldRouteBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _WorldRoutePainter(),
    );
  }
}

class _WorldRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.035)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 76) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        gridPaint,
      );
    }

    for (double i = 0; i < size.width + size.height; i += 94) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        gridPaint,
      );
    }

    final routePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.10, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.14,
        size.width * 0.82,
        size.height * 0.28,
      )
      ..moveTo(size.width * 0.18, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.64,
        size.width * 0.88,
        size.height * 0.72,
      );

    canvas.drawPath(path, routePaint);

    final dotPaint = Paint()
      ..color = AppColors.saffron.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    for (final offset in [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.55, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.28),
      Offset(size.width * 0.20, size.height * 0.76),
      Offset(size.width * 0.58, size.height * 0.66),
      Offset(size.width * 0.88, size.height * 0.72),
    ]) {
      canvas.drawCircle(offset, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingClaySticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FloatingClaySticker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.10,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.96),
              offset: const Offset(-6, -6),
              blurRadius: 14,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              offset: const Offset(7, 8),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 27),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}