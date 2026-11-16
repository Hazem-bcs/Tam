import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/app/theme/app_typography.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_booking_card.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_masthead.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_carousel.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_ride_intro.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_service_showcase.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_status_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A journey-first home. Presentation never invents available services or
/// sessions; those remain owned by HomeCubit and the navigation contract.
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
      // Use the centrally defined Arabic/Latin font pair only on Home.
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(textTheme: AppTypography.home(Theme.of(context).textTheme)),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
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
                      phoneE164: phoneE164,
                      notificationsButton: notificationsButton,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const HomeRideIntro(),
                          const SizedBox(height: AppSpacing.md),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              final ready =
                                  state.status == HomeLoadStatus.ready &&
                                  state.content != null;
                              final services = ready
                                  ? state.content!.services
                                  : const <HomeService>[];
                              final ride = services
                                  .where((s) => s.id == HomeServiceId.ride)
                                  .firstOrNull;
                              final rideEnabled =
                                  ride != null &&
                                  ride.available &&
                                  ride.action == HomeAction.rideRequest;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (rideEnabled)
                                    HomeDeparturePortal(
                                      onRideRequest: navigation.openRideRequest,
                                      child: HomeBookingCard(
                                        onRideRequest:
                                            navigation.openRideRequest,
                                      ),
                                    )
                                  else if (ready)
                                    const _RideUnavailableHint()
                                  else
                                    HomeStatusPanel(state: state),
                                  const SizedBox(height: AppSpacing.md),
                                  HomeQuickActions(
                                    onAddresses: navigation.openAddresses,
                                    onActiveTrip: () =>
                                        navigation.openActiveTrip(),
                                  ),
                                  if (ready &&
                                      state.content!.promotions.any(
                                        (promotion) => promotion.enabled,
                                      )) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    HomePromotionCarousel(
                                      promotions: state.content!.promotions,
                                      rideAvailable: rideEnabled,
                                      onRideRequest: navigation.openRideRequest,
                                    ),
                                  ],
                                  if (ready && services.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xl),
                                    HomeServiceShowcase(services: services),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
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
