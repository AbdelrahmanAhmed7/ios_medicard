import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _locationRepository;
  final LocationService _locationService;

  LocationCubit(this._locationRepository, this._locationService)
    : super(const LocationInitial());

  Future<void> loadLocation() async {
    await _resolveLocationName(clearCache: false);
  }

  Future<void> refreshLocation() async {
    await _resolveLocationName(clearCache: true);
  }

  Future<void> _resolveLocationName({required bool clearCache}) async {
    if (isClosed) return;

    emit(const LocationLoading());

    if (clearCache) {
      _locationRepository.clear();
    }

    final result = _locationRepository.cached?.hasCoordinates == true
        ? _locationRepository.cached!
        : await _locationRepository.resolve(_locationService);

    if (isClosed) return;

    if (!result.hasCoordinates) {
      emit(const LocationError('Location unavailable'));
      return;
    }

    try {
      final latitude = result.latitude!;
      final longitude = result.longitude!;
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (isClosed) return;

      final name = _locationNameFromPlacemarks(placemarks);
      if (name == null) {
        emit(const LocationError('Location unavailable'));
        return;
      }

      emit(LocationLoaded(name: name, latitude: latitude, longitude: longitude));
    } catch (_) {
      if (!isClosed) {
        emit(const LocationError('Location unavailable'));
      }
    }
  }

  String? _locationNameFromPlacemarks(List<Placemark> placemarks) {
    if (placemarks.isEmpty) return null;

    final placemark = placemarks.first;
    final parts = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.country,
    ];

    final uniqueParts = <String>[];
    for (final part in parts) {
      final normalized = part?.trim();
      if (normalized == null || normalized.isEmpty) continue;
      if (!uniqueParts.contains(normalized)) {
        uniqueParts.add(normalized);
      }
    }

    return uniqueParts.isNotEmpty ? uniqueParts.join(', ') : null;
  }
}
