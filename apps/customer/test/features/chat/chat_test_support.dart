import 'dart:async';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

final chatNow = DateTime.utc(2026, 11, 9, 12);
const chatDriver = TripDriver(
  id: 'driver-1',
  name: 'أحمد',
  nameEn: 'Ahmad',
  vehicle: 'سيارة',
  vehicleEn: 'Car',
  plate: '123',
  rating: 4.8,
);
Trip chatTrip({
  String id = 'trip-1',
  TripStatus status = TripStatus.confirmed,
  TripDriver? driver = chatDriver,
  int revision = 1,
}) => Trip(
  id: id,
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
  createdAt: chatNow.subtract(const Duration(minutes: 5)),
  status: status,
  live: TripLiveDetails(
    revision: revision,
    updatedAt: chatNow,
    statusChangedAt: chatNow,
    driver: driver,
  ),
);
MockTripStore chatStore() =>
    MockTripStore(seed: [chatTrip()], now: () => chatNow);
ChatMetadata chatMetadata({
  int revision = 1,
  bool canSend = true,
  int delivered = 0,
  int read = 0,
  int customerRead = 0,
}) => ChatMetadata(
  tripId: 'trip-1',
  driverId: 'driver-1',
  driverName: 'أحمد',
  driverNameEn: 'Ahmad',
  revision: revision,
  canSend: canSend,
  deliveredThrough: delivered,
  readThrough: read,
  customerReadThrough: customerRead,
);
ChatMessage chatMessage(int sequence, {String? clientId}) => ChatMessage(
  id: 'message-$sequence',
  sequence: sequence,
  author: clientId == null ? ChatAuthor.driver : ChatAuthor.customer,
  body: 'message $sequence',
  sentAt: chatNow,
  clientMessageId: clientId,
);

final class ControlledChatRepository implements ChatRepository {
  final events = StreamController<ChatChange>.broadcast(sync: true);
  Future<ChatMessagePage> Function(int?)? onFetch;
  Future<ChatSent> Function(String, String)? onSend;
  Future<ChatMetadata> Function(int)? onRead;
  final reads = <int>[];
  final sends = <String>[];
  @override
  Future<ChatMessagePage> fetch(String tripId, {int? beforeSequence}) =>
      onFetch?.call(beforeSequence) ??
      Future.value(
        ChatMessagePage(metadata: chatMetadata(), messages: [chatMessage(1)]),
      );
  @override
  Future<ChatSent> send(
    String tripId, {
    required String clientMessageId,
    required String body,
  }) {
    sends.add(clientMessageId);
    return onSend?.call(clientMessageId, body) ??
        Future.value(
          ChatSent(
            chatMetadata(revision: 2),
            ChatMessage(
              id: 'sent',
              sequence: 2,
              author: ChatAuthor.customer,
              body: body,
              sentAt: chatNow,
              clientMessageId: clientMessageId,
            ),
          ),
        );
  }

  @override
  Future<ChatMetadata> markRead(String tripId, int throughSequence) {
    reads.add(throughSequence);
    return onRead?.call(throughSequence) ??
        Future.value(chatMetadata(revision: 2, customerRead: throughSequence));
  }

  @override
  Stream<ChatChange> get changes => events.stream;
}

Future<void> chatFlush() => Future<void>.delayed(Duration.zero);
