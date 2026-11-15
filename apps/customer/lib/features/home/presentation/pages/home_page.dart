import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_journal.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_status_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// TAM home / editorial journey concept. Keeps the real HomeCubit and navigation.
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

  static const _wine = Color(0xFF8D153A);
  static const _ink = Color(0xFF281A1E);
  static const _muted = Color(0xFF786F75);
  static const _canvas = Color(0xFFFFF9F8);
  static const _font = 'TamSansArabic';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: _canvas),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                key: const PageStorageKey('home-scroll'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _masthead(context, t),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        final content = state.content;
                        final ready =
                            state.status == HomeLoadStatus.ready &&
                            content != null;
                        final rideAvailable =
                            ready &&
                            content.services.any(
                              (s) => s.id == HomeServiceId.ride && s.available,
                            );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _hero(context, isArabic),
                            if (rideAvailable)
                              HomeDeparturePortal(
                                onRideRequest: navigation.openRideRequest,
                                child: _bookingCard(
                                  context,
                                  isArabic,
                                  reduceMotion,
                                ),
                              )
                            else
                              HomeStatusPanel(state: state),
                            _shortcuts(context, t),
                            if (ready && content.services.isNotEmpty)
                              _services(context, content.services, isArabic),
                            if (ready && content.promotions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    for (final promotion in content.promotions)
                                      HomePromotionJournal(
                                        key: Key('home-promo-${promotion.id}'),
                                        promotion: promotion,
                                        onRideRequest:
                                            navigation.openRideRequest,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 5, 24, 18),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => unawaited(logout()),
                          icon: Icon(
                            isGuest
                                ? Icons.login_rounded
                                : Icons.logout_rounded,
                            size: 19,
                          ),
                          label: Text(isGuest ? t.authSignIn : t.authLogout),
                          style: TextButton.styleFrom(foregroundColor: _wine),
                        ),
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

  Widget _masthead(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 13, 20, 9),
      child: Row(
        children: [
          const Text(
            'تم',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w900,
              fontSize: 38,
              height: 1,
              color: _wine,
            ),
          ),
          const SizedBox(width: 13),
          Container(height: 34, width: 1, color: const Color(0xFFE9D8DD)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.homeGreeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _wine,
                  ),
                ),
                Text(
                  isGuest ? t.authGuestTitle : t.authSignedInTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
                if (phoneE164 != null)
                  Text(
                    phoneE164!,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontSize: 10, color: _muted),
                  ),
              ],
            ),
          ),
          notificationsButton ??
              IconButton(
                key: const Key('home-notifications'),
                onPressed: navigation.openNotifications,
                icon: const Icon(Icons.notifications_none_rounded, size: 23),
                color: _wine,
                tooltip: t.navNotifications,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFBEFF2),
                  minimumSize: const Size(46, 46),
                ),
              ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, bool ar) {
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero_aleppo.webp',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            semanticLabel: ar
                ? 'سيارة تم على طريق بالقرب من قلعة حلب'
                : 'A car on a road by Aleppo Citadel',
          ),
          PositionedDirectional(
            start: 22,
            top: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'وين رايح اليوم؟' : 'Where to today?',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    fontSize: 25,
                    height: 1.35,
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 5, start: 2),
                  width: 58,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _wine,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(BuildContext context, bool ar, bool reduceMotion) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 0, 17, 11),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [
            BoxShadow(
              color: Color(0x159A4560),
              blurRadius: 24,
              offset: Offset(0, 9),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _locationLine(
              ar ? 'نقطة الانطلاق' : 'Pickup',
              ar ? 'حدد موقع الانطلاق' : 'Set pickup location',
              Icons.my_location_rounded,
              true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 23),
              child: Row(
                children: [
                  Container(
                    height: 13,
                    width: 1,
                    color: const Color(0xFFDDBDC7),
                  ),
                ],
              ),
            ),
            _locationLine(
              ar ? 'الوجهة' : 'Destination',
              ar ? 'إلى أين؟' : 'Where to?',
              Icons.location_on_rounded,
              false,
            ),
            InkWell(
              onTap: navigation.openRideRequest,
              child: Padding(
                padding: const EdgeInsets.only(top: 7, bottom: 7),
                child: Text(
                  AppLocalizations.of(context).homeRideEntryHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ),
            ),
            Material(
              color: _wine,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                key: const Key('home-ride-entry'),
                onTap: navigation.openRideRequest,
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ar ? 'اطلب مشوار' : 'Book a ride',
                            style: const TextStyle(
                              fontFamily: _font,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          textDirection: TextDirection.ltr,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationLine(
    String caption,
    String value,
    IconData icon,
    bool pickup,
  ) {
    return Material(
      color: const Color(0xFFFCF5F6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: navigation.openRideRequest,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: pickup
                    ? const Color(0xFFF5E0E6)
                    : const Color(0xFFF5E0E6),
                child: Icon(icon, color: _wine, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caption,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 14,
                        color: _ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFB39CA3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcuts(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: _shortcut(
              key: const Key('home-addresses'),
              label: t.addressesTitle,
              icon: Icons.bookmark_border_rounded,
              onTap: navigation.openAddresses,
              color: const Color(0xFFF9EAF0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _shortcut(
              key: const Key('home-active-trip'),
              label: t.activeTripFollow,
              icon: Icons.route_rounded,
              onTap: () => navigation.openActiveTrip(),
              color: const Color(0xFFF1F1E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcut({
    required Key key,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: _wine),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 12,
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _services(BuildContext context, List<HomeService>? services, bool ar) {
    final ride = services?.where((s) => s.id == HomeServiceId.ride).firstOrNull;
    final food = services?.where((s) => s.id == HomeServiceId.food).firstOrNull;
    final shop = services
        ?.where((s) => s.id == HomeServiceId.shopping)
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ar ? 'اختر خدمتك' : 'Choose your service',
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _serviceCard(
                  ar ? 'مشوار' : 'Ride',
                  'ride_car.webp',
                  true,
                  ride?.available ?? false,
                  navigation.openRideRequest,
                  ar,
                ),
              ),
              if (food != null) ...[
                const SizedBox(width: 9),
                Expanded(
                  child: _serviceCard(
                    ar ? 'الطعام' : 'Food',
                    'food.webp',
                    false,
                    food.available,
                    null,
                    ar,
                  ),
                ),
              ],
              if (shop != null) ...[
                const SizedBox(width: 9),
                Expanded(
                  child: _serviceCard(
                    ar ? 'التسوق' : 'Shopping',
                    'shopping.webp',
                    false,
                    shop.available,
                    null,
                    ar,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(
    String label,
    String icon,
    bool feature,
    bool enabled,
    VoidCallback? onTap,
    bool ar,
  ) {
    return Material(
      color: feature ? _wine : const Color(0xFFF7F0EF),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(minHeight: 133),
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/$icon',
                width: 94,
                height: 70,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: feature ? Colors.white : _ink,
                ),
              ),
              if (!enabled) ...[
                const SizedBox(height: 3),
                Text(
                  ar ? 'قريبًا' : 'Coming soon',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
