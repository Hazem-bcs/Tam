import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart' as rive;
import 'package:tam_customer/features/auth/presentation/widgets/auth_rive_mascot.dart';

void main() {
  Future<rive.RiveWidgetController> load(
    WidgetTester tester,
    AuthRiveMascot mascot, {
    bool visible = true,
  }) async {
    // Start native image decoding in the real async zone so that all native
    // callbacks can finish before this helper returns to FakeAsync.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: TickerMode(
            enabled: visible,
            child: Center(child: mascot),
          ),
        ),
      );
      final builder = tester.widget<rive.RiveWidgetBuilder>(
        find.byType(rive.RiveWidgetBuilder),
      );
      await builder.fileLoader.file().timeout(const Duration(seconds: 10));
    });
    await tester.pump();
    return tester
        .widget<rive.RiveWidget>(find.byType(rive.RiveWidget))
        .controller;
  }

  testWidgets('only the winning expression reaches Rive; OTP stays context', (
    tester,
  ) async {
    final controller = await load(
      tester,
      const AuthRiveMascot(
        size: 250,
        inputFocused: true,
        busy: true,
        hasError: true,
        otpStage: true,
        success: true,
      ),
    );
    final model = controller.stateMachine.boundRuntimeViewModelInstance!;
    expect(model.boolean('success')!.value, isTrue);
    expect(model.boolean('hasError')!.value, isFalse);
    expect(model.boolean('waiting')!.value, isFalse);
    expect(model.boolean('phoneFocused')!.value, isFalse);
    expect(model.boolean('otpStage')!.value, isTrue);

    await load(
      tester,
      const AuthRiveMascot(
        size: 250,
        inputFocused: true,
        busy: true,
        hasError: true,
        otpStage: true,
      ),
    );
    expect(model.boolean('success')!.value, isFalse);
    expect(model.boolean('hasError')!.value, isTrue);
    expect(model.boolean('waiting')!.value, isFalse);
    expect(model.boolean('phoneFocused')!.value, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion settles new poses and gaze without a ticker', (
    tester,
  ) async {
    final controller = await load(
      tester,
      const AuthRiveMascot(size: 250, reduceMotion: true),
    );
    final model = controller.stateMachine.boundRuntimeViewModelInstance!;
    // Requires the V4 export: a missing static-mode input is an asset mismatch.
    expect(model.boolean('reduceMotion')!.value, isTrue);
    final body = controller.artboard.component('Body pose hinge')!;
    final leftWrist = controller.artboard.component(
      'Left Wrist follow-through',
    )!;
    final rightWrist = controller.artboard.component(
      'Right Wrist follow-through',
    )!;
    final idleY = body.y;

    await load(
      tester,
      const AuthRiveMascot(size: 250, hasError: true, reduceMotion: true),
    );
    final sadY = body.y;
    final sadWrists = [leftWrist.rotation, rightWrist.rotation];
    expect(sadY, isNot(closeTo(idleY, 0.001)));
    expect(controller.active, isFalse);
    expect(controller.isTickerActive, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(body.y, sadY);
    expect([leftWrist.rotation, rightWrist.rotation], sadWrists);

    await load(
      tester,
      const AuthRiveMascot(size: 250, success: true, reduceMotion: true),
      visible: false,
    );
    expect(body.y, sadY);
    expect(controller.isTickerActive, isFalse);
    await load(
      tester,
      const AuthRiveMascot(size: 250, success: true, reduceMotion: true),
    );
    expect(body.y, isNot(closeTo(sadY, 0.001)));
    await load(
      tester,
      const AuthRiveMascot(
        size: 250,
        inputFocused: true,
        gazeProgress: 1,
        reduceMotion: true,
      ),
    );
    expect(model.number('gazeX')!.value, 9);
    expect(model.number('gazeY')!.value, 12);
    expect(controller.isTickerActive, isFalse);
    expect(tester.binding.transientCallbackCount, 0);
    body.dispose();
    leftWrist.dispose();
    rightWrist.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hidden routes and background stop playback and safely resume', (
    tester,
  ) async {
    final controller = await load(tester, const AuthRiveMascot(size: 250));
    await load(tester, const AuthRiveMascot(size: 250), visible: false);
    expect(controller.active, isFalse);
    expect(controller.isTickerActive, isFalse);
    await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 1),
      visible: false,
    );
    final model = controller.stateMachine.boundRuntimeViewModelInstance!;
    expect(model.number('gazeX')!.value, 9);
    await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 1),
    );
    expect(controller.active, isTrue);
    expect(controller.isTickerActive, isTrue);
    expect(model.number('gazeX')!.value, 9);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(controller.active, isFalse);
    expect(controller.isTickerActive, isFalse);
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.active, isTrue);
    expect(controller.isTickerActive, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unmounting during native loading has no late callback errors', (
    tester,
  ) async {
    late rive.FileLoader loader;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(home: AuthRiveMascot(size: 250)),
      );
      loader = tester
          .widget<rive.RiveWidgetBuilder>(find.byType(rive.RiveWidgetBuilder))
          .fileLoader;
      final pendingFile = loader.file();
      await tester.pumpWidget(const SizedBox.shrink());
      await pendingFile.timeout(const Duration(seconds: 10));
    });
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion preference toggles keep the rig and pending gaze', (
    tester,
  ) async {
    final controller = await load(
      tester,
      const AuthRiveMascot(
        size: 250,
        inputFocused: true,
        gazeProgress: 0.8,
        reduceMotion: true,
      ),
    );
    final machine = controller.stateMachine;
    final model = machine.boundRuntimeViewModelInstance!;
    final playing = await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 0.8),
    );
    // Resuming the same rig avoids reloading its initial Welcome state.
    expect(playing, same(controller));
    expect(playing.stateMachine, same(machine));
    expect(controller.isTickerActive, isTrue);
    expect(model.number('gazeX')!.value, closeTo(5.4, 0.001));

    await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 0.1),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 0.1),
      visible: false,
    );
    expect(model.number('gazeX')!.value, closeTo(-7.2, 0.001));
    for (final reduced in [true, false]) {
      await load(
        tester,
        AuthRiveMascot(
          size: 250,
          inputFocused: true,
          gazeProgress: 1,
          reduceMotion: reduced,
        ),
        visible: false,
      );
      expect(controller.active, isFalse);
      expect(controller.isTickerActive, isFalse);
      expect(model.number('gazeX')!.value, 9);
      expect(tester.binding.transientCallbackCount, 0);
    }
    final resumed = await load(
      tester,
      const AuthRiveMascot(size: 250, inputFocused: true, gazeProgress: 1),
    );
    expect(resumed.stateMachine, same(machine));
    expect(controller.isTickerActive, isTrue);
    expect(model.number('gazeX')!.value, 9);
    await load(tester, const AuthRiveMascot(size: 250, reduceMotion: true));
    await load(tester, const AuthRiveMascot(size: 250));
    await tester.pump(const Duration(milliseconds: 500));
    final shoulder = controller.artboard.component('Right Shoulder control')!;
    // V4 Idle stays gently down (+.15..35 rad); Welcome's wave is negative
    // around this point. Static -> animated must return directly to Idle.
    expect(shoulder.rotation, inInclusiveRange(0.15, 0.35));
    shoulder.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
