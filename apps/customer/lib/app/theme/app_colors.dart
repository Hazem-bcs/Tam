import 'package:flutter/material.dart';
import 'app_map_colors.dart';

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

  static const dark = ColorScheme.dark(
    primary: Color(0xFFFFB1CA),
    onPrimary: Color(0xFF570D29),
    primaryContainer: Color(0xFF741035),
    onPrimaryContainer: Color(0xFFFFD9E5),
    primaryFixed: Color(0xFFFCE7EE),
    primaryFixedDim: Color(0xFFF3B5C9),
    onPrimaryFixed: Color(0xFF4A0A21),
    onPrimaryFixedVariant: Color(0xFF70102F),
    secondary: Color(0xFFDFBECD),
    onSecondary: Color(0xFF402B35),
    secondaryContainer: Color(0xFF58414C),
    onSecondaryContainer: Color(0xFFFBD9E8),
    secondaryFixed: Color(0xFFF3E4EB),
    secondaryFixedDim: Color(0xFFD9BFCC),
    onSecondaryFixed: Color(0xFF2C1721),
    onSecondaryFixedVariant: Color(0xFF59404C),
    tertiary: Color(0xFFD3BFE8),
    onTertiary: Color(0xFF382A49),
    tertiaryContainer: Color(0xFF504060),
    onTertiaryContainer: Color(0xFFEEDBFF),
    tertiaryFixed: Color(0xFFEDE3F8),
    tertiaryFixedDim: Color(0xFFCFC0E1),
    onTertiaryFixed: Color(0xFF281B3A),
    onTertiaryFixedVariant: Color(0xFF4A3F5C),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF191216),
    onSurface: Color(0xFFF0DFE5),
    onSurfaceVariant: Color(0xFFD4BFC8),
    surfaceDim: Color(0xFF191216),
    surfaceBright: Color(0xFF40363C),
    surfaceContainerLowest: Color(0xFF130D10),
    surfaceContainerLow: Color(0xFF221A1F),
    surfaceContainer: Color(0xFF271E23),
    surfaceContainerHigh: Color(0xFF32282E),
    surfaceContainerHighest: Color(0xFF3D3339),
    outline: Color(0xFFA48D97),
    outlineVariant: Color(0xFF55424B),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF0DFE5),
    onInverseSurface: Color(0xFF382D33),
    inversePrimary: Color(0xFF8D153A),
    surfaceTint: Color(0xFFFFB1CA),
  );

  static final homeDark = dark.copyWith(
    primary: const Color(0xFFC8C1FF),
    onPrimary: const Color(0xFF29215C),
    primaryContainer: const Color(0xFF40378D),
    onPrimaryContainer: const Color(0xFFE8E2FF),
    secondary: const Color(0xFFC2D58F),
    onSecondary: const Color(0xFF29350F),
    secondaryContainer: const Color(0xFF3E4C22),
    onSecondaryContainer: const Color(0xFFDFEEAA),
    surface: const Color(0xFF15141D),
    onSurface: const Color(0xFFE8E2F2),
    onSurfaceVariant: const Color(0xFFCAC3D7),
    surfaceContainerLowest: const Color(0xFF100F17),
    surfaceContainerLow: const Color(0xFF1E1D27),
    surfaceContainer: const Color(0xFF24222D),
    surfaceContainerHigh: const Color(0xFF2F2D38),
    surfaceContainerHighest: const Color(0xFF3B3844),
    outline: const Color(0xFF9690A3),
    outlineVariant: const Color(0xFF494452),
  );

  static const darkStatus = AppStatusColors(
    success: Color(0xFF9DD6AE),
    onSuccess: Color(0xFF07391B),
    successContainer: Color(0xFF174F2B),
    onSuccessContainer: Color(0xFFBAF3C8),
    warning: Color(0xFFE9C36A),
    onWarning: Color(0xFF402E00),
    warningContainer: Color(0xFF5C4300),
    onWarningContainer: Color(0xFFFFDFA1),
  );

  /// Opt-in Fluid Editorial palette. Installed by Home only.
  static final home = light.copyWith(
    primary: const Color(0xFF5145CD),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFEAE6FF),
    onPrimaryContainer: const Color(0xFF29215E),
    secondary: const Color(0xFF454D2B),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFDFEEAA),
    onSecondaryContainer: const Color(0xFF242D12),
    tertiary: const Color(0xFF5145CD),
    tertiaryContainer: const Color(0xFFEAE6FF),
    onTertiaryContainer: const Color(0xFF29215E),
    surface: const Color(0xFFF5F4EF),
    onSurface: const Color(0xFF24233B),
    onSurfaceVariant: const Color(0xFF5F5C70),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF0EEE8),
    surfaceContainer: const Color(0xFFEAE8E3),
    surfaceContainerHigh: const Color(0xFFE5E2DC),
    surfaceContainerHighest: const Color(0xFFDEDBD5),
    outline: const Color(0xFF777381),
    outlineVariant: const Color(0xFFD9D6DF),
    inverseSurface: const Color(0xFF24233B),
    onInverseSurface: const Color(0xFFF5F4EF),
    inversePrimary: const Color(0xFFC8C1FF),
    surfaceTint: const Color(0xFF5145CD),
  );

  static const mapLight = AppMapColors(
    land: Color(0xFFF0F2F2),
    building: Color(0xFFDFE4E6),
    buildingOutline: Color(0xFFD0D7DA),
    road: Color(0xFFFFFFFF),
    roadCasing: Color(0xFFD8DEE1),
    majorRoad: Color(0xFFFAFBFC),
    water: Color(0xFFD5E6EF),
    green: Color(0xFFE3EBE2),
    text: Color(0xFF34434B),
    secondaryText: Color(0xFF667680),
  );

  static const mapDark = AppMapColors(
    land: Color(0xFF182023),
    building: Color(0xFF303B42),
    buildingOutline: Color(0xFF354149),
    road: Color(0xFF44515A),
    roadCasing: Color(0xFF222D33),
    majorRoad: Color(0xFF53636D),
    water: Color(0xFF213D49),
    green: Color(0xFF243C31),
    text: Color(0xFFE2E9EC),
    secondaryText: Color(0xFFA5B3BB),
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
