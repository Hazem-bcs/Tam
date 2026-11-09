import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

void main() {
  const policy = RideSchedulePolicy();
  final now = DateTime.utc(2026, 11, 9, 22, 45, 12);

  test('immediate and inclusive minimum/maximum boundaries', () {
    expect(policy.allows(null, now), isTrue);
    expect(policy.allows(now.add(const Duration(minutes: 30)), now), isTrue);
    expect(policy.allows(now.add(const Duration(days: 7)), now), isTrue);
    for (final delta in [
      const Duration(minutes: 29, seconds: 59),
      const Duration(days: 7, microseconds: 1),
      const Duration(seconds: -1),
    ]) {
      expect(policy.allows(now.add(delta), now), isFalse);
    }
  });

  test(
    'service calendar crosses midnight independently of device timezone',
    () {
      final wall = policy.wallTime(now);
      expect(wall, DateTime.utc(2026, 11, 10, 1, 45, 12));
      expect(
        policy.fromWallTime(DateTime.utc(2026, 11, 10, 1, 45)),
        DateTime.utc(2026, 11, 9, 22, 45),
      );
      expect(policy.offsetLabel, 'UTC+03:00');
      const different = RideSchedulePolicy(
        serviceUtcOffset: Duration(hours: -5),
      );
      expect(
        different.fromWallTime(different.wallTime(now)),
        DateTime.utc(2026, 11, 9, 22, 45),
      );
      expect(different.offsetLabel, 'UTC-05:00');
    },
  );

  test('initial selection rounds up to an available minute', () {
    expect(policy.initialTime(now), DateTime.utc(2026, 11, 9, 23, 17));
    expect(policy.allows(policy.initialTime(now), now), isTrue);
    expect(
      policy.initialTime(DateTime.utc(2026, 11, 9, 12)),
      DateTime.utc(2026, 11, 9, 12, 31),
    );
  });
}
