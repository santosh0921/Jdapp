import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/models/shipment_model.dart';
import 'package:jd_style_logistics/services/courier_service.dart';
import 'package:jd_style_logistics/services/location_service.dart';
import 'package:jd_style_logistics/services/tracking_service.dart';

class LiveShipmentMapScreen extends StatefulWidget {
  final String id;
  final String mode;

  const LiveShipmentMapScreen({
    super.key,
    this.id = '',
    this.mode = 'road',
  });

  @override
  State<LiveShipmentMapScreen> createState() => _LiveShipmentMapScreenState();
}

class _LiveShipmentMapScreenState extends State<LiveShipmentMapScreen> {
  GoogleMapController? _mapCtrl;
  Timer? _pollTimer;

  // Coordinates
  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  LatLng? _driverLatLng;

  // Route
  Set<Polyline> _polylines = {};

  // Status
  List<TrackingEventModel> _events = [];
  String _statusText = 'Loading…';
  String _locationText = '';
  String _eta = '—';
  String _distance = '—';
  String _speed = '—';
  double _progressFraction = 0.0;

  // Labels
  String _fromCity = '';
  String _toCity = '';

  bool _loading = true;
  bool _mapFallback = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchOrderAndRoute();
    await _fetchEvents();
    if (!mounted) return;
    setState(() => _loading = false);

