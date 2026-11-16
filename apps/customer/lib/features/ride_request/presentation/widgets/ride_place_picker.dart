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
import 'ride_artwork.dart';
import 'ride_place_suggestion_tile.dart';

class RidePlacePicker extends StatefulWidget {
  const RidePlacePicker({
    super.key,
    required this.pickup,
    this.savedAddressPickerBuilder,
    this.onSelected,
    this.onPickOnMap,
    this.embedded = false,
  });
  final bool pickup, embedded;
  final VoidCallback? onPickOnMap;
  final ValueChanged<TripLocation>? onSelected;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;
  @override
  State<RidePlacePicker> createState() => _RidePlacePickerState();
}

class _RidePlacePickerState extends State<RidePlacePicker> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  bool _hasQuery = false;

  void _searchChanged(String query) {
    final hasQuery = query.trim().isNotEmpty;
    if (_hasQuery != hasQuery) setState(() => _hasQuery = hasQuery);
    context.read<RideDraftBloc>().add(RidePlaceSearchChanged(query));
  }

  void _select(TripLocation selected) {
    _focus.unfocus();
    if (widget.onSelected != null) {
      widget.onSelected!(selected);
    } else {
      context.read<RideDraftBloc>().add(
        widget.pickup
            ? PickupSelected(selected)
            : DestinationSelected(selected),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickOnMap() async {
    _focus.unfocus();
    if (widget.onPickOnMap != null) {
      widget.onPickOnMap!();
      return;
    }
    final selected = await showMapLocationPicker(context);
    if (mounted && selected != null) _select(selected);
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
    final theme = Theme.of(context);
    final content = ListView(
      shrinkWrap: widget.embedded,
      primary: !widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded ? EdgeInsets.zero : AppSpacing.pagePadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (!widget.embedded) ...[
          Text(
            widget.pickup
                ? t.rideRequestSearchPickupTitle
                : t.rideRequestSearchDestinationTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TamTextField(
          key: const Key('ride-place-search'),
          labelText: widget.pickup
              ? t.rideRequestSearchPlaces
              : t.rideRequestSearchDestinationHint,
          controller: _search,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _hasQuery
              ? IconButton(
                  tooltip: t.rideRequestClearSearch,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _search.clear();
                    _searchChanged('');
                  },
                )
              : null,
          onChanged: _searchChanged,
        ),
        if (MapsScope.maybeOf(context) != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            key: const Key('ride-pick-on-map'),
            onPressed: _pickOnMap,
            child: Row(
              children: [
                const RideArtwork(
                  type: RideArtworkType.mapSelect,
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(t.rideRequestChooseFromMap)),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const Divider(height: AppSpacing.lg),
        ] else
          const SizedBox(height: AppSpacing.lg),
        Visibility(
          visible: !_hasQuery,
          maintainState: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.rideRequestSavedPlaces,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              widget.savedAddressPickerBuilder?.call(_select) ??
                  Text(t.addressesEmpty),
            ],
          ),
        ),
        if (_hasQuery)
          BlocBuilder<RideDraftBloc, RideDraftState>(
            buildWhen: (a, b) =>
                a.suggestions != b.suggestions ||
                a.searching != b.searching ||
                a.searchError != b.searchError,
            builder: _results,
          ),
      ],
    );
    if (widget.embedded) return content;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height:
            (MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom) *
            .8,
        child: content,
      ),
    );
  }

  Widget _results(BuildContext context, RideDraftState state) {
    final t = AppLocalizations.of(context);
    if (state.searching) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: t.rideRequestPlaceSearchLoading,
          ),
        ),
      );
    }
    if (state.searchError != null) {
      return Column(
        children: [
          Text(t.rideRequestErrorUnavailable),
          TamButton.secondary(
            label: t.rideRequestRetry,
            onPressed: () => _searchChanged(_search.text),
          ),
        ],
      );
    }
    if (state.suggestions.isEmpty) return Text(t.rideRequestNoPlaces);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.rideRequestSearchResults,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < state.suggestions.length; i++) ...[
          RidePlaceSuggestionTile(
            label: ar
                ? state.suggestions[i].location.label
                : state.suggestions[i].englishLabel,
            onTap: () => _select(
              TripLocation(
                label: ar
                    ? state.suggestions[i].location.label
                    : state.suggestions[i].englishLabel,
                point: state.suggestions[i].location.point,
              ),
            ),
          ),
          if (i < state.suggestions.length - 1)
            const Divider(height: 1, indent: 56, endIndent: AppSpacing.sm),
        ],
      ],
    );
  }
}
