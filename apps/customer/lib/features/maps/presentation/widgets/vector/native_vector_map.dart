import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../map_feedback.dart';
import '../map_selection_cursor.dart';
import '../map_tap_feedback.dart';
import 'vector_camera.dart';
import 'vector_map_controls.dart';
import 'vector_map_scene.dart';
import 'vector_marker_images.dart';
import 'vector_scene_layers.dart';

/// Owns only a native rendering surface. Device location remains owned by the
/// existing foreground location service; MapLibre's location engine stays off.
class NativeVectorMap extends StatefulWidget {
  const NativeVectorMap({
    super.key,
    required this.style,
    required this.scene,
    required this.initialCenter,
    this.onSelected,
    this.bottomInset,
    this.onLocate,
    this.locating = false,
    this.markerImageLoader = VectorMarkerImages.load,
  });
  final String style;
  final VectorMapScene scene;
  final GeoPoint initialCenter;
  final ValueChanged<GeoPoint>? onSelected;
  final ValueListenable<double>? bottomInset;
  final VoidCallback? onLocate;
  final bool locating;
  final Future<Uint8List> Function(String, Color) markerImageLoader;
  @override
  State<NativeVectorMap> createState() => _NativeVectorMapState();
}

class _NativeVectorMapState extends State<NativeVectorMap>
    with WidgetsBindingObserver {
  MapLibreMapController? _controller;
  VectorSceneLayers? _layers;
  VectorMapScene? _drawn;
  late CameraPosition _camera;
  Timer? _deadline, _paddingTimer;
  Size _size = Size.zero;
  int _epoch = 0;
  bool _loading = true, _failed = false, _installed = false;
  bool _syncing = false, _dirty = false, _fitPending = true;
  bool _foreground = true;
  final _moving = ValueNotifier<bool>(false);
  final _tap = ValueNotifier<MapTap?>(null);
  final _appliedInset = ValueNotifier<double>(0);
  Offset? _pointerStart;
  int _tapId = 0;
  bool _cameraAnimating = false;
  EdgeInsets? _lastPadding;
  bool _selectionGesture = false, _focusSelectionPending = false;
  GeoPoint? _emittedSelection;
  bool get _picking =>
      widget.scene.selection != null && widget.onSelected != null;
  double get _inset => widget.bottomInset?.value ?? 0;
  bool _current(int epoch) => mounted && epoch == _epoch;

  @override
  void initState() {
    super.initState();
    final center =
        widget.scene.origin ?? widget.scene.destination ?? widget.initialCenter;
    _camera = CameraPosition(target: _latLng(center), zoom: 15);
    WidgetsBinding.instance.addObserver(this);
    widget.bottomInset?.addListener(_schedulePadding);
    _focusSelectionPending = _picking;
    _startDeadline();
  }

  void _startDeadline() {
    _deadline?.cancel();
    if (!_loading || !_foreground) return;
    _deadline = Timer(const Duration(seconds: 25), () {
      if (mounted && _loading) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _startDeadline();
      _schedulePadding();
      _queueSync();
    } else {
      _deadline?.cancel();
      _paddingTimer?.cancel();
      _paddingTimer = null;
    }
  }

  @override
  void didUpdateWidget(NativeVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottomInset != widget.bottomInset) {
      oldWidget.bottomInset?.removeListener(_schedulePadding);
      widget.bottomInset?.addListener(_schedulePadding);
      _schedulePadding();
    }
    if (oldWidget.style != widget.style) _reset();
    if (oldWidget.scene.selection != widget.scene.selection &&
        widget.scene.selection != _emittedSelection) {
      _focusSelectionPending = _picking;
    }
    if (!_picking) {
      _selectionGesture = false;
      _moving.value = false;
    }
    if (oldWidget.scene.origin != widget.scene.origin ||
        oldWidget.scene.destination != widget.scene.destination ||
        oldWidget.scene.route != widget.scene.route) {
      _fitPending = true;
    }
    if (oldWidget.scene != widget.scene) _queueSync();
  }

  void _reset() {
    _epoch++;
    _controller = null;
    _layers = null;
    _drawn = null;
    _installed = false;
    _lastPadding = null;
    _focusSelectionPending = _picking;
    _loading = true;
    _failed = false;
    _fitPending = true;
    _startDeadline();
  }

  Future<void> _onStyleLoaded(int epoch) async {
    final controller = _controller;
    if (!_current(epoch) || controller == null || _layers != null) return;
    final colors = Theme.of(context).colorScheme;
    final layers = VectorSceneLayers(
      controller,
      () => _current(epoch),
      colors.primary,
      colors.surfaceContainerLowest,
      loadMarker: widget.markerImageLoader,
    );
    _layers = layers;
    try {
      if (!await layers.install() || !_current(epoch)) return;
      _installed = true;
      await _applyPadding(epoch);
      _queueSync();
    } catch (_) {
      _showFailure(epoch);
    }
  }

  void _queueSync() {
    _dirty = true;
    if (_syncing || !_installed || !_foreground) return;
    unawaited(_synchronize());
  }

  Future<void> _synchronize() async {
    _syncing = true;
    final epoch = _epoch;
    try {
      while (_dirty && _current(epoch) && _installed && _foreground) {
        _dirty = false;
        final scene = widget.scene;
        if (_drawn != scene) {
          await _layers!.update(scene);
          if (!_current(epoch)) return;
          _drawn = scene;
        }
        if (_focusSelectionPending && _picking) {
          _focusSelectionPending = false;
          _fitPending = false;
          if (!_current(epoch)) return;
          final update = CameraUpdate.newLatLng(
            _latLng(widget.scene.selection!),
          );
          _cameraAnimating = true;
          _moving.value = true;
          try {
            if (MediaQuery.disableAnimationsOf(context)) {
              await _controller!.moveCamera(update);
            } else {
              await _controller!.animateCamera(
                update,
                duration: AppMotion.medium,
              );
            }
          } finally {
            _cameraAnimating = false;
            if (_current(epoch)) {
              _moving.value = false;
              await _applyPadding(epoch);
            }
          }
        }
        if (_fitPending && !_picking) {
          _fitPending = false;
          await _fit(epoch);
        }
      }
    } catch (_) {
      _showFailure(epoch);
    } finally {
      _syncing = false;
      if (mounted && _dirty && _installed && _foreground) _queueSync();
    }
  }

  Future<void> _fit(int epoch) async {
    if (!_current(epoch) || _controller == null) return;
    final update = VectorCamera.fit(widget.scene, _size, _inset);
    if (update != null) await _controller!.moveCamera(update);
  }

  // Debounce sheet geometry. Native padding is itself a camera operation:
  // sending it every few frames would cancel an in-flight selection animation.
  void _schedulePadding() {
    _paddingTimer?.cancel();
    if (!_foreground) return;
    _paddingTimer = Timer(AppMotion.short, () {
      _paddingTimer = null;
      unawaited(_applyPadding(_epoch));
    });
  }

  Future<void> _applyPadding(int epoch) async {
    if (!_current(epoch) || !_installed || _size.isEmpty || _cameraAnimating)
      return;
    try {
      final bottom = _inset.clamp(0.0, math.max(0.0, _size.height - 160));
      final padding = EdgeInsets.fromLTRB(0, 80, 0, bottom.toDouble());
      if (padding == _lastPadding) return;
      _lastPadding = padding;
      _appliedInset.value = bottom.toDouble();
      await _controller!.updateContentInsets(
        padding,
        !_loading && !MediaQuery.disableAnimationsOf(context),
      );
    } catch (_) {
      _showFailure(epoch);
    }
  }

  void _showFailure(int epoch) {
    if (!_current(epoch)) return;
    _deadline?.cancel();
    setState(() {
      _failed = true;
      _loading = false;
    });
  }

  void _onIdle(int epoch) {
    if (!_current(epoch) || !_installed) return;
    if (_loading) {
      _deadline?.cancel();
      setState(() {
        _loading = false;
        _failed = false;
      });
    }
    _moving.value = false;
    if (_picking && _selectionGesture) {
      _selectionGesture = false;
      final target = _camera.target;
      final point = GeoPoint(
        latitude: target.latitude,
        longitude: target.longitude,
      );
      _emittedSelection = point;
      widget.onSelected?.call(point);
    }
  }

  @override
  void dispose() {
    _epoch++;
    _moving.dispose();
    _tap.dispose();
    _appliedInset.dispose();
    _deadline?.cancel();
    _paddingTimer?.cancel();
    widget.bottomInset?.removeListener(_schedulePadding);
    WidgetsBinding.instance.removeObserver(this);
    // MapLibreMap owns its platform view and controller disposal.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epoch = _epoch;
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, bounds) {
        if (_size != bounds.biggest) {
          _size = bounds.biggest;
          _schedulePadding();
        }
        return AnimatedBuilder(
          animation:
              widget.bottomInset ?? const AlwaysStoppedAnimation<double>(0),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => _pointerStart = event.localPosition,
            onPointerMove: (event) {
              final start = _pointerStart;
              if (_picking &&
                  start != null &&
                  (event.localPosition - start).distance > 12) {
                _selectionGesture = true;
                _moving.value = true;
              }
            },
            child: MapLibreMap(
              key: ValueKey('vector-map-$epoch'),
              initialCameraPosition: _camera,
              styleString: widget.style,
              annotationOrder: const [],
              myLocationEnabled: false,
              trackCameraPosition: true,
              tiltGesturesEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(3, 19),
              compassEnabled: false,
              attributionButtonColor: Theme.of(context).colorScheme.primary,
              attributionButtonPosition: AttributionButtonPosition.topRight,
              attributionButtonMargins: const math.Point(12, 100),
              onMapCreated: (controller) {
                if (_current(epoch)) _controller = controller;
              },
              onStyleLoadedCallback: () => unawaited(_onStyleLoaded(epoch)),
              onMapIdle: () => _onIdle(epoch),
              onCameraMove: (camera) {
                if (_current(epoch)) _camera = camera;
              },
              onMapClick: (screen, point) {
                if (widget.onSelected == null) return;
                _selectionGesture = false;
                final ratio = defaultTargetPlatform == TargetPlatform.android
                    ? MediaQuery.devicePixelRatioOf(context)
                    : 1;
                _tap.value = (
                  point: Offset(screen.x / ratio, screen.y / ratio),
                  id: ++_tapId,
                );
                widget.onSelected!(
                  GeoPoint(
                    latitude: point.latitude,
                    longitude: point.longitude,
                  ),
                );
              },
            ),
          ),
          builder: (context, map) => Stack(
            fit: StackFit.expand,
            children: [
              map!,
              MapTapFeedback(tap: _tap),
              if (_picking && !_loading && !_failed)
                ValueListenableBuilder<double>(
                  valueListenable: _appliedInset,
                  builder: (context, inset, _) => MapSelectionCursor(
                    anchor: Offset(
                      _size.width / 2,
                      (80 + _size.height - inset) / 2,
                    ),
                    moving: _moving,
                  ),
                ),
              if (_loading)
                const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(),
                ),
              if (_failed)
                Positioned(
                  top: 88,
                  left: 8,
                  right: 8,
                  child: MapFeedback(
                    text: l.mapsTilesFailed,
                    onRetry: () => setState(_reset),
                  ),
                ),
              if (_size.height - _inset >= 220)
                VectorMapControls(
                  bottomInset: _inset,
                  onLocate: widget.onLocate,
                  locating: widget.locating,
                ),
            ],
          ),
        );
      },
    );
  }

  static LatLng _latLng(GeoPoint point) =>
      LatLng(point.latitude.clamp(-85.0511, 85.0511), point.longitude);
}
