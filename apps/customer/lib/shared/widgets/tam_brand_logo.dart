import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class TamBrandLogo extends StatelessWidget {
  const TamBrandLogo({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return Image.asset(
      'assets/images/brand/logo_${language == 'ar' ? 'ar' : 'en'}.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      color: Theme.of(context).colorScheme.primary,
      semanticLabel: AppLocalizations.of(context).appName,
    );
  }
}
