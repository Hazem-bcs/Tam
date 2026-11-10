import 'package:flutter/widgets.dart';
import '../maps_dependencies.dart';

class MapsScope extends InheritedWidget {
  const MapsScope({
    super.key,
    required this.dependencies,
    required super.child,
  });
  final MapsDependencies dependencies;
  static MapsDependencies? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapsScope>()?.dependencies;
  @override
  bool updateShouldNotify(MapsScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
