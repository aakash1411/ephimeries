import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

/// A single geocoded match for a city query.
class CityMatch {
  const CityMatch({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  /// Human-readable label: "City, Region, Country".
  final String label;
  final double latitude;
  final double longitude;
}

/// Thin facade over `package:geocoding` + `package:geolocator`. Keeps the UI
/// layer unaware of platform APIs and lets tests fake it out.
class LocationService {
  const LocationService();

  /// Geocode a free-text query into up to ~5 candidate cities.
  ///
  /// Returns empty list if nothing matches (or on platform-unsupported hosts
  /// during tests).
  Future<List<CityMatch>> searchCity(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final results = await geo.locationFromAddress(q);
      final out = <CityMatch>[];
      for (final r in results.take(5)) {
        final label = await _reverseLabel(r.latitude, r.longitude) ?? q;
        out.add(CityMatch(
          label: label,
          latitude: r.latitude,
          longitude: r.longitude,
        ));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<String?> _reverseLabel(double lat, double lon) async {
    try {
      final marks = await geo.placemarkFromCoordinates(lat, lon);
      if (marks.isEmpty) return null;
      final m = marks.first;
      final parts = <String>[
        if ((m.locality ?? '').isNotEmpty) m.locality!,
        if ((m.administrativeArea ?? '').isNotEmpty) m.administrativeArea!,
        if ((m.country ?? '').isNotEmpty) m.country!,
      ];
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  /// Request permission + read the device's current position.
  /// Returns null if the user denies permission or location services are off.
  Future<CityMatch?> currentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition();
      final label = await _reverseLabel(pos.latitude, pos.longitude) ??
          'Current location';
      return CityMatch(
        label: label,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
