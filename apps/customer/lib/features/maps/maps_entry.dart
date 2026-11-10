import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'presentation/bloc/map_picker_cubit.dart';
import 'presentation/maps_scope.dart';
import 'presentation/pages/map_location_picker_page.dart';

Future<TripLocation?> showMapLocationPicker(
  BuildContext context, {
  TripLocation? initial,
}) async {
  final dependencies = MapsScope.maybeOf(context);
  if (dependencies == null) return null;
  final language = Localizations.localeOf(context).languageCode;
  return Navigator.of(context).push<TripLocation>(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => MapPickerCubit(
          dependencies.repository,
          dependencies.deviceLocation,
          language: language,
          initial: initial,
        ),
        child: MapLocationPickerPage(dependencies: dependencies),
      ),
    ),
  );
}
