import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

String mapFailureText(AppLocalizations l, String? code) => switch (code) {
  'MAP_NOT_CONFIGURED' => l.mapsNotConfigured,
  'LOCATION_DISABLED' => l.mapsLocationDisabled,
  'LOCATION_DENIED' => l.mapsPermissionDenied,
  'LOCATION_DENIED_FOREVER' => l.mapsPermissionPermanent,
  'LOCATION_UNAVAILABLE' => l.mapsLocationUnavailable,
  'LOCATION_INACCURATE' => l.mapsLocationInaccurate,
  'LOCATION_NOT_FOUND' => l.mapsNotFound,
  'RATE_LIMITED' => l.mapsRateLimited,
  'VALIDATION_ERROR' => l.mapsInvalidInput,
  _ => l.mapsServiceFailed,
};

class MapFeedback extends StatelessWidget {
  const MapFeedback({super.key, required this.text, this.onRetry});
  final String text;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(AppRadii.sm),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(text, style: Theme.of(context).textTheme.bodySmall),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).mapsRetry),
            ),
        ],
      ),
    ),
  );
}
