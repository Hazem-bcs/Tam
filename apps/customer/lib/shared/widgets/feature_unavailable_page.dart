import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Honest route boundary until its feature owner supplies the implementation.
class FeatureUnavailablePage extends StatelessWidget {
  const FeatureUnavailablePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(AppLocalizations.of(context).featureNotConnected),
        ),
      ),
    ),
  );
}
