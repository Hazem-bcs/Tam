import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_masthead.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_journal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_service_index.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_status_panel.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_utility_links.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.navigation,
    required this.logout,
    this.phoneE164,
    this.isAuthenticated = false,
    this.isGuest = false,
    this.notificationsButton,
  });
  final CustomerNavigation navigation;
  final Future<void> Function() logout;
  final String? phoneE164;
  final bool isAuthenticated;
  final bool isGuest;
  final Widget? notificationsButton;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.home(Theme.of(context)),
    child: Builder(builder: _buildScaffold),
  );

  Widget _buildScaffold(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              navigation.openTrips();
            case 2:
              navigation.openSettings();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            label: t.navTrips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            label: t.navSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              key: const PageStorageKey('home-scroll'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) => _content(context, state),
                  ),
                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => unawaited(logout()),
                        icon: Icon(
                          isGuest ? Icons.login_rounded : Icons.logout_rounded,
                        ),
                        label: Text(isGuest ? t.authSignIn : t.authLogout),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, HomeState state) {
    final colors = Theme.of(context).colorScheme;
    final data = state.content;
    final ready = state.status == HomeLoadStatus.ready && data != null;
    final rideAvailable =
        ready &&
        data.services.any(
          (service) => service.id == HomeServiceId.ride && service.available,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.primary,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppRadii.sheet),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.pagePadding,
                child: HomeMasthead(
                  onNotifications: navigation.openNotifications,
                  phoneE164: phoneE164,
                  isAuthenticated: isAuthenticated,
                  isGuest: isGuest,
                  notificationsButton: notificationsButton,
                ),
              ),
              if (rideAvailable)
                HomeDeparturePortal(onRideRequest: navigation.openRideRequest)
              else
                const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeUtilityLinks(
                onAddresses: navigation.openAddresses,
                onActiveTrip: () => navigation.openActiveTrip(),
              ),
              if (!ready)
                HomeStatusPanel(state: state)
              else ...[
                if (data.services.isNotEmpty)
                  HomeServiceIndex(
                    services: data.services,
                    onRideRequest: navigation.openRideRequest,
                  ),
                if (data.promotions.isNotEmpty)
                  const SizedBox(height: AppSpacing.lg),
                for (final promotion in data.promotions)
                  HomePromotionJournal(
                    key: Key('home-promo-${promotion.id}'),
                    promotion: promotion,
                    onRideRequest: navigation.openRideRequest,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
