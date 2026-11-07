import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onNotifications,
    this.phoneE164,
    this.isAuthenticated = false,
    this.isGuest = false,
  });

  final VoidCallback onNotifications;
  final String? phoneE164;
  final bool isAuthenticated;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.homeGreeting,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isGuest
                    ? t.authGuestTitle
                    : isAuthenticated
                    ? t.authSignedInTitle
                    : t.homePhoneTitle,
                style: text.titleLarge,
              ),
              if (phoneE164 != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      phoneE164!,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          key: const Key('home-notifications'),
          onPressed: onNotifications,
          tooltip: t.navNotifications,
          icon: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    );
  }
}
