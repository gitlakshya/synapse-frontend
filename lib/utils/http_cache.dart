/// Simple in-memory HTTP cache with TTL
class HttpCache {
  static final HttpCache _instance = HttpCache._internal();
  factory HttpCache() => _instance;
  HttpCache._internal();

  final Map<String, _CacheEntry> _cache = {};

  /// Get cached response if not expired
  String? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data;
  }

  /// Set cache with TTL
  void set(String key, String data, Duration ttl) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Clear all cache
  void clear() => _cache.clear();

  /// Remove specific key
  void remove(String key) => _cache.remove(key);
}

class _CacheEntry {
  final String data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});
}
