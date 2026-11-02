/// A read-cache policy. Stale data is allowed only for safe read models.
final class CachePolicy {
  const CachePolicy({required this.freshFor, required this.serveStaleFor});

  final Duration freshFor;
  final Duration serveStaleFor;

  bool isFresh(DateTime fetchedAt, DateTime now) =>
      now.difference(fetchedAt) < freshFor;

  bool canShow(DateTime fetchedAt, DateTime now) =>
      now.difference(fetchedAt) < freshFor + serveStaleFor;
}
