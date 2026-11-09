import '../../domain/support_repository.dart';

final class SupportEditorState {
  const SupportEditorState({
    this.options,
    this.body = '',
    this.categoryId,
    this.loading = true,
    this.sending = false,
    this.locked = false,
    this.ended = false,
    this.failure,
    this.accepted,
  });
  final SupportOptions? options;
  final String body;
  final String? categoryId;
  final bool loading, sending, locked, ended;
  final SupportFailure? failure;
  final SupportTicket? accepted;
  SupportEditorState copyWith({
    SupportOptions? options,
    String? body,
    String? categoryId,
    bool? loading,
    bool? sending,
    bool? locked,
    bool? ended,
    SupportFailure? failure,
    bool clearFailure = false,
    SupportTicket? accepted,
  }) => SupportEditorState(
    options: options ?? this.options,
    body: body ?? this.body,
    categoryId: categoryId ?? this.categoryId,
    loading: loading ?? this.loading,
    sending: sending ?? this.sending,
    locked: locked ?? this.locked,
    ended: ended ?? this.ended,
    failure: clearFailure ? null : failure ?? this.failure,
    accepted: accepted ?? this.accepted,
  );
}
