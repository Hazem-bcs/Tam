import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/maps_repository.dart';

final class MapPickerState {
  const MapPickerState({
    this.point,
    this.label = '',
    this.results = const [],
    this.busy = false,
    this.searching = false,
    this.failure,
  });
  final GeoPoint? point;
  final String label;
  final List<TripLocation> results;
  final bool busy, searching;
  final String? failure;
  bool get canConfirm =>
      !busy &&
      point != null &&
      label.trim().isNotEmpty &&
      label.runes.length <= 200;
  MapPickerState copy({
    GeoPoint? point,
    String? label,
    List<TripLocation>? results,
    bool? busy,
    bool? searching,
    String? failure,
  }) => MapPickerState(
    point: point ?? this.point,
    label: label ?? this.label,
    results: results == null ? this.results : List.unmodifiable(results),
    busy: busy ?? this.busy,
    searching: searching ?? this.searching,
    failure: failure,
  );
}

final class MapPickerCubit extends Cubit<MapPickerState> {
  MapPickerCubit(
    this.repository,
    this.device, {
    required this.language,
    TripLocation? initial,
  }) : super(
         MapPickerState(point: initial?.point, label: initial?.label ?? ''),
       );
  final MapsRepository repository;
  final DeviceLocation device;
  final String language;
  int _selection = 0, _search = 0, _label = 0;
  Timer? _debounce;
  void labelChanged(String label) {
    if (isClosed) return;
    _label++;
    emit(state.copy(label: label, failure: state.failure));
  }

  void choose(TripLocation location) {
    if (isClosed) return;
    _selection++;
    _cancelSearch();
    emit(MapPickerState(point: location.point, label: location.label));
  }

  void search(String query) {
    if (isClosed) return;
    _debounce?.cancel();
    final generation = ++_search;
    final q = query.trim();
    if (q.isEmpty) {
      emit(state.copy(results: [], searching: false));
      return;
    }
    if (q.runes.length > 100) {
      emit(
        state.copy(results: [], searching: false, failure: 'VALIDATION_ERROR'),
      );
      return;
    }
    emit(state.copy(searching: true, results: []));
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await repository.search(q, language: language);
        if (!isClosed && generation == _search) {
          emit(
            state.copy(
              results: results,
              searching: false,
              failure: state.failure,
            ),
          );
        }
      } catch (error) {
        if (!isClosed && generation == _search) {
          emit(state.copy(searching: false, failure: _code(error)));
        }
      }
    });
  }

  Future<void> select(GeoPoint point) async {
    if (isClosed) return;
    final generation = ++_selection, labelRevision = ++_label;
    _cancelSearch();
    emit(
      state.copy(
        point: point,
        label: '',
        busy: true,
        results: [],
        searching: false,
      ),
    );
    await _reverse(point, generation, labelRevision);
  }

  Future<void> _reverse(
    GeoPoint point,
    int generation,
    int labelRevision,
  ) async {
    try {
      final location = await repository.reverse(point, language: language);
      if (isClosed || generation != _selection) return;
      if (location.point != point) throw const MapsFailure('INVALID_RESPONSE');
      emit(
        state.copy(
          label: labelRevision == _label ? location.label : state.label,
          busy: false,
        ),
      );
    } catch (error) {
      if (!isClosed && generation == _selection) {
        emit(state.copy(busy: false, failure: _code(error)));
      }
    }
  }

  Future<void> locate() async {
    if (isClosed || state.busy) return;
    final generation = ++_selection, labelRevision = ++_label;
    _cancelSearch();
    emit(state.copy(busy: true, results: [], searching: false));
    try {
      final point = await device.locate();
      if (isClosed || generation != _selection) return;
      emit(
        state.copy(
          point: point,
          label: labelRevision == _label ? '' : state.label,
          busy: true,
        ),
      );
      await _reverse(point, generation, labelRevision);
    } catch (error) {
      if (!isClosed && generation == _selection) {
        emit(state.copy(busy: false, failure: _code(error)));
      }
    }
  }

  void _cancelSearch() {
    _search++;
    _debounce?.cancel();
  }

  String _code(Object error) =>
      error is MapsFailure ? error.code : 'SERVICE_UNAVAILABLE';
  @override
  Future<void> close() {
    _selection++;
    _search++;
    _debounce?.cancel();
    return super.close();
  }
}
