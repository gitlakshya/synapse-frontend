class ApiCache {
  static final ApiCache _instance = ApiCache._internal();
  factory ApiCache() => _instance;
  ApiCache._internal();

  final Map<String, CacheEntry> _cache = {};
  static const Duration _defaultTTL = Duration(minutes: 10);

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      expiry: DateTime.now().add(ttl ?? _defaultTTL),
    );
  }

  void clear() => _cache.clear();

  void remove(String key) => _cache.remove(key);
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry({required this.data, required this.expiry});
}
