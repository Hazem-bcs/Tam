import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
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
    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: _canvas),
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
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
                            _journeySection(
                              context,
                              isArabic,
                              rideAvailable,
                              state,
                            ),
                            _shortcuts(context, t),
                            if (ready && content.services.isNotEmpty)
                              _services(context, content.services, isArabic),
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

  /// A single journey composition: image, route and action belong together.
  Widget _journeySection(
    BuildContext context,
    bool ar,
    bool rideAvailable,
    HomeState state,
  ) {
    return Stack(
      children: [
        _hero(context, ar),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 170, 16, 0),
          child: rideAvailable
              ? HomeDeparturePortal(
                  onRideRequest: navigation.openRideRequest,
                  child: _bookingCard(context, ar),
                )
              : HomeStatusPanel(state: state),
        ),
      ],
    );
  }

  Widget _hero(BuildContext context, bool ar) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      child: SizedBox(
        height: 214,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/hero_aleppo.webp',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              semanticLabel: ar
                  ? 'سيارة على طريق بالقرب من قلعة حلب'
                  : 'Car on the road near Aleppo Citadel',
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.42, 1],
                    colors: [
                      Color(0xFFFFF9F8),
                      Color(0xEFFFF9F8),
                      Color(0x00FFF9F8),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 25,
              top: 10,
              end: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? 'تم • مشوار' : 'TAM • RIDES',
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0,
                      color: _wine,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ar ? 'وين رايح اليوم؟' : 'Where to today?',
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      fontSize: 24,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(BuildContext context, bool ar) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(17, 16, 17, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1E5E9), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4D1529),
            offset: Offset(0, 12),
            blurRadius: 32,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 27,
                height: 96,
                child: CustomPaint(painter: _JourneyRoutePainter()),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  children: [
                    _routeRow(
                      caption: ar ? 'نقطة الانطلاق' : 'Pickup',
                      value: ar ? 'من وين بدنا نبلّش؟' : 'Choose your pickup',
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.7,
                      color: Color(0xFFF0E8EA),
                    ),
                    _routeRow(
                      caption: ar ? 'الوجهة' : 'Destination',
                      value: ar ? 'لوين المشوار؟' : 'Where are you going?',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Material(
            color: _wine,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              key: const Key('home-ride-entry'),
              onTap: navigation.openRideRequest,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(17, 0, 13, 0),
                child: SizedBox(
                  height: MediaQuery.textScalerOf(context).scale(51),
                  child: Row(
                    children: [
                      Container(
                        width: 33,
                        height: 33,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ar ? 'اطلب مشوار' : 'Book a ride',
                          style: const TextStyle(
                            fontFamily: _font,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.local_taxi_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeRow({required String caption, required String value}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: navigation.openRideRequest,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 47),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontSize: 10,
                            color: _muted,
                          ),
                        ),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontSize: 13,
                            height: 1.42,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  textDirection: TextDirection.ltr,
                  size: 12,
                  color: Color(0xFFB9A8AE),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shortcuts(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 15, 18, 13),
      child: Row(
        children: [
          Expanded(
            child: _shortcut(
              key: const Key('home-addresses'),
              label: t.addressesTitle,
              icon: Icons.bookmark_outline_rounded,
              onTap: navigation.openAddresses,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _shortcut(
              key: const Key('home-active-trip'),
              label: t.activeTripFollow,
              icon: Icons.route_rounded,
              onTap: () => navigation.openActiveTrip(),
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
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 53,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEEE2E5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: _wine),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                size: 17,
                color: Color(0xFFC3B5BA),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _services(BuildContext context, List<HomeService> services, bool ar) {
    final ride = services.where((s) => s.id == HomeServiceId.ride).firstOrNull;
    final food = services.where((s) => s.id == HomeServiceId.food).firstOrNull;
    final shop = services
        .where((s) => s.id == HomeServiceId.shopping)
        .firstOrNull;
    if (food == null && shop == null && (ride == null || ride.available)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 13, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 19,
                decoration: BoxDecoration(
                  color: _wine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  ar ? 'خدمات تم' : 'TAM services',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              if (ride != null && !ride.available) ...[
                Expanded(
                  child: _serviceCard(
                    label: ar ? 'مشوار' : 'Ride',
                    asset: 'ride_car.webp',
                    available: false,
                    ar: ar,
                    onTap: null,
                  ),
                ),
                if (food != null || shop != null) const SizedBox(width: 9),
              ],
              if (food != null) ...[
                Expanded(
                  child: _serviceCard(
                    label: ar ? 'الطعام' : 'Food',
                    asset: 'food.webp',
                    available: food.available,
                    ar: ar,
                    onTap: null,
                  ),
                ),
                if (shop != null) const SizedBox(width: 9),
              ],
              if (shop != null)
                Expanded(
                  child: _serviceCard(
                    label: ar ? 'التسوق' : 'Shopping',
                    asset: 'shopping.webp',
                    available: shop.available,
                    ar: ar,
                    onTap: null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required String label,
    required String asset,
    required bool available,
    required bool ar,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFFF7F2F1),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: available && onTap != null ? onTap : null,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsetsDirectional.fromSTEB(6, 7, 8, 7),
          child: Row(
            children: [
              Image.asset(
                'assets/images/$asset',
                width: 67,
                height: 68,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    if (!available || onTap == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ar ? 'قريبًا' : 'Coming soon',
                        style: const TextStyle(
                          fontFamily: _font,
                          color: _muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyRoutePainter extends CustomPainter {
  const _JourneyRoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final line = Paint()
      ..color = const Color(0xFFCBA5B2)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var y = 32.0; y < size.height - 29; y += 8) {
      canvas.drawLine(Offset(center, y), Offset(center, y + 3), line);
    }
    canvas.drawCircle(
      Offset(center, 21),
      8,
      Paint()..color = const Color(0xFFEBD4DD),
    );
    canvas.drawCircle(
      Offset(center, 21),
      4,
      Paint()..color = const Color(0xFF8D153A),
    );
    canvas.drawCircle(
      Offset(center, size.height - 21),
      8.5,
      Paint()
        ..color = const Color(0xFF8D153A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(center, size.height - 21),
      2.7,
      Paint()..color = const Color(0xFF8D153A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
