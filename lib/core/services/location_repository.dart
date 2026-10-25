import 'location_service.dart';

/// Simple cache layer around [LocationService].
///
/// Resolves location once and keeps the result in memory. Subsequent calls
/// to [resolve] return the cached value immediately without re-requesting
/// permission or GPS.
class LocationRepository {
  LocationResult? _cached;
  Future<LocationResult>? _ongoingResolution;

  LocationResult? get cached => _cached;

  bool get hasLocation => _cached?.hasCoordinates == true;

  Future<LocationResult> resolve(
    LocationService service, {
    Future<bool> Function()? showRationaleDialog,
  }) {
    if (_cached?.hasCoordinates == true) return Future.value(_cached!);

    final ongoing = _ongoingResolution;
    if (ongoing != null) return ongoing;

    final resolution = service.resolveLocation(
      requestIfNeeded: true,
      showRationaleDialog: showRationaleDialog,
    );
    _ongoingResolution = resolution;
    return resolution
        .then((result) {
          // Keep denied/disabled results too. Passive consumers such as Home must
          // not immediately trigger a second native prompt after the user denies
          // the first one. Explicit user actions clear this value before retrying.
          _cached = result;
          return result;
        })
        .whenComplete(() {
          if (identical(_ongoingResolution, resolution)) {
            _ongoingResolution = null;
          }
        });
  }

  void cache(LocationResult result) {
    _cached = result;
  }

  void clear() => _cached = null;
}
