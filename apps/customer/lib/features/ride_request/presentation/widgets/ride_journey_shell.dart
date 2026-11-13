import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_journey_panel_content.dart';

/// Only panel geometry and map controls listen to the short-lived animation.
/// The tile renderer stays mounted while dragging or changing journey stages.
class RideJourneyShell extends StatefulWidget {
  const RideJourneyShell({
    super.key,
    required this.header,
    required this.mapBuilder,
    required this.panel,
    required this.stageKey,
    required this.collapsedLabel,
    required this.preferredExtent,
  });
  final Widget header, panel;
  final Widget Function(ValueListenable<double>) mapBuilder;
  final Object stageKey;
  final String collapsedLabel;
  final double preferredExtent;

  @override
  State<RideJourneyShell> createState() => _RideJourneyShellState();
}

class _RideJourneyShellState extends State<RideJourneyShell>
    with SingleTickerProviderStateMixin {
  late final _extent = AnimationController(
    vsync: this,
    value: widget.preferredExtent,
  )..addListener(_changed);
  final _mapInset = ValueNotifier<double>(0);
  double _height = 0, _minimum = .15, _maximum = .90;
  bool _compact = false;

  double get _preferred => widget.preferredExtent.clamp(_minimum, _maximum);
  void _changed() {
    _mapInset.value = _extent.value * _height;
    final compact =
        _mapInset.value < math.min(220, math.max(128, _height * .42));
    if (compact != _compact && mounted) setState(() => _compact = compact);
  }

  void _move(double target) {
    FocusScope.of(context).unfocus();
    if (MediaQuery.disableAnimationsOf(context)) {
      _extent.value = target;
    } else {
      _extent.animateTo(
        target,
        duration: AppMotion.medium,
        curve: AppMotion.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(RideJourneyShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stageKey != oldWidget.stageKey ||
        (widget.preferredExtent != oldWidget.preferredExtent && !_compact)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _move(_preferred);
      });
    }
  }

  @override
  void dispose() {
    _extent.dispose();
    _mapInset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, bounds) {
        if (_height != bounds.maxHeight) {
          _height = bounds.maxHeight;
          _minimum = (108 / _height).clamp(.12, .40);
          final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
          final mapSpace = math.min(
            140 * math.min(textScale, 1.6),
            _height * .45,
          );
          _maximum = math.max(
            _minimum,
            ((_height - mapSpace) / _height).clamp(.5, .92),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _extent.value = _preferred;
              _changed();
            }
          });
        }
        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(child: widget.mapBuilder(_mapInset)),
            ),
            PositionedDirectional(
              top: AppSpacing.md,
              start: AppSpacing.lg,
              end: AppSpacing.lg,
              child: widget.header,
            ),
            AnimatedBuilder(
              animation: _extent,
              builder: (context, child) => Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: (_extent.value * _height).clamp(0, _height),
                child: child!,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Material(
                    color: c.surfaceContainerLowest,
                    elevation: AppElevation.raised,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadii.sheet),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: (_) =>
                              FocusScope.of(context).unfocus(),
                          onVerticalDragUpdate: (details) {
                            _extent.stop();
                            _extent.value =
                                (_extent.value - details.delta.dy / _height)
                                    .clamp(_minimum, _maximum);
                          },
                          onVerticalDragEnd: (details) {
                            final velocity = details.primaryVelocity ?? 0;
                            final fold =
                                velocity > 250 ||
                                (velocity >= -250 &&
                                    _extent.value <
                                        (_minimum + _preferred) / 2);
                            _move(fold ? _minimum : _preferred);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: AppDimensions.minTapTarget,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: c.outlineVariant,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.sm,
                                    ),
                                  ),
                                ),
                                PositionedDirectional(
                                  end: AppSpacing.sm,
                                  child: IconButton(
                                    key: const Key('ride-sheet-toggle'),
                                    tooltip: _compact
                                        ? t.rideRequestExpandPanel
                                        : t.rideRequestCollapsePanel,
                                    onPressed: () =>
                                        _move(_compact ? _preferred : _minimum),
                                    icon: Icon(
                                      _compact
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RideJourneyPanelContent(
                            compact: _compact,
                            expandedHeight: math.max(
                              240,
                              _preferred * _height - AppDimensions.minTapTarget,
                            ),
                            stageKey: widget.stageKey,
                            collapsedLabel: widget.collapsedLabel,
                            onExpand: () => _move(_preferred),
                            child: widget.panel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
