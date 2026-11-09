import '../../domain/chat_repository.dart';

final class ChatState {
  ChatState({
    this.metadata,
    Iterable<ChatMessage> messages = const [],
    Iterable<ChatPending> pending = const [],
    this.loading = false,
    this.loadingOlder = false,
    this.failure,
    this.nextBeforeSequence,
    this.loaded = false,
    this.sessionEnded = false,
  }) : messages = List.unmodifiable(messages),
       pending = List.unmodifiable(pending);
  final ChatMetadata? metadata;
  final List<ChatMessage> messages;
  final List<ChatPending> pending;
  final bool loading, loadingOlder, loaded, sessionEnded;
  final String? failure;
  final int? nextBeforeSequence;
  bool get canSend =>
      !sessionEnded &&
      loaded &&
      metadata?.canSend == true &&
      !{
        'DRIVER_CHANGED',
        'CHAT_UNAVAILABLE',
        'TRIP_NOT_FOUND',
      }.contains(failure);
}
