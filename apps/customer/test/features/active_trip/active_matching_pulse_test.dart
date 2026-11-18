import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
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
    expect(tester.widget<LottieBuilder>(finder).animate, isTrue);
    final before = tester.getCenter(finder);
    await tester.pump(const Duration(milliseconds: 550));
    expect(tester.getCenter(finder).dx, greaterThan(before.dx + 10));
    await show(reduced: true);
    expect(tester.widget<LottieBuilder>(finder).animate, isFalse);
    final resting = tester.getCenter(finder);
    await tester.pump(const Duration(milliseconds: 550));
    expect(tester.getCenter(finder), resting);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
