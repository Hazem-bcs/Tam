import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A real swipeable ad slot, sourced from Home data rather than UI fixtures.
/// The service tile owns booking; campaigns remain informational.
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
        !TickerMode.valuesOf(context).enabled) {
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
    final scale = MediaQuery.textScalerOf(context).scale(16);
    final visibleIndex = _index.clamp(0, items.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: scale > 24 ? scale * 12 : 170,
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
              // The viewport is edge-to-edge. Only the card is inset,
              // so incoming and outgoing slides pass the page gutters.
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: _PromotionSlide(promotion: items[index], index: index),
              ),
            ),
          ),
        ),
        if (items.length > 1)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 11),
            child: Semantics(
              key: ValueKey('home-promotion-current-$visibleIndex'),
              label: MaterialLocalizations.of(
                context,
              ).tabLabel(tabIndex: visibleIndex + 1, tabCount: items.length),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : AppMotion.short,
                      width: i == visibleIndex ? 8 : 6,
                      height: i == visibleIndex ? 8 : 6,
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
    final theme = Theme.of(context), colors = theme.colorScheme;
    final type = theme.textTheme;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final remote = promotion.imageUrl != null;
    final foreground = remote ? colors.onPrimary : colors.primary;
    return Semantics(
      container: true,
      label: promotion.title.forLanguage(lang),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          key: Key('home-promotion-slide-$index'),
          fit: StackFit.expand,
          children: [
            if (remote)
              Image.network(
                promotion.imageUrl!,
                fit: BoxFit.cover,
                cacheWidth: 1000,
                errorBuilder: (_, error, stack) =>
                    ColoredBox(color: colors.primary),
              )
            else
              Transform.flip(
                flipX: Directionality.of(context) == TextDirection.ltr,
                child: Image.asset(
                  'assets/images/ahmad_ui/home_hero.webp',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            if (remote)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      colors.scrim.withValues(alpha: .85),
                      colors.scrim.withValues(alpha: .15),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.appName,
                          style: type.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          promotion.title.forLanguage(lang),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: type.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          promotion.subtitle.forLanguage(lang),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: type.bodySmall?.copyWith(
                            color: remote
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
