import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

/// Coordinates can be used immediately; an unavailable address lookup never
/// substitutes a fixture or drops the user's selected point.
class RideMapPointPanel extends StatefulWidget {
  const RideMapPointPanel({
    super.key,
    required this.point,
    this.address,
    required this.resolving,
    required this.onPickup,
    required this.onDestination,
    required this.onClose,
  });
  final GeoPoint point;
  final String? address;
  final bool resolving;
  final ValueChanged<TripLocation> onPickup, onDestination;
  final VoidCallback onClose;

  @override
  State<RideMapPointPanel> createState() => _RideMapPointPanelState();
}

class _RideMapPointPanelState extends State<RideMapPointPanel> {
  late final _description = TextEditingController(text: widget.address);
  bool _edited = false;
  @override
  void didUpdateWidget(RideMapPointPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.point != widget.point) {
      _edited = false;
      _description.text = widget.address ?? '';
    } else if (!_edited && oldWidget.address != widget.address) {
      _description.text = widget.address ?? '';
    }
  }

  TripLocation _location(AppLocalizations t) => TripLocation(
    point: widget.point,
    label: _description.text.trim().isEmpty
        ? t.rideRequestMapPoint
        : _description.text.trim(),
  );

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.rideRequestMapPointTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: t.rideRequestMapPointCancel,
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(
              t.rideRequestMapPointHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.point.latitude.toStringAsFixed(5)}, ${widget.point.longitude.toStringAsFixed(5)}',
              textDirection: TextDirection.ltr,
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TamTextField(
              key: const Key('ride-map-point-description'),
              controller: _description,
              labelText: t.rideRequestMapPointDescription,
              hintText: t.mapsAddressHint,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              onChanged: (_) => _edited = true,
            ),
            if (widget.resolving) const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            TamButton.primary(
              key: const Key('ride-map-use-destination'),
              label: t.rideRequestUseAsDestination,
              icon: Icons.location_on_outlined,
              onPressed: () => widget.onDestination(_location(t)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TamButton.secondary(
              key: const Key('ride-map-use-pickup'),
              label: t.rideRequestUseAsPickup,
              icon: Icons.trip_origin_rounded,
              onPressed: () => widget.onPickup(_location(t)),
            ),
          ],
        ),
      ),
    );
  }
}
