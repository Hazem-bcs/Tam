import 'package:flutter/material.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

/// Visual interpolation only. Never predicts beyond the last received fix.
class DriverMapMotion extends StatefulWidget {
  const DriverMapMotion({
    super.key,
    required this.point,
    this.bearing,
    this.recordedAt,
    this.path = const [],
    this.identity,
    required this.builder,
  });
  final GeoPoint? point;
  final double? bearing;
  final DateTime? recordedAt;
  final List<GeoPoint> path;
  final Object? identity;
  final Widget Function(GeoPoint?, double) builder;
  @override
  State<DriverMapMotion> createState() => _DriverMapMotionState();
}

class _DriverMapMotionState extends State<DriverMapMotion>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animation = AnimationController(vsync: this)
    ..addListener(_frame);
  GeoPoint? _from, _to;
  double _fromBearing = 0, _toBearing = 0;
  GeoPath? _path;
  double _start = 0, _end = 0;
  DateTime? _acceptedAt;
  Duration _lastFrame = Duration.zero;
  bool _foreground = true;
  double get _t => _animation.value;
  GeoPoint? get _point => _to == null
      ? null
      : _from == null
      ? _to
      : _path != null
      ? _path!.at(_start + (_end - _start) * _t)
      : GeoPath.mix(_from!, _to!, _t);
  double get _bearing => _path != null && (_end - _start).abs() > 1
      ? _path!.headingAt(_start + (_end - _start) * _t)
      : GeoPath.turn(_fromBearing, _toBearing, _t);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _from = _to = widget.point;
    final initialPath = widget.path.length >= 2 ? GeoPath(widget.path) : null;
    _fromBearing = _toBearing =
        widget.bearing ??
        (initialPath != null && widget.point != null
            ? initialPath.headingAt(initialPath.project(widget.point!).distance)
            : 0);
    _acceptedAt = widget.recordedAt;
    _animation.value = 1;
  }

  void _frame() {
    final elapsed = _animation.lastElapsedDuration ?? Duration.zero;
    if (_animation.value == 1 ||
        elapsed - _lastFrame >= const Duration(milliseconds: 33)) {
      _lastFrame = elapsed;
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 1;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    // Catch up at a fix; never replay motion accumulated in the background.
    _animation.stop();
    _animation.value = 1;
  }

  @override
  void didUpdateWidget(DriverMapMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.point == oldWidget.point &&
        widget.bearing == oldWidget.bearing &&
        widget.identity == oldWidget.identity) {
      return;
    }
    final stamp = widget.recordedAt;
    final sameIdentity = widget.identity == oldWidget.identity;
    if (widget.point != null &&
        sameIdentity &&
        stamp != null &&
        _acceptedAt != null &&
        stamp.isBefore(_acceptedAt!)) {
      return;
    }
    final current = _point;
    final angle = _bearing;
    final interval = stamp != null && _acceptedAt != null
        ? stamp.difference(_acceptedAt!).inMilliseconds
        : 1000;
    _acceptedAt = stamp;
    _animation.stop();
    _from = current;
    _to = widget.point;
    _fromBearing = angle;
    _toBearing =
        widget.bearing ??
        (current != null &&
                widget.point != null &&
                GeoPath.meters(current, widget.point!) > 1
            ? GeoPath.bearing(current, widget.point!)
            : angle);
    _path = null;
    final distance = current == null || widget.point == null
        ? 0.0
        : GeoPath.meters(current, widget.point!);
    if (sameIdentity &&
        current != null &&
        widget.point != null &&
        distance < .8) {
      _from = _to = current;
      _toBearing = angle;
      _animation.value = 1;
      return;
    }
    final maxTravel = (interval / 1000 * 80 + 50).clamp(100.0, 1000.0);
    var discontinuity =
        distance > maxTravel || interval > 10000 || interval <= 0;
    if (widget.path.length >= 2 && current != null && widget.point != null) {
      final path = GeoPath(widget.path);
      final a = path.project(current), b = path.project(widget.point!);
      if (a.error < 45 && b.error < 45 && b.distance >= a.distance - 3) {
        _path = path;
        _start = a.distance;
        _end = b.distance;
        discontinuity = discontinuity || (_end - _start).abs() > maxTravel;
      }
    }
    _lastFrame = Duration.zero;
    if (!sameIdentity ||
        discontinuity ||
        current == null ||
        widget.point == null ||
        !_foreground ||
        MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      _animation.duration = Duration(milliseconds: interval.clamp(250, 5000));
      _animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_point, _bearing);
}
