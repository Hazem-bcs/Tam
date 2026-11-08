import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_display.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Makes a failed refresh visible even when older content remains available.
class TripsFailureBanner extends StatelessWidget {
  const TripsFailureBanner({
    super.key,
    required this.errorCode,
    required this.onRetry,
  });

  final String errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          Text(
            tripsErrorLabel(AppLocalizations.of(context), errorCode),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).tripsRetry),
          ),
        ],
      ),
    ),
  );
}
