import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Keeps the three-item customer navigation visible without owning routes.
class SettingsBottomNavigation extends StatelessWidget {
  const SettingsBottomNavigation({
    super.key,
    required this.onHome,
    required this.onTrips,
  });

  final VoidCallback onHome;
  final VoidCallback onTrips;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) onHome();
          if (index == 1) onTrips();
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            label: t.navTrips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: t.navSettings,
          ),
        ],
      ),
    );
  }
}
