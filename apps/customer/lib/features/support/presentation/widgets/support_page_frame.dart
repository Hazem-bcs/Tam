import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

class SupportPageFrame extends StatelessWidget {
  const SupportPageFrame({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
  });
  final String title;
  final VoidCallback onBack;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: BackButton(onPressed: onBack),
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: AppSpacing.pagePadding, children: children),
        ),
      ),
    ),
  );
}
