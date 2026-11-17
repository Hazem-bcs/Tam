import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class AuthLegalFooter extends StatelessWidget {
  const AuthLegalFooter({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      textStyle: theme.textTheme.bodySmall,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l.authLegalIntro, style: theme.textTheme.bodySmall),
        TextButton(
          style: style,
          onPressed: () => context.push(AppRoutes.terms),
          child: Text(l.settingsTerms),
        ),
        TextButton(
          style: style,
          onPressed: () => context.push(AppRoutes.privacy),
          child: Text(l.settingsPrivacy),
        ),
      ],
    );
  }
}
