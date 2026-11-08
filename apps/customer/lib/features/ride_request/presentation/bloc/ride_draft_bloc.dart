import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/shared/domain/trip.dart';

export 'ride_draft_state.dart';

/// Owns the draft, quote lifecycle and single in-flight confirmation.
final class RideDraftBloc extends Bloc<RideDraftEvent, RideDraftState> {
  RideDraftBloc({
    required RideRequestRepository repository,
    TripPrefill? prefill,
    DateTime Function()? now,
    String Function()? newIdempotencyKey,
  }) : _repository = repository,
       _now = now ?? DateTime.now,
       _newKey = newIdempotencyKey ?? _randomKey,
       super(
         RideDraftState(
           pickup: prefill?.pickup,
           destination: prefill?.destination,
         ),
       ) {
    on<PickupSelected>((event, emit) {
      if (_locked) return;
      _resetQuote();
      emit(
        state.copyWith(
          pickup: event.location,
          clearQuote: true,
          clearError: true,
          status: RideFlowStatus.editing,
        ),
      );
      if (state.hasRoute) add(const RideQuoteRequested());
    });
    on<DestinationSelected>((event, emit) {
      if (_locked) return;
      _resetQuote();
      emit(
        state.copyWith(
          destination: event.location,
          clearQuote: true,
          clearError: true,
          status: RideFlowStatus.editing,
        ),
      );
      if (state.hasRoute) add(const RideQuoteRequested());
    });
    on<VehicleClassSelected>((event, emit) {
      if (_locked || state.vehicleClass == event.vehicleClass) return;
      _resetQuote();
      emit(
        state.copyWith(
          vehicleClass: event.vehicleClass,
          clearQuote: true,
          clearError: true,
          status: RideFlowStatus.editing,
        ),
      );
      if (state.hasRoute) add(const RideQuoteRequested());
    });
    on<RidePlaceSearchChanged>(_search);
    on<RideQuoteRequested>(_quote);
    on<RideConfirmationRequested>(_confirm);
    on<RideQuoteExpired>((event, emit) {
      if (state.quote?.id != event.id || _locked || _pendingKey != null) return;
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: 'QUOTE_EXPIRED',
          failureStep: RideFailureStep.quote,
        ),
      );
    });
    if (prefill != null && state.hasRoute) add(const RideQuoteRequested());
  }

  final RideRequestRepository _repository;
  final DateTime Function() _now;
  final String Function() _newKey;
  Timer? _expiryTimer;
  String? _pendingKey;
  bool _confirming = false;
  int _revision = 0;
  int _searchRevision = 0;

  bool get _locked => _confirming || state.status == RideFlowStatus.booked;

  void _resetQuote() {
    _revision++;
    _expiryTimer?.cancel();
    _pendingKey = null;
  }

  Future<void> _search(
    RidePlaceSearchChanged event,
    Emitter<RideDraftState> emit,
  ) async {
    final requestId = ++_searchRevision;
    emit(
      state.copyWith(
        searching: true,
        suggestions: const [],
        clearSearchError: true,
      ),
    );
    try {
      final places = await _repository.searchPlaces(event.query);
      if (requestId == _searchRevision && !isClosed) {
        emit(
          state.copyWith(
            searching: false,
            suggestions: places,
            clearSearchError: true,
          ),
        );
      }
    } on RideRequestFailure catch (error) {
      if (requestId == _searchRevision && !isClosed) {
        emit(state.copyWith(searching: false, searchError: error.code));
      }
    }
  }

  Future<void> _quote(
    RideQuoteRequested event,
    Emitter<RideDraftState> emit,
  ) async {
    if (_locked || !state.hasRoute) {
      if (!_locked) {
        emit(
          state.copyWith(
            status: RideFlowStatus.failed,
            errorCode: 'VALIDATION_ERROR',
            failureStep: RideFailureStep.quote,
            clearQuote: true,
          ),
        );
      }
      return;
    }
    _resetQuote();
    final revision = _revision;
    final pickup = state.pickup!;
    final destination = state.destination!;
    final vehicle = state.vehicleClass;
    emit(
      state.copyWith(
        status: RideFlowStatus.quoting,
        clearQuote: true,
        clearError: true,
      ),
    );
    try {
      final quote = await _repository.requestQuote(
        pickup: pickup,
        destination: destination,
        vehicleClass: vehicle,
      );
      if (isClosed || revision != _revision) return;
      if (!quote.isValidAt(_now())) {
        throw const RideRequestFailure('QUOTE_EXPIRED');
      }
      emit(
        state.copyWith(
          quote: quote,
          status: RideFlowStatus.ready,
          clearError: true,
        ),
      );
      _expiryTimer?.cancel();
      _expiryTimer = Timer(quote.expiresAt.difference(_now()), () {
        if (!isClosed) add(RideQuoteExpired(quote.id));
      });
    } on RideRequestFailure catch (error) {
      if (isClosed || revision != _revision) return;
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: error.code,
          failureStep: RideFailureStep.quote,
          clearQuote: true,
        ),
      );
    }
  }

  Future<void> _confirm(
    RideConfirmationRequested event,
    Emitter<RideDraftState> emit,
  ) async {
    // Set the guard before the first await; consecutive taps share one request.
    if (_locked) return;
    final retryingUncertainConfirmation =
        _pendingKey != null &&
        state.failureStep == RideFailureStep.confirmation &&
        state.quote != null &&
        state.hasRoute;
    if (!retryingUncertainConfirmation && !state.canConfirmAt(_now())) {
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: state.quote != null && !state.quote!.isValidAt(_now())
              ? 'QUOTE_EXPIRED'
              : 'VALIDATION_ERROR',
          failureStep: RideFailureStep.quote,
        ),
      );
      return;
    }
    _confirming = true;
    // An uncertain confirmation can be retried with its original key even
    // if the quote expires while waiting for the server response.
    _expiryTimer?.cancel();
    final quote = state.quote!;
    _pendingKey ??= _newKey();
    emit(state.copyWith(status: RideFlowStatus.confirming, clearError: true));
    try {
      final trip = await _repository.confirm(
        quote: quote,
        idempotencyKey: _pendingKey!,
      );
      if (isClosed) return;
      _expiryTimer?.cancel();
      emit(
        state.copyWith(
          confirmedTrip: trip,
          status: RideFlowStatus.booked,
          clearError: true,
        ),
      );
    } on RideRequestFailure catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: error.code,
          failureStep: error.code == 'QUOTE_EXPIRED'
              ? RideFailureStep.quote
              : RideFailureStep.confirmation,
        ),
      );
    } finally {
      _confirming = false;
    }
  }

  static String _randomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  Future<void> close() async {
    _expiryTimer?.cancel();
    await super.close();
  }
}
