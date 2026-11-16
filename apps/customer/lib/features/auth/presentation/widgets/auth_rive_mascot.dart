import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

/// Interactive TAM mascot: Rive owns its autonomous idle and blinking.
/// Flutter only sends auth state and the text caret position.
/// No camera, pointer tracking, video, or raster fallback is involved.
class AuthRiveMascot extends StatefulWidget {
  const AuthRiveMascot({
    super.key,
    required this.size,
    this.inputFocused = false,
    this.gazeProgress = 0,
    this.busy = false,
    this.hasError = false,
    this.otpStage = false,
    this.success = false,
    this.reduceMotion = false,
  });

  final double size;
  final bool inputFocused;
  final double gazeProgress;
  final bool busy;
  final bool hasError;
  final bool otpStage;
  final bool success;
  final bool reduceMotion;

  @override
  State<AuthRiveMascot> createState() => _AuthRiveMascotState();
}

class _AuthRiveMascotState extends State<AuthRiveMascot>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _asset = 'assets/animations/tam_mascot_auth.riv';

  late final rive.FileLoader _loader = rive.FileLoader.fromAsset(
    _asset,
    riveFactory: rive.Factory.flutter,
  );

  /// Only animates in response to caret changes, never continuously.
  late final AnimationController _lookEasing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lookEasing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(_tickLook);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeVisible = TickerMode.valuesOf(context).enabled;
    _syncPlayback();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  void _syncPlayback() {
    final controller = _riveController;
    final shouldPlay = _appVisible && _routeVisible && !widget.reduceMotion;
    if (controller != null && controller.active != shouldPlay) {
      controller.active = shouldPlay;
    }
    if (!shouldPlay) _lookEasing.stop();
  }

  rive.ViewModelInstance? _model;
  rive.ViewModelInstanceNumber? _gazeX;
  rive.ViewModelInstanceNumber? _gazeY;
  rive.RiveWidgetController? _riveController;
  bool _appVisible = true;
  bool _routeVisible = true;

  double _fromX = 0;
  double _fromY = 0;
  double _targetX = 0;
  double _targetY = 0;
  double _currentX = 0;
  double _currentY = 0;

  void _writeLookValues() {
    // Cache native property handles: per-frame name lookups are unnecessary.
    _gazeX?.value = _currentX;
    _gazeY?.value = _currentY;
  }

  void _tickLook() {
    final t = Curves.easeInOutCubic.transform(_lookEasing.value);
    _currentX = _fromX + (_targetX - _fromX) * t;
    _currentY = _fromY + (_targetY - _fromY) * t;
    _writeLookValues();
  }

  void _animateLookTo(double x, double y) {
    if ((_targetX - x).abs() < 0.02 && (_targetY - y).abs() < 0.02) {
      return;
    }
    _fromX = _currentX;
    _fromY = _currentY;
    _targetX = x;
    _targetY = y;
    if (widget.reduceMotion || !_appVisible || !_routeVisible) {
      _lookEasing.stop();
      _currentX = x;
      _currentY = y;
      _writeLookValues();
      return;
    }
    _lookEasing.forward(from: 0);
  }

  void _onLoaded(rive.RiveLoaded state) {
    _model = state.viewModelInstance;
    _gazeX = _model?.number('gazeX');
    _gazeY = _model?.number('gazeY');
    _riveController = state.controller;
    _syncInputs();
  }

  void _syncInputs() {
    final model = _model;
    if (model == null) return;
    final focused = widget.inputFocused && !widget.busy && !widget.hasError;

    model.boolean('phoneFocused')?.value = focused;
    model.boolean('waiting')?.value = widget.busy;
    model.boolean('hasError')?.value = widget.hasError;
    model.boolean('otpStage')?.value = widget.otpStage;
    model.boolean('success')?.value = widget.success;

    if (focused) {
      final caret = widget.gazeProgress.clamp(0.0, 1.0).toDouble();
      // Source-space movement, kept within both eyes' clipping contours.
      // The LTR number progresses from left to right, capped at 9 digits.
      _animateLookTo(-9 + 18 * caret, 12);
    } else {
      // Release the gaze back to Rive's autonomous idle and eye contact.
      _animateLookTo(0, 0);
    }

    // Pause fully when this route is hidden or the app goes to background.
    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant AuthRiveMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputFocused != oldWidget.inputFocused ||
        widget.gazeProgress != oldWidget.gazeProgress ||
        widget.busy != oldWidget.busy ||
        widget.hasError != oldWidget.hasError ||
        widget.otpStage != oldWidget.otpStage ||
        widget.success != oldWidget.success ||
        widget.reduceMotion != oldWidget.reduceMotion) {
      _syncInputs();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lookEasing.dispose();
    // RiveWidgetBuilder owns its controller and bound view model.
    _gazeX = null;
    _gazeY = null;
    _model = null;
    _riveController = null;
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: const Key('auth-tam-mascot'),
      dimension: widget.size,
      child: rive.RiveWidgetBuilder(
        fileLoader: _loader,
        dataBind: rive.DataBind.auto(),
        onLoaded: _onLoaded,
        builder: (context, state) => switch (state) {
          rive.RiveLoaded() => rive.RiveWidget(
            controller: state.controller,
            fit: rive.Fit.contain,
            // All gestures belong to the Flutter form, not to the mascot.
            hitTestBehavior: rive.RiveHitTestBehavior.none,
          ),
          rive.RiveLoading() => const SizedBox.shrink(),
          rive.RiveFailed() => Builder(
            builder: (context) {
              debugPrint(
                'Unable to load TAM mascot Rive asset: ${state.error}',
              );
              return Center(
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.primary,
                  semanticLabel: 'Mascot animation unavailable',
                ),
              );
            },
          ),
        },
      ),
    );
  }
}
