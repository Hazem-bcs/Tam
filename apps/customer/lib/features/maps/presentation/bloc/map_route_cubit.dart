import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import '../../domain/maps_repository.dart';

final class MapRouteState {
  const MapRouteState({this.route, this.busy = false, this.failure});
  final MapRoute? route;
  final bool busy;
  final String? failure;
}

final class MapRouteCubit extends Cubit<MapRouteState> {
  MapRouteCubit(this.repository) : super(const MapRouteState());
  final MapsRepository repository;
  int _epoch = 0;
  Future<void> load(GeoPoint? origin, GeoPoint? destination) async {
    if (isClosed) return;
    final epoch = ++_epoch;
    if (origin == null || destination == null || origin == destination) {
      emit(const MapRouteState());
      return;
    }
    emit(const MapRouteState(busy: true));
    try {
      final route = await repository.route(origin, destination);
      if (isClosed || epoch != _epoch) return;
      if (route.origin != origin ||
          route.destination != destination ||
          route.points.length < 2) {
        throw const MapsFailure('INVALID_RESPONSE');
      }
      emit(MapRouteState(route: route));
    } catch (error) {
      if (!isClosed && epoch == _epoch) {
        emit(
          MapRouteState(
            failure: error is MapsFailure ? error.code : 'SERVICE_UNAVAILABLE',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _epoch++;
    return super.close();
  }
}
