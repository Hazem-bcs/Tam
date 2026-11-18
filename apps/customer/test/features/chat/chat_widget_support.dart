import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:tam_customer/features/chat/presentation/pages/chat_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../support/preview_fonts.dart';
import 'chat_test_support.dart';

const captureChatUi = bool.fromEnvironment('CAPTURE_CHAT_UI');
Future<void> loadChatFonts() => loadPreviewFonts(enabled: captureChatUi);
Future<ChatCubit> pumpChat(
  WidgetTester tester, {
  required ChatRepository repository,
  String locale = 'ar',
  bool settle = true,
  double scale = 1,
  bool showDemoAvatar = false,
  GlobalKey<NavigatorState>? navigator,
}) async {
  late ChatCubit cubit;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('chat-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigator,
        theme: captureChatUi ? previewTheme() : AppTheme.light,
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
          create: (_) => cubit = ChatCubit(
            repository,
            tripId: 'trip-1',
            policy: const ChatPolicy(),
            now: () => chatNow,
          ),
          child: ChatPage(onBack: () {}, showDemoAvatar: showDemoAvatar),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
    if (captureChatUi && showDemoAvatar) {
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/driver_demo_160.webp'),
          tester.element(find.byType(ChatPage)),
        ),
      );
      await tester.pumpAndSettle();
    }
  } else {
    await tester.pump();
  }
  return cubit;
}

Future<void> captureChat(WidgetTester tester, String name) async {
  if (captureChatUi) {
    await expectLater(
      find.byKey(const Key('chat-preview')),
      matchesGoldenFile(
        '../../../../../docs/engineering/deliveries/${const String.fromEnvironment('CHAT_UI_DELIVERY', defaultValue: 'W2-CHAT')}/screenshots/$name.png',
      ),
    );
  }
}
