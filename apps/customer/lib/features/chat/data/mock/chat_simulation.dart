import '../../domain/chat_repository.dart';

/// Synthetic server events caught up by reads, including after app suspension.
final class ChatSimulation {
  final _events = <_Delivery>[];
  void sent(ChatMessage message) => _events.add(_Delivery(message));
  ({int delivered, int read, bool changed}) advance(
    List<ChatMessage> messages,
    DateTime now, {
    required String tripId,
    required bool canReply,
    required int deliveredThrough,
    required int readThrough,
  }) {
    var delivered = deliveredThrough, read = readThrough, changed = false;
    for (final event in _events) {
      final age = now.difference(event.message.sentAt);
      if (age >= const Duration(seconds: 2) &&
          event.message.sequence > delivered) {
        delivered = event.message.sequence;
        changed = true;
      }
      if (age >= const Duration(seconds: 4) && event.message.sequence > read) {
        read = event.message.sequence;
        changed = true;
      }
      if (age >= const Duration(seconds: 6) && !event.replied) {
        event.replied = true;
        if (canReply) {
          final sequence = (messages.lastOrNull?.sequence ?? 0) + 1;
          final planned = event.message.sentAt.add(const Duration(seconds: 6));
          final last = messages.lastOrNull?.sentAt;
          messages.add(
            ChatMessage(
              id: '$tripId-message-$sequence',
              sequence: sequence,
              author: ChatAuthor.driver,
              body: 'وصلت رسالتك، شكرًا لك.',
              sentAt: last != null && planned.isBefore(last) ? last : planned,
            ),
          );
          changed = true;
        }
      }
    }
    return (delivered: delivered, read: read, changed: changed);
  }
}

final class _Delivery {
  _Delivery(this.message);
  final ChatMessage message;
  bool replied = false;
}
