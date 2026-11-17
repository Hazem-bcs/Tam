import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

String tripStatusLabel(AppLocalizations l, TripStatus status) =>
    switch (status) {
      TripStatus.scheduled => l.tripsStatusScheduled,
      TripStatus.requested => l.tripsStatusRequested,
      TripStatus.confirmed => l.tripsStatusConfirmed,
      TripStatus.driverEnRoute => l.tripsStatusDriverEnRoute,
      TripStatus.driverArrived => l.tripsStatusDriverArrived,
      TripStatus.noDriver => l.tripsStatusNoDriver,
      TripStatus.inProgress => l.tripsStatusInProgress,
      TripStatus.completed => l.tripsStatusCompleted,
      TripStatus.cancelled => l.tripsStatusCancelled,
    };

String tripsErrorLabel(AppLocalizations l, String? code) => switch (code) {
  'SERVICE_UNAVAILABLE' => l.tripsServiceUnavailable,
  'VALIDATION_ERROR' => l.tripsValidationError,
  'TRIP_NOT_CANCELLABLE' => l.tripsCannotCancel,
  'TRIP_NOT_FOUND' => l.tripsNotFoundDescription,
  _ => l.tripsUnknownError,
};

String tripMoneyLabel(BuildContext context, Money money) {
  final locale = Localizations.localeOf(context).languageCode;
  final digits = money.amountMinor.toString().padLeft(money.minorUnit + 1, '0');
  final integerLength = digits.length - money.minorUnit;
  final integral = int.parse(digits.substring(0, integerLength));
  final fraction = money.minorUnit == 0
      ? ''
      : '.${digits.substring(integerLength)}';
  final currency = money.currency == 'SYP'
      ? AppLocalizations.of(context).tripsCurrencySyp
      : money.currency;
  return '${NumberFormat.decimalPattern(locale).format(integral)}$fraction $currency';
}

String tripDateLabel(BuildContext context, DateTime time) => DateFormat.yMMMd(
  Localizations.localeOf(context).languageCode,
).add_jm().format(time.toLocal());

String tripVehicleLabel(AppLocalizations l, String classId) =>
    switch (classId) {
      'standard' => l.tripsVehicleStandard,
      'comfort' => l.rideRequestComfort,
      'van' => l.rideRequestVan,
      'motorbike' => l.rideRequestMotorbike,
      _ => classId,
    };

({Color foreground, Color background, IconData icon}) tripStatusColors(
  BuildContext context,
  TripStatus status,
) {
  final scheme = Theme.of(context).colorScheme;
  final custom = Theme.of(context).extension<AppStatusColors>()!;
  return switch (status) {
    TripStatus.completed => (
      foreground: custom.onSuccessContainer,
      background: custom.successContainer,
      icon: Icons.check_circle_outline,
    ),
    TripStatus.cancelled || TripStatus.noDriver => (
      foreground: scheme.onErrorContainer,
      background: scheme.errorContainer,
      icon: Icons.cancel_outlined,
    ),
    TripStatus.driverEnRoute ||
    TripStatus.driverArrived ||
    TripStatus.inProgress => (
      foreground: scheme.onPrimaryContainer,
      background: scheme.primaryContainer,
      icon: Icons.route_outlined,
    ),
    TripStatus.scheduled || TripStatus.confirmed => (
      foreground: scheme.onSecondaryContainer,
      background: scheme.secondaryContainer,
      icon: Icons.check_circle_outline,
    ),
    TripStatus.requested => (
      foreground: custom.onWarningContainer,
      background: custom.warningContainer,
      icon: Icons.schedule,
    ),
  };
}

class TripStatusBadge extends StatelessWidget {
  const TripStatusBadge({super.key, required this.status});
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = tripStatusColors(context, status);
    final text = tripStatusLabel(AppLocalizations.of(context), status);
    return Semantics(
      label: text,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(colors.icon, size: 16, color: colors.foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: colors.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
