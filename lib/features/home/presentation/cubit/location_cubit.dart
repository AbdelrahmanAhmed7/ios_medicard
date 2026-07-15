import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _locationRepository;
  final LocationService _locationService;

  // Callback the UI provides to show the dialog
  void Function(Completer<bool> completer)? onShowRationaleDialog;

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

    LocationResult result;
    if (_locationRepository.cached?.hasCoordinates == true) {
      result = _locationRepository.cached!;
    } else {
      // Call resolveLocation with showRationaleDialog
      result = await _locationRepository.resolve(
        _locationService,
        showRationaleDialog: () async {
          if (onShowRationaleDialog == null) {
            return false;
          }
          final completer = Completer<bool>();
          onShowRationaleDialog!(completer);
          return completer.future;
        },
      );
    }

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
