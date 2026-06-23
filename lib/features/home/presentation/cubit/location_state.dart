import 'package:equatable/equatable.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

final class LocationInitial extends LocationState {
  const LocationInitial();
}

final class LocationLoading extends LocationState {
  const LocationLoading();
}

final class LocationLoaded extends LocationState {
  final String name;
  final double latitude;
  final double longitude;

  const LocationLoaded({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [name, latitude, longitude];
}

final class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
