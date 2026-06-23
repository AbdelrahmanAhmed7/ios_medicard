import 'location_service.dart';

/// Simple cache layer around [LocationService].
///
/// Resolves location once and keeps the result in memory. Subsequent calls
/// to [resolve] return the cached value immediately without re-requesting
/// permission or GPS.
class LocationRepository {
  LocationResult? _cached;

  LocationResult? get cached => _cached;

  bool get hasLocation => _cached?.hasCoordinates == true;

  Future<LocationResult> resolve(LocationService service) async {
    if (_cached?.hasCoordinates == true) return _cached!;
    final result = await service.resolveLocation(requestIfNeeded: true);
    _cached = result;
    return result;
  }

  void clear() => _cached = null;
}
