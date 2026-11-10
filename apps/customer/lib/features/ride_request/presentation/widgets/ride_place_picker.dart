import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/maps_entry.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

class RidePlacePicker extends StatefulWidget {
  const RidePlacePicker({
    super.key,
    required this.pickup,
    this.savedAddressPickerBuilder,
  });

  final bool pickup;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  @override
  State<RidePlacePicker> createState() => _RidePlacePickerState();
}

class _RidePlacePickerState extends State<RidePlacePicker> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  bool _saved = false;

  void _select(TripLocation selected) {
    context.read<RideDraftBloc>().add(
      widget.pickup ? PickupSelected(selected) : DestinationSelected(selected),
    );
    Navigator.of(context).pop();
  }

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
    final t = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height:
            (MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom) *
            0.8,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              widget.pickup ? t.rideRequestPickup : t.rideRequestDestination,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (MapsScope.maybeOf(context) != null) ...[
              TamButton.secondary(
                key: const Key('ride-pick-on-map'),
                label: t.mapsPickLocation,
                icon: Icons.map_outlined,
                onPressed: () async {
                  _focus.unfocus();
                  final selected = await showMapLocationPicker(context);
                  if (mounted && selected != null) _select(selected);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (widget.savedAddressPickerBuilder != null) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: Text(t.addressesSearchTab),
                    selected: !_saved,
                    onSelected: (_) => setState(() => _saved = false),
                  ),
                  ChoiceChip(
                    key: const Key('ride-saved-addresses'),
                    label: Text(t.addressesSavedTab),
                    selected: _saved,
                    onSelected: (_) {
                      _focus.unfocus();
                      setState(() => _saved = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (!_saved)
              TamTextField(
                labelText: t.rideRequestSearchPlaces,
                controller: _search,
                focusNode: _focus,
                prefixIcon: const Icon(Icons.search),
                onChanged: (query) => context.read<RideDraftBloc>().add(
                  RidePlaceSearchChanged(query),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            if (_saved)
              widget.savedAddressPickerBuilder!(_select)
            else
              BlocBuilder<RideDraftBloc, RideDraftState>(
                buildWhen: (a, b) =>
                    a.suggestions != b.suggestions ||
                    a.searching != b.searching ||
                    a.searchError != b.searchError,
                builder: (context, state) =>
                    _searchResults(context, state, language),
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchResults(
    BuildContext context,
    RideDraftState state,
    String language,
  ) {
    final t = AppLocalizations.of(context);
    if (state.searching) {
      return Center(
        child: Semantics(
          label: t.rideRequestPlaceSearchLoading,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (state.searchError != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Text(t.rideRequestErrorUnavailable),
            const SizedBox(height: AppSpacing.sm),
            TamButton.secondary(
              label: t.rideRequestRetry,
              onPressed: () => context.read<RideDraftBloc>().add(
                RidePlaceSearchChanged(_search.text),
              ),
            ),
          ],
        ),
      );
    }
    if (state.suggestions.isEmpty) {
      return SingleChildScrollView(child: Text(t.rideRequestNoPlaces));
    }
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: state.suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = state.suggestions[index];
        final label = language == 'ar'
            ? place.location.label
            : place.englishLabel;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.place_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(label),
          onTap: () =>
              _select(TripLocation(label: label, point: place.location.point)),
        );
      },
    );
  }
}
