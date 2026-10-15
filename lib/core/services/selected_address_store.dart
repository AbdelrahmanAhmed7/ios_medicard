import 'dart:convert';

import '../helpers/shared_pref_helper.dart';

/// A saved user address chosen as the app's active location.
class SelectedAddressData {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;

  const SelectedAddressData({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// Persists the address the user chose to use as their active location so it
/// survives app restarts.
class SelectedAddressStore {
  SelectedAddressStore._();

  static const String _key = 'selected_user_address';

  static Future<void> save({
    required int? id,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    await SharedPrefHelper.setData(
      _key,
      jsonEncode({'id': id, 'name': name, 'lat': latitude, 'lng': longitude}),
    );
  }

  static Future<SelectedAddressData?> read() async {
    final raw = await SharedPrefHelper.getString(_key);
    if (raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final name = map['name'] as String?;
      final lat = (map['lat'] as num?)?.toDouble();
      final lng = (map['lng'] as num?)?.toDouble();
      if (name == null || name.isEmpty || lat == null || lng == null) {
        return null;
      }
      return SelectedAddressData(
        id: (map['id'] as num?)?.toInt(),
        name: name,
        latitude: lat,
        longitude: lng,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await SharedPrefHelper.removeData(_key);
  }
}
