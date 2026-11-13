import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Keeps the map interactive and its attribution above the introduction.
class RideJourneyEntryLayout extends StatelessWidget {
  const RideJourneyEntryLayout({
    super.key,
    required this.header,
    required this.map,
    required this.panel,
  });
  final Widget header, map, panel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final wide = bounds.maxWidth >= 700;
      final scrollPanel = SingleChildScrollView(child: panel);
      return Column(
        children: [
          header,
          if (wide)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: map),
                  SizedBox(width: 380, child: scrollPanel),
                ],
              ),
            )
          else ...[
            Expanded(child: map),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    (bounds.maxHeight - 100).clamp(0, bounds.maxHeight) * .72,
              ),
              child: scrollPanel,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
        ],
      );
    },
  );
}
