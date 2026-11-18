import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// One notice can move between scaffolds. Its display clock must not restart.
/// This local, timer-free object expires with the native SnackBar's content.
final class SnackBarLifetime extends ChangeNotifier {
  SnackBarLifetime({required this.duration, required this.persistent});
  final Duration duration;
  final bool persistent;
  Duration? _startedAt;
  bool _closed = false;
  Duration get _now => SchedulerBinding.instance.currentSystemFrameTimeStamp;
  bool get started => _startedAt != null;
  void start() {
    if (_closed || started) return;
    _startedAt = _now;
    notifyListeners();
  }

  Duration get remaining =>
      duration - (_startedAt == null ? Duration.zero : _now - _startedAt!);
  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}

/// Native SnackBar owns dismissal/queueing; this only visualizes its lifetime.
class SnackBarCountdown extends StatefulWidget {
  const SnackBarCountdown({
    super.key,
    required this.lifetime,
    required this.color,
  });
  final SnackBarLifetime lifetime;
  final Color color;

  @override
  State<SnackBarCountdown> createState() => _SnackBarCountdownState();
}

class _SnackBarCountdownState extends State<SnackBarCountdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = AnimationController(vsync: this, value: 1);
    widget.lifetime.addListener(_start);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _remaining.stop();
    } else if (widget.lifetime.started) {
      _start();
    }
  }

  @override
  void didUpdateWidget(SnackBarCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lifetime != widget.lifetime) {
      oldWidget.lifetime.removeListener(_start);
      widget.lifetime.addListener(_start);
      _remaining.stop();
      _remaining.value = 1;
      if (widget.lifetime.started) _start();
    }
  }

  void _start() {
    if (widget.lifetime.persistent || MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    final remaining = widget.lifetime.remaining;
    final total = widget.lifetime.duration.inMicroseconds;
    _remaining.value = total <= 0
        ? 0
        : (remaining.inMicroseconds / total).clamp(0, 1);
    if (remaining > Duration.zero) {
      _remaining.animateTo(0, duration: remaining, curve: Curves.linear);
    }
  }

  @override
  void dispose() {
    widget.lifetime.removeListener(_start);
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdown =
        !widget.lifetime.persistent && !MediaQuery.disableAnimationsOf(context);
    return IconButton(
      key: const Key('tam-snackbar-dismiss'),
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: () => ScaffoldMessenger.of(
        context,
      ).hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss),
      style: IconButton.styleFrom(
        foregroundColor: widget.color,
        minimumSize: const Size.square(AppDimensions.minTapTarget),
        padding: EdgeInsets.zero,
      ),
      icon: SizedBox.square(
        dimension: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (countdown)
              ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: _remaining,
                  builder: (context, _) => SizedBox.square(
                    dimension: 26,
                    child: CircularProgressIndicator(
                      key: const Key('tam-snackbar-countdown'),
                      value: _remaining.value,
                      strokeWidth: 2,
                      strokeCap: StrokeCap.round,
                      color: widget.color,
                      backgroundColor: widget.color.withValues(alpha: .13),
                    ),
                  ),
                ),
              ),
            Icon(Icons.close_rounded, size: countdown ? 14 : 18),
          ],
        ),
      ),
    );
  }
}
