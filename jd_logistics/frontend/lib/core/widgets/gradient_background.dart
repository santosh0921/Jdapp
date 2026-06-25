import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool showLogisticsLayer;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.showLogisticsLayer = true,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final gradientColors =
        widget.colors ?? (isDark ? AppColors.darkGradient : AppColors.lightGradient);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: widget.begin,
          end: widget.end,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          if (widget.showLogisticsLayer)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _LogisticsBackgroundPainter(
                        progress: _controller.value,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class HeroGradientBackground extends StatelessWidget {
  final Widget child;
  final bool showLogisticsLayer;

  const HeroGradientBackground({
    super.key,
    required this.child,
    this.showLogisticsLayer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return GradientBackground(
      colors: isDark ? AppColors.oceanGradient : AppColors.lightGradient,
      showLogisticsLayer: showLogisticsLayer,
      child: child,
    );
  }
}

class _LogisticsBackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _LogisticsBackgroundPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawOceanDepth(canvas, size);
    _drawMapWatermark(canvas, size);
    _drawRouteLines(canvas, size);
    _drawNodes(canvas, size);
    _drawMovingDots(canvas, size);
    _drawVehicleIcons(canvas, size);
  }

  void _drawOceanDepth(Canvas canvas, Size size) {
    if (!isDark) return;

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.8),
        radius: 1.35,
        colors: [
          AppColors.oceanBlue.withValues(alpha: 0.10),
          AppColors.darkBg1.withValues(alpha: 0.00),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);

    final secondPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.9, 0.8),
        radius: 1.25,
        colors: [
          AppColors.portOrange.withValues(alpha: 0.055),
          AppColors.darkBg1.withValues(alpha: 0.00),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, secondPaint);
  }

  void _drawMapWatermark(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.shipmentDot : AppColors.primary)
          .withValues(alpha: isDark ? 0.055 : 0.030)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDark ? 1.25 : 1.05
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width * 0.05, size.height * 0.20);
    path.quadraticBezierTo(
      size.width * 0.16,
      size.height * 0.09,
      size.width * 0.33,
      size.height * 0.16,
    );
    path.quadraticBezierTo(
      size.width * 0.44,
      size.height * 0.23,
      size.width * 0.54,
      size.height * 0.14,
    );
    path.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.03,
      size.width * 0.94,
      size.height * 0.20,
    );

    path.moveTo(size.width * 0.12, size.height * 0.64);
    path.quadraticBezierTo(
      size.width * 0.29,
      size.height * 0.50,
      size.width * 0.46,
      size.height * 0.63,
    );
    path.quadraticBezierTo(
      size.width * 0.62,
      size.height * 0.76,
      size.width * 0.88,
      size.height * 0.59,
    );

    path.moveTo(size.width * 0.18, size.height * 0.42);
    path.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.33,
      size.width * 0.68,
      size.height * 0.42,
    );

    canvas.drawPath(path, paint);
  }

  void _drawRouteLines(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = (isDark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: isDark ? 0.18 : 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDark ? 1.35 : 1.2
      ..strokeCap = StrokeCap.round;

    final orangePaint = Paint()
      ..color = AppColors.portOrange.withValues(alpha: isDark ? 0.13 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round;

    final top = Path()
      ..moveTo(size.width * 0.08, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.07,
        size.width * 0.92,
        size.height * 0.23,
      );

    final bottom = Path()
      ..moveTo(size.width * 0.12, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.52,
        size.width * 0.88,
        size.height * 0.70,
      );

    final mid = Path()
      ..moveTo(size.width * 0.05, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.38,
        size.width * 0.94,
        size.height * 0.50,
      );

    canvas.drawPath(top, routePaint);
    _drawDashedPath(canvas, bottom, orangePaint);
    canvas.drawPath(mid, routePaint..color = routePaint.color.withValues(alpha: isDark ? 0.09 : 0.16));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 7.0;
    const dashSpace = 9.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    final nodes = [
      Offset(size.width * 0.12, size.height * 0.30),
      Offset(size.width * 0.88, size.height * 0.23),
      Offset(size.width * 0.17, size.height * 0.78),
      Offset(size.width * 0.84, size.height * 0.70),
      Offset(size.width * 0.52, size.height * 0.50),
      Offset(size.width * 0.68, size.height * 0.38),
    ];

    final colors = [
      AppColors.warehouseNode,
      AppColors.airportNode,
      AppColors.portNode,
      AppColors.warehouseNode,
      AppColors.routeNode,
      AppColors.oceanCyan,
    ];

    for (var i = 0; i < nodes.length; i++) {
      final outer = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.12 : 0.13);

      final inner = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.36 : 0.38);

      final ring = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.24 : 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;

      canvas.drawCircle(nodes[i], 9, outer);
      canvas.drawCircle(nodes[i], 4.2, ring);
      canvas.drawCircle(nodes[i], 2.4, inner);
    }
  }

  void _drawMovingDots(Canvas canvas, Size size) {
    final paths = [
      _buildTopPath(size),
      _buildBottomPath(size),
      _buildMiddlePath(size),
    ];

    final colors = [
      AppColors.shipmentDot,
      AppColors.portOrange,
      AppColors.oceanCyan,
    ];

    for (var i = 0; i < paths.length; i++) {
      final metric = paths[i].computeMetrics().first;
      final distance = metric.length * ((progress + i * 0.29) % 1.0);
      final tangent = metric.getTangentForOffset(distance);

      if (tangent == null) continue;

      final paint = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.58 : 0.48);

      canvas.drawCircle(tangent.position, isDark ? 3.0 : 2.7, paint);
    }
  }

  Path _buildTopPath(Size size) {
    return Path()
      ..moveTo(size.width * 0.08, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.07,
        size.width * 0.92,
        size.height * 0.23,
      );
  }

  Path _buildBottomPath(Size size) {
    return Path()
      ..moveTo(size.width * 0.12, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.52,
        size.width * 0.88,
        size.height * 0.70,
      );
  }

  Path _buildMiddlePath(Size size) {
    return Path()
      ..moveTo(size.width * 0.05, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.38,
        size.width * 0.94,
        size.height * 0.50,
      );
  }

  void _drawVehicleIcons(Canvas canvas, Size size) {
    final iconPaint = Paint()
      ..color = (isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary)
          .withValues(alpha: isDark ? 0.13 : 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round;

    _drawShip(canvas, size, iconPaint);
    _drawTruck(canvas, size, iconPaint);
    _drawPlane(canvas, size, iconPaint);
  }

  void _drawShip(Canvas canvas, Size size, Paint paint) {
    final shipX = size.width * (0.10 + 0.72 * progress);
    final shipY = size.height * 0.88;

    canvas.drawLine(Offset(shipX, shipY), Offset(shipX + 30, shipY), paint);
    canvas.drawLine(Offset(shipX + 4, shipY - 7), Offset(shipX + 24, shipY - 7), paint);
    canvas.drawLine(Offset(shipX + 10, shipY - 7), Offset(shipX + 10, shipY - 18), paint);

    final wavePaint = Paint()
      ..color = (isDark ? AppColors.oceanCyan : AppColors.routeLine)
          .withValues(alpha: isDark ? 0.12 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(Offset(shipX - 8, shipY + 8), Offset(shipX + 36, shipY + 8), wavePaint);
  }

  void _drawTruck(Canvas canvas, Size size, Paint paint) {
    final truckX = size.width * (0.88 - 0.70 * progress);
    final truckY = size.height * 0.12;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX, truckY, 30, 14),
        const Radius.circular(4),
      ),
      paint,
    );

    canvas.drawLine(
      Offset(truckX + 30, truckY + 5),
      Offset(truckX + 38, truckY + 9),
      paint,
    );

    canvas.drawCircle(Offset(truckX + 8, truckY + 16), 3, paint);
    canvas.drawCircle(Offset(truckX + 25, truckY + 16), 3, paint);
  }

  void _drawPlane(Canvas canvas, Size size, Paint paint) {
    final planeX = size.width * (0.06 + 0.84 * progress);
    final planeY = size.height * (0.44 - math.sin(progress * math.pi) * 0.08);

    canvas.save();
    canvas.translate(planeX, planeY);
    canvas.rotate(-0.25);
    canvas.drawLine(const Offset(-13, 0), const Offset(15, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(-9, -8), paint);
    canvas.drawLine(const Offset(2, 0), const Offset(-8, 8), paint);
    canvas.drawLine(const Offset(10, 0), const Offset(4, -5), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogisticsBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}