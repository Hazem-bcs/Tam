import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class HomeUtilityLinks extends StatelessWidget {
  const HomeUtilityLinks({
    super.key,
    required this.onAddresses,
    required this.onActiveTrip,
  });
  final VoidCallback onAddresses;
  final VoidCallback onActiveTrip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final links = [
      TextButton.icon(
        key: const Key('home-addresses'),
        onPressed: onAddresses,
        icon: const Icon(Icons.bookmark_border_rounded),
        label: Text(t.addressesTitle),
      ),
      TextButton.icon(
        key: const Key('home-active-trip'),
        onPressed: onActiveTrip,
        icon: const Icon(Icons.route_outlined),
        label: Text(t.activeTripFollow),
      ),
    ];
    return LayoutBuilder(
      builder: (context, bounds) {
        final stack =
            bounds.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(16) > 24;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: stack
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: links,
                )
              : Row(
                  children: [for (final link in links) Expanded(child: link)],
                ),
        );
      },
    );
  }
}
