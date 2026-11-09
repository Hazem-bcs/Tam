import 'package:equatable/equatable.dart';

enum ChatAuthor { customer, driver }

enum ChatSendStatus { sending, failed, uncertain }

final class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.sequence,
    required this.author,
    required this.body,
    required this.sentAt,
    this.clientMessageId,
  });
  final String id, body;
  final int sequence;
  final ChatAuthor author;
  final DateTime sentAt;
  final String? clientMessageId;
  @override
  List<Object?> get props => [
    id,
    sequence,
    author,
    body,
    sentAt,
    clientMessageId,
  ];
}

final class ChatMetadata extends Equatable {
  const ChatMetadata({
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.driverNameEn,
    required this.revision,
    required this.canSend,
    this.deliveredThrough = 0,
    this.readThrough = 0,
    this.customerReadThrough = 0,
  });
  final String tripId, driverId, driverName, driverNameEn;
  final int revision, deliveredThrough, readThrough, customerReadThrough;
  final bool canSend;
  @override
  List<Object?> get props => [
    tripId,
    driverId,
    driverName,
    driverNameEn,
    revision,
    canSend,
    deliveredThrough,
    readThrough,
    customerReadThrough,
  ];
}

final class ChatMessagePage {
  ChatMessagePage({
    required this.metadata,
    required Iterable<ChatMessage> messages,
    this.nextBeforeSequence,
  }) : messages = List.unmodifiable(messages);
  final ChatMetadata metadata;
  final List<ChatMessage> messages;
  final int? nextBeforeSequence;
}

final class ChatSent {
  const ChatSent(this.metadata, this.message);
  final ChatMetadata metadata;
  final ChatMessage message;
}

final class ChatPending extends Equatable {
  const ChatPending({
    required this.clientMessageId,
    required this.body,
    required this.createdAt,
    required this.status,
  });
  final String clientMessageId, body;
  final DateTime createdAt;
  final ChatSendStatus status;
  ChatPending withStatus(ChatSendStatus value) => ChatPending(
    clientMessageId: clientMessageId,
    body: body,
    createdAt: createdAt,
    status: value,
  );
  @override
  List<Object?> get props => [clientMessageId, body, createdAt, status];
}
