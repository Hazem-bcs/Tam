import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/domain/usecases/load_ride_quotes.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';
import 'package:tam_customer/shared/domain/trip.dart';

export 'ride_draft_state.dart';

/// Owns the draft, quote lifecycle and single in-flight confirmation.
final class RideDraftBloc extends Bloc<RideDraftEvent, RideDraftState> {
  RideDraftBloc({
    required RideRequestRepository repository,
    TripPrefill? prefill,
    this.schedulePolicy = const RideSchedulePolicy(),
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
    on<PickupSelected>(
      (event, emit) => _edit(
        state.copyWith(
          pickup: event.location,
          pickupFromDevice: event.fromDevice,
        ),
        emit,
      ),
    );
    on<DestinationSelected>(
      (event, emit) => _edit(state.copyWith(destination: event.location), emit),
    );
    on<VehicleClassSelected>((event, emit) {
      if (_locked || state.vehicleClass == event.vehicleClass) return;
      final cached = state.vehicleQuotes[event.vehicleClass];
      if (cached != null &&
          cached.isValidAt(_now()) &&
          schedulePolicy.allows(cached.scheduledAt, _now())) {
        _resetQuote();
        emit(
          state.copyWith(
            vehicleClass: event.vehicleClass,
            quote: cached,
            status: RideFlowStatus.ready,
            clearError: true,
          ),
        );
        _armExpiry(cached);
      } else {
        _edit(state.copyWith(vehicleClass: event.vehicleClass), emit);
      }
    });
    on<RideScheduleChanged>((event, emit) {
      if (_locked) return;
      final scheduledAt = event.scheduledAt?.toUtc();
      if (!schedulePolicy.allows(scheduledAt, _now())) {
        emit(
          state.copyWith(
            errorCode: 'SCHEDULE_OUT_OF_RANGE',
            failureStep: RideFailureStep.quote,
          ),
        );
        return;
      }
      if (scheduledAt != state.scheduledAt) {
        _edit(
          state.copyWith(
            scheduledAt: scheduledAt,
            clearSchedule: scheduledAt == null,
          ),
          emit,
        );
      }
    });
    on<RidePaymentChanged>((event, emit) {
      if (event.paymentMethod != state.paymentMethod) {
        _edit(state.copyWith(paymentMethod: event.paymentMethod), emit);
      }
    });
    on<RideCouponApplied>((event, emit) {
      final code = event.code.trim().toUpperCase();
      if (code != state.couponCode) {
        _edit(state.copyWith(couponCode: code), emit);
      }
    });
    on<RideCouponRemoved>((event, emit) {
      if (state.couponCode != null) {
        _edit(state.copyWith(clearCoupon: true), emit);
      }
    });
    on<RidePlaceSearchChanged>(_search);
    on<RideQuoteRequested>(_quote);
    on<RideConfirmationRequested>(_confirm);
    on<RideQuoteExpired>((event, emit) {
      if (state.quote?.id != event.id || _locked || _pendingKey != null) return;
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: schedulePolicy.allows(state.scheduledAt, _now())
              ? 'QUOTE_EXPIRED'
              : 'SCHEDULE_OUT_OF_RANGE',
          failureStep: RideFailureStep.quote,
        ),
      );
    });
    if (prefill != null && state.hasRoute) add(const RideQuoteRequested());
  }

  final RideSchedulePolicy schedulePolicy;
  DateTime get currentTime => _now().toUtc();
  bool get canConfirm => state.canConfirmAt(_now(), policy: schedulePolicy);
  final RideRequestRepository _repository;
  final DateTime Function() _now;
  final String Function() _newKey;
  Timer? _expiryTimer;
  String? _pendingKey;
  bool _confirming = false;
  int _revision = 0;
  int _searchRevision = 0;

  bool get _locked => _confirming || state.confirmationPending;

  void _edit(RideDraftState edited, Emitter<RideDraftState> emit) {
    if (_locked) return;
    _resetQuote();
    emit(
      edited.copyWith(
        clearQuote: true,
        vehicleQuotes: const {},
        clearError: true,
        status: RideFlowStatus.editing,
      ),
    );
    if (state.hasRoute) add(const RideQuoteRequested());
  }

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
    if (event.query.trim().isEmpty) {
      emit(
        state.copyWith(
          searching: false,
          suggestions: const [],
          clearSearchError: true,
        ),
      );
      return;
    }
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
    final scheduledAt = state.scheduledAt;
    final payment = state.paymentMethod;
    final coupon = state.couponCode;
    emit(
      state.copyWith(
        status: RideFlowStatus.quoting,
        vehicleQuotes: const {},
        clearQuote: true,
        clearError: true,
      ),
    );
    try {
      if (!schedulePolicy.allows(scheduledAt, _now())) {
        throw const RideRequestFailure('SCHEDULE_OUT_OF_RANGE');
      }
      final catalog = await LoadRideQuotes(_repository)(
        pickup: pickup,
        destination: destination,
        selected: vehicle,
        scheduledAt: scheduledAt,
        paymentMethod: payment,
        couponCode: coupon,
      );
      final quote = catalog[vehicle]!;
      if (isClosed || revision != _revision) return;
      if (quote.scheduledAt != scheduledAt) {
        throw const RideRequestFailure('INVALID_RESPONSE');
      }
      if (!schedulePolicy.allows(scheduledAt, _now())) {
        throw const RideRequestFailure('SCHEDULE_OUT_OF_RANGE');
      }
      if (!quote.isValidAt(_now())) {
        throw const RideRequestFailure('QUOTE_EXPIRED');
      }
      emit(
        state.copyWith(
          quote: quote,
          vehicleQuotes: catalog,
          status: RideFlowStatus.ready,
          clearError: true,
        ),
      );
      _armExpiry(quote);
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

  void _armExpiry(RideQuote quote) {
    _expiryTimer?.cancel();
    var deadline = quote.expiresAt;
    final scheduledAt = quote.scheduledAt;
    if (scheduledAt != null) {
      final scheduleDeadline = scheduledAt
          .subtract(schedulePolicy.minimumLeadTime)
          .add(const Duration(microseconds: 1));
      if (scheduleDeadline.isBefore(deadline)) deadline = scheduleDeadline;
    }
    _expiryTimer = Timer(deadline.difference(_now()), () {
      if (!isClosed) add(RideQuoteExpired(quote.id));
    });
  }

  Future<void> _confirm(
    RideConfirmationRequested event,
    Emitter<RideDraftState> emit,
  ) async {
    // Set the guard before the first await; consecutive taps share one request.
    if (_confirming || state.status == RideFlowStatus.booked) return;
    final retryingUncertainConfirmation =
        _pendingKey != null &&
        state.failureStep == RideFailureStep.confirmation &&
        state.quote != null &&
        state.hasRoute;
    if (!retryingUncertainConfirmation && !canConfirm) {
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: state.quote != null && !state.quote!.isValidAt(_now())
              ? 'QUOTE_EXPIRED'
              : !schedulePolicy.allows(state.scheduledAt, _now())
              ? 'SCHEDULE_OUT_OF_RANGE'
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
      final definitive = const {
        'QUOTE_EXPIRED',
        'SCHEDULE_OUT_OF_RANGE',
        'SCHEDULE_UNAVAILABLE',
        'VALIDATION_ERROR',
        'IDEMPOTENCY_CONFLICT',
        'COUPON_INVALID',
        'PAYMENT_UNAVAILABLE',
        'WALLET_INSUFFICIENT',
      }.contains(error.code);
      if (definitive) _pendingKey = null;
      emit(
        state.copyWith(
          status: RideFlowStatus.failed,
          errorCode: error.code,
          failureStep: definitive
              ? RideFailureStep.quote
              : RideFailureStep.confirmation,
          clearQuote: definitive,
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
