import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports the actual animated card height to the native map's viewport.
/// Only the viewport notifier changes; map and form state stay mounted.
class RidePanelSizeObserver extends SingleChildRenderObjectWidget {
  const RidePanelSizeObserver({
    super.key,
    required this.onHeight,
    required super.child,
  });
  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _PanelSizeRenderObject(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _PanelSizeRenderObject renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _PanelSizeRenderObject extends RenderProxyBox {
  _PanelSizeRenderObject(this.onHeight);
  ValueChanged<double> onHeight;
  double? _height;

  @override
  void performLayout() {
    super.performLayout();
    if (_height == size.height) return;
    _height = size.height;
    final height = size.height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _height == height) onHeight(height);
    });
  }
}
