import 'network_cache_service.dart';

class CacheService {
  // ==================== Support Contacts Cache ====================

  /// Cache support contacts data
  static Future<void> cacheSupportContactsData(dynamic data) async {
    return NetworkCacheService.cacheSupportContactsData(data);
  }

  /// Get cached support contacts data
  static Future<dynamic> getCachedSupportContactsData() async {
    return NetworkCacheService.getCachedSupportContactsData();
  }

  /// Clear support contacts cache
  static Future<void> clearSupportContactsCache() async {
    return NetworkCacheService.clearSupportContactsCache();
  }
}
