import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashwar_customer/features/ride_request/domain/entities/geo_point.dart';

sealed class RideDraftEvent extends Equatable {
  const RideDraftEvent();

  @override
  List<Object?> get props => [];
}

final class PickupSelected extends RideDraftEvent {
  const PickupSelected(this.location);

  final GeoPoint location;

  @override
  List<Object?> get props => [location];
}

final class DestinationSelected extends RideDraftEvent {
  const DestinationSelected(this.location);

  final GeoPoint location;

  @override
  List<Object?> get props => [location];
}

final class RideDraftState extends Equatable {
  const RideDraftState({this.pickup, this.destination});

  final GeoPoint? pickup;
  final GeoPoint? destination;

  bool get hasRoute => pickup != null && destination != null;

  RideDraftState copyWith({GeoPoint? pickup, GeoPoint? destination}) {
    return RideDraftState(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
    );
  }

  @override
  List<Object?> get props => [pickup, destination];
}

final class RideDraftBloc extends Bloc<RideDraftEvent, RideDraftState> {
  RideDraftBloc() : super(const RideDraftState()) {
    on<PickupSelected>((event, emit) {
      emit(state.copyWith(pickup: event.location));
    });
    on<DestinationSelected>((event, emit) {
      emit(state.copyWith(destination: event.location));
    });
  }
}
