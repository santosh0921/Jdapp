import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/services/tracking_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class JdMapWidget extends StatefulWidget {
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final String fromLabel;
  final String toLabel;
  final String? eta;
  final double height;

  // Optional pre-decoded polyline points. If null, widget fetches from backend.
  final List<LatLng>? routePoints;

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
    this.routePoints,
  });

  @override
  State<JdMapWidget> createState() => _JdMapWidgetState();
}

class _JdMapWidgetState extends State<JdMapWidget> {
  GoogleMapController? _ctrl;
  Set<Polyline> _polylines = {};

  bool get _hasValidFrom => widget.fromLat != 0 || widget.fromLng != 0;
  bool get _hasValidTo   => widget.toLat   != 0 || widget.toLng   != 0;
  bool get _hasAnyCoords => _hasValidFrom || _hasValidTo;

  LatLng get _center {
    if (_hasValidFrom && _hasValidTo) {
      return LatLng(
        (widget.fromLat + widget.toLat) / 2,
        (widget.fromLng + widget.toLng) / 2,
      );
    }
    if (_hasValidFrom) return LatLng(widget.fromLat, widget.fromLng);
    if (_hasValidTo)   return LatLng(widget.toLat,   widget.toLng);
    return const LatLng(20.5937, 78.9629); // India centre fallback
  }

  double get _initialZoom => (_hasValidFrom && _hasValidTo) ? 8 : 12;

  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (_hasValidFrom) {
      markers.add(Marker(
        markerId: const MarkerId('from'),
        position: LatLng(widget.fromLat, widget.fromLng),
        infoWindow: InfoWindow(title: widget.fromLabel),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (_hasValidTo) {
      markers.add(Marker(
        markerId: const MarkerId('to'),
        position: LatLng(widget.toLat, widget.toLng),
        infoWindow: InfoWindow(title: widget.toLabel),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    return markers;
  }

  @override
  void initState() {
    super.initState();
    if (widget.routePoints != null) {
      _buildPolylineFrom(widget.routePoints!);
    } else if (_hasValidFrom && _hasValidTo) {
      _fetchRoute();
    }
  }

  @override
  void didUpdateWidget(JdMapWidget old) {
    super.didUpdateWidget(old);
    final coordsChanged = old.fromLat != widget.fromLat ||
        old.fromLng != widget.fromLng ||
        old.toLat != widget.toLat ||
        old.toLng != widget.toLng;
    if (coordsChanged) {
      if (widget.routePoints != null) {
        _buildPolylineFrom(widget.routePoints!);
      } else if (_hasValidFrom && _hasValidTo) {
        _fetchRoute();
      }
    }
  }

  void _buildPolylineFrom(List<LatLng> points) {
    if (!mounted) return;
    setState(() {
      _polylines = points.isEmpty
          ? {}
          : {
              Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: AppColors.primary,
                width: 4,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
    });
    if (points.isNotEmpty && _ctrl != null) {
      _fitBounds(points);
    }
  }

  Future<void> _fetchRoute() async {
    try {
      final result = await TrackingService.instance.getRoute(
        fromLat: widget.fromLat,
        fromLng: widget.fromLng,
        toLat: widget.toLat,
        toLng: widget.toLng,
      );
      final encoded = (result['overview_polyline'] ??
          result['polyline'] ??
          result['encoded_polyline'] ??
          result['path']) as String?;
      if (encoded != null && encoded.isNotEmpty && mounted) {
        final decoded = PolylinePoints()
            .decodePolyline(encoded)
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        _buildPolylineFrom(decoded);
        if (_ctrl != null) _fitBounds(decoded);
      }
    } catch (_) {
      // Route unavailable — just show markers
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty || _ctrl == null) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _ctrl?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      56,
    ));
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyCoords) {
      return _MockMap(
        fromLabel: widget.fromLabel,
        toLabel: widget.toLabel,
        eta: widget.eta,
        height: widget.height,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _initialZoom,
              ),
              onMapCreated: (ctrl) {
                _ctrl = ctrl;
                if (_polylines.isNotEmpty) {
                  _fitBounds(_polylines.first.points);
                } else if (_hasValidFrom && _hasValidTo) {
                  _fitBounds([
                    LatLng(widget.fromLat, widget.fromLng),
                    LatLng(widget.toLat, widget.toLng),
                  ]);
                }
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,
            ),
            // ETA badge
            if (widget.eta != null)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.saffron, size: 14),
                        const SizedBox(width: 5),
                        Text('ETA ${widget.eta}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Fallback when coordinates are unavailable ────────────────────────────────

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
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          Center(
            child: CustomPaint(
              size: const Size(200, 80),
              painter: _RoutePainter(),
            ),
          ),
          Positioned(
            left: 40,
            top: height / 2 - 36,
            child: _Pin(label: fromLabel, color: AppColors.primary),
          ),
          Positioned(
            right: 40,
            top: height / 2 - 36,
            child: _Pin(label: toLabel, color: AppColors.success),
          ),
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.saffron, size: 14),
                    const SizedBox(width: 5),
                    Text('ETA $eta',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.black54, borderRadius: BorderRadius.circular(6)),
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
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          CustomPaint(size: const Size(12, 8), painter: _PinTailPainter(color)),
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      );
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
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
      ..cubicTo(size.width * 0.25, size.height * 0.2, size.width * 0.75,
          size.height * 0.8, size.width, 0);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}
