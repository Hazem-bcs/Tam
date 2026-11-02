import 'package:flutter_test/flutter_test.dart';
import 'package:mashwar_customer/features/ride_request/domain/entities/geo_point.dart';
import 'package:mashwar_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';

void main() {
  test('draft is complete only after pickup and destination', () async {
    final bloc = RideDraftBloc();
    addTearDown(bloc.close);
    expect(bloc.state.hasRoute, isFalse);

    bloc.add(PickupSelected(GeoPoint(latitude: 36.2, longitude: 37.1)));
    await bloc.stream.firstWhere((state) => state.pickup != null);
    expect(bloc.state.hasRoute, isFalse);

    bloc.add(DestinationSelected(GeoPoint(latitude: 36.3, longitude: 37.2)));
    await bloc.stream.firstWhere((state) => state.hasRoute);
    expect(bloc.state.hasRoute, isTrue);
  });
}
