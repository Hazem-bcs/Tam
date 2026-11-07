import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class AuthStatusPage extends StatelessWidget {
  const AuthStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return AuthScaffold(
          title: t.authRestoring,
          description: t.authSessionDescription,
          artwork: AuthArtwork.recovery,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isBusy || state.status == AuthStatus.restoring)
                Center(
                  child: TamLoadingIndicator(semanticLabel: t.authRestoring),
                ),
              if (state.failure != null) ...[
                AuthErrorNotice(failure: state.failure!),
                const SizedBox(height: AppSpacing.xl),
                TamButton.primary(
                  label: t.authRetry,
                  isLoading: state.isBusy,
                  onPressed: context.read<AuthCubit>().restoreSession,
                ),
                const SizedBox(height: AppSpacing.md),
                TamButton.secondary(
                  label: t.authSignOutThisDevice,
                  onPressed: state.isBusy
                      ? null
                      : context.read<AuthCubit>().logout,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