    // Poll events every 10 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchEvents());
  }

  Future<void> _fetchOrderAndRoute() async {
    if (widget.id.isEmpty) return;
    try {
      final order = await CourierService.instance.getOrderById(widget.id);
      if (!mounted) return;

      // Extract coordinates from order
      final fromLat = _toDouble(order['pickup_lat'] ?? order['from_lat']);
      final fromLng = _toDouble(order['pickup_lng'] ?? order['from_lng']);
      final toLat   = _toDouble(order['delivery_lat'] ?? order['to_lat']);
      final toLng   = _toDouble(order['delivery_lng'] ?? order['to_lng']);

      LatLng? from, to;

      if (fromLat != 0 && fromLng != 0) {
        from = LatLng(fromLat, fromLng);
      }
      if (toLat != 0 && toLng != 0) {
        to = LatLng(toLat, toLng);
      }

      // If coordinates not in order, geocode addresses
      final pickupAddr  = (order['pickup_address']   ?? order['from_address']  ?? '') as String;
      final deliverAddr = (order['delivery_address'] ?? order['to_address']    ?? '') as String;

      if (from == null && pickupAddr.isNotEmpty) {
        final locs = await LocationService.instance.geocodeAddress(pickupAddr);
        if (locs.isNotEmpty) from = LatLng(locs.first.latitude, locs.first.longitude);
      }
      if (to == null && deliverAddr.isNotEmpty) {
        final locs = await LocationService.instance.geocodeAddress(deliverAddr);
        if (locs.isNotEmpty) to = LatLng(locs.first.latitude, locs.first.longitude);
      }

      _fromCity = _extractCity(order['pickup_address'] ?? order['from_city'] ?? pickupAddr);
      _toCity   = _extractCity(order['delivery_address'] ?? order['to_city'] ?? deliverAddr);

      if (mounted) setState(() { _fromLatLng = from; _toLatLng = to; });

      // Fetch route between valid coordinates
      if (from != null && to != null) {
        _fetchRoute(from, to);
      } else {
        if (mounted) setState(() => _mapFallback = true);
      }
    } catch (_) {
      if (mounted) setState(() => _mapFallback = true);
    }
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    try {
      final result = await TrackingService.instance.getRoute(
        fromLat: from.latitude, fromLng: from.longitude,
        toLat: to.latitude,   toLng: to.longitude,
      );
      final encoded = (result['overview_polyline'] ?? result['polyline'] ??
          result['encoded_polyline'] ?? result['path']) as String?;
      if (encoded != null && encoded.isNotEmpty && mounted) {
        final points = PolylinePoints()
            .decodePolyline(encoded)
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: _modeColor,
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          };
        });
        // Extract distance from result
        final distM = _toDouble(result['distance_meters'] ?? result['distance'] ?? result['length']);
        if (distM > 0) {
          final distKm = (distM / 1000).toStringAsFixed(1);
          if (mounted) setState(() => _distance = '$distKm km');
        }
        // Extract ETA
        final durationSec = _toDouble(result['duration_seconds'] ?? result['duration'] ?? result['eta_seconds']);
        if (durationSec > 0) {
          final min = (durationSec / 60).round();
          final hrs = min ~/ 60;
          final rem = min % 60;
          if (mounted) setState(() => _eta = hrs > 0 ? '${hrs}h ${rem}m' : '${min}m');
        }
        _fitBounds([from, to]);
      }
    } catch (_) {
      // Route unavailable — just show markers
    }
  }

  Future<void> _fetchEvents() async {
    if (widget.id.isEmpty) return;
    try {
      final events = await TrackingService.instance.getEvents(widget.id);
      if (!mounted) return;
      if (events.isNotEmpty) {
        final latest = events.last;
        setState(() {
          _events = events;
          _statusText = _statusLabel(latest.status);
          _locationText = latest.location;
          _progressFraction = _statusProgress(latest.status);
        });
      }
    } catch (_) {}
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty || _mapCtrl == null) return;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapCtrl?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      64,
    ));
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _extractCity(String addr) {
    if (addr.isEmpty) return '—';
    final parts = addr.split(',');
    return parts.first.trim();
  }

  Set<Marker> get _markers {
    final ms = <Marker>{};
    if (_fromLatLng != null) {
      ms.add(Marker(
        markerId: const MarkerId('from'),
        position: _fromLatLng!,
        infoWindow: InfoWindow(title: _fromCity.isNotEmpty ? _fromCity : 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (_toLatLng != null) {
      ms.add(Marker(
        markerId: const MarkerId('to'),
        position: _toLatLng!,
        infoWindow: InfoWindow(title: _toCity.isNotEmpty ? _toCity : 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    if (_driverLatLng != null) {
      ms.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLatLng!,
        infoWindow: const InfoWindow(title: 'Driver'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    return ms;
  }

  LatLng get _mapCenter {
    if (_fromLatLng != null && _toLatLng != null) {
      return LatLng(
        (_fromLatLng!.latitude  + _toLatLng!.latitude)  / 2,
        (_fromLatLng!.longitude + _toLatLng!.longitude) / 2,
      );
    }
    return _fromLatLng ?? _toLatLng ?? const LatLng(20.5937, 78.9629);
  }

  Color get _modeColor {
    switch (widget.mode.toLowerCase()) {
      case 'air':   return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default:      return AppColors.roadColor;
    }
  }

  IconData get _vehicleIcon {
    switch (widget.mode.toLowerCase()) {
      case 'air':   return Icons.flight_takeoff_rounded;
      case 'ocean': return Icons.directions_boat_filled_rounded;
      default:      return Icons.local_shipping_rounded;
    }
  }

  String get _modeLabel {
    switch (widget.mode.toLowerCase()) {
      case 'air':   return 'Air Cargo';
      case 'ocean': return 'Ocean Freight';
      default:      return 'Road Freight';
    }
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'booked':            return 'Shipment Booked';
      case 'driver_assigned':   return 'Driver Assigned';
      case 'driver_accepted':   return 'Driver Accepted';
      case 'reached_pickup':    return 'Reached Pickup';
      case 'picked_up':         return 'Picked Up';
      case 'in_transit':        return 'In Transit';
      case 'at_hub':            return 'At Warehouse Hub';
      case 'out_for_delivery':  return 'Out for Delivery';
      case 'delivered':         return 'Delivered';
      case 'cancelled':         return 'Cancelled';
      default: return s.replaceAll('_', ' ').split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
    }
  }

  double _statusProgress(String s) {
    const map = {
      'booked': 0.05, 'driver_assigned': 0.15, 'driver_accepted': 0.20,
      'reached_pickup': 0.25, 'picked_up': 0.35, 'in_transit': 0.60,
      'at_hub': 0.65, 'out_for_delivery': 0.80, 'delivered': 1.0,
    };
    return map[s.toLowerCase()] ?? 0.5;
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
            Text('Live Tracking',
                style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
            Text('${widget.id} · $_modeLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: AppColors.text(context)),
            onPressed: () => context.push('/shipment/share-tracking?id=${widget.id}'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : GradientBackground(
              child: Stack(
                children: [
                  // ── Map section ───────────────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 260,
                    child: _mapFallback || (_fromLatLng == null && _toLatLng == null)
                        ? _FallbackMapCard(
                            fromCity: _fromCity,
                            toCity: _toCity,
                            modeColor: _modeColor,
                            vehicleIcon: _vehicleIcon,
                          )
                        : GoogleMap(
                            initialCameraPosition:
                                CameraPosition(target: _mapCenter, zoom: 8),
                            onMapCreated: (ctrl) {
                              _mapCtrl = ctrl;
                              if (_fromLatLng != null && _toLatLng != null) {
                                _fitBounds([_fromLatLng!, _toLatLng!]);
                              }
                            },
                            markers: _markers,
                            polylines: _polylines,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          ),
                  ),

                  // ── Floating status chip ───────────────────────────────────
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 12,
                    child: _FloatingMapStatus(
                      id: widget.id,
                      modeLabel: _modeLabel,
                      modeColor: _modeColor,
                      vehicleIcon: _vehicleIcon,
                      statusText: _statusText,
                    ),
                  ),

                  // ── Bottom panel ───────────────────────────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomTrackingPanel(
                      modeColor: _modeColor,
                      vehicleIcon: _vehicleIcon,
                      statusText: _statusText,
                      locationText: _locationText,
                      eta: _eta,
                      distance: _distance,
                      speed: _speed,
                      fromCity: _fromCity,
                      toCity: _toCity,
                      progressFraction: _progressFraction,
                      eventCount: _events.length,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FallbackMapCard extends StatelessWidget {
  final String fromCity, toCity;
  final Color modeColor;
  final IconData vehicleIcon;
  const _FallbackMapCard({
    required this.fromCity, required this.toCity,
    required this.modeColor, required this.vehicleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(vehicleIcon, color: modeColor, size: 52),
            const SizedBox(height: 12),
            Text('$fromCity → $toCity',
                style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            const SizedBox(height: 6),
            Text('Map coordinates not available',
                style: TextStyle(color: AppColors.subtext(context), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _FloatingMapStatus extends StatelessWidget {
  final String id, modeLabel, statusText;
  final Color modeColor;
  final IconData vehicleIcon;
  const _FloatingMapStatus({
    required this.id, required this.modeLabel, required this.modeColor,
    required this.vehicleIcon, required this.statusText,
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
                Text(id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text(statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: modeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
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
  final String statusText, locationText, eta, distance, speed, fromCity, toCity;
  final double progressFraction;
  final int eventCount;

  const _BottomTrackingPanel({
    required this.modeColor, required this.vehicleIcon,
    required this.statusText, required this.locationText,
    required this.eta, required this.distance, required this.speed,
    required this.fromCity, required this.toCity,
    required this.progressFraction, required this.eventCount,
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
              width: 38, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(99)),
            ),
            Row(
              children: [
                _MapIcon(icon: vehicleIcon, color: modeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusText,
                          style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 14)),
                      if (locationText.isNotEmpty)
                        Text(locationText,
                            style: TextStyle(
                                color: AppColors.subtext(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                    ],
                  ),
                ),
                const _LivePill(),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'ETA', value: eta,
                    icon: Icons.schedule_rounded, color: AppColors.success)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Distance', value: distance,
                    icon: Icons.route_rounded, color: modeColor)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Events', value: '$eventCount',
                    icon: Icons.timeline_rounded, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 14),
            _RouteStopsCard(
                modeColor: modeColor,
                fromCity: fromCity,
                toCity: toCity,
                progressFraction: progressFraction),
          ],
        ),
      ),
    );
  }
}

class _RouteStopsCard extends StatelessWidget {
  final Color modeColor;
  final String fromCity, toCity;
  final double progressFraction;

  const _RouteStopsCard({
    required this.modeColor, required this.fromCity,
    required this.toCity, required this.progressFraction,
  });

  @override
  Widget build(BuildContext context) {
    final pct = '${(progressFraction * 100).round()}%';
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _StopRow(label: fromCity.isEmpty ? 'Origin' : fromCity,
                icon: Icons.circle, color: AppColors.success, bold: true),
            _StopLine(),
            _StopRow(label: 'In Transit',
                icon: Icons.location_on_rounded, color: modeColor, bold: true),
            _StopLine(),
            _StopRow(label: toCity.isEmpty ? 'Destination' : toCity,
                icon: Icons.location_on_rounded, color: AppColors.error),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('— km total',
                style: TextStyle(color: AppColors.subtext(context),
                    fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                width: 106,
                child: LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 7,
                  backgroundColor: AppColors.surface(context),
                  valueColor: AlwaysStoppedAnimation(modeColor),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(pct,
                style: TextStyle(color: modeColor,
                    fontWeight: FontWeight.w900, fontSize: 11)),
          ]),
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
    required this.label, required this.icon,
    required this.color, this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              color: bold ? color : AppColors.subtext(context),
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: 12)),
    ]);
  }
}

class _StopLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(width: 2, height: 18, color: AppColors.border(context)),
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
            alpha: AppColors.isDark(context) ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.24)),
      ),
      child: const Text('Live',
          style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
              fontSize: 12)),
    );
  }
}

class _MapIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MapIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 46, height: 46, borderRadius: 16, padding: EdgeInsets.zero,
      color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.11),
      borderColor: color.withValues(alpha: 0.24),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(height: 4),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
                fontSize: 11)),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
                fontSize: 10)),
      ]),
    );
  }
}
