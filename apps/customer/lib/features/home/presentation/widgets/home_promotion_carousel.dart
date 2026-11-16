import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Only server-enabled promotions appear. Manual paging avoids auto-motion
/// and uses existing local TAM mascot art instead of introducing new styles.
class HomePromotionCarousel extends StatefulWidget {
  const HomePromotionCarousel({
    super.key,
    required this.promotions,
    required this.onRideRequest,
    required this.rideAvailable,
  });

  final List<HomePromotion> promotions;
  final VoidCallback onRideRequest;
  final bool rideAvailable;

  @override
  State<HomePromotionCarousel> createState() => _HomePromotionCarouselState();
}

class _HomePromotionCarouselState extends State<HomePromotionCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
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
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(172).clamp(172, 360),
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final promo = items[index];
              final interactive =
                  widget.rideAvailable &&
                  promo.action == HomeAction.rideRequest;
              final showMascot =
                  index == 0 &&
                  promo.kind == HomePromotionKind.hero &&
                  MediaQuery.sizeOf(context).width >= 355 &&
                  MediaQuery.textScalerOf(context).scale(14) < 21;
              return Semantics(
                container: true,
                child: Material(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(21),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: interactive ? widget.onRideRequest : null,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          end: -52,
                          bottom: -80,
                          child: ExcludeSemantics(
                            child: Container(
                              height: 170,
                              width: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 24,
                                  color: colors.primary.withValues(alpha: .07),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            17,
                            14,
                            14,
                            14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).homeLatest,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      promo.title.forLanguage(
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: colors.onPrimaryContainer,
                                            fontWeight: FontWeight.w800,
                                            height: 1.25,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      promo.subtitle.forLanguage(
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                    ),
                                    if (interactive) ...[
                                      const SizedBox(height: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (showMascot) ...[
                                const SizedBox(width: AppSpacing.xs),
                                ExcludeSemantics(
                                  child: Image.asset(
                                    'assets/images/tam_account_mascot.webp',
                                    width: 101,
                                    height: 111,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.medium,
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
            },
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppMotion.short,
                  height: 5,
                  width: i == _index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: i == _index ? colors.primary : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
