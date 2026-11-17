import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/presentation/widgets/completion_rating_stars.dart';

import '../trips/support/trips_test_support.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('stars enter on scroll, reduced motion=$reduced', (
      tester,
    ) async {
      tripsViewport(tester, const Size(390, 700));
      await tester.pumpWidget(
        tripsTestApp(
          MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 700),
              disableAnimations: reduced,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 1000),
                    CompletionRatingStars(value: 0, onChanged: (_) {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      double opacity(int star) => tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byKey(ValueKey('completion-star-item-$star')),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      expect(opacity(1), reduced ? 1 : 0);
      await tester.ensureVisible(
        find.byKey(const Key('completion-star-item-1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 180));
      if (!reduced) {
        expect(opacity(1), greaterThan(opacity(5)));
        expect(opacity(1), greaterThan(0));
      }
      await tester.pumpAndSettle();
      expect(opacity(5), 1);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
