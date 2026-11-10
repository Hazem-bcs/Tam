import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scroll the page itself; a drag starting on an interactive map pans the map.
Future<void> revealPageWidget(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
    final visible = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              {
                AxisDirection.down,
                AxisDirection.up,
              }.contains(widget.axisDirection),
        )
        .hitTestable();
    final movable = tester
        .stateList<ScrollableState>(visible)
        .where(
          (state) =>
              state.position.hasContentDimensions &&
              state.position.maxScrollExtent > 0,
        )
        .toList();
    if (movable.isEmpty) break;
    final scrollable = movable.last;
    final position = scrollable.position;
    final next = (position.pixels + 180).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (next == position.pixels) break;
    position.jumpTo(next);
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}
