import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Returns true if permission is granted and GPS is on.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Returns current high-accuracy position, or null on failure.
  Future<Position?> getCurrentPosition() async {
    try {
      final ok = await requestPermission();
      if (!ok) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Stream of position updates; [distanceFilter] in metres before a new event.
  Stream<Position> getPositionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Reverse geocode lat/lng to a human-readable address string.
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      final p = marks.first;
      final parts = <String>[];
      if (p.name?.isNotEmpty == true && p.name != p.thoroughfare) parts.add(p.name!);
      if (p.thoroughfare?.isNotEmpty == true) parts.add(p.thoroughfare!);
      if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
      if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
      if (p.postalCode?.isNotEmpty == true) parts.add(p.postalCode!);
      if (parts.isEmpty) return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      return parts.join(', ');
    } catch (_) {
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  /// Forward geocode address text to a list of matching [Location]s.
  Future<List<Location>> geocodeAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (_) {
      return [];
    }
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Haversine distance in metres between two lat/lng pairs.
  double distanceBetween(double fromLat, double fromLng, double toLat, double toLng) =>
      Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
}
