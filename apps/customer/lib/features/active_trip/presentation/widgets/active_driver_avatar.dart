import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Fictional portrait is restricted to the mock repository composition.
class ActiveDriverAvatar extends StatelessWidget {
  const ActiveDriverAvatar({
    super.key,
    this.size = 56,
    this.showDemoAvatar = false,
  });

  final double size;
  final bool showDemoAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.primaryContainer, width: 2),
      ),
      child: ClipOval(
        child: showDemoAvatar
            ? Image.asset(
                'assets/images/driver_demo_160.webp',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => _fallback(colors),
              )
            : _fallback(colors),
      ),
    );
  }

  Widget _fallback(ColorScheme colors) => ColoredBox(
    color: colors.primaryContainer,
    child: Icon(
      Icons.person_outline_rounded,
      color: colors.onPrimaryContainer,
      size: size * 0.58,
    ),
  );
}
