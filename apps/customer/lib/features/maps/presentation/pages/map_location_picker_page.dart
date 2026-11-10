import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

import '../../maps_dependencies.dart';
import '../bloc/map_picker_cubit.dart';
import '../widgets/map_feedback.dart';
import '../widgets/map_selection_details.dart';
import '../widgets/tam_map_canvas.dart';

class MapLocationPickerPage extends StatefulWidget {
  const MapLocationPickerPage({super.key, required this.dependencies});
  final MapsDependencies dependencies;
  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  final _query = TextEditingController();
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<MapPickerCubit>();
    return BlocBuilder<MapPickerCubit, MapPickerState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(l.mapsPickLocation)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                padding: AppSpacing.pagePadding,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  TamTextField(
                    key: const Key('map-search'),
                    labelText: l.mapsSearch,
                    controller: _query,
                    prefixIcon: const Icon(Icons.search),
                    onChanged: cubit.search,
                  ),
                  if (state.searching) const LinearProgressIndicator(),
                  for (final result in state.results)
                    ListTile(
                      title: Text(result.label),
                      leading: const Icon(Icons.place_outlined),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        cubit.choose(result);
                      },
                    ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 300,
                    child: TamMapCanvas(
                      configuration: widget.dependencies.configuration,
                      onAttribution: widget.dependencies.attribution.open,
                      tileProviderFactory:
                          widget.dependencies.tileProviderFactory,
                      origin: state.point,
                      onSelected: cubit.select,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TamButton.secondary(
                    key: const Key('map-use-device-location'),
                    label: l.mapsUseMyLocation,
                    icon: Icons.my_location,
                    onPressed: state.busy ? null : cubit.locate,
                  ),
                  if (state.busy) const LinearProgressIndicator(),
                  if (state.failure != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    MapFeedback(text: mapFailureText(l, state.failure)),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  MapSelectionDetails(
                    label: state.label,
                    point: state.point,
                    onLabel: cubit.labelChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: TamButton.primary(
                  key: const Key('map-confirm-location'),
                  label: l.mapsConfirmLocation,
                  onPressed: !state.canConfirm
                      ? null
                      : () => Navigator.pop(
                          context,
                          TripLocation(
                            label: state.label.trim(),
                            point: state.point!,
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
