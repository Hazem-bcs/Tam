import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';
import '../../support/fake_auth_repository.dart';
import '../../support/preview_fonts.dart';

const _capture = bool.fromEnvironment('CAPTURE_AHMAD_AUTH');
void main() {
  setUpAll(() async {
    await loadPreviewFonts(enabled: _capture);
    if (_capture) {
      for (final entry in {
        'TamSansArabic': 'NotoSansArabic-Regular.ttf',
        'TamSansLatin': 'NotoSans-Regular.ttf',
      }.entries) {
        await (FontLoader(
          entry.key,
        )..addFont(rootBundle.load('assets/fonts/${entry.value}'))).load();
      }
    }
  });
  testWidgets(
    'registration preview does not create credentials; login still requests OTP',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fake = FakeAuthRepository(latency: Duration.zero);
      final store = MemoryAuthSessionStore();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: TamApp(authRepository: fake, sessionStore: store),
        ),
      );
      await tester.pumpAndSettle();
      final auth = tester.element(find.byType(PhoneAuthPage)).read<AuthCubit>();
      Future<void> capture(String name) async {
        if (!_capture) return;
        await tester.runAsync(() async {
          await precacheImage(
            const AssetImage('assets/images/ahmad_ui/auth_route.webp'),
            boundary.currentContext!,
          );
          await precacheImage(
            const AssetImage('assets/images/ahmad_ui/auth_otp.webp'),
            boundary.currentContext!,
          );
        });
        await tester.pumpAndSettle();
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final im = await render.toImage(pixelRatio: 2);
          final data = await im.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory(
            '../../docs/ahmad-ui/deliveries/AUI-02-AUTH-20261117',
          )..createSync(recursive: true);
          File(
            '${dir.path}/$name.png',
          ).writeAsBytesSync(data!.buffer.asUint8List());
          im.dispose();
        });
      }

      await capture('login-widget');
      await tester.ensureVisible(find.byKey(const Key('auth-toggle-account')));
      await tester.tap(find.byKey(const Key('auth-toggle-account')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-name')), findsOneWidget);
      await capture('registration-widget');
      await tester.enterText(find.byKey(const Key('auth-name')), 'أحمد');
      await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
      await tester.ensureVisible(find.text('متابعة'));
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(auth.state.status, AuthStatus.signedOut);
      expect(auth.state.challenge, isNull);
      expect(auth.state.user, isNull);
      expect(fake.debugOtpCode, isNull);
      expect(await store.read(), isNull);
      await tester.ensureVisible(find.byKey(const Key('auth-toggle-account')));
      await tester.tap(find.byKey(const Key('auth-toggle-account')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '912345678',
      );
      await tester.ensureVisible(find.text('إرسال رمز التحقق'));
      await tester.tap(find.text('إرسال رمز التحقق'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-code')), findsOneWidget);
      expect(auth.state.status, AuthStatus.awaitingOtp);
      await capture('otp-widget');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
