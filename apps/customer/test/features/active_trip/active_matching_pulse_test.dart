import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_matching_pulse.dart';

void main() {
  testWidgets('search animation moves and respects reduced motion', (
    tester,
  ) async {
    Future<void> show({required bool reduced}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: const Scaffold(body: ActiveMatchingPulse()),
          ),
        ),
      );
      await tester.pump();
    }

    final finder = find.byKey(const Key('driver-search-animation'));
    await show(reduced: false);
    final icon = find.byIcon(Icons.search_rounded);
    expect(icon, findsOneWidget);
    final fixedBounds = tester.getRect(finder);
    final before = tester.getCenter(icon);
    await tester.pump(const Duration(milliseconds: 550));
    expect(tester.getCenter(icon).dx, greaterThan(before.dx + 2));
    expect(tester.getRect(finder), fixedBounds);
    await show(reduced: true);
    final resting = tester.getCenter(icon);
    await tester.pump(const Duration(milliseconds: 550));
    expect(tester.getCenter(icon), resting);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
