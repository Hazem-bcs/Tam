import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

class SupportEditorHero extends StatelessWidget {
  const SupportEditorHero({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mascotSize = MediaQuery.sizeOf(context).width < 360 ? 88.0 : 110.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ExcludeSemantics(
          child: Container(
            width: mascotSize,
            height: mascotSize,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.48),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/tam_account_mascot.webp',
              width: mascotSize,
              height: mascotSize,
              cacheWidth: 256,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ],
    );
  }
}

class SupportEditorNotice extends StatelessWidget {
  const SupportEditorNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colors.primary.withValues(alpha: 0.88),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportEditorTripReference extends StatelessWidget {
  const SupportEditorTripReference({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 20,
            color: colors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportEditorFieldHeading extends StatelessWidget {
  const SupportEditorFieldHeading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: colors.onSurface.withValues(alpha: 0.76),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Form-specific soft filled input, without a heavy outline or duplicate label.
class SupportEditorDetailsField extends StatelessWidget {
  const SupportEditorDetailsField({
    super.key,
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.length,
    required this.maxLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final int length;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadii.lg);
    final plainBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );

    return Stack(
      children: [
        TextFormField(
          key: const Key('support-body'),
          controller: controller,
          enabled: enabled,
          minLines: 5,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.76),
            ),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            contentPadding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              46,
            ),
            border: plainBorder,
            enabledBorder: plainBorder,
            disabledBorder: plainBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: colors.primary.withValues(alpha: 0.50),
                width: 1.1,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: AppSpacing.lg,
          bottom: AppSpacing.md,
          child: IgnorePointer(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$length / $maxLength',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
