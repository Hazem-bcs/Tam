import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_header.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_card.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_ride_entry.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_services.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.navigation,
    required this.logout,
    this.phoneE164,
    this.isAuthenticated = false,
    this.isGuest = false,
  });

  final CustomerNavigation navigation;
  final Future<void> Function() logout;
  final String? phoneE164;
  final bool isAuthenticated;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
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
            selectedIcon: const Icon(Icons.home),
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              key: const Key('home-scroll'),
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeader(
                    onNotifications: navigation.openNotifications,
                    phoneE164: phoneE164,
                    isAuthenticated: isAuthenticated,
                    isGuest: isGuest,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) => _body(context, state),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => unawaited(logout()),
                      child: Text(isGuest ? t.authSignIn : t.authLogout),
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

  Widget _body(BuildContext context, HomeState state) {
    final t = AppLocalizations.of(context);
    switch (state.status) {
      case HomeLoadStatus.initial:
      case HomeLoadStatus.loading:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: TamLoadingIndicator(semanticLabel: t.homeLoading),
          ),
        );
      case HomeLoadStatus.empty:
        return _message(
          context,
          icon: Icons.inbox_outlined,
          description: t.homeEmpty,
          retry: true,
        );
      case HomeLoadStatus.failure:
        return _message(
          context,
          icon: Icons.wifi_off_outlined,
          description: state.failure == HomeFailureCode.serviceUnavailable
              ? t.homeUnavailable
              : t.homeError,
          retry: true,
        );
      case HomeLoadStatus.ready:
        final data = state.content!;
        final rideAvailable = data.services.any(
          (item) => item.id == HomeServiceId.ride && item.available,
        );
        final heroes = data.promotions.where(
          (item) => item.kind == HomePromotionKind.hero,
        );
        final announcements = data.promotions.where(
          (item) => item.kind == HomePromotionKind.announcement,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final promo in heroes) ...[
              HomePromotionCard(
                key: Key('home-promo-${promo.id}'),
                promotion: promo,
                onRideRequest: navigation.openRideRequest,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (rideAvailable) ...[
              HomeRideEntry(onRideRequest: navigation.openRideRequest),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (data.services.isNotEmpty) ...[
              HomeServices(
                services: data.services,
                onRideRequest: navigation.openRideRequest,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            for (final promo in announcements) ...[
              HomePromotionCard(
                key: Key('home-promo-${promo.id}'),
                promotion: promo,
                onRideRequest: navigation.openRideRequest,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
    }
  }

  Widget _message(
    BuildContext context, {
    required IconData icon,
    required String description,
    required bool retry,
  }) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(description, textAlign: TextAlign.center),
          if (retry) ...[
            const SizedBox(height: AppSpacing.lg),
            TamButton.secondary(
              label: t.authRetry,
              onPressed: context.read<HomeCubit>().load,
            ),
          ],
        ],
      ),
    );
  }
}
