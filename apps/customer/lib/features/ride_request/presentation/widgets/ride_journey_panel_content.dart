import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Folding keeps form controllers alive and stops hidden animation tickers.
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
    final reduced = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, bounds) {
        final height = compact ? expandedHeight : bounds.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Visibility(
              visible: !compact,
              maintainState: true,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: height,
                maxHeight: height,
                child: ClipRect(
                  child: AnimatedSwitcher(
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    duration: reduced ? Duration.zero : AppMotion.medium,
                    switchInCurve: AppMotion.easeOut,
                    switchOutCurve: AppMotion.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .035),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(key: ValueKey(stageKey), child: child),
                  ),
                ),
              ),
            ),
            if (compact)
              SingleChildScrollView(
                child: ListTile(
                  minTileHeight: 56,
                  title: Text(
                    collapsedLabel,
                    style: theme.textTheme.titleMedium,
                  ),
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
      },
    );
  }
}
