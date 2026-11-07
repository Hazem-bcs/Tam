import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_otp_input.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_phone_field.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  setUp(() {
    Map<Object?, Object?> clipboard = {'text': ''};
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = Map<Object?, Object?>.from(call.arguments as Map);
          }
          if (call.method == 'Clipboard.getData') return clipboard;
          if (call.method == 'Clipboard.hasStrings') {
            return {'value': (clipboard['text'] as String? ?? '').isNotEmpty};
          }
          return null;
        });
  });
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('the presentation prefix preserves existing accepted phone formats', () {
    for (final input in [
      '912345678',
      '0912345678',
      '+963912345678',
      '963912345678',
      '00963912345678',
      '٠٩١٢٣٤٥٦٧٨',
      '۹۱۲۳۴۵۶۷۸',
      '٩٦٣٩١٢٣٤٥٦٧٨',
      '۹۶۳۹۱۲۳۴۵۶۷۸',
    ]) {
      expect(
        normalizeSyrianPhone(phoneEntryForRequest(input)),
        '+963912345678',
      );
      expect(nationalPhoneEntry(input), '912345678');
    }
    expect(normalizeSyrianPhone(phoneEntryForRequest('+936123')), isNull);
  });

  testWidgets('pasted country code without plus requests the same E164 phone', (
    tester,
  ) async {
    final fake = FakeAuthRepository(latency: Duration.zero);
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EditableText));
    await Clipboard.setData(const ClipboardData(text: '963 912 345 678'));
    await tester
        .state<EditableTextState>(find.byType(EditableText))
        .pasteText(SelectionChangedCause.keyboard);
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '912345678',
    );
    await tester.ensureVisible(find.text('إرسال رمز التحقق'));
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthOtpInput), findsOneWidget);
    expect(find.text('+963912345678'), findsOneWidget);
    expect(fake.debugOtpCode, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'phone input announces its label and country in one editable node',
    (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _host(
          AuthPhoneField(
            controller: controller,
            label: 'Phone number',
            hint: '9XX XXX XXX',
            invalidMessage: 'Invalid phone',
            semanticLabel: 'Phone number, country code +963',
            onChanged: (_) {},
            onSubmitted: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final node = tester.getSemantics(find.byType(EditableText));
      expect(node.flagsCollection.isTextField, isTrue);
      expect(node.label, contains('Phone number, country code +963'));
      expect('+963'.allMatches(node.label), hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets('loading retains the slots and prevents another confirmation', (
    tester,
  ) async {
    final fake = FakeAuthRepository(latency: const Duration(milliseconds: 350));
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    await _request(tester, 'إرسال رمز التحقق');
    await tester.enterText(
      find.byKey(const Key('auth-code')),
      fake.debugOtpCode!,
    );
    await tester.ensureVisible(find.byKey(const Key('auth-confirm')));
    await tester.tap(find.byKey(const Key('auth-confirm')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byKey(const ValueKey('otp-slot-5')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('تم تسجيل الدخول'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('exhausted attempts retain a readable blocked state', (
    tester,
  ) async {
    final fake = FakeAuthRepository(latency: Duration.zero, maxAttempts: 1);
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    await _request(tester, 'إرسال رمز التحقق');
    await tester.enterText(find.byKey(const Key('auth-code')), '000000');
    await tester.ensureVisible(find.byKey(const Key('auth-confirm')));
    await tester.tap(find.byKey(const Key('auth-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('تجاوزت محاولات التحقق'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final direction in TextDirection.values) {
    testWidgets('six slots expose one logical input in $direction', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_host(_input(controller), direction: direction));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('otp-slot-$i')), findsOneWidget);
      }
      await tester.enterText(find.byType(TextField), '٠١٢٣٤٥');
      await tester.pumpAndSettle();
      expect(controller.text, '012345');
      final node = tester.getSemantics(find.byType(EditableText));
      expect(node.flagsCollection.isTextField, isTrue);
      expect(node.value, '012345');
      expect(node.label, contains('Verification code'));
      final first = tester
          .getCenter(find.byKey(const ValueKey('otp-slot-0')))
          .dx;
      final last = tester
          .getCenter(find.byKey(const ValueKey('otp-slot-5')))
          .dx;
      expect(first, lessThan(last));
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }

  testWidgets(
    'native clipboard paste, leading zero and external-keyboard deletion',
    (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_host(_input(controller)));
      await tester.pumpAndSettle();
      await Clipboard.setData(const ClipboardData(text: '۰۱۲۳۴۵'));
      final editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      await editable.pasteText(SelectionChangedCause.keyboard);
      await tester.pumpAndSettle();
      expect(controller.text, '012345');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(controller.text, '01234');
      await tester.enterText(find.byType(TextField), '012345678');
      expect(controller.text, '012345');
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets(
    'native SMS autofill preserves six digits including a leading zero',
    (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_host(_input(controller)));
      await tester.pumpAndSettle();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '٠١٢٣٤٥',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, '012345');
      expect(
        tester.widget<TextField>(find.byType(TextField)).autofillHints,
        contains(AutofillHints.oneTimeCode),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets('invalid, blocked and reduced-motion states remain accessible', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123456');
    await tester.pumpWidget(
      _host(
        _input(controller, error: 'Invalid verification code'),
        reducedMotion: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Invalid verification code'), findsOneWidget);
    for (final box in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    )) {
      expect(box.duration, Duration.zero);
    }
    await tester.pumpWidget(_host(_input(controller, blocked: true)));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('resend countdown consumes the returned server deadline', (
    tester,
  ) async {
    final fake = FakeAuthRepository(
      latency: Duration.zero,
      resendDelay: const Duration(seconds: 7),
    );
    await tester.pumpWidget(
      TamApp(
        authRepository: fake,
        sessionStore: MemoryAuthSessionStore(),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    await _request(tester, 'Send verification code');
    expect(find.text('Resend code in 00:07'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byKey(const Key('auth-resend'))).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('expired OTP disables the code and confirmation action', (
    tester,
  ) async {
    final fake = FakeAuthRepository(
      latency: Duration.zero,
      otpLifetime: Duration.zero,
    );
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    await _request(tester, 'إرسال رمز التحقق');
    expect(find.text('انتهت صلاحية الرمز'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final size in [
    const Size(320, 700),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
    const Size(600, 960),
    const Size(840, 1100),
    const Size(1024, 1100),
    const Size(844, 390),
  ]) {
    for (final arabic in [true, false]) {
      testWidgets('phone and OTP fit $size / ${arabic ? 'ar' : 'en'}', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fake = FakeAuthRepository(latency: Duration.zero);
        await tester.pumpWidget(
          TamApp(
            authRepository: fake,
            sessionStore: MemoryAuthSessionStore(),
            locale: Locale(arabic ? 'ar' : 'en'),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _request(
          tester,
          arabic ? 'إرسال رمز التحقق' : 'Send verification code',
        );
        expect(find.byType(AuthOtpInput), findsOneWidget);
        final inputWidth = tester.getSize(find.byType(AuthOtpInput)).width;
        expect(inputWidth, lessThanOrEqualTo(432));
        for (var i = 0; i < 6; i++) {
          expect(find.byKey(ValueKey('otp-slot-$i')), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final arabic in [true, false]) {
    testWidgets(
      '320px with large text and open keyboard / ${arabic ? 'ar' : 'en'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        tester.platformDispatcher.textScaleFactorTestValue = 2.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final fake = FakeAuthRepository(latency: Duration.zero);
        await tester.pumpWidget(
          TamApp(
            authRepository: fake,
            sessionStore: MemoryAuthSessionStore(),
            locale: Locale(arabic ? 'ar' : 'en'),
          ),
        );
        await tester.pumpAndSettle();
        await _request(
          tester,
          arabic ? 'إرسال رمز التحقق' : 'Send verification code',
        );
        await tester.enterText(find.byKey(const Key('auth-code')), '012345');
        await tester.pumpAndSettle();
        final confirm = find.byKey(const Key('auth-confirm'));
        await tester.ensureVisible(confirm);
        await tester.pumpAndSettle();
        expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(460));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

Future<void> _request(WidgetTester tester, String sendLabel) async {
  await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
  await tester.ensureVisible(find.text(sendLabel));
  await tester.tap(find.text(sendLabel));
  await tester.pumpAndSettle();
}

Widget _input(
  TextEditingController controller, {
  String? error,
  bool blocked = false,
}) => AuthOtpInput(
  controller: controller,
  label: 'Verification code',
  errorText: error,
  blocked: blocked,
  onChanged: (_) {},
  onSubmitted: () {},
  validator: (value) => value?.length == 6 ? null : 'Enter all six digits',
);

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool reducedMotion = false,
}) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('ar'), Locale('en')],
  locale: Locale(direction == TextDirection.rtl ? 'ar' : 'en'),
  home: Scaffold(
    body: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(child: child),
        ),
      ),
    ),
  ),
);
