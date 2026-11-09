import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_time_dialog.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

class RideScheduleDialog extends StatefulWidget {
  const RideScheduleDialog({
    super.key,
    required this.policy,
    required this.now,
    this.initialTime,
  });

  final RideSchedulePolicy policy;
  final DateTime Function() now;
  final DateTime? initialTime;

  @override
  State<RideScheduleDialog> createState() => _RideScheduleDialogState();
}

class _RideScheduleDialogState extends State<RideScheduleDialog> {
  late DateTime _wall;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    final current = widget.now();
    final initial = widget.initialTime;
    _wall = widget.policy.wallTime(
      initial != null && widget.policy.allows(initial, current)
          ? initial
          : widget.policy.initialTime(current),
    );
  }

  Future<void> _pickDate() async {
    final policy = widget.policy;
    final now = widget.now();
    final first = policy.wallTime(now.add(policy.minimumLeadTime));
    final last = policy.wallTime(now.add(policy.maximumAdvance));
    final initial = _wall.isBefore(first)
        ? first
        : _wall.isAfter(last)
        ? last
        : _wall;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (selected != null && mounted) {
      setState(() {
        _wall = DateTime.utc(
          selected.year,
          selected.month,
          selected.day,
          _wall.hour,
          _wall.minute,
        );
        _invalid = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final selected = await showDialog<TimeOfDay>(
      context: context,
      builder: (_) => RideTimeDialog(
        initialTime: TimeOfDay(hour: _wall.hour, minute: _wall.minute),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _wall = DateTime.utc(
          _wall.year,
          _wall.month,
          _wall.day,
          selected.hour,
          selected.minute,
        );
        _invalid = false;
      });
    }
  }

  void _confirm() {
    final instant = widget.policy.fromWallTime(_wall);
    if (!widget.policy.allows(instant, widget.now())) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(instant);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.rideRequestScheduleTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                key: const Key('schedule-date'),
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  '${l.rideRequestScheduleDate}: ${DateFormat.yMMMd(locale).format(_wall)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const Key('schedule-time'),
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  '${l.rideRequestScheduleTime}: ${TimeOfDay(hour: _wall.hour, minute: _wall.minute).format(context)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.rideRequestScheduleTimezone(widget.policy.offsetLabel),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.rideRequestScheduleRange(
                  widget.policy.minimumLeadTime.inMinutes,
                  widget.policy.maximumAdvance.inDays,
                ),
              ),
              if (_invalid) ...[
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l.rideRequestScheduleInvalid,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              TamButton.primary(
                key: const Key('schedule-confirm'),
                label: l.rideRequestScheduleSave,
                onPressed: _confirm,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.rideRequestScheduleCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
