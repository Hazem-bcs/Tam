import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const pagePadding = EdgeInsetsDirectional.symmetric(
    horizontal: xl,
    vertical: lg,
  );
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double sheet = 24;
}

abstract final class AppDimensions {
  // Minimums, not fixed heights: controls grow with wrapped/scaled text.
  static const double minTapTarget = 48;
  static const double controlMinHeight = 52;
  static const double iconSize = 24;
  static const double progressSize = 24;
  static const double buttonProgressSize = 20;
  static const double progressStroke = 2.5;
  static const double borderWidth = 1;
  static const double focusBorderWidth = 2;
}

/// Prefer borders to shadows. Use Material elevation for raised surfaces.
abstract final class AppElevation {
  static const double flat = 0;
  static const double raised = 1;
}
