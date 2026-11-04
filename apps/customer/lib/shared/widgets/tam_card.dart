import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// A neutral bordered surface; optionally actionable with native ink/focus.
/// Static cards do not advertise button semantics. Put actions in the child
/// when the card itself should not be tappable.
class TamCard extends StatelessWidget {
  const TamCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      child: onTap == null
          ? content
          : Semantics(
              button: true,
              child: InkWell(
                onTap: onTap,
                customBorder: Theme.of(context).cardTheme.shape,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppDimensions.minTapTarget,
                    minWidth: AppDimensions.minTapTarget,
                  ),
                  child: content,
                ),
              ),
            ),
    );
  }
}
