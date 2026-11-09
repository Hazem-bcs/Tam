import '../../domain/chat_models.dart';

abstract final class ChatFixtures {
  static List<ChatMessage> messages(String tripId, DateTime time) => [
    ChatMessage(
      id: '$tripId-message-1',
      sequence: 1,
      author: ChatAuthor.driver,
      body: 'مرحبًا، أنا في طريقي إليك.',
      sentAt: time.subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: '$tripId-message-2',
      sequence: 2,
      clientMessageId: '$tripId-fixture-2',
      author: ChatAuthor.customer,
      body: 'أهلًا، أنا عند المدخل الرئيسي.',
      sentAt: time.subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      id: '$tripId-message-3',
      sequence: 3,
      author: ChatAuthor.driver,
      body: 'تمام، سأصل خلال دقائق.',
      sentAt: time.subtract(const Duration(minutes: 1)),
    ),
  ];
}
