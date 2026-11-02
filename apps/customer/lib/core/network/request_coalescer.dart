/// Shares one in-flight operation for a local request key.
/// NOT a replacement for server-side idempotency on booking mutations.
final class RequestCoalescer {
  final Map<String, Future<Object?>> _pending = {};

  Future<T> run<T>(String key, Future<T> Function() operation) {
    final existing = _pending[key];
    if (existing != null) {
      return existing.then((value) => value as T);
    }
    final future = Future<T>.sync(operation);
    _pending[key] = future;
    future.then<void>(
      (_) {
        _pending.remove(key);
      },
      onError: (Object error, StackTrace trace) {
        _pending.remove(key);
      },
    );
    return future;
  }
}
