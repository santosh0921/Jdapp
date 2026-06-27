import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/driver_provider.dart';
import 'package:jd_style_logistics/services/location_service.dart';
import 'package:jd_style_logistics/services/tracking_service.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Map
  GoogleMapController? _mapCtrl;
  Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  LatLng? _destination;

  // Metrics
  double _distanceKm = 0;
  int _etaMinutes = 0;

  // Subscriptions
  StreamSubscription<Position>? _locationSub;
  Timer? _updateTimer;

  // Status
  bool _permissionDenied = false;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _updateTimer?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final order = context.read<DriverProvider>().activeDelivery;

    // 1. Request location permission
    final granted = await LocationService.instance.requestPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() => _permissionDenied = true);
      return;
    }

    // 2. Get current position
    final pos = await LocationService.instance.getCurrentPosition();
    if (!mounted) return;
    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPosition = ll;
        _locationReady = true;
      });
    }

    // 3. Geocode delivery destination
    if (order != null && order.deliveryAddress.isNotEmpty) {
      final locs = await LocationService.instance.geocodeAddress(order.deliveryAddress);
      if (!mounted) return;
      if (locs.isNotEmpty) {
        final dest = LatLng(locs.first.latitude, locs.first.longitude);
        setState(() => _destination = dest);
        if (_currentPosition != null) {
          _fetchRoute(_currentPosition!, dest);
        }
      }
    }

    // 4. Start position stream
    _locationSub = LocationService.instance
        .getPositionStream(distanceFilter: 20)
        .listen(_onPositionUpdate);

    // 5. Post location to backend every 15 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (_) => _postLocation());
  }

  void _onPositionUpdate(Position pos) {
    if (!mounted) return;
    final ll = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _currentPosition = ll;
      _locationReady = true;
    });
    _mapCtrl?.animateCamera(CameraUpdate.newLatLng(ll));

    // Recalculate remaining distance & ETA
    if (_destination != null) {
      final distM = LocationService.instance.distanceBetween(
        ll.latitude, ll.longitude,
        _destination!.latitude, _destination!.longitude,
      );
      final distKm = distM / 1000;
      final avgSpeedKmh = 30.0;
      final etaMin = ((distKm / avgSpeedKmh) * 60).round();
      if (mounted) setState(() { _distanceKm = distKm; _etaMinutes = etaMin; });
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
              color: const Color(0xFF0B5FFF),
              width: 6,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          };
        });
      }
    } catch (_) {
      // Route unavailable — driver still sees current position
    }
  }

  Future<void> _postLocation() async {
    final pos = _currentPosition;
    if (pos == null) return;
    final order = context.read<DriverProvider>().activeDelivery;
    if (order == null) return;
    await TrackingService.instance.updateDriverLocation(
      orderId: order.id,
      lat: pos.latitude,
      lng: pos.longitude,
    );
  }

  void _recenter() {
    if (_currentPosition != null) {
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
    }
  }

  bool _dark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  Color _bg(BuildContext context) => _dark(context) ? AppColors.darkBg1 : const Color(0xFFFFFFFF);
  Color _surface(BuildContext context) => _dark(context) ? AppColors.darkCard : const Color(0xFFF8FAFF);
  Color _text(BuildContext context) => _dark(context) ? Colors.white : const Color(0xFF0F172A);
  Color _sub(BuildContext context) => _dark(context) ? Colors.white70 : const Color(0xFF64748B);

  Set<Marker> get _markers {
    final ms = <Marker>{};
    if (_currentPosition != null) {
      ms.add(Marker(
        markerId: const MarkerId('driver'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    if (_destination != null) {
      ms.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destination!,
        infoWindow: const InfoWindow(title: 'Delivery'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    return ms;
  }

  String get _etaLabel {
    if (_etaMinutes <= 0) return '—';
    final h = _etaMinutes ~/ 60;
    final m = _etaMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${_etaMinutes}m';
  }

  String get _distanceLabel {
    if (_distanceKm <= 0) return '—';
    return '${_distanceKm.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<DriverProvider>().activeDelivery;
    final orderId = order != null
        ? (order.trackingId.isNotEmpty ? order.trackingId : order.id)
        : 'Active Delivery';
    final stops = order == null
        ? const <_Stop>[]
        : [
            _Stop(label: 'Pickup', address: order.pickupAddress.isNotEmpty ? order.pickupAddress : '—',
                isOrigin: true, completed: true),
            _Stop(label: 'Delivery', address: order.deliveryAddress.isNotEmpty ? order.deliveryAddress : '—',
                isOrigin: false, completed: false),
          ];

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
                  subtitle: orderId,
                  textColor: _text(context),
                  subTextColor: _sub(context),
                  surfaceColor: _surface(context),
                  onBack: () { HapticFeedback.lightImpact(); if (context.canPop()) context.pop(); },
                  onRecenter: _recenter,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
                    child: Column(
                      children: [
                        _MapCard(
                          currentPosition: _currentPosition,
                          destination: _destination,
                          polylines: _polylines,
                          markers: _markers,
                          permissionDenied: _permissionDenied,
                          locationReady: _locationReady,
                          surfaceColor: _surface(context),
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          onMapCreated: (ctrl) {
                            _mapCtrl = ctrl;
                            if (_currentPosition != null) {
                              ctrl.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _TripMetricsGrid(
                          etaLabel: _etaLabel,
                          distanceLabel: _distanceLabel,
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 14),
                        _DeliveryProgressCard(
                          stops: stops,
                          textColor: _text(context),
                          subTextColor: _sub(context),
                          surfaceColor: _surface(context),
                        ),
                        const SizedBox(height: 14),
                        _CustomerCard(
                          amount: order?.amount ?? 0,
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

// ── Map card ─────────────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  final LatLng? currentPosition;
  final LatLng? destination;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final bool permissionDenied;
  final bool locationReady;
  final Color surfaceColor;
  final Color textColor;
  final Color subTextColor;
  final void Function(GoogleMapController) onMapCreated;

  const _MapCard({
    required this.currentPosition,
    required this.destination,
    required this.polylines,
    required this.markers,
    required this.permissionDenied,
    required this.locationReady,
    required this.surfaceColor,
    required this.textColor,
    required this.subTextColor,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.42;
    final h = height.clamp(300.0, 420.0);

    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: permissionDenied
              ? _PermissionDeniedPlaceholder(surfaceColor: surfaceColor, textColor: textColor)
              : !locationReady
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const CircularProgressIndicator(color: Color(0xFF0B5FFF)),
                        const SizedBox(height: 12),
                        Text('Getting your location…',
                            style: TextStyle(color: textColor, fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                    )
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: currentPosition ?? const LatLng(20.5937, 78.9629),
                            zoom: 15,
                          ),
                          onMapCreated: onMapCreated,
                          markers: markers,
                          polylines: polylines,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          mapType: MapType.normal,
                        ),
                        // ETA chip
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _MapInfoChip(
                            title: currentPosition != null && destination != null
                                ? '${((LocationService.instance.distanceBetween(
                                    currentPosition!.latitude, currentPosition!.longitude,
                                    destination!.latitude, destination!.longitude,
                                  ) / 1000 / 30) * 60).round()} min'
                                : '—',
                            subtitle: 'ETA',
                            icon: Icons.timer_rounded,
                            color: const Color(0xFF0B5FFF),
                          ),
                        ),
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: _MapInfoChip(
                            title: 'Live',
                            subtitle: 'GPS Active',
                            icon: Icons.gps_fixed_rounded,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _PermissionDeniedPlaceholder extends StatelessWidget {
  final Color surfaceColor, textColor;
  const _PermissionDeniedPlaceholder({required this.surfaceColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceColor,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.location_off_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text('Location permission denied', style: TextStyle(color: textColor,
              fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => LocationService.instance.openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ]),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title, subtitle;
  final Color textColor, subTextColor, surfaceColor;
  final VoidCallback onBack, onRecenter;

  const _Header({
    required this.title, required this.subtitle,
    required this.textColor, required this.subTextColor,
    required this.surfaceColor, required this.onBack, required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          _ClayButton(icon: Icons.arrow_back_rounded, color: const Color(0xFF0B5FFF),
              surfaceColor: surfaceColor, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12,
                    fontWeight: FontWeight.w700)),
                Text(title, style: TextStyle(color: textColor, fontSize: 23,
                    fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          _ClayButton(icon: Icons.my_location_rounded, color: AppColors.success,
              surfaceColor: surfaceColor, onTap: onRecenter),
        ],
      ),
    );
  }
}

// ── Trip metrics ──────────────────────────────────────────────────────────────

class _TripMetricsGrid extends StatelessWidget {
  final String etaLabel, distanceLabel;
  final Color textColor, subTextColor, surfaceColor;

  const _TripMetricsGrid({
    required this.etaLabel, required this.distanceLabel,
    required this.textColor, required this.subTextColor, required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;
    final items = [
      _MetricData('ETA', etaLabel, Icons.timer_rounded, const Color(0xFF0B5FFF)),
      _MetricData('Distance', distanceLabel, Icons.route_rounded, AppColors.success),
      const _MetricData('OBC Reward', '+15', Icons.monetization_on_rounded, Color(0xFFFF8A00)),
      const _MetricData('Score', '96%', Icons.speed_rounded, AppColors.warning),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => SizedBox(
        width: width,
        child: _ClayCard(
          surfaceColor: surfaceColor,
          padding: const EdgeInsets.all(13),
          child: Row(children: [
            _SoftIcon(icon: item.icon, color: item.color),
            const SizedBox(width: 9),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.value,
                      style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w900)),
                  Text(item.label,
                      style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      )).toList(),
    );
  }
}

// ── Delivery progress ─────────────────────────────────────────────────────────

class _DeliveryProgressCard extends StatelessWidget {
  final List<_Stop> stops;
  final Color textColor, subTextColor, surfaceColor;

  const _DeliveryProgressCard({
    required this.stops, required this.textColor,
    required this.subTextColor, required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _CardTitle(title: 'Delivery Progress', trailing: '72% Complete',
            textColor: textColor, subTextColor: subTextColor),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            value: .72,
            minHeight: 9,
            backgroundColor: Color(0xFF0B5FFF),
            valueColor: AlwaysStoppedAnimation(Color(0xFFFF8A00)),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(stops.length, (i) {
          final stop = stops[i];
          return Column(children: [
            _StopRow(stop: stop, textColor: textColor, subTextColor: subTextColor),
            if (i != stops.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(width: 2, height: 20,
                      color: const Color(0xFF0B5FFF).withValues(alpha: .18)),
                ),
              ),
          ]);
        }),
      ]),
    );
  }
}

class _StopRow extends StatelessWidget {
  final _Stop stop;
  final Color textColor, subTextColor;

  const _StopRow({required this.stop, required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    final color = stop.completed
        ? AppColors.success
        : stop.isOrigin ? const Color(0xFF0B5FFF) : AppColors.warning;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(
        stop.completed ? Icons.check_circle_rounded : stop.isOrigin ? Icons.circle : Icons.location_on_rounded,
        color: color, size: 24,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stop.label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900)),
            Text(stop.address, style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ]);
  }
}

// ── Customer card ─────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final double amount;
  final Color textColor, subTextColor, surfaceColor;

  const _CustomerCard({
    required this.amount, required this.textColor,
    required this.subTextColor, required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final amtLabel = amount > 0 ? '₹${amount.toStringAsFixed(0)}' : '—';
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _CardTitle(title: 'Customer', trailing: amtLabel,
            textColor: textColor, subTextColor: subTextColor),
        const SizedBox(height: 14),
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0B5FFF).withValues(alpha: .12),
            child: const Icon(Icons.person_rounded, color: Color(0xFF0B5FFF), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Customer', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900)),
                Text('Contact via app', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          _RoundAction(icon: Icons.call_rounded, color: AppColors.success,
              onTap: () => HapticFeedback.mediumImpact()),
          const SizedBox(width: 8),
          _RoundAction(icon: Icons.chat_bubble_rounded, color: const Color(0xFF0B5FFF),
              onTap: () => HapticFeedback.lightImpact()),
        ]),
      ]),
    );
  }
}

// ── OBC reward card ───────────────────────────────────────────────────────────

class _ObcRewardCard extends StatelessWidget {
  final Color textColor, subTextColor, surfaceColor;
  const _ObcRewardCard({required this.textColor, required this.subTextColor, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return _ClayCard(
      surfaceColor: surfaceColor,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _CardTitle(title: 'One Bharat Coin', trailing: 'Driver Rewards',
            textColor: textColor, subTextColor: subTextColor),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _RewardMini(label: 'Trip',    value: '+15 OBC',  color: const Color(0xFFFF8A00)),
          _RewardMini(label: 'Weekly',  value: '+120 OBC', color: const Color(0xFF0B5FFF)),
          _RewardMini(label: 'Monthly', value: '+480 OBC', color: AppColors.success),
        ]),
      ]),
    );
  }
}

class _RewardMini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _RewardMini({required this.label, required this.value, required this.color});

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
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: color.withValues(alpha: .75), fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

// ── Bottom actions ────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final Color surfaceColor, textColor;
  const _BottomActions({required this.surfaceColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _ActionButton(label: 'Emergency', icon: Icons.sos_rounded,
          color: AppColors.error, filled: false,
          onTap: () => HapticFeedback.heavyImpact())),
      const SizedBox(width: 10),
      Expanded(child: _ActionButton(label: 'Proof', icon: Icons.fact_check_rounded,
          color: AppColors.warning, filled: false,
          onTap: () => HapticFeedback.lightImpact())),
      const SizedBox(width: 10),
      Expanded(
        flex: 2,
        child: _ActionButton(label: 'Navigation', icon: Icons.navigation_rounded,
            color: const Color(0xFF0B5FFF), filled: true,
            onTap: () => HapticFeedback.mediumImpact()),
      ),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label, required this.icon, required this.color,
    required this.filled, required this.onTap,
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
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: filled ? Colors.white : color, size: 20),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(color: filled ? Colors.white : color,
                      fontSize: 13, fontWeight: FontWeight.w900)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color surfaceColor;

  const _ClayCard({required this.child, required this.surfaceColor,
      this.padding = const EdgeInsets.all(16)});

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
            color: dark ? Colors.white.withValues(alpha: .05) : const Color(0xFFDFEAFF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: dark ? .24 : .075),
              blurRadius: 22, offset: const Offset(10, 12)),
          BoxShadow(color: Colors.white.withValues(alpha: dark ? .03 : .92),
              blurRadius: 18, offset: const Offset(-8, -8)),
        ],
      ),
      child: child,
    );
  }
}

