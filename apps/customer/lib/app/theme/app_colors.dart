import 'package:flutter/material.dart';

/// Palette definitions belong here; widgets consume the ambient ColorScheme.
abstract final class AppColors {
  static const light = ColorScheme.light(
    primary: Color(0xFF8D153A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFCE7EE),
    onPrimaryContainer: Color(0xFF4A0A21),
    primaryFixed: Color(0xFFFCE7EE),
    primaryFixedDim: Color(0xFFF3B5C9),
    onPrimaryFixed: Color(0xFF4A0A21),
    onPrimaryFixedVariant: Color(0xFF70102F),
    secondary: Color(0xFF715361),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3E4EB),
    onSecondaryContainer: Color(0xFF2C1721),
    secondaryFixed: Color(0xFFF3E4EB),
    secondaryFixedDim: Color(0xFFD9BFCC),
    onSecondaryFixed: Color(0xFF2C1721),
    onSecondaryFixedVariant: Color(0xFF59404C),
    tertiary: Color(0xFF625775),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFEDE3F8),
    onTertiaryContainer: Color(0xFF281B3A),
    tertiaryFixed: Color(0xFFEDE3F8),
    tertiaryFixedDim: Color(0xFFCFC0E1),
    onTertiaryFixed: Color(0xFF281B3A),
    onTertiaryFixedVariant: Color(0xFF4A3F5C),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFCF8F9),
    onSurface: Color(0xFF241A1E),
    onSurfaceVariant: Color(0xFF66535B),
    surfaceDim: Color(0xFFE5D8DE),
    surfaceBright: Color(0xFFFCF8F9),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFCF2F5),
    surfaceContainer: Color(0xFFF7EAEE),
    surfaceContainerHigh: Color(0xFFF0E2E6),
    surfaceContainerHighest: Color(0xFFEBDCE1),
    outline: Color(0xFF8C737B),
    outlineVariant: Color(0xFFE4D5DA),
    shadow: Color(0xFF241A1E),
    scrim: Color(0xFF241A1E),
    inverseSurface: Color(0xFF392D33),
    onInverseSurface: Color(0xFFFCEFF4),
    inversePrimary: Color(0xFFFFB1CA),
    surfaceTint: Color(0xFF8D153A),
  );

  static const lightStatus = AppStatusColors(
    success: Color(0xFF22643D),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFE5F4E9),
    onSuccessContainer: Color(0xFF143D24),
    warning: Color(0xFF795800),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF1C7),
    onWarningContainer: Color(0xFF4D3900),
  );
}

/// Success and warning are not represented by Material's ColorScheme.
/// Pair a status color with an icon and localized text, never color alone.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) => AppStatusColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
  );

  @override
  AppStatusColors lerp(covariant AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
    );
  }
}
