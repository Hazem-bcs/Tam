import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class HomeStatusPanel extends StatelessWidget {
  const HomeStatusPanel({super.key, required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final loading =
        state.status == HomeLoadStatus.initial ||
        state.status == HomeLoadStatus.loading;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          if (loading)
            TamLoadingIndicator(semanticLabel: t.homeLoading)
          else ...[
            Icon(
              state.status == HomeLoadStatus.empty
                  ? Icons.inbox_outlined
                  : Icons.wifi_off_outlined,
              size: AppDimensions.minTapTarget,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.status == HomeLoadStatus.empty
                  ? t.homeEmpty
                  : state.failure == HomeFailureCode.serviceUnavailable
                  ? t.homeUnavailable
                  : t.homeError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TamButton.secondary(
              label: t.authRetry,
              onPressed: context.read<HomeCubit>().load,
            ),
          ],
        ],
      ),
    );
  }
}
