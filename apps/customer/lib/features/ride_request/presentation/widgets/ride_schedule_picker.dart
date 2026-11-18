import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_schedule_dialog.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';

class RideSchedulePicker extends StatelessWidget {
  const RideSchedulePicker({
    super.key,
    required this.scheduledAt,
    required this.enabled,
    required this.policy,
    required this.now,
    required this.onChanged,
    this.compact = false,
  });

  final DateTime? scheduledAt;
  final bool compact;
  final bool enabled;
  final RideSchedulePolicy policy;
  final DateTime Function() now;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (_) => RideScheduleDialog(
        policy: policy,
        now: now,
        initialTime: scheduledAt,
      ),
    );
    if (result != null && context.mounted) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.textScalerOf(context).scale(1) > 1.5)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                key: const Key('ride-immediate'),
                label: Text(l.rideRequestImmediate),
                avatar: const Icon(Icons.bolt_outlined),
                selected: scheduledAt == null,
                onSelected: enabled ? (_) => onChanged(null) : null,
              ),
              ChoiceChip(
                key: const Key('ride-scheduled'),
                label: Text(l.rideRequestScheduled),
                avatar: const Icon(Icons.calendar_month_outlined),
                selected: scheduledAt != null,
                onSelected: enabled ? (_) => _pick(context) : null,
              ),
            ],
          )
        else
          SegmentedButton<bool>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.standard,
            ),
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.bolt_rounded),
                label: Text(
                  key: const Key('ride-immediate'),
                  l.rideRequestImmediate,
                ),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  key: const Key('ride-scheduled'),
                  l.rideRequestScheduled,
                ),
              ),
            ],
            selected: {scheduledAt != null},
            onSelectionChanged: !enabled
                ? null
                : (values) {
                    if (values.isEmpty) {
                      if (scheduledAt != null) _pick(context);
                      return;
                    }
                    if (values.single) {
                      _pick(context);
                    } else {
                      onChanged(null);
                    }
                  },
          ),
        if (scheduledAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(rideTimeLabel(context, scheduledAt!, policy: policy)),
          if (!compact)
            Text(
              l.rideRequestScheduledNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ],
    );
  }
}
