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
    this.onSelected,
    this.embedded = false,
  });
  final bool pickup;
  final bool embedded;
  final ValueChanged<TripLocation>? onSelected;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;
  @override
  State<RidePlacePicker> createState() => _RidePlacePickerState();
}

class _RidePlacePickerState extends State<RidePlacePicker> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  bool _saved = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RideDraftBloc>().add(const RidePlaceSearchChanged(''));
      }
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
    final content = ListView(
      shrinkWrap: widget.embedded,
      primary: !widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded ? EdgeInsets.zero : AppSpacing.pagePadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (!widget.embedded) ...[
          Text(
            widget.pickup ? t.rideRequestPickup : t.rideRequestDestination,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (!_saved) ...[
          TamTextField(
            key: const Key('ride-place-search'),
            labelText: t.rideRequestSearchPlaces,
            controller: _search,
            focusNode: _focus,
            prefixIcon: const Icon(Icons.search_rounded),
            onChanged: (query) => context.read<RideDraftBloc>().add(
              RidePlaceSearchChanged(query),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (widget.savedAddressPickerBuilder != null) ...[
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
            if (MapsScope.maybeOf(context) != null)
              ActionChip(
                key: const Key('ride-pick-on-map'),
                avatar: const Icon(Icons.map_outlined),
                label: Text(t.mapsPickLocation),
                onPressed: () async {
                  _focus.unfocus();
                  final selected = await showMapLocationPicker(context);
                  if (mounted && selected != null) _select(selected);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_saved)
          widget.savedAddressPickerBuilder!(_select)
        else
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (state.searching) {
      return Center(
        child: Semantics(
          label: t.rideRequestPlaceSearchLoading,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (state.searchError != null) {
      return Column(
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
      );
    }
    if (state.suggestions.isEmpty) return Text(t.rideRequestNoPlaces);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      children: [
        for (final place in state.suggestions) ...[
          Material(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                radius: 18,
                child: const Icon(Icons.near_me_outlined, size: 20),
              ),
              title: Text(
                ar ? place.location.label : place.englishLabel,
                style: theme.textTheme.titleSmall,
              ),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
              onTap: () => _select(
                TripLocation(
                  label: ar ? place.location.label : place.englishLabel,
                  point: place.location.point,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
