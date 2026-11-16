import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_journey_panel_content.dart';
import 'ride_panel_size_observer.dart';

/// Only panel geometry and map controls listen to the short-lived animation.
/// The tile renderer stays mounted while dragging or changing journey stages.
class RideJourneyShell extends StatefulWidget {
  const RideJourneyShell({
    super.key,
    required this.header,
    required this.mapBuilder,
    this.panel,
    this.panelBuilder,
    required this.stageKey,
    required this.collapsedLabel,
    required this.preferredExtent,
    this.expandOnChange,
  }) : assert(panel != null || panelBuilder != null);
  final Widget header;
  final Widget? panel;
  final Widget Function(VoidCallback collapse)? panelBuilder;
  final Widget Function(ValueListenable<double>) mapBuilder;
  final Object stageKey;
  final String collapsedLabel;
  final double preferredExtent;
  final Object? expandOnChange;

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
  double _keyboardInset = 0, _panelHeight = 0;
  bool _compact = false;
  Offset? _mapDragOrigin;

  double get _preferred => widget.preferredExtent.clamp(_minimum, _maximum);
  void _changed() {
    final compact =
        _extent.value * _height < math.min(180, math.max(108, _height * .30));
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
    if (widget.expandOnChange != oldWidget.expandOnChange ||
        widget.stageKey != oldWidget.stageKey ||
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
    final keyboardInset = math.max(
      0.0,
      MediaQuery.viewInsetsOf(context).bottom -
          MediaQuery.viewPaddingOf(context).bottom,
    );
    final keyboardTransition = keyboardInset > 0 || _keyboardInset > 0;
    if (_keyboardInset > 0 && keyboardInset == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardInset == 0) {
          _mapInset.value = _panelHeight + AppSpacing.md;
        }
      });
    }
    _keyboardInset = keyboardInset;
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
              child: Listener(
                onPointerDown: (event) => _mapDragOrigin = event.position,
                onPointerUp: (_) => _mapDragOrigin = null,
                onPointerCancel: (_) => _mapDragOrigin = null,
                onPointerMove: (event) {
                  final start = _mapDragOrigin;
                  if (start != null && (event.position - start).distance > 12) {
                    _mapDragOrigin = null;
                    if (!_compact) _move(_minimum);
                  }
                },
                child: RepaintBoundary(
                  child: MediaQuery.removeViewInsets(
                    context: context,
                    removeBottom: true,
                    child: widget.mapBuilder(_mapInset),
                  ),
                ),
              ),
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
                bottom: keyboardInset + AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: math.min(
                      (_extent.value * _height).clamp(0, _height),
                      math.max(0, _height - keyboardInset - 96),
                    ),
                  ),
                  child: child!,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: RidePanelSizeObserver(
                    onHeight: (height) {
                      _panelHeight = height;
                      if (mounted && _keyboardInset == 0) {
                        _mapInset.value = height + AppSpacing.md;
                      }
                    },
                    child: AnimatedSize(
                      alignment: Alignment.bottomCenter,
                      duration:
                          keyboardTransition ||
                              MediaQuery.disableAnimationsOf(context)
                          // A nonzero tick avoids AnimatedSize completing
                          // synchronously inside its own layout pass.
                          ? const Duration(milliseconds: 1)
                          : AppMotion.medium,
                      curve: AppMotion.easeOut,
                      child: Material(
                        color: c.surfaceContainerLowest,
                        elevation: AppElevation.raised,
                        borderRadius: BorderRadius.circular(AppRadii.sheet),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                              child: Tooltip(
                                message: _compact
                                    ? t.rideRequestExpandPanel
                                    : t.rideRequestCollapsePanel,
                                child: InkWell(
                                  key: const Key('ride-sheet-toggle'),
                                  onTap: () =>
                                      _move(_compact ? _preferred : _minimum),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: AppDimensions.minTapTarget,
                                    child: Center(
                                      child: Container(
                                        width: 36,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: c.outlineVariant,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.sm,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: RideJourneyPanelContent(
                                compact: _compact,
                                expandedHeight: math.max(
                                  240,
                                  _preferred * _height -
                                      AppDimensions.minTapTarget,
                                ),
                                stageKey: widget.stageKey,
                                collapsedLabel: widget.collapsedLabel,
                                onExpand: () => _move(_preferred),
                                child:
                                    widget.panelBuilder?.call(
                                      () => _move(_minimum),
                                    ) ??
                                    widget.panel!,
                              ),
                            ),
                          ],
                        ),
                      ),
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
