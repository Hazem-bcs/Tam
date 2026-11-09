/// Service wall time uses an explicit offset, independent of the device zone.
/// UTC-shaped wall values are calendar components, never transport instants.
final class RideSchedulePolicy {
  const RideSchedulePolicy({
    this.minimumLeadTime = const Duration(minutes: 30),
    this.maximumAdvance = const Duration(days: 7),
    this.serviceUtcOffset = const Duration(hours: 3),
  });

  final Duration minimumLeadTime;
  final Duration maximumAdvance;
  final Duration serviceUtcOffset;

  bool allows(DateTime? scheduledAt, DateTime now) {
    if (scheduledAt == null) return true;
    final advance = scheduledAt.toUtc().difference(now.toUtc());
    return advance >= minimumLeadTime && advance <= maximumAdvance;
  }

  DateTime wallTime(DateTime instant) => instant.toUtc().add(serviceUtcOffset);
  DateTime fromWallTime(DateTime wall) => DateTime.utc(
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
  ).subtract(serviceUtcOffset);

  /// Leave a minute to review, then round up to a selectable whole minute.
  DateTime initialTime(DateTime now) {
    final earliest = now.toUtc().add(
      minimumLeadTime + const Duration(minutes: 1),
    );
    final minute = DateTime.utc(
      earliest.year,
      earliest.month,
      earliest.day,
      earliest.hour,
      earliest.minute,
    );
    return minute.isBefore(earliest)
        ? minute.add(const Duration(minutes: 1))
        : minute;
  }

  String get offsetLabel {
    final minutes = serviceUtcOffset.inMinutes;
    final hours = (minutes.abs() ~/ 60).toString().padLeft(2, '0');
    final rest = (minutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC${minutes < 0 ? '-' : '+'}$hours:$rest';
  }
}
