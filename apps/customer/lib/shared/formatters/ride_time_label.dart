import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

/// Booking and history use the same service clock, even on a device abroad.
String rideTimeLabel(
  BuildContext context,
  DateTime time, {
  RideSchedulePolicy policy = AppConfig.rideSchedulePolicy,
}) {
  final locale = Localizations.localeOf(context).languageCode;
  final date = DateFormat.yMMMd(locale).add_jm().format(policy.wallTime(time));
  return '$date (${policy.offsetLabel})';
}
