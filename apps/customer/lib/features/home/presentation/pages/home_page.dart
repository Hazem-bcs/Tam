import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) => Scaffold(
        appBar: AppBar(title: Text(t.appName)),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.homeWelcome,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TamCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.status == AuthStatus.guest
                                ? t.authGuestTitle
                                : auth.status == AuthStatus.localAccess
                                ? t.homePhoneTitle
                                : t.authSignedInTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (auth.status == AuthStatus.guest)
                            Text(t.authGuestDescription)
                          else
                            Text(
                              auth.localPhoneE164 ??
                                  auth.user?.displayName ??
                                  auth.user?.phoneE164 ??
                                  '',
                              textDirection: auth.user?.displayName == null
                                  ? TextDirection.ltr
                                  : null,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TamCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            t.homeServiceTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            t.homeServiceDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (auth.failure != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AuthErrorNotice(failure: auth.failure!),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    TamButton.secondary(
                      label: auth.status == AuthStatus.guest
                          ? t.authSignIn
                          : t.authLogout,
                      loadingLabel: t.authLoggingOut,
                      isLoading: auth.isSigningOut,
                      onPressed: auth.isBusy
                          ? null
                          : context.read<AuthCubit>().logout,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
