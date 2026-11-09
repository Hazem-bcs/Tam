import 'chat_models.dart';
export 'chat_models.dart';

final class ChatPolicy {
  const ChatPolicy({
    this.maxBodyCodePoints = 1000,
    this.pageSize = 30,
    this.pollInterval = const Duration(seconds: 5),
  });
  final int maxBodyCodePoints, pageSize;
  final Duration pollInterval;
  String validate(String body) {
    final value = body.trim();
    if (value.isEmpty || value.runes.length > maxBodyCodePoints) {
      throw const ChatFailure('VALIDATION_ERROR');
    }
    return value;
  }
}

final class ChatFailure implements Exception {
  const ChatFailure(this.code, {this.uncertain = false});
  final String code;
  final bool uncertain;
}

final class ChatChange {
  const ChatChange({this.sessionReset = false});
  final bool sessionReset;
}

abstract interface class ChatRepository {
  Future<ChatMessagePage> fetch(String tripId, {int? beforeSequence});
  Future<ChatSent> send(
    String tripId, {
    required String clientMessageId,
    required String body,
  });
  Future<ChatMetadata> markRead(String tripId, int throughSequence);
  Stream<ChatChange> get changes;
}
