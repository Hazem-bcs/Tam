import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Only the booking entry and its matching destination opt into this transition.
Page<void> rideJourneyPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: reduced ? Duration.zero : AppMotion.medium,
    reverseTransitionDuration: reduced ? Duration.zero : AppMotion.short,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final eased = animation.drive(CurveTween(curve: AppMotion.easeOut));
      return FadeTransition(
        opacity: eased,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, .025),
            end: Offset.zero,
          ).animate(eased),
          child: child,
        ),
      );
    },
  );
}
