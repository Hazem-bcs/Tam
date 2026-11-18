import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A very short landscape keyboard viewport can scroll the whole conversation.
/// Normal viewports keep the message list flexible and the composer anchored.
class ChatViewport extends StatelessWidget {
  const ChatViewport({
    super.key,
    required this.header,
    required this.status,
    required this.timeline,
    required this.composer,
    this.newest,
    this.onViewportChanged,
  });
  final Widget header, status, timeline;
  final Widget? newest;
  final VoidCallback? onViewportChanged;
  final Widget Function(double maxHeight) composer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final height = math.max(240.0, bounds.maxHeight);
      return NotificationListener<ScrollNotification>(
        onNotification: (_) {
          onViewportChanged?.call();
          return false;
        },
        child: SingleChildScrollView(
          physics: bounds.maxHeight < height
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height * .26),
                  child: SingleChildScrollView(child: header),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height * .16),
                  child: status,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: timeline),
                      if (newest != null)
                        Align(alignment: Alignment.bottomCenter, child: newest),
                    ],
                  ),
                ),
                composer((height * .28).clamp(48, 180)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
