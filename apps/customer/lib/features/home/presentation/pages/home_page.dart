import 'package:flutter/material.dart';
import 'package:mashwar_customer/l10n/app_localizations.dart';

/// Temporary boot screen; replaced after professional UI review.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.starterTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(t.starterDescription, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
