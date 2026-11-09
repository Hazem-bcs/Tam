import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/pages/completion_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../support/preview_fonts.dart';

const captureCompletionUi = bool.fromEnvironment('CAPTURE_COMPLETION_UI');
Future<void> loadCompletionFonts() =>
    loadPreviewFonts(enabled: captureCompletionUi);
Future<CompletionCubit> pumpCompletion(
  WidgetTester tester, {
  required CompletionRepository repository,
  String locale = 'ar',
  double scale = 1,
  VoidCallback? onBack,
  VoidCallback? onSupport,
  VoidCallback? onHome,
  bool settle = true,
}) async {
  late CompletionCubit cubit;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('completion-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: captureCompletionUi ? previewTheme() : AppTheme.light,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider(
          create: (_) => cubit = CompletionCubit(
            repository,
            tripId: 'mock-history-001',
            createIdempotencyKey: () => 'widget-key',
          ),
          child: CompletionPage(
            onBack: onBack ?? () {},
            onSupport: onSupport ?? () {},
            onHome: onHome ?? () {},
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return cubit;
}

Future<void> captureCompletion(WidgetTester tester, String name) async {
  if (!captureCompletionUi) return;
  await expectLater(
    find.byKey(const Key('completion-preview')),
    matchesGoldenFile(
      '../../../../../docs/engineering/deliveries/W2-COMPLETION/screenshots/$name.png',
    ),
  );
}

Future<void> showCompletionForm(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('completion-comment')));
  await tester.pumpAndSettle();
}
