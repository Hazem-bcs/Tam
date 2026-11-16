import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/app/theme/app_typography.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_destination_hero.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_masthead.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_carousel.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_service_showcase.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_status_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Destination-first home: one ride entry, real campaign paging, no redundant
/// shortcuts for routes already available in the ride flow or bottom navigation.
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(textTheme: AppTypography.home(Theme.of(context).textTheme)),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: SingleChildScrollView(
                key: const PageStorageKey('home-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.only(
                  bottom: AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeMasthead(
                      onNotifications: navigation.openNotifications,
                      isGuest: isGuest,
                      isAuthenticated: isAuthenticated,
                      notificationsButton: notificationsButton,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 18,
                      ),
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final ready =
                              state.status == HomeLoadStatus.ready &&
                              state.content != null;
                          final content = state.content;
                          final services = ready
                              ? content!.services
                              : const <HomeService>[];
                          final rideService = services
                              .where(
                                (service) => service.id == HomeServiceId.ride,
                              )
                              .firstOrNull;
                          final canRide =
                              ready &&
                              rideService != null &&
                              rideService.available &&
                              rideService.action == HomeAction.rideRequest;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (canRide)
                                HomeDeparturePortal(
                                  onRideRequest: navigation.openRideRequest,
                                  child: HomeDestinationHero(
                                    onChooseDestination:
                                        navigation.openRideRequest,
                                  ),
                                )
                              else if (ready)
                                const _RideUnavailableHint()
                              else
                                HomeStatusPanel(state: state),
                              if (ready &&
                                  content!.promotions.any(
                                    (promotion) => promotion.enabled,
                                  )) ...[
                                const SizedBox(height: AppSpacing.xl),
                                HomePromotionCarousel(
                                  promotions: content.promotions,
                                ),
                              ],
                              if (ready && services.isNotEmpty)
                                HomeServiceShowcase(services: services),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RideUnavailableHint extends StatelessWidget {
  const _RideUnavailableHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppLocalizations.of(context).homeRideUnavailable,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
