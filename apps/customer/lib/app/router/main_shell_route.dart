import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/shell/main_shell.dart';
import 'app_routes.dart';

/// Branches load lazily and retain their Navigator and feature state.
/// Full-screen journeys remain siblings on the root Navigator.
StatefulShellRoute buildMainShellRoute({
  required WidgetBuilder home,
  required WidgetBuilder activity,
  required WidgetBuilder account,
}) => StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => MainShell(navigationShell: shell),
  branches: [
    for (final destination in [
      (AppRoutes.home, home),
      (AppRoutes.trips, activity),
      (AppRoutes.settings, account),
    ])
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: destination.$1,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: destination.$2(context),
            ),
          ),
        ],
      ),
  ],
);
