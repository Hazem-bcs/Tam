import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'chat_test_support.dart';
import 'chat_widget_support.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets(
      '$locale tiny landscape keyboard keeps send reachable and draft intact',
      (tester) async {
        tester.view.physicalSize = const Size(740, 320);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final repo = ControlledChatRepository();
        addTearDown(repo.events.close);
        await pumpChat(tester, repository: repo, locale: locale, scale: 2);
        final input = find.byKey(const Key('chat-input'));
        await tester.enterText(input, 'رسالة جديدة');
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('chat-send')));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(input).controller!.text, 'رسالة جديدة');
        await tester.tap(find.byKey(const Key('chat-send')));
        await tester.pumpAndSettle();
        expect(repo.sends, hasLength(1));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
