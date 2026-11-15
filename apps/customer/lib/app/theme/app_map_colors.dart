import 'package:flutter/material.dart';

/// Semantic cartography roles; scenes read the ambient extension.
@immutable
class AppMapColors extends ThemeExtension<AppMapColors> {
  const AppMapColors({
    required this.land,
    required this.building,
    required this.buildingOutline,
    required this.road,
    required this.roadCasing,
    required this.majorRoad,
    required this.water,
    required this.green,
    required this.text,
    required this.secondaryText,
  });
  final Color land;
  final Color building;
  final Color buildingOutline;
  final Color road;
  final Color roadCasing;
  final Color majorRoad;
  final Color water;
  final Color green;
  final Color text;
  final Color secondaryText;

  @override
  AppMapColors copyWith({
    Color? land,
    Color? building,
    Color? buildingOutline,
    Color? road,
    Color? roadCasing,
    Color? majorRoad,
    Color? water,
    Color? green,
    Color? text,
    Color? secondaryText,
  }) => AppMapColors(
    land: land ?? this.land,
    building: building ?? this.building,
    buildingOutline: buildingOutline ?? this.buildingOutline,
    road: road ?? this.road,
    roadCasing: roadCasing ?? this.roadCasing,
    majorRoad: majorRoad ?? this.majorRoad,
    water: water ?? this.water,
    green: green ?? this.green,
    text: text ?? this.text,
    secondaryText: secondaryText ?? this.secondaryText,
  );

  @override
  AppMapColors lerp(covariant AppMapColors? other, double t) {
    if (other == null) return this;
    return AppMapColors(
      land: Color.lerp(land, other.land, t)!,
      building: Color.lerp(building, other.building, t)!,
      buildingOutline: Color.lerp(buildingOutline, other.buildingOutline, t)!,
      road: Color.lerp(road, other.road, t)!,
      roadCasing: Color.lerp(roadCasing, other.roadCasing, t)!,
      majorRoad: Color.lerp(majorRoad, other.majorRoad, t)!,
      water: Color.lerp(water, other.water, t)!,
      green: Color.lerp(green, other.green, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
    );
  }
}
