import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/router/app_router.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class TamApp extends StatefulWidget {
  const TamApp({
    super.key,
    this.authRepository,
    this.sessionStore,
    this.temporaryPhoneEntryEnabled,
    this.locale = const Locale('ar'),
  }) : assert((authRepository == null) == (sessionStore == null));

  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;
  final bool? temporaryPhoneEntryEnabled;
  final Locale locale;

  @override
  State<TamApp> createState() => _TamAppState();
}

class _TamAppState extends State<TamApp> with WidgetsBindingObserver {
  late final AuthCubit _auth;
  late final AuthRouterRefresh _refresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final presentation = widget.authRepository == null
        ? locator<AuthPresentationConfig>()
        : const AuthPresentationConfig();
    _auth = AuthCubit(
      widget.authRepository ?? locator<AuthRepository>(),
      widget.sessionStore ?? locator<AuthSessionStore>(),
      temporaryPhoneEntryEnabled:
          widget.temporaryPhoneEntryEnabled ??
          presentation.temporaryPhoneEntryEnabled,
    );
    _refresh = AuthRouterRefresh(_auth);
    _router = createAppRouter(_auth, _refresh);
    unawaited(_auth.restoreSession());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _auth.state.status == AuthStatus.authenticated) {
      unawaited(_auth.restoreSession());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    _refresh.dispose();
    unawaited(_auth.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _auth,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        routerConfig: _router,
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: widget.locale,
      ),
    );
  }
}
