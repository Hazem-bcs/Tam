import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Keeps form controllers alive while the map is expanded. Loose constraints
/// let short forms size the floating card instead of filling a reserved box.
class RideJourneyPanelContent extends StatelessWidget {
  const RideJourneyPanelContent({
    super.key,
    required this.compact,
    required this.expandedHeight,
    required this.stageKey,
    required this.collapsedLabel,
    required this.onExpand,
    required this.child,
  });
  final bool compact;
  final double expandedHeight;
  final Object stageKey;
  final String collapsedLabel;
  final VoidCallback onExpand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Visibility(
          visible: !compact,
          maintainState: true,
          child: OverflowBox(
            fit: OverflowBoxFit.deferToChild,
            alignment: Alignment.topCenter,
            minHeight: compact ? expandedHeight : null,
            maxHeight: compact ? expandedHeight : null,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppMotion.short,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(key: ValueKey(stageKey), child: child),
            ),
          ),
        ),
        if (compact)
          SingleChildScrollView(
            child: ListTile(
              minTileHeight: 56,
              title: Text(collapsedLabel, style: theme.textTheme.titleSmall),
              subtitle: Text(
                t.rideRequestExpandPanel,
                style: theme.textTheme.bodySmall,
              ),
              leading: Icon(
                Icons.route_rounded,
                color: theme.colorScheme.primary,
              ),
              onTap: onExpand,
            ),
          ),
      ],
    );
  }
}
