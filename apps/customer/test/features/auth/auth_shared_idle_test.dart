import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart' as rive;
import 'package:tam_customer/features/auth/presentation/widgets/auth_rive_mascot.dart';

void main() {
  testWidgets(
    'shared idle loops around its anchor and resumes after an event',
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(home: Center(child: AuthRiveMascot(size: 250))),
        );
        final builder = tester.widget<rive.RiveWidgetBuilder>(
          find.byType(rive.RiveWidgetBuilder),
        );
        await builder.fileLoader.file().timeout(const Duration(seconds: 10));
      });
      await tester.pump();
      final controller = tester
          .widget<rive.RiveWidget>(find.byType(rive.RiveWidget))
          .controller;
      controller.active = false;
      final model = controller.stateMachine.boundRuntimeViewModelInstance!;
      final body = controller.artboard.component('Body pose hinge')!;
      final gaze = controller.artboard.component('left Idle Drift')!;
      final wrist = controller.artboard.component('Left Wrist follow-through')!;
      void advance(int frames) {
        for (var frame = 0; frame < frames; frame++) {
          controller.advance(1 / 60);
        }
      }

      // Welcome finishes, then Idle reaches its deliberate side glance.
      advance(300);
      expect(gaze.x, lessThan(-8));
      model.boolean('waiting')!.value = true;
      advance(30);
      model.boolean('waiting')!.value = false;
      advance(25);
      // A reset would look straight ahead at t=0. The persistent base keeps
      // its ongoing glance while the event temporarily overrides the pose.
      expect(gaze.x, lessThan(-8));
      final initial = [body.x, body.y, body.rotation, wrist.rotation, gaze.x];
      var lowestWrist = wrist.rotation;
      var highestWrist = wrist.rotation;
      for (var frame = 0; frame < 960; frame++) {
        advance(1);
        lowestWrist = math.min(lowestWrist, wrist.rotation);
        highestWrist = math.max(highestWrist, wrist.rotation);
        expect(
          body.x - 205 * body.scaleY * math.sin(body.rotation),
          closeTo(250, .01),
        );
        expect(
          body.y + 205 * body.scaleY * math.cos(body.rotation),
          closeTo(455, .01),
        );
      }
      expect(highestWrist - lowestWrist, greaterThan(.06));
      final returned = [body.x, body.y, body.rotation, wrist.rotation, gaze.x];
      for (var index = 0; index < initial.length; index++) {
        expect(returned[index], closeTo(initial[index], .005));
      }
      body.dispose();
      gaze.dispose();
      wrist.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
