import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/cache/cache_policy.dart';

void main() {
  test('fresh, stale and expired boundaries are separate', () {
    const policy = CachePolicy(
      freshFor: Duration(minutes: 5),
      serveStaleFor: Duration(minutes: 15),
    );
    final now = DateTime.utc(2026, 11, 3, 12);
    final saved = now.subtract(const Duration(minutes: 6));

    expect(policy.isFresh(saved, now), isFalse);
    expect(policy.canShow(saved, now), isTrue);
    expect(
      policy.canShow(now.subtract(const Duration(minutes: 21)), now),
      isFalse,
    );
  });
}
