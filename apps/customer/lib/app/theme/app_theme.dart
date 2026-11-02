import 'package:flutter/material.dart';

/// Provisional theme tokens; the visual design is intentionally not finalized.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF247D79)),
  );
}
