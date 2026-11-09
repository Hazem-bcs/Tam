import 'package:tam_customer/shared/data/utc_timestamp.dart';
import '../domain/chat_repository.dart';

/// Versioned boundary for the proposed API. No HTTP or transport leaks to domain.
abstract final class ChatCodec {
  static Map<String, dynamic> _object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static String _text(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid $key');
    }
    return value;
  }

  static int _integer(Map<String, dynamic> json, String key, {int min = 0}) {
    final value = json[key];
    if (value is! int || value < min) throw FormatException('Invalid $key');
    return value;
  }

  static ChatMetadata metadata(Object? value) {
    final json = _object(value);
    final driver = _object(json['driver']);
    if (json['version'] != 1 || json['can_send'] is! bool) {
      throw const FormatException('Invalid chat version/eligibility');
    }
    final delivered = _integer(json, 'delivered_through');
    final read = _integer(json, 'read_through');
    if (read > delivered) throw const FormatException('Receipt order');
    return ChatMetadata(
      tripId: _text(json, 'trip_id'),
      driverId: _text(driver, 'id'),
      driverName: _text(driver, 'name_ar'),
      driverNameEn: _text(driver, 'name_en'),
      revision: _integer(json, 'revision', min: 1),
      canSend: json['can_send'] as bool,
      deliveredThrough: delivered,
      readThrough: read,
      customerReadThrough: _integer(json, 'customer_read_through'),
    );
  }

  static ChatMessage message(
    Object? value, {
    ChatPolicy policy = const ChatPolicy(),
  }) {
    final json = _object(value);
    final author = switch (json['author']) {
      'customer' => ChatAuthor.customer,
      'driver' => ChatAuthor.driver,
      _ => throw const FormatException('Invalid author'),
    };
    final body = _text(json, 'body');
    if (body != body.trim() || body.runes.length > policy.maxBodyCodePoints) {
      throw const FormatException('Invalid body');
    }
    final clientId = json['client_message_id'];
    if ((author == ChatAuthor.customer &&
            (clientId is! String || clientId.trim().isEmpty)) ||
        (author == ChatAuthor.driver && clientId != null)) {
      throw const FormatException('Invalid client id');
    }
    return ChatMessage(
      id: _text(json, 'id'),
      sequence: _integer(json, 'sequence', min: 1),
      author: author,
      body: body,
      sentAt: UtcTimestamp.parse(json['sent_at']),
      clientMessageId: clientId as String?,
    );
  }

  static ChatMessagePage page(
    Map<String, dynamic> envelope, {
    ChatPolicy policy = const ChatPolicy(),
  }) {
    final data = _object(envelope['data']);
    final meta = metadata(data['metadata']);
    final items = data['messages'];
    if (items is! List || items.length > policy.pageSize) {
      throw const FormatException('Invalid messages');
    }
    final messages = items
        .map((item) => message(item, policy: policy))
        .toList();
    var previous = 0;
    final ids = <String>{}, clientIds = <String>{};
    DateTime? lastTime;
    for (final item in messages) {
      if (item.sequence <= previous ||
          !ids.add(item.id) ||
          (item.clientMessageId != null &&
              !clientIds.add(item.clientMessageId!)) ||
          (lastTime != null && item.sentAt.isBefore(lastTime))) {
        throw const FormatException('Invalid message order/identity');
      }
      previous = item.sequence;
      lastTime = item.sentAt;
    }
    final next = data['next_before_sequence'];
    if (!data.containsKey('next_before_sequence') ||
        (next != null &&
            (next is! int ||
                messages.isEmpty ||
                next != messages.first.sequence))) {
      throw const FormatException('Invalid cursor');
    }
    return ChatMessagePage(
      metadata: meta,
      messages: messages,
      nextBeforeSequence: next as int?,
    );
  }

  static ChatSent sent(Map<String, dynamic> envelope) {
    final data = _object(envelope['data']);
    final item = message(data['message']);
    if (item.author != ChatAuthor.customer) {
      throw const FormatException('Send must return customer message');
    }
    return ChatSent(metadata(data['metadata']), item);
  }

  static ChatMetadata read(Map<String, dynamic> envelope) =>
      metadata(_object(envelope['data'])['metadata']);
  static ChatFailure failure(Map<String, dynamic> envelope) {
    final error = _object(envelope['error']);
    final text = _object(error['message']);
    _text(text, 'ar');
    _text(text, 'en');
    return ChatFailure(_text(error, 'code'));
  }

  static Map<String, dynamic> encodeMetadata(ChatMetadata meta) => {
    'version': 1,
    'trip_id': meta.tripId,
    'driver': {
      'id': meta.driverId,
      'name_ar': meta.driverName,
      'name_en': meta.driverNameEn,
    },
    'revision': meta.revision,
    'can_send': meta.canSend,
    'delivered_through': meta.deliveredThrough,
    'read_through': meta.readThrough,
    'customer_read_through': meta.customerReadThrough,
  };
  static Map<String, dynamic> encodeMessage(ChatMessage message) => {
    'id': message.id,
    'sequence': message.sequence,
    'author': message.author.name,
    'client_message_id': message.clientMessageId,
    'body': message.body,
    'sent_at': message.sentAt.toUtc().toIso8601String(),
  };
  static Map<String, dynamic> encodePage(ChatMessagePage page) => {
    'data': {
      'metadata': encodeMetadata(page.metadata),
      'messages': page.messages.map(encodeMessage).toList(),
      'next_before_sequence': page.nextBeforeSequence,
    },
  };
}
