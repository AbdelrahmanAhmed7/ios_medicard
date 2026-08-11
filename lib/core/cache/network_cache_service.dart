import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Network cache service - handles caching for network feature data
class NetworkCacheService {
  // Support Contacts Cache
  static const String _supportContactsDataKey = 'support_contacts_data';
  static const String _supportContactsLastUpdateKey = 'support_contacts_last_update';
  static const int _supportContactsCacheExpiryHours = 48; // 48 hours

  // Support Contacts Cache Methods
  static Future<void> cacheSupportContactsData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_supportContactsDataKey, jsonString);
    await prefs.setInt(
      _supportContactsLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getCachedSupportContactsData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_supportContactsDataKey);
    final lastUpdate = prefs.getInt(_supportContactsLastUpdateKey);

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _supportContactsCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearSupportContactsCache();
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      await clearSupportContactsCache();
      return null;
    }
  }

  static Future<void> clearSupportContactsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_supportContactsDataKey);
    await prefs.remove(_supportContactsLastUpdateKey);
  }
}

