import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/support/support_entry.dart';

/// Composition of support and published-content routes; access stays in policy.
List<RouteBase> buildSupportRoutes(
  SupportRepository repository, {
  required SupportPolicy policy,
  required DateTime Function() now,
}) => [
  GoRoute(
    path: AppRoutes.support,
    builder: (context, state) => buildSupportFeature(
      repository: repository,
      policy: policy,
      now: now,
      onBack: () => _back(context, AppRoutes.settings),
      onCreate: () =>
          unawaited(GoRouter.of(context).push<void>(AppRoutes.supportNew)),
      onTicket: (id) => unawaited(
        GoRouter.of(context).push<void>(AppRoutes.supportTicketLocation(id)),
      ),
      // Trips belongs to the existing StatefulShellRoute branch; pushing it
      // would insert a second shell page with the same Navigator page key.
      onChooseTrip: () => GoRouter.of(context).go(AppRoutes.trips),
    ),
  ),
  GoRoute(
    path: AppRoutes.supportNew,
    builder: (context, state) => buildSupportEditorFeature(
      repository: repository,
      policy: policy,
      now: now,
      tripId: state.uri.queryParameters['trip_id'],
      onBack: () => _back(context, AppRoutes.support),
      onCreated: (id) => unawaited(
        GoRouter.of(
          context,
        ).pushReplacement<void>(AppRoutes.supportTicketLocation(id)),
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.supportTicket,
    builder: (context, state) => buildSupportTicketFeature(
      repository: repository,
      id: state.pathParameters['ticketId']!,
      onBack: () => _back(context, AppRoutes.support),
    ),
  ),
  for (final entry in {
    AppRoutes.terms: LegalDocumentKind.terms,
    AppRoutes.privacy: LegalDocumentKind.privacy,
  }.entries)
    GoRoute(
      path: entry.key,
      builder: (context, state) => buildLegalFeature(
        repository: repository,
        kind: entry.value,
        languageCode: Localizations.localeOf(context).languageCode,
        onBack: () => _back(context, AppRoutes.settings),
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
