import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/features/account_management/account_management_entry.dart';
import 'package:tam_customer/features/driver_contact/driver_contact_entry.dart';
import 'app_routes.dart';

List<RouteBase> buildAccountRoutes({
  required AccountManagementRepository accounts,
  required DriverContactRepository contacts,
  required PhoneDialer dialer,
  required DateTime Function() now,
  required Future<void> Function() onAccountCompleted,
}) => [
  for (final entry in {
    AppRoutes.changePhone: AccountAction.changePhone,
    AppRoutes.deleteAccount: AccountAction.deleteAccount,
  }.entries)
    GoRoute(
      path: entry.key,
      builder: (context, state) => buildAccountManagementFeature(
        repository: accounts,
        action: entry.value,
        now: now,
        onBack: () => _back(context, AppRoutes.settings),
        onCompleted: onAccountCompleted,
      ),
    ),
  GoRoute(
    path: AppRoutes.driverContact,
    builder: (context, state) => buildDriverContactFeature(
      repository: contacts,
      dialer: dialer,
      tripId: state.pathParameters['tripId']!,
      driverId: state.pathParameters['driverId']!,
      now: now,
      onBack: () => _back(
        context,
        AppRoutes.activeTripLocation(state.pathParameters['tripId']!),
      ),
    ),
  ),
];
void _back(BuildContext context, String fallback) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go(fallback);
  }
}
