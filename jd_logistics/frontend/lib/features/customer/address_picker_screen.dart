import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/services/location_service.dart';

class AddressPickerResult {
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double lat;
  final double lng;

  const AddressPickerResult({
    required this.address,
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    required this.lat,
    required this.lng,
  });
}

class AddressPickerScreen extends StatefulWidget {
  final String title;
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const AddressPickerScreen({
    super.key,
    this.title = 'Pick Location',
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  GoogleMapController? _mapCtrl;
  final _searchCtrl = TextEditingController();

  LatLng _center = const LatLng(20.5937, 78.9629); // India default
  String _pickedAddress = 'Tap map or search to pick a location';
  String _pickedCity = '';
  String _pickedState = '';
  String _pickedCountry = '';
  String _pickedPostalCode = '';
  bool _isGeocoding = false;
  bool _isSearching = false;
  bool _hasPicked = false;
  List<Location> _searchResults = [];
  List<Placemark> _searchPlacemarks = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null &&
        (widget.initialLat! != 0 || widget.initialLng! != 0)) {
      _center = LatLng(widget.initialLat!, widget.initialLng!);
      _hasPicked = true;
      _reverseGeocode(_center);
    } else if (widget.initialAddress?.isNotEmpty == true) {
      _searchCtrl.text = widget.initialAddress!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchAddress(widget.initialAddress!));
    } else {
      _tryCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _tryCurrentLocation() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null && mounted) {
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = ll);
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 15));
      _reverseGeocode(ll);
    }
  }

  Future<void> _reverseGeocode(LatLng ll) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);
    try {
      final marks = await placemarkFromCoordinates(ll.latitude, ll.longitude);
      if (!mounted) return;
      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = <String>[];
        if (p.name?.isNotEmpty == true && p.name != p.thoroughfare) parts.add(p.name!);
        if (p.thoroughfare?.isNotEmpty == true) parts.add(p.thoroughfare!);
        if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
        if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
        if (p.postalCode?.isNotEmpty == true) parts.add(p.postalCode!);
        setState(() {
          _pickedAddress = parts.isEmpty
              ? '${ll.latitude.toStringAsFixed(4)}, ${ll.longitude.toStringAsFixed(4)}'
              : parts.join(', ');
          _pickedCity = p.locality ?? '';
          _pickedState = p.administrativeArea ?? '';
          _pickedCountry = p.country ?? '';
          _pickedPostalCode = p.postalCode ?? '';
          _hasPicked = true;
          _isGeocoding = false;
        });
      } else {
        setState(() {
          _pickedAddress = '${ll.latitude.toStringAsFixed(4)}, ${ll.longitude.toStringAsFixed(4)}';
          _hasPicked = true;
          _isGeocoding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickedAddress = '${ll.latitude.toStringAsFixed(4)}, ${ll.longitude.toStringAsFixed(4)}';
          _hasPicked = true;
          _isGeocoding = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() { _searchResults = []; _searchPlacemarks = []; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _searchAddress(query));
  }

  Future<void> _searchAddress(String query) async {
    if (!mounted || query.trim().length < 3) return;
    setState(() => _isSearching = true);
    try {
      final results = await locationFromAddress(query.trim());
      if (!mounted) return;
      // Fetch placemarks for display names
      final pms = <Placemark>[];
      for (final loc in results.take(5)) {
        try {
          final marks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          pms.add(marks.isNotEmpty ? marks.first : const Placemark());
        } catch (_) {
          pms.add(const Placemark());
        }
      }
      if (mounted) {
        setState(() {
          _searchResults = results.take(5).toList();
          _searchPlacemarks = pms;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _searchResults = []; _isSearching = false; });
    }
  }

  void _selectSearchResult(int index) {
    final loc = _searchResults[index];
    final ll = LatLng(loc.latitude, loc.longitude);
    _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 14));
    setState(() {
      _center = ll;
      _searchResults = [];
      _searchPlacemarks = [];
    });
    _reverseGeocode(ll);
    FocusScope.of(context).unfocus();
  }

  void _onCameraIdle() {
    if (_hasPicked) {
      _reverseGeocode(_center);
    }
  }

  String _resultLabel(int i) {
    final p = i < _searchPlacemarks.length ? _searchPlacemarks[i] : null;
    if (p == null) return '${_searchResults[i].latitude.toStringAsFixed(4)}, ${_searchResults[i].longitude.toStringAsFixed(4)}';
    final parts = <String>[
      if (p.name?.isNotEmpty == true) p.name!,
      if (p.locality?.isNotEmpty == true) p.locality!,
      if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
      if (p.country?.isNotEmpty == true) p.country!,
    ];
    return parts.isEmpty ? '${_searchResults[i].latitude.toStringAsFixed(4)}, ${_searchResults[i].longitude.toStringAsFixed(4)}' : parts.join(', ');
  }

  void _confirmLocation() {
    if (!_hasPicked) return;
    context.pop(AddressPickerResult(
      address: _pickedAddress,
      city: _pickedCity,
      state: _pickedState,
      country: _pickedCountry,
      postalCode: _pickedPostalCode,
      lat: _center.latitude,
      lng: _center.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Real map ──────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 14),
            onMapCreated: (ctrl) => _mapCtrl = ctrl,
            onCameraMove: (pos) {
              _center = pos.target;
              _hasPicked = true;
            },
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Centre crosshair ───────────────────────────────────────────────
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 40),
                SizedBox(height: 36), // lift the icon above true center
              ],
            ),
          ),

          // ── Top bar: back + title + search ─────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Back + title row
                  Row(
                    children: [
                      _CircleBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.86)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: _searchAddress,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search address…',
                                    hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_isSearching)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                ),
                              if (_searchCtrl.text.isNotEmpty && !_isSearching)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _searchPlacemarks = [];
                                    });
                                  },
                                  child: const Icon(Icons.close_rounded,
                                      size: 18, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search results dropdown
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(left: 50),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.90)
                            : Colors.white.withValues(alpha: 0.97),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(_searchResults.length, (i) {
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined,
                                color: AppColors.primary, size: 20),
                            title: Text(
                              _resultLabel(i),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            dense: true,
                            onTap: () => _selectSearchResult(i),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── FABs: current location + map type ──────────────────────────────
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleBtn(
                  icon: Icons.my_location_rounded,
                  color: AppColors.primary,
                  onTap: _tryCurrentLocation,
                ),
              ],
            ),
          ),

          // ── Bottom confirmation panel ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.97),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    // Location label
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _isGeocoding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                )
                              : const Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedAddress,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                              if (_pickedCity.isNotEmpty ||
                                  _pickedState.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    [_pickedCity, _pickedState, _pickedCountry]
                                        .where((s) => s.isNotEmpty)
                                        .join(', '),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _hasPicked && !_isGeocoding
                            ? _confirmLocation
                            : null,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          _hasPicked ? 'Confirm Location' : 'Move map to pick',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
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

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      shape: const CircleBorder(),
      color: isDark
          ? Colors.black.withValues(alpha: 0.86)
          : Colors.white.withValues(alpha: 0.95),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
