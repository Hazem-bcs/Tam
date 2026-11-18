import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_feedback.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

Future<bool> showRideLocationAccessPrompt(
  BuildContext context,
  String failure,
) async {
  final t = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.location_on_outlined),
          title: Text(
            failure == 'LOCATION_DISABLED'
                ? t.mapsEnableLocation
                : t.mapsOpenSettings,
          ),
          content: Text(mapFailureText(t, failure)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.mapsPickLocation),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                failure == 'LOCATION_DISABLED'
                    ? t.mapsTurnOnLocation
                    : t.mapsOpenSettings,
              ),
            ),
          ],
        ),
      ) ??
      false;
}

class RideLocationStatus extends StatelessWidget {
  const RideLocationStatus({
    super.key,
    required this.locating,
    this.failure,
    this.onRetry,
    this.onSettings,
  });
  final bool locating;
  final String? failure;
  final VoidCallback? onRetry, onSettings;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (!locating && failure == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: AppSpacing.xs,
              end: AppSpacing.sm,
            ),
            child: Icon(
              locating
                  ? Icons.gps_not_fixed_rounded
                  : Icons.location_off_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              locating ? t.mapsLocating : mapFailureText(t, failure),
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (failure != null)
            TextButton(
              onPressed:
                  {
                    'LOCATION_DISABLED',
                    'LOCATION_DENIED_FOREVER',
                    'LOCATION_PRECISE_REQUIRED',
                  }.contains(failure)
                  ? onSettings
                  : onRetry,
              child: Text(
                {
                      'LOCATION_DISABLED',
                      'LOCATION_DENIED_FOREVER',
                      'LOCATION_PRECISE_REQUIRED',
                    }.contains(failure)
                    ? t.mapsOpenSettings
                    : t.mapsRetry,
              ),
            ),
        ],
      ),
    );
  }
}

Future<bool> showRideVpnLocationNotice(BuildContext context) async {
  final t = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.vpn_key_outlined),
          title: Text(t.mapsVpnActive),
          content: Text(t.mapsVpnLocationNotice),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.mapsPickLocation),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.mapsRetry),
            ),
          ],
        ),
      ) ??
      false;
}
