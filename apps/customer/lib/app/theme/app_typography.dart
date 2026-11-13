import 'package:flutter/material.dart';

/// Native platform fonts/fallbacks shape Arabic and Latin without a font package.
/// No tracking is added to Arabic, and the user's text scale is never capped.
abstract final class AppTypography {
  /// Bundled, OFL-licensed Arabic sans. This does not affect other pages.
  static TextTheme home(TextTheme ambient) {
    final text = ambient.apply(
      fontFamily: 'TamSansArabic',
      fontFamilyFallback: const ['TamSansLatin'],
    );
    return text.copyWith(
      displayLarge: text.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: text.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  /// A quieter, denser scale for the five-stage ride journey.
  static TextTheme rideJourney(TextTheme ambient) {
    final text = home(ambient);
    return text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: text.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12),
      labelLarge: text.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: text.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: text.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.4,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.4,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.4,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
  );
}
