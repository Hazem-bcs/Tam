import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/app/theme/app_typography.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_address_bar.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_coupon_banner.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_masthead.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_carousel.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_reference_services.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_status_panel.dart';

/// Ahmad UI reference layout; the existing masthead and product contracts stay.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.navigation,
    required this.logout,
    this.phoneE164,
    this.isAuthenticated = false,
    this.isGuest = false,
    this.notificationsButton,
    this.addressBar,
    this.upcomingTrips,
  });

  final CustomerNavigation navigation;
  final Future<void> Function() logout;
  final String? phoneE164;
  final bool isAuthenticated;
  final bool isGuest;
  final Widget? notificationsButton;
  final Widget? addressBar, upcomingTrips;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusBar = Color.alphaBlend(
      colors.primaryContainer.withValues(alpha: .85),
      colors.surface,
    );
    final statusBarBrightness = ThemeData.estimateBrightnessForColor(statusBar);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBar,
        statusBarIconBrightness: statusBarBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: statusBarBrightness,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primaryContainer.withValues(alpha: .85),
                colors.surface,
                colors.surface,
              ],
              stops: const [0, .34, 1],
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: AppTypography.home(Theme.of(context).textTheme),
            ),
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
                        addressBar ??
                            HomeAddressBar(onManage: navigation.openAddresses),
                        ?upcomingTrips,
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            final ready =
                                state.status == HomeLoadStatus.ready &&
                                state.content != null;
                            final content = state.content;
                            final services = ready
                                ? content!.services
                                : const <HomeService>[];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!ready)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl,
                                    ),
                                    child: HomeStatusPanel(state: state),
                                  ),
                                if (ready &&
                                    content!.promotions.any(
                                      (promotion) => promotion.enabled,
                                    )) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  HomePromotionCarousel(
                                    promotions: content.promotions,
                                  ),
                                ],
                                if (ready && services.isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.symmetric(
                                          horizontal: AppSpacing.xl,
                                        ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: AppSpacing.xl),
                                        HomeReferenceServices(
                                          services: services,
                                          onRideRequest:
                                              navigation.openRideRequest,
                                        ),
                                        const SizedBox(height: AppSpacing.xl),
                                        const HomeCouponBanner(),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
