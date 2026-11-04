import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

void main() {
  test('semantic text/background pairs meet normal-text contrast', () {
    final colors = AppTheme.light.colorScheme;
    final status = AppTheme.light.extension<AppStatusColors>()!;
    final pairs = <String, (Color, Color)>{
      'primary': (colors.onPrimary, colors.primary),
      'primary container': (colors.onPrimaryContainer, colors.primaryContainer),
      'secondary': (colors.onSecondary, colors.secondary),
      'secondary container': (
        colors.onSecondaryContainer,
        colors.secondaryContainer,
      ),
      'tertiary': (colors.onTertiary, colors.tertiary),
      'tertiary container': (
        colors.onTertiaryContainer,
        colors.tertiaryContainer,
      ),
      'body': (colors.onSurface, colors.surface),
      'supporting copy': (colors.onSurfaceVariant, colors.surface),
      'supporting copy on card': (
        colors.onSurfaceVariant,
        colors.surfaceContainerLowest,
      ),
      'error': (colors.onError, colors.error),
      'error container': (colors.onErrorContainer, colors.errorContainer),
      'error copy on field': (colors.error, colors.surfaceContainerLowest),
      'snackbar': (colors.onInverseSurface, colors.inverseSurface),
      'snackbar action': (colors.inversePrimary, colors.inverseSurface),
      'success': (status.onSuccess, status.success),
      'success container': (status.onSuccessContainer, status.successContainer),
      'warning': (status.onWarning, status.warning),
      'warning container': (status.onWarningContainer, status.warningContainer),
    };
    for (final entry in pairs.entries) {
      expect(
        _contrast(entry.value.$1, entry.value.$2),
        greaterThanOrEqualTo(4.5),
        reason: entry.key,
      );
    }
    expect(
      _contrast(colors.outline, colors.surfaceContainerLowest),
      greaterThanOrEqualTo(3),
      reason: 'An enabled field boundary must remain visible.',
    );
  });

  test('native button themes provide pressed and keyboard focus feedback', () {
    final theme = AppTheme.light;
    for (final style in [
      theme.filledButtonTheme.style!,
      theme.outlinedButtonTheme.style!,
    ]) {
      for (final state in [WidgetState.pressed, WidgetState.focused]) {
        expect(style.overlayColor!.resolve({state})!.a, greaterThan(0));
      }
    }
  });

  for (final secondary in [false, true]) {
    testWidgets(
      '${secondary ? 'secondary' : 'primary'} button blocks disabled/loading taps and exposes state',
      (tester) async {
        var activations = 0;
        Widget button({bool loading = false, bool enabled = true}) {
          final callback = enabled ? () => activations++ : null;
          return secondary
              ? TamButton.secondary(
                  label: 'Continue',
                  onPressed: callback,
                  isLoading: loading,
                  loadingLabel: 'Please wait',
                )
              : TamButton.primary(
                  label: 'Continue',
                  onPressed: callback,
                  isLoading: loading,
                  loadingLabel: 'Please wait',
                );
        }

        await tester.pumpWidget(_host(button()));
        await tester.tap(find.text('Continue'));
        expect(activations, 1);

        await tester.pumpWidget(_host(button(enabled: false)));
        await tester.tap(find.text('Continue'));
        expect(activations, 1);
        final native = find.byType(secondary ? OutlinedButton : FilledButton);
        expect(
          tester.getSemantics(native).flagsCollection.isEnabled,
          Tristate.isFalse,
        );

        await tester.pumpWidget(_host(button(loading: true)));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('Please wait'));
        expect(activations, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.bySemanticsLabel('Please wait'), findsOneWidget);
        expect(tester.getSemantics(native).flagsCollection.isButton, isTrue);
        expect(
          tester.getSemantics(native).flagsCollection.isEnabled,
          Tristate.isFalse,
        );
        final material = tester.widget<Material>(
          find.descendant(of: native, matching: find.byType(Material)).first,
        );
        if (!secondary) {
          expect(material.color, AppTheme.light.colorScheme.primary);
        }
      },
    );
  }

  testWidgets('primary button supports keyboard activation', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      _host(
        TamButton.primary(label: 'Continue', onPressed: () => activations++),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);
  });

  testWidgets('field validates, accepts input and clears corrected errors', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? changed;
    String? submitted;
    await tester.pumpWidget(
      _host(
        Form(
          key: formKey,
          child: TamTextField(
            labelText: 'Name',
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your name'
                : null,
            onChanged: (value) => changed = value,
            onFieldSubmitted: (value) => submitted = value,
          ),
        ),
      ),
    );
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Enter your name'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Tam');
    await tester.pumpAndSettle();
    expect(changed, 'Tam');
    expect(formKey.currentState!.validate(), isTrue);
    expect(find.text('Enter your name'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'Tam');
  });

  testWidgets('field exposes server errors and caller-owned focus/controller', (
    tester,
  ) async {
    final controller = TextEditingController(text: '+963944123456');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _host(
        TamTextField(
          labelText: 'رقم الهاتف',
          controller: controller,
          focusNode: focusNode,
          textDirection: TextDirection.ltr,
          errorText: 'تعذر التحقق من الرقم، حاول مرة أخرى',
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(find.text('تعذر التحقق من الرقم، حاول مرة أخرى'), findsOneWidget);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.textDirection, TextDirection.ltr);
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);
    expect(controller.text, '+963944123456');
  });

  testWidgets('disabled and read-only fields block editing', (tester) async {
    final controller = TextEditingController(text: 'Existing value');
    addTearDown(controller.dispose);
    for (final enabled in [false, true]) {
      await tester.pumpWidget(
        _host(
          TamTextField(
            labelText: 'Name',
            controller: controller,
            enabled: enabled,
            readOnly: enabled,
          ),
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly || field.enabled == false, isTrue);
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isFalse);
      expect(controller.text, 'Existing value');
    }
  });

  testWidgets('cards expose interaction only when they have an action', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(_host(const TamCard(child: Text('Summary'))));
    expect(find.byType(InkWell), findsNothing);
    expect(
      tester.getSemantics(find.text('Summary')).flagsCollection.isButton,
      isFalse,
    );
    await tester.pumpWidget(
      _host(TamCard(onTap: () => activations++, child: const Text('Details'))),
    );
    await tester.tap(find.text('Details'));
    expect(activations, 1);
    expect(
      tester.getSemantics(find.byType(InkWell)).flagsCollection.isButton,
      isTrue,
    );
    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(AppDimensions.minTapTarget),
    );
  });

  testWidgets('progress exposes a localized label and determinate value', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TamLoadingIndicator(semanticLabel: 'جارٍ التحميل', value: 0.5),
      ),
    );
    final node = tester.getSemantics(find.byType(CircularProgressIndicator));
    expect(node.label, 'جارٍ التحميل');
    expect(node.value, anyOf('50', '50%'));
  });

  for (final direction in TextDirection.values) {
    for (final scale in [1.0, 2.0, 3.2]) {
      testWidgets('320px layout supports $direction at ${scale}x text', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final arabic = direction == TextDirection.rtl;
        final label = arabic
            ? 'متابعة وإكمال البيانات'
            : 'Continue with details';
        await tester.pumpWidget(
          _host(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TamButton.primary(
                  label: label,
                  icon: Icons.arrow_forward,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                TamButton.secondary(
                  label: label,
                  onPressed: null,
                  isLoading: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                TamTextField(
                  labelText: arabic ? 'الاسم' : 'Name',
                  errorText: arabic
                      ? 'تحقق من البيانات المدخلة ثم حاول مرة أخرى'
                      : 'Check the information you entered and try again',
                ),
                const SizedBox(height: AppSpacing.lg),
                TamCard(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.xl,
                    end: AppSpacing.sm,
                    top: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                  ),
                  child: Text(
                    arabic
                        ? 'ملخص البيانات المدخلة'
                        : 'Your information summary',
                  ),
                ),
              ],
            ),
            direction: direction,
            scale: scale,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        final primary = find.byType(FilledButton);
        expect(
          tester.getSize(primary).height,
          greaterThanOrEqualTo(AppDimensions.controlMinHeight),
        );
        final iconX = tester.getCenter(find.byIcon(Icons.arrow_forward)).dx;
        final textX = tester.getCenter(find.text(label).first).dx;
        expect(arabic ? iconX > textX : iconX < textX, isTrue);
      });
    }
  }
}

double _contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

Widget _host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: Locale(direction == TextDirection.rtl ? 'ar' : 'en'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [child],
        ),
      ),
    ),
  );
}
