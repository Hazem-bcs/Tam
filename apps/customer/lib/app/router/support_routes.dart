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
  // Legacy URLs render the editor directly, never the removed hub.
  GoRoute(
    path: AppRoutes.support,
    builder: (context, state) => _editor(
      context,
      state,
      repository: repository,
      policy: policy,
      now: now,
    ),
  ),
  GoRoute(
    path: AppRoutes.supportNew,
    builder: (context, state) => _editor(
      context,
      state,
      repository: repository,
      policy: policy,
      now: now,
    ),
  ),
  GoRoute(
    path: AppRoutes.supportTicket,
    builder: (context, state) => buildSupportTicketFeature(
      repository: repository,
      id: state.pathParameters['ticketId']!,
      onBack: () => _back(context, AppRoutes.settings),
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

Widget _editor(
  BuildContext context,
  GoRouterState state, {
  required SupportRepository repository,
  required SupportPolicy policy,
  required DateTime Function() now,
}) => buildSupportEditorFeature(
  repository: repository,
  policy: policy,
  now: now,
  tripId: state.uri.queryParameters['trip_id'],
  onBack: () => _back(context, AppRoutes.settings),
  onCreated: (id) => unawaited(
    GoRouter.of(
      context,
    ).pushReplacement<void>(AppRoutes.supportTicketLocation(id)),
  ),
);

void _back(BuildContext context, String fallback) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go(fallback);
  }
}
