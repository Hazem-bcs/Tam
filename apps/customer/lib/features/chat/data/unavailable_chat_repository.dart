import '../domain/chat_repository.dart';

final class UnavailableChatRepository implements ChatRepository {
  const UnavailableChatRepository();
  @override
  Future<ChatMessagePage> fetch(String tripId, {int? beforeSequence}) async =>
      throw const ChatFailure('SERVICE_UNAVAILABLE');
  @override
  Future<ChatSent> send(
    String tripId, {
    required String clientMessageId,
    required String body,
  }) async => throw const ChatFailure('SERVICE_UNAVAILABLE');
  @override
  Future<ChatMetadata> markRead(String tripId, int throughSequence) async =>
      throw const ChatFailure('SERVICE_UNAVAILABLE');
  @override
  Stream<ChatChange> get changes => const Stream.empty();
}
