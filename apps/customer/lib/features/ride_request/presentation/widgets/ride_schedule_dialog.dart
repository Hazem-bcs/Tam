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

  void _selectDay(DateTime day) {
    setState(() {
      _wall = DateTime.utc(
        day.year,
        day.month,
        day.day,
        _wall.hour,
        _wall.minute,
      );
      _invalid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final today = widget.policy.wallTime(widget.now());
    final tomorrow = today.add(const Duration(days: 1));
    final first = widget.policy.wallTime(
      widget.now().add(widget.policy.minimumLeadTime),
    );
    final last = widget.policy.wallTime(
      widget.now().add(widget.policy.maximumAdvance),
    );
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    bool available(DateTime day) {
      final date = DateUtils.dateOnly(day);
      return !date.isBefore(DateUtils.dateOnly(first)) &&
          !date.isAfter(DateUtils.dateOnly(last));
    }

    final date = DateFormat.yMMMMEEEEd(locale).format(_wall);
    final time = TimeOfDay(
      hour: _wall.hour,
      minute: _wall.minute,
    ).format(context);
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(context).height * .9,
          ),
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l.rideRequestScheduleTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.rideRequestScheduleRange(
                    widget.policy.minimumLeadTime.inMinutes,
                    widget.policy.maximumAdvance.inDays,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      key: const Key('schedule-today'),
                      label: Text(l.rideRequestScheduleToday),
                      selected: sameDay(today, _wall),
                      onSelected: available(today)
                          ? (_) => _selectDay(today)
                          : null,
                    ),
                    ChoiceChip(
                      key: const Key('schedule-tomorrow'),
                      label: Text(l.rideRequestScheduleTomorrow),
                      selected: sameDay(tomorrow, _wall),
                      onSelected: available(tomorrow)
                          ? (_) => _selectDay(tomorrow)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _ScheduleOption(
                  key: const Key('schedule-date'),
                  icon: Icons.calendar_month_outlined,
                  label: l.rideRequestScheduleDate,
                  value: date,
                  onTap: _pickDate,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ScheduleOption(
                  key: const Key('schedule-time'),
                  icon: Icons.access_time_rounded,
                  label: l.rideRequestScheduleTime,
                  value: time,
                  onTap: _pickTime,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.rideRequestScheduleSummary,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$date • $time',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.rideRequestScheduleTimezone(
                          widget.policy.offsetLabel,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_invalid) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l.rideRequestScheduleInvalid,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.error,
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
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.rideRequestScheduleCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleOption extends StatelessWidget {
  const _ScheduleOption({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 20, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
