final class CachedPayload {
  const CachedPayload({required this.value, required this.fetchedAt});

  final String value;
  final DateTime fetchedAt;
}

/// Backend-agnostic interface: repositories decide keys and invalidation.
abstract interface class LocalCacheStore {
  Future<CachedPayload?> read(String key);
  Future<void> write(String key, String payload, DateTime fetchedAt);
  Future<void> remove(String key);
  Future<void> clear();
}
