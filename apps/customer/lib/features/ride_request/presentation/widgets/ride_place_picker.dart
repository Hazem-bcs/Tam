import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

class RidePlacePicker extends StatefulWidget {
  const RidePlacePicker({super.key, required this.pickup});

  final bool pickup;

  @override
  State<RidePlacePicker> createState() => _RidePlacePickerState();
}

class _RidePlacePickerState extends State<RidePlacePicker> {
  final _search = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RideDraftBloc>().add(const RidePlaceSearchChanged(''));
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pickup
                    ? l10n.rideRequestPickup
                    : l10n.rideRequestDestination,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TamTextField(
                labelText: l10n.rideRequestSearchPlaces,
                controller: _search,
                focusNode: _focus,
                prefixIcon: const Icon(Icons.search),
                onChanged: (query) => context.read<RideDraftBloc>().add(
                  RidePlaceSearchChanged(query),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: BlocBuilder<RideDraftBloc, RideDraftState>(
                  buildWhen: (a, b) =>
                      a.suggestions != b.suggestions ||
                      a.searching != b.searching ||
                      a.searchError != b.searchError,
                  builder: (context, state) {
                    if (state.searching) {
                      return Center(
                        child: Semantics(
                          label: l10n.rideRequestPlaceSearchLoading,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.searchError != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.rideRequestErrorUnavailable),
                            const SizedBox(height: AppSpacing.sm),
                            TamButton.secondary(
                              label: l10n.rideRequestRetry,
                              onPressed: () => context
                                  .read<RideDraftBloc>()
                                  .add(RidePlaceSearchChanged(_search.text)),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state.suggestions.isEmpty) {
                      return Center(child: Text(l10n.rideRequestNoPlaces));
                    }
                    return ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: state.suggestions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final place = state.suggestions[index];
                        final label = language == 'ar'
                            ? place.location.label
                            : place.englishLabel;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.place_outlined,
                            color: colors.primary,
                          ),
                          title: Text(label),
                          onTap: () {
                            final selected = TripLocation(
                              label: label,
                              point: place.location.point,
                            );
                            context.read<RideDraftBloc>().add(
                              widget.pickup
                                  ? PickupSelected(selected)
                                  : DestinationSelected(selected),
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
