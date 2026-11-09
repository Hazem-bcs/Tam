import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class TripRoute extends StatelessWidget {
  const TripRoute({super.key, required this.pickup, required this.destination});

  final TripLocation pickup;
  final TripLocation destination;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RouteRow(
          title: l.tripsFrom,
          label: pickup.label,
          color: colors.primary,
          icon: Icons.circle,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              height: 18,
              child: VerticalDivider(
                color: colors.outline,
                thickness: 2,
                width: 2,
              ),
            ),
          ),
        ),
        _RouteRow(
          title: l.tripsTo,
          label: destination.label,
          color: colors.primary,
          icon: Icons.location_on,
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.title,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String title;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 22, child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$title  ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}
