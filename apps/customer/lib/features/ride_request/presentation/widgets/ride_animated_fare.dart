import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'ride_fare_format.dart';

/// Retains the current numeric position across requotes and interrupted tweens.
/// A pending quote is never presented as a valid price for the new selection.
class RideAnimatedFare extends StatefulWidget {
  const RideAnimatedFare({
    super.key,
    required this.value,
    required this.loading,
  });
  final Money? value;
  final bool loading;
  @override
  State<RideAnimatedFare> createState() => _RideAnimatedFareState();
}

class _RideAnimatedFareState extends State<RideAnimatedFare>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  double? _from, _to;
  bool _reduceMotion = false;
  double? get _current => _to == null
      ? null
      : (_from ?? _to!) +
            (_to! - (_from ?? _to!)) *
                Curves.easeOutCubic.transform(_animation.value);

  @override
  void initState() {
    super.initState();
    _from = _to = widget.value?.amountMinor.toDouble();
    _animation.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _animation.value = 1;
  }

  @override
  void didUpdateWidget(RideAnimatedFare oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.value;
    if (value == null || value.amountMinor.toDouble() == _to) return;
    final before = _current;
    _from = before ?? value.amountMinor.toDouble();
    _to = value.amountMinor.toDouble();
    if (before == null || _reduceMotion) {
      _animation.value = 1;
    } else {
      _animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final value = widget.value;
    return Semantics(
      liveRegion: true,
      excludeSemantics: true,
      label: widget.loading
          ? l.rideRequestQuoteLoading
          : value == null
          ? l.rideRequestRouteHint
          : '${rideFareFormat(value, locale)} ${l.rideRequestCurrencySyp}',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) => Text(
          widget.loading || value == null
              ? '—'
              : '${rideFareFormat(value, locale, amountMinor: (_current ?? value.amountMinor).round())} ${l.rideRequestCurrencySyp}',
          key: const Key('ride-animated-fare'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
