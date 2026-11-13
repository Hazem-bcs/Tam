import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class MapAttributionLink extends StatefulWidget {
  const MapAttributionLink({super.key, this.onOpen, this.permanent = false});
  final Future<void> Function()? onOpen;
  final bool permanent;
  @override
  State<MapAttributionLink> createState() => _MapAttributionLinkState();
}

class _MapAttributionLinkState extends State<MapAttributionLink> {
  Timer? _timer;
  bool _expanded = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleCollapse();
  }

  void _scheduleCollapse() {
    _timer?.cancel();
    // Keep the notice available to users who need longer to read it.
    if (widget.permanent ||
        !_expanded ||
        MediaQuery.accessibleNavigationOf(context)) {
      return;
    }
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _expanded = false);
    });
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _scheduleCollapse();
  }

  Future<void> _open() async {
    try {
      await widget.onOpen!();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).mapsAttributionUnavailable,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_expanded || widget.permanent)
              Flexible(
                child: Semantics(
                  link: widget.onOpen != null,
                  child: TextButton(
                    key: const Key('map-attribution'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      disabledForegroundColor:
                          theme.colorScheme.onSurfaceVariant,
                      minimumSize: const Size(
                        AppDimensions.minTapTarget,
                        AppDimensions.minTapTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                    ),
                    onPressed: widget.onOpen == null ? null : _open,
                    child: Text(
                      widget.permanent
                          ? l.mapsOsmAttribution
                          : l.mapsAttribution,
                      textDirection: widget.permanent
                          ? TextDirection.ltr
                          : null,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            if (!_expanded && !widget.permanent)
              IconButton(
                key: const Key('map-attribution-toggle'),
                tooltip: l.mapsShowAttribution,
                color: theme.colorScheme.onSurfaceVariant,
                iconSize: 18,
                icon: const Icon(Icons.info_outline),
                onPressed: _toggle,
              ),
          ],
        ),
      ),
    );
  }
}
