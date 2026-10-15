import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/selected_address_store.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _locationRepository;
  final LocationService _locationService;

  // Callback the UI provides to show the dialog
  void Function(Completer<bool> completer)? onShowRationaleDialog;

  LocationCubit(this._locationRepository, this._locationService)
    : super(const LocationInitial());

  Future<void> loadLocation() async {
    // Prefer a previously selected saved address over the device GPS.
    final saved = await SelectedAddressStore.read();
    if (isClosed) return;
    if (saved != null) {
      _applySelectedAddress(saved);
      return;
    }
    await _resolveLocationName(clearCache: false);
  }

  Future<void> refreshLocation() async {
    await _resolveLocationName(clearCache: true);
  }

  /// Uses a saved user address as the active location (persisted across
  /// restarts). Coordinates are cached so home/search requests use them.
  Future<void> selectAddress({
    required int? id,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    if (isClosed) return;
    await SelectedAddressStore.save(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
    );
    if (isClosed) return;
    _applySelectedAddress(
      SelectedAddressData(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  /// Drops the selected address and falls back to the device GPS.
  Future<void> clearSelectedAddress() async {
    await SelectedAddressStore.clear();
    _locationRepository.clear();
  }

  void _applySelectedAddress(SelectedAddressData data) {
    _locationRepository.cache(
      LocationResult.granted(data.latitude, data.longitude),
    );
    emit(
      LocationLoaded(
        name: data.name,
        latitude: data.latitude,
        longitude: data.longitude,
      ),
    );
  }

  /// Called when user taps the location display (e.g. "Location unavailable").
  ///
  /// Re-asks through the native OS dialog whenever the system still allows
  /// prompting.
  Future<void> retryLocation() async {
    if (isClosed) return;

    var permission = await Geolocator.checkPermission();
    if (isClosed) return;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (isClosed) return;

      switch (permission) {
        case LocationPermission.denied:
        case LocationPermission.unableToDetermine:
          emit(const LocationError('Location unavailable'));
          return;
        case LocationPermission.deniedForever:
          emit(const LocationError('Location unavailable'));
          return;
        default:
          break;
      }

      await _resolveLocationName(clearCache: true);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!isClosed) emit(const LocationError('Location unavailable'));
      return;
    }

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

    final latitude = result.latitude!;
    final longitude = result.longitude!;

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (isClosed) return;

      final name = _locationNameFromPlacemarks(placemarks);
      if (name == null) {
        emit(
          LocationLoaded(
            name: _fallbackLocationName(latitude, longitude),
            latitude: latitude,
            longitude: longitude,
          ),
        );
        return;
      }

      emit(
        LocationLoaded(name: name, latitude: latitude, longitude: longitude),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          LocationLoaded(
            name: _fallbackLocationName(latitude, longitude),
            latitude: latitude,
            longitude: longitude,
          ),
        );
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

  String _fallbackLocationName(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
