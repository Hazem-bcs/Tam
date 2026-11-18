import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

/// A real point is usable even when reverse geocoding is unavailable.
class RideMapPointPanel extends StatefulWidget {
  const RideMapPointPanel({
    super.key,
    required this.point,
    this.address,
    required this.resolving,
    required this.onPickup,
    required this.onDestination,
    required this.onClose,
    this.initialPickup = false,
  });
  final GeoPoint point;
  final String? address;
  final bool resolving, initialPickup;
  final ValueChanged<TripLocation> onPickup, onDestination;
  final VoidCallback onClose;

  @override
  State<RideMapPointPanel> createState() => _RideMapPointPanelState();
}

class _RideMapPointPanelState extends State<RideMapPointPanel> {
  final _description = TextEditingController();
  bool _showDescription = false;

  TripLocation _location(AppLocalizations t) {
    final description = _description.text.trim();
    return TripLocation(
      point: widget.point,
      label: description.isNotEmpty
          ? description
          : widget.address?.trim().isNotEmpty == true
          ? widget.address!
          : t.rideRequestMapPoint,
    );
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final address = widget.address?.trim();
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
            Text(
              t.rideRequestSelectedPlace,
              style: theme.textTheme.labelSmall?.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                address?.isNotEmpty == true
                    ? address!
                    : t.rideRequestConfirmMapPoint,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('ride-map-add-description'),
                onPressed: () =>
                    setState(() => _showDescription = !_showDescription),
                icon: Icon(
                  _showDescription ? Icons.remove_rounded : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(t.rideRequestAddDriverNote),
              ),
            ),
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppMotion.short,
              alignment: Alignment.topCenter,
              child: _showDescription
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TamTextField(
                        key: const Key('ride-map-point-description'),
                        controller: _description,
                        labelText: t.rideRequestMapPointDescription,
                        hintText: t.rideRequestDriverNoteHint,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TamButton.primary(
              key: Key(
                widget.initialPickup
                    ? 'ride-map-use-pickup'
                    : 'ride-map-use-destination',
              ),
              label: widget.initialPickup
                  ? t.rideRequestConfirmPickup
                  : t.rideRequestConfirmDestination,
              icon: Icons.check_rounded,
              onPressed: () => (widget.initialPickup
                  ? widget.onPickup
                  : widget.onDestination)(_location(t)),
            ),
          ],
        ),
      ),
    );
  }
}
