import 'dart:async';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final supportNow = DateTime.utc(2026, 11, 9, 12);
MockTripStore supportStore() => MockTripStore(
  seed: [
    Trip(
      id: 'trip-1',
      booking: TripBookingInput(
        pickup: TripLocation(
          label: 'A',
          point: GeoPoint(latitude: 33, longitude: 36),
        ),
        destination: TripLocation(
          label: 'B',
          point: GeoPoint(latitude: 33.1, longitude: 36.1),
        ),
        vehicleClassId: 'standard',
        fare: Money(amountMinor: 27000),
      ),
      createdAt: supportNow,
      status: TripStatus.completed,
    ),
  ],
  now: () => supportNow,
);
SupportTicket supportTicket({
  String id = 'ticket-1',
  String clientId = 'request-0000000001',
  String body = 'Details of the issue',
  String category = 'general',
  String? tripId,
  int revision = 1,
}) => SupportTicket(
  id: id,
  clientRequestId: clientId,
  categoryId: category,
  body: body,
  status: SupportTicketStatus.open,
  createdAt: supportNow,
  updatedAt: supportNow,
  revision: revision,
  tripId: tripId,
);

final class ControlledSupportRepository implements SupportRepository {
  final events = StreamController<SupportChange>.broadcast(sync: true);
  Future<SupportOptions> Function(String?)? onOptions;
  Future<SupportTicketPage> Function(String?)? onList;
  Future<SupportTicket> Function(String)? onTicket;
  Future<SupportTicket> Function(String, String, String, String?)? onCreate;
  Future<LegalDocument?> Function(LegalDocumentKind, String)? onLegal;
  final requests =
      <({String id, String category, String body, String? tripId})>[];
  @override
  Future<SupportOptions> options({String? tripId}) =>
      onOptions?.call(tripId) ??
      Future.value(
        SupportOptions(
          tripId: tripId,
          categories: const [
            SupportCategory(
              id: 'general',
              nameAr: 'استفسار عام',
              nameEn: 'General question',
            ),
          ],
        ),
      );
  @override
  Future<SupportTicketPage> tickets({String? cursor}) =>
      onList?.call(cursor) ?? Future.value(SupportTicketPage(tickets: []));
  @override
  Future<SupportTicket> ticket(String id) =>
      onTicket?.call(id) ?? Future.value(supportTicket(id: id));
  @override
  Future<SupportTicket> create({
    required String clientRequestId,
    required String categoryId,
    required String body,
    String? tripId,
  }) {
    requests.add((
      id: clientRequestId,
      category: categoryId,
      body: body,
      tripId: tripId,
    ));
    return onCreate?.call(clientRequestId, categoryId, body, tripId) ??
        Future.value(
          supportTicket(
            clientId: clientRequestId,
            category: categoryId,
            body: body,
            tripId: tripId,
          ),
        );
  }

  @override
  Future<LegalDocument?> legal(
    LegalDocumentKind kind, {
    required String languageCode,
  }) => onLegal?.call(kind, languageCode) ?? Future.value(null);
  @override
  Stream<SupportChange> get changes => events.stream;
}

Future<void> flushSupport() => Future<void>.delayed(Duration.zero);
