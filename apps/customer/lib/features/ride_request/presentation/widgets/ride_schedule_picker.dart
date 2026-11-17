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
    final result = await showDialog<DateTime>(
      context: context,
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
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              showCheckmark: false,
              labelStyle: compact
                  ? Theme.of(context).textTheme.labelSmall
                  : null,
              labelPadding: compact
                  ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs)
                  : null,
              key: const Key('ride-immediate'),
              avatar: const Icon(Icons.bolt_outlined),
              label: Text(l.rideRequestImmediate),
              selected: scheduledAt == null,
              onSelected: enabled ? (_) => onChanged(null) : null,
            ),
            ChoiceChip(
              showCheckmark: false,
              labelStyle: compact
                  ? Theme.of(context).textTheme.labelSmall
                  : null,
              labelPadding: compact
                  ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs)
                  : null,
              key: const Key('ride-scheduled'),
              avatar: const Icon(Icons.calendar_month_outlined),
              label: Text(l.rideRequestScheduled),
              selected: scheduledAt != null,
              onSelected: enabled ? (_) => _pick(context) : null,
            ),
          ],
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
