import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/normalize_digits.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

/// A scrollable time input avoids the native picker's fixed-height input form
/// clipping its actions at large text scale with an open keyboard.
class RideTimeDialog extends StatefulWidget {
  const RideTimeDialog({super.key, required this.initialTime});
  final TimeOfDay initialTime;

  @override
  State<RideTimeDialog> createState() => _RideTimeDialogState();
}

class _RideTimeDialogState extends State<RideTimeDialog> {
  final _form = GlobalKey<FormState>();
  late String _hour = widget.initialTime.hour.toString().padLeft(2, '0');
  late String _minute = widget.initialTime.minute.toString().padLeft(2, '0');

  String? _validate(String? value, int maximum) {
    final text = normalizeDigits(value ?? '').trim();
    final number = int.tryParse(text);
    return !RegExp(r'^\d{1,2}$').hasMatch(text) ||
            number == null ||
            number < 0 ||
            number > maximum
        ? AppLocalizations.of(context).rideRequestTimeInvalid
        : null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      TimeOfDay(
        hour: int.parse(normalizeDigits(_hour)),
        minute: int.parse(normalizeDigits(_minute)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.rideRequestScheduleTime,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l.rideRequestTimeFormat),
                const SizedBox(height: AppSpacing.lg),
                TamTextField(
                  key: const Key('schedule-hour-input'),
                  labelText: l.rideRequestHour,
                  initialValue: _hour,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(2)],
                  validator: (value) => _validate(value, 23),
                  onChanged: (value) => _hour = value,
                ),
                const SizedBox(height: AppSpacing.lg),
                TamTextField(
                  key: const Key('schedule-minute-input'),
                  labelText: l.rideRequestMinuteInput,
                  initialValue: _minute,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(2)],
                  validator: (value) => _validate(value, 59),
                  onChanged: (value) => _minute = value,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: AppSpacing.lg),
                TamButton.primary(
                  key: const Key('schedule-time-save'),
                  label: l.rideRequestScheduleSave,
                  onPressed: _save,
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
