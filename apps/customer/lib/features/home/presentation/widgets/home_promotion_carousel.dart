import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A real swipeable ad slot, sourced from Home data rather than UI fixtures.
/// No promo triggers ride navigation: the hero already owns that destination.
class HomePromotionCarousel extends StatefulWidget {
  const HomePromotionCarousel({super.key, required this.promotions});

  final List<HomePromotion> promotions;

  @override
  State<HomePromotionCarousel> createState() => _HomePromotionCarouselState();
}

class _HomePromotionCarouselState extends State<HomePromotionCarousel>
    with WidgetsBindingObserver {
  static const _autoAdvanceDelay = Duration(seconds: 5);
  static const _transitionDuration = Duration(milliseconds: 420);

  final PageController _controller = PageController();
  Timer? _autoAdvanceTimer;
  int _index = 0;
  bool _pointerDown = false;
  AppLifecycleState? _lifecycle;

  int get _enabledCount =>
      widget.promotions.where((promotion) => promotion.enabled).length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycle = WidgetsBinding.instance.lifecycleState;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant HomePromotionCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousCount = oldWidget.promotions
        .where((promotion) => promotion.enabled)
        .length;
    final count = _enabledCount;
    if (count == 0) {
      _index = 0;
    } else if (_index >= count) {
      _index = count - 1;
    }
    if (count != previousCount && count > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(_index);
        }
      });
    }
    _restartAutoAdvance();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _restartAutoAdvance();
  }

  void _restartAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (_enabledCount < 2 ||
        _pointerDown ||
        (_lifecycle != null && _lifecycle != AppLifecycleState.resumed) ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.of(context)) {
      return;
    }
    _autoAdvanceTimer = Timer(_autoAdvanceDelay, () {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % _enabledCount,
        duration: _transitionDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _restartAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.promotions
        .where((promotion) => promotion.enabled)
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(16);
    final visibleIndex = _index.clamp(0, items.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: 11,
            start: 2,
            end: 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t.homePromotionsTitle,
                  style: type.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (items.length > 1)
                Text(
                  '${visibleIndex + 1} / ${items.length}',
                  textDirection: TextDirection.ltr,
                  style: type.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: scale > 24 ? scale * 12 : 182,
          child: Listener(
            onPointerDown: (_) {
              _pointerDown = true;
              _autoAdvanceTimer?.cancel();
            },
            onPointerUp: (_) {
              _pointerDown = false;
              _restartAutoAdvance();
            },
            onPointerCancel: (_) {
              _pointerDown = false;
              _restartAutoAdvance();
            },
            child: PageView.builder(
              key: const Key('home-promotions-slider'),
              controller: _controller,
              itemCount: items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) =>
                  _PromotionSlide(promotion: items[index], index: index),
            ),
          ),
        ),
        if (items.length > 1)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppMotion.short,
                    width: i == visibleIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: i == visibleIndex
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _PromotionSlide extends StatelessWidget {
  const _PromotionSlide({required this.promotion, required this.index});

  final HomePromotion promotion;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context);
    final isMedia = promotion.imageUrl != null;
    final dark = isMedia || index.isOdd;
    final fg = dark ? colors.onPrimary : colors.onPrimaryContainer;
    final secondary = dark
        ? colors.onPrimary.withValues(alpha: .82)
        : colors.onSurfaceVariant;
    final background = index.isOdd
        ? colors.primary
        : (index % 3 == 2
              ? colors.secondaryContainer
              : colors.primaryContainer);
    final showArt =
        !isMedia &&
        MediaQuery.textScalerOf(context).scale(16) < 22 &&
        MediaQuery.sizeOf(context).width >= 350;
    final lang = Localizations.localeOf(context).languageCode;

    return Semantics(
      container: true,
      label: promotion.title.forLanguage(lang),
      child: DecoratedBox(
        key: Key('home-promotion-slide-$index'),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(23),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              if (isMedia) ...[
                Positioned.fill(
                  child: Image.network(
                    promotion.imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 1000,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          colors.scrim.withValues(alpha: .82),
                          colors.scrim.withValues(alpha: .45),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (!isMedia)
                PositionedDirectional(
                  end: -25,
                  bottom: -55,
                  child: ExcludeSemantics(
                    child: Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: fg.withValues(alpha: .09),
                          width: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.homePromotionEyebrow,
                            style: type.labelSmall?.copyWith(
                              color: fg.withValues(alpha: .88),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            promotion.title.forLanguage(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: type.titleMedium?.copyWith(
                              color: fg,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            promotion.subtitle.forLanguage(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: type.bodySmall?.copyWith(
                              color: secondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showArt) ...[
                      const SizedBox(width: 7),
                      ExcludeSemantics(
                        child: index == 0
                            ? Image.asset(
                                'assets/images/tam_account_mascot.webp',
                                height: 111,
                                width: 93,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                index.isOdd
                                    ? Icons.campaign_outlined
                                    : Icons.route_rounded,
                                color: fg.withValues(alpha: .78),
                                size: 60,
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
