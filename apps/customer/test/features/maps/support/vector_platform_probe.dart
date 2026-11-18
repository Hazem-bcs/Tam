import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Native boundary fake. It never renders or requests public tiles.
class VectorPlatformProbe extends MapLibrePlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final installed = Completer<void>();
  final scenes = <Map<String, dynamic>>[];
  final insets = <EdgeInsets>[];
  final cameras = <CameraUpdate>[];
  int images = 0, disposed = 0;
  final imageNames = <String>[];
  final symbolLayers = <String, Map<String, dynamic>>{};
  final animations = <Duration?>[];
  Future<bool?> Function()? onAnimate;
  bool _created = false;
  bool failUpdates = false;

  @override
  Widget buildView(
    Map<String, dynamic> params,
    void Function(int) onCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestures,
  ) {
    if (!_created) {
      _created = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => onCreated(1));
    }
    return const SizedBox.expand();
  }

  @override
  Future<void> initPlatform(int id) async {}
  @override
  Future<CameraPosition?> updateMapOptions(
    Map<String, dynamic> updates,
  ) async => null;
  @override
  Future<void> addImage(
    String name,
    Uint8List bytes, [
    bool sdf = false,
  ]) async {
    images++;
    imageNames.add(name);
  }

  @override
  Future<void> addGeoJsonSource(
    String id,
    Map<String, dynamic> json, {
    String? promoteId,
  }) async {}
  @override
  Future<void> setGeoJsonSource(String id, Map<String, dynamic> json) async {
    if (failUpdates) throw StateError('Native update failed');
    scenes.add(json);
  }

  @override
  Future<void> addLineLayer(
    String sourceId,
    String layerId,
    Map<String, dynamic> properties, {
    String? belowLayerId,
    String? sourceLayer,
    double? minzoom,
    double? maxzoom,
    dynamic filter,
    required bool enableInteraction,
  }) async {}
  @override
  Future<void> addCircleLayer(
    String sourceId,
    String layerId,
    Map<String, dynamic> properties, {
    String? belowLayerId,
    String? sourceLayer,
    double? minzoom,
    double? maxzoom,
    dynamic filter,
    required bool enableInteraction,
  }) async {}
  @override
  Future<void> addSymbolLayer(
    String sourceId,
    String layerId,
    Map<String, dynamic> properties, {
    String? belowLayerId,
    String? sourceLayer,
    double? minzoom,
    double? maxzoom,
    dynamic filter,
    required bool enableInteraction,
  }) async {
    symbolLayers[layerId] = properties;
    if (layerId == 'tam-driver' && !installed.isCompleted) installed.complete();
  }

  LatLng projectedPoint = const LatLng(33.63, 36.4);
  Point projectedScreen = const Point(400.0, 300.0);
  Point? lastInverseProjection;
  @override
  Future<LatLng> toLatLng(Point point) async {
    lastInverseProjection = point;
    return projectedPoint;
  }

  @override
  Future<Point> toScreenLocation(LatLng point) async => projectedScreen;

  @override
  Future<void> updateContentInsets(EdgeInsets padding, bool animated) async {
    insets.add(padding);
  }

  @override
  Future<bool?> moveCamera(CameraUpdate update) async {
    cameras.add(update);
    return true;
  }

  @override
  Future<bool?> animateCamera(CameraUpdate update, {Duration? duration}) async {
    cameras.add(update);
    animations.add(duration);
    return onAnimate == null ? true : await onAnimate!();
  }

  @override
  void dispose() {
    disposed++;
    super.dispose();
  }
}
