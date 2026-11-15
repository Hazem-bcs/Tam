import 'dart:async';

import 'package:tam_customer/shared/domain/geo_point.dart';

import 'location_fix.dart';
import 'maps_repository.dart';

/// One location owner per app session. No persistence, uploads or OS background
/// tracking. Every consumer rechecks access and freshness before using a fix.
final class ForegroundLocation implements DeviceLocation {
  ForegroundLocation({
    required this.sensor,
    required this.policy,
    DateTime Function()? now,
    Duration Function()? elapsed,
  }) : _now = now ?? DateTime.now,
       _elapsed = elapsed ?? (Stopwatch()..start()).elapsedGetter;

  final LocationSensor sensor;
  final LocationPolicy policy;
  final DateTime Function() _now;
  final Duration Function() _elapsed;
  StreamSubscription<LocationFix>? _positions;
  StreamSubscription<bool>? _service;
  Future<void> _stopping = Future.value();
  Future<GeoPoint>? _pending;
  LocationFix? _fix;
  Duration? _received;
  DateTime? _lastObservedAt;
  int _epoch = 0;
  bool _session = false, _foreground = true, _disposed = false;
  bool get _active => _session && _foreground && !_disposed;

  void setSession(bool entered) {
    if (_session == entered || _disposed) return;
    _session = entered;
    _invalidate();
    if (_active) _warm(requestPermission: true);
  }

  void setForeground(bool foreground) {
    if (_foreground == foreground || _disposed) return;
    _foreground = foreground;
    _invalidate();
    if (_active) _warm(requestPermission: false);
  }

  void _warm({required bool requestPermission}) {
    unawaited(
      _locate(
        requestPermission: requestPermission,
      ).then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
  }

  @override
  Future<GeoPoint> locate({bool requireFresh = false}) async {
    if (requireFresh && _pending != null) {
      final epoch = _epoch;
      try {
        await _pending;
      } catch (_) {
        /* Fresh acquisition still follows. */
      }
      _check(epoch);
    }
    return _locate(requestPermission: true, requireFresh: requireFresh);
  }

  Future<GeoPoint> _locate({
    required bool requestPermission,
    bool requireFresh = false,
  }) {
    if (!_active) {
      return Future.error(const MapsFailure('LOCATION_UNAVAILABLE'));
    }
    if (_pending != null) return _pending!;
    final epoch = _epoch;
    final future = _acquire(epoch, requestPermission, requireFresh);
    _pending = future;
    // The original future remains observable by the caller; the cleanup branch
    // handles both outcomes so a warm-up error never becomes unhandled.
    unawaited(
      future.then<void>(
        (_) {
          if (epoch == _epoch) _pending = null;
        },
        onError: (Object _, StackTrace _) {
          if (epoch == _epoch) _pending = null;
        },
      ),
    );
    return future;
  }

  void _check(int epoch) {
    if (!_active || epoch != _epoch) {
      throw const MapsFailure('LOCATION_UNAVAILABLE');
    }
  }

  Future<GeoPoint> _acquire(
    int epoch,
    bool requestPermission,
    bool requireFresh,
  ) async {
    try {
      await _stopping;
      _check(epoch);
      await sensor.checkAccess(requestPermission: requestPermission);
      _check(epoch);
      _watch(epoch);
      final fix = _fix;
      final received = _received;
      if (!requireFresh &&
          fix != null &&
          received != null &&
          policy.accepts(fix, _now()) &&
          _elapsed() - received >= Duration.zero &&
          _elapsed() - received <= policy.maximumAge) {
        return fix.point;
      }
      _fix = null;
      _received = null;
      if (_lastObservedAt?.isAfter(_now()) ?? false) _lastObservedAt = null;
      final observation = await sensor.read().timeout(policy.fixTimeout);
      _check(epoch);
      _accept(observation);
      final latest = _fix;
      if (latest == null ||
          !policy.accepts(latest, _now(), verification: requireFresh)) {
        throw const MapsFailure('LOCATION_INACCURATE');
      }
      return latest.point;
    } catch (error) {
      if (epoch == _epoch) {
        _fix = null;
        _received = null;
        if (error is MapsFailure &&
            const [
              'LOCATION_DISABLED',
              'LOCATION_DENIED',
              'LOCATION_DENIED_FOREVER',
            ].contains(error.code)) {
          _stopPositions();
        }
      }
      if (error is MapsFailure) rethrow;
      throw const MapsFailure('LOCATION_UNAVAILABLE');
    }
  }

  void _accept(LocationFix observation) {
    if (_lastObservedAt != null &&
        observation.capturedAt.isBefore(_lastObservedAt!)) {
      return;
    }
    if (observation.capturedAt.isAfter(_now())) return;
    _lastObservedAt = observation.capturedAt;
    if (!policy.accepts(observation, _now())) {
      // A newer, imprecise observation must not leave an older precise fix
      // masquerading as the user's current position.
      _fix = null;
      _received = null;
      return;
    }
    if (_fix != null &&
        observation.capturedAt == _fix!.capturedAt &&
        observation.accuracyMeters >= _fix!.accuracyMeters) {
      return;
    }
    _fix = observation;
    _received = _elapsed();
  }

  void _watch(int epoch) {
    _service ??= sensor.watchService().listen(
      (enabled) {
        if (!_active) return;
        _invalidate(keepService: true);
        if (enabled) _warm(requestPermission: false);
      },
      onError: (Object _) {
        // Some platforms cannot observe service changes. Access is still checked
        // on every locate and on foreground resume; never trust cache alone.
      },
    );
    _positions ??= sensor.watch().listen(
      (fix) {
        if (_active && epoch == _epoch) _accept(fix);
      },
      onError: (Object _) {
        if (epoch != _epoch) return;
        _fix = null;
        _received = null;
        _stopPositions();
      },
      onDone: () {
        if (epoch == _epoch) _positions = null;
      },
    );
  }

  void _stopPositions() {
    final positions = _positions;
    _positions = null;
    _stopping = Future.wait([
      _stopping,
      if (positions != null) positions.cancel(),
    ]);
  }

  void _invalidate({bool keepService = false}) {
    _epoch++;
    _pending = null;
    _fix = null;
    _received = null;
    _lastObservedAt = null;
    _stopPositions();
    if (keepService) return;
    final service = _service;
    _service = null;
    _stopping = Future.wait([_stopping, if (service != null) service.cancel()]);
  }

  Future<void> dispose() async {
    _disposed = true;
    _invalidate();
    await _stopping;
  }
}

extension on Stopwatch {
  Duration elapsedGetter() => elapsed;
}
