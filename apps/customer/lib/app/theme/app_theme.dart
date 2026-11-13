import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/app/theme/app_typography.dart';

/// Shared visual foundation for Tam. Construct once, outside widget builds.
abstract final class AppTheme {
  static final ThemeData light = _build(AppColors.light, AppColors.lightStatus);

  /// Central, route-local opt-in; pushed pages keep their ambient app theme.
  static ThemeData home(ThemeData ambient) => _build(
    AppColors.home,
    ambient.extension<AppStatusColors>() ?? AppColors.lightStatus,
    textTheme: AppTypography.home(ambient.textTheme),
  );

  static ThemeData rideJourney(ThemeData ambient) => _build(
    AppColors.urban,
    ambient.extension<AppStatusColors>() ?? AppColors.lightStatus,
    textTheme: AppTypography.home(ambient.textTheme).apply(
      bodyColor: AppColors.urban.onSurface,
      displayColor: AppColors.urban.onSurface,
    ),
  );

  // A future dark palette can use the same component and typography rules.
  static ThemeData _build(
    ColorScheme colors,
    AppStatusColors status, {
    TextTheme? textTheme,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      textTheme: textTheme ?? AppTypography.textTheme,
      extensions: [status],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    final text = base.textTheme;
    final disabledForeground = colors.onSurface.withValues(alpha: 0.38);
    final disabledBackground = colors.onSurface.withValues(alpha: 0.08);
    const controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      borderSide: BorderSide(
        color: colors.outline,
        width: AppDimensions.borderWidth,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      disabledColor: disabledForeground,
      iconTheme: IconThemeData(
        color: colors.onSurfaceVariant,
        size: AppDimensions.iconSize,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        scrolledUnderElevation: AppElevation.flat,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: disabledBackground,
          disabledForegroundColor: disabledForeground,
          minimumSize: const Size(
            AppDimensions.minTapTarget,
            AppDimensions.controlMinHeight,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: controlShape,
          textStyle: text.labelLarge,
          elevation: AppElevation.flat,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              disabledForegroundColor: disabledForeground,
              minimumSize: const Size(
                AppDimensions.minTapTarget,
                AppDimensions.controlMinHeight,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: controlShape,
              textStyle: text.labelLarge,
            ).copyWith(
              side: WidgetStateProperty.resolveWith((states) {
                return BorderSide(
                  color: states.contains(WidgetState.disabled)
                      ? colors.outlineVariant
                      : colors.primary,
                  width: states.contains(WidgetState.focused)
                      ? AppDimensions.focusBorderWidth
                      : AppDimensions.borderWidth,
                );
              }),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          disabledForegroundColor: disabledForeground,
          minimumSize: const Size.square(AppDimensions.minTapTarget),
          shape: controlShape,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.surfaceContainer
              : colors.surfaceContainerLowest,
        ),
        contentPadding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        labelStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          final color = states.contains(WidgetState.error)
              ? colors.error
              : states.contains(WidgetState.focused)
              ? colors.primary
              : colors.onSurfaceVariant;
          return text.bodyMedium!.copyWith(color: color);
        }),
        hintStyle: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        helperStyle: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: colors.error),
        helperMaxLines: 3,
        errorMaxLines: 3,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colors.primary,
            width: AppDimensions.focusBorderWidth,
          ),
        ),
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colors.error,
            width: AppDimensions.focusBorderWidth,
          ),
        ),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        constraints: const BoxConstraints(
          minHeight: AppDimensions.controlMinHeight,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.raised,
        modalElevation: AppElevation.raised,
        showDragHandle: true,
        dragHandleColor: colors.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.raised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: AppDimensions.borderWidth,
        space: AppSpacing.xl,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primaryContainer,
        strokeWidth: AppDimensions.progressStroke,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.18),
        selectionHandleColor: colors.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        shape: controlShape,
      ),
    );
  }
}
