import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

// When google_maps_flutter is properly configured (API key set, billing enabled),
// replace _MockMap with a real GoogleMap widget.

class JdMapWidget extends StatelessWidget {
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final String fromLabel;
  final String toLabel;
  final String? eta;
  final double height;

  const JdMapWidget({
    super.key,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    this.fromLabel = 'Pickup',
    this.toLabel = 'Drop',
    this.eta,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    // Swap this block for a real GoogleMap once the API key is configured:
    //
    // return SizedBox(
    //   height: height,
    //   child: GoogleMap(
    //     initialCameraPosition: CameraPosition(
    //       target: LatLng((fromLat + toLat) / 2, (fromLng + toLng) / 2),
    //       zoom: 10,
    //     ),
    //     markers: {
    //       Marker(markerId: const MarkerId('from'), position: LatLng(fromLat, fromLng), infoWindow: InfoWindow(title: fromLabel)),
    //       Marker(markerId: const MarkerId('to'),   position: LatLng(toLat, toLng),   infoWindow: InfoWindow(title: toLabel)),
    //     },
    //   ),
    // );

    return _MockMap(
      fromLabel: fromLabel,
      toLabel: toLabel,
      eta: eta,
      height: height,
    );
  }
}

class _MockMap extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final String? eta;
  final double height;

  const _MockMap({
    required this.fromLabel,
    required this.toLabel,
    required this.eta,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Grid lines — simulated map tiles
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),
          // Route line
          Center(
            child: CustomPaint(
              size: const Size(200, 80),
              painter: _RoutePainter(),
            ),
          ),
          // From pin
          Positioned(
            left: 40,
            top: height / 2 - 36,
            child: _Pin(label: fromLabel, color: AppColors.primary),
          ),
          // To pin
          Positioned(
            right: 40,
            top: height / 2 - 36,
            child: _Pin(label: toLabel, color: AppColors.success),
          ),
          // ETA badge
          if (eta != null)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          color: AppColors.saffron, size: 14),
                      const SizedBox(width: 5),
                      Text('ETA $eta',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          // Map placeholder label
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Map Preview',
                  style: TextStyle(color: Colors.white38, fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final String label;
  final Color color;
  const _Pin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTailPainter(color),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height)
      ..cubicTo(
        size.width * 0.25, size.height * 0.2,
        size.width * 0.75, size.height * 0.8,
        size.width, 0,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