class _ClayButton extends StatelessWidget {
  final IconData icon;
  final Color color, surfaceColor;
  final VoidCallback onTap;

  const _ClayButton({
    required this.icon, required this.color,
    required this.surfaceColor, required this.onTap,
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
          height: 44, width: 44,
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
  const _SoftIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42, width: 42,
      decoration: BoxDecoration(
          color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(height: 42, width: 42, child: Icon(icon, color: color, size: 20)),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title, trailing;
  final Color textColor, subTextColor;
  const _CardTitle({required this.title, required this.trailing,
      required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title,
          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w900))),
      Text(trailing,
          style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _MapInfoChip extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _MapInfoChip({required this.title, required this.subtitle,
      required this.icon, required this.color});

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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 7),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Color(0xFF0F172A),
                  fontSize: 14, fontWeight: FontWeight.w900)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B),
                  fontSize: 10, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
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

    canvas.drawPath(
      Path()
        ..moveTo(-20, size.height * .17)
        ..cubicTo(size.width * .28, size.height * .08,
            size.width * .56, size.height * .32, size.width + 20, size.height * .20),
      routePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width + 20, size.height * .64)
        ..cubicTo(size.width * .70, size.height * .52,
            size.width * .42, size.height * .78, -20, size.height * .72),
      routePaint,
    );

    final dotPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: dark ? .10 : .15);
    for (int i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset(((i * 53) % size.width).toDouble(),
            (55 + ((i * 97) % size.height)).toDouble()),
        2.8, dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NavigationBackgroundPainter old) => old.dark != dark;
}

// ── Data models ───────────────────────────────────────────────────────────────

class _MetricData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _Stop {
  final String label, address;
  final bool isOrigin, completed;
  const _Stop({required this.label, required this.address,
      required this.isOrigin, required this.completed});
}
