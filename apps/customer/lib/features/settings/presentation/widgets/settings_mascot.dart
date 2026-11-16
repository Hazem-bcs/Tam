import 'package:flutter/material.dart';

/// Static approved TAM character until the shared Rive rig is finalized.
/// The future Rive implementation can replace this image without changing
/// the settings UI's layout or introducing a second animation controller.
class SettingsMascot extends StatelessWidget {
  const SettingsMascot({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/images/tam_account_mascot.webp',
      key: const Key('settings-mascot'),
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}
