import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class MapAttributionLink extends StatelessWidget {
  const MapAttributionLink({super.key, this.onOpen});
  final Future<void> Function()? onOpen;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Text(
      l.mapsAttribution,
      style: Theme.of(context).textTheme.labelSmall,
    );
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SizedBox(
        width: double.infinity,
        child: onOpen == null
            ? Padding(padding: const EdgeInsets.all(AppSpacing.xs), child: text)
            : Semantics(
                link: true,
                child: TextButton(
                  key: const Key('map-attribution'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      AppDimensions.minTapTarget,
                      AppDimensions.minTapTarget,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await onOpen!();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.mapsAttributionUnavailable)),
                        );
                      }
                    }
                  },
                  child: text,
                ),
              ),
      ),
    );
  }
}
