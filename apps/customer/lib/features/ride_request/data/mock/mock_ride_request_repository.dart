import 'dart:math' as math;

import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Deterministic simulation. Trips are written exclusively to the injected store.
final class MockRideRequestRepository implements RideRequestRepository {
  MockRideRequestRepository({
    required MockTripStore trips,
    DateTime Function()? now,
    this.failNextQuote = false,
    this.loseFirstConfirmationResponse = false,
  }) : _trips = trips,
       _now = now ?? DateTime.now;

  final MockTripStore _trips;
  final DateTime Function() _now;
  bool failNextQuote;
  bool loseFirstConfirmationResponse;
  int _sequence = 0;
  final Map<String, RideQuote> _quotes = {};
  // Tracks successful store writes only, not another trip collection.
  final Map<String, String> _committedQuotesByKey = {};

  @override
  Future<List<RidePlace>> searchPlaces(String query) async {
    final needle = query.trim().toLowerCase();
    return List.unmodifiable(
      mockRidePlaces.where(
        (place) =>
            place.location.label.toLowerCase().contains(needle) ||
            place.englishLabel.toLowerCase().contains(needle),
      ),
    );
  }

  @override
  Future<RideQuote> requestQuote({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass vehicleClass,
  }) async {
    _checkRoute(pickup, destination);
    if (failNextQuote) {
      failNextQuote = false;
      throw const RideRequestFailure('SERVICE_UNAVAILABLE');
    }
    final straightMeters = _haversineMeters(pickup, destination);
    final distanceMeters = (straightMeters * 1.35).round();
    final kilometers = (distanceMeters / 1000).ceil();
    final base = switch (vehicleClass) {
      RideVehicleClass.standard => 15000,
      RideVehicleClass.comfort => 25000,
      RideVehicleClass.van => 35000,
      RideVehicleClass.motorbike => 5000,
    };
    final quote = RideQuote(
      id: 'mock-quote-${++_sequence}',
      pickup: pickup,
      destination: destination,
      vehicleClass: vehicleClass,
      fare: Money(amountMinor: base + kilometers * 2000),
      distanceMeters: distanceMeters,
      durationMinutes: math.max(5, (distanceMeters / 280).ceil()),
      expiresAt: _now().toUtc().add(const Duration(seconds: 90)),
    );
    _quotes[quote.id] = quote;
    return quote;
  }

  @override
  Future<Trip> confirm({
    required RideQuote quote,
    required String idempotencyKey,
  }) async {
    _checkRoute(quote.pickup, quote.destination);
    if (idempotencyKey.trim().isEmpty) {
      throw const RideRequestFailure('VALIDATION_ERROR');
    }
    final issued = _quotes[quote.id];
    if (issued == null || issued != quote) {
      throw const RideRequestFailure('VALIDATION_ERROR');
    }
    final committedQuoteId = _committedQuotesByKey[idempotencyKey];
    if (committedQuoteId != null && committedQuoteId != quote.id) {
      throw const RideRequestFailure('IDEMPOTENCY_CONFLICT');
    }
    // A retry after a lost server response must resolve the original booking,
    // even when the quote expired after that booking was committed.
    if (!quote.isValidAt(_now()) && committedQuoteId == null) {
      throw const RideRequestFailure('QUOTE_EXPIRED');
    }
    try {
      final trip = _trips.create(
        TripBookingInput(
          pickup: quote.pickup,
          destination: quote.destination,
          vehicleClassId: quote.vehicleClass.name,
          fare: quote.fare,
        ),
        idempotencyKey: idempotencyKey,
      );
      _committedQuotesByKey[idempotencyKey] = quote.id;
      if (loseFirstConfirmationResponse) {
        loseFirstConfirmationResponse = false;
        throw const RideRequestFailure('SERVICE_UNAVAILABLE');
      }
      return trip;
    } on MockTripStoreFailure catch (failure) {
      throw RideRequestFailure(failure.code);
    }
  }

  static void _checkRoute(TripLocation pickup, TripLocation destination) {
    if (pickup.label.trim().isEmpty ||
        destination.label.trim().isEmpty ||
        pickup.point == destination.point) {
      throw const RideRequestFailure('VALIDATION_ERROR');
    }
  }

  static double _haversineMeters(TripLocation a, TripLocation b) {
    const radius = 6371000.0;
    final latDelta = (b.point.latitude - a.point.latitude) * math.pi / 180;
    final lonDelta = (b.point.longitude - a.point.longitude) * math.pi / 180;
    final aLat = a.point.latitude * math.pi / 180;
    final bLat = b.point.latitude * math.pi / 180;
    final square =
        math.pow(math.sin(latDelta / 2), 2) +
        math.cos(aLat) * math.cos(bLat) * math.pow(math.sin(lonDelta / 2), 2);
    return radius * 2 * math.atan2(math.sqrt(square), math.sqrt(1 - square));
  }
}
