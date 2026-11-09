import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../../domain/chat_repository.dart';
import '../bloc/chat_cubit.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final _scroll = ScrollController();
  bool _resumed = true, _atNewest = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    context.read<ChatCubit>().setActive(_resumed);
    if (_resumed) _scheduleRead();
  }

  void _onScroll() {
    final newest = _scroll.hasClients && _scroll.offset < 32;
    if (newest != _atNewest) setState(() => _atNewest = newest);
    if (newest) _scheduleRead();
  }

  void _scheduleRead() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_resumed ||
          !_atNewest ||
          ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      final cubit = context.read<ChatCubit>();
      final last = cubit.state.messages.lastOrNull;
      if (last != null) cubit.displayedThrough(last.sequence);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (_, state) => _scheduleRead(),
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final metadata = state.metadata;
        final name = Localizations.localeOf(context).languageCode == 'ar'
            ? metadata?.driverName
            : metadata?.driverNameEn;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: widget.onBack),
            title: Text(name ?? t.chatTitle),
            actions: [
              IconButton(
                key: const Key('chat-refresh'),
                tooltip: t.chatRefresh,
                onPressed: cubit.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    if (state.failure != null)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          _failure(t, state.failure!),
                          semanticsLabel: _failure(t, state.failure!),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    if (metadata != null && !state.canSend)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(t.chatReadOnly),
                      ),
                    if (state.loading)
                      Expanded(
                        child: Center(
                          child: TamLoadingIndicator(
                            semanticLabel: t.chatLoading,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: state.messages.isEmpty && state.pending.isEmpty
                            ? Center(child: Text(t.chatEmpty))
                            : ListView.builder(
                                controller: _scroll,
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                itemCount:
                                    state.messages.length +
                                    state.pending.length +
                                    (state.nextBeforeSequence == null ? 0 : 1),
                                itemBuilder: (_, index) {
                                  final count =
                                      state.messages.length +
                                      state.pending.length;
                                  if (index == count) {
                                    return TextButton(
                                      key: const Key('chat-load-older'),
                                      onPressed: state.loadingOlder
                                          ? null
                                          : cubit.loadOlder,
                                      child: Text(
                                        state.loadingOlder
                                            ? t.chatLoading
                                            : t.chatLoadOlder,
                                      ),
                                    );
                                  }
                                  final chronological = count - 1 - index;
                                  if (chronological >= state.messages.length) {
                                    final p =
                                        state.pending[chronological -
                                            state.messages.length];
                                    return ChatMessageBubble(
                                      key: ValueKey(p.clientMessageId),
                                      body: p.body,
                                      sentAt: p.createdAt,
                                      customer: true,
                                      status: switch (p.status) {
                                        ChatSendStatus.sending => t.chatSending,
                                        ChatSendStatus.failed => t.chatFailed,
                                        ChatSendStatus.uncertain =>
                                          t.chatUncertain,
                                      },
                                      onRetry:
                                          p.status == ChatSendStatus.sending ||
                                              !state.canSend
                                          ? null
                                          : () =>
                                                cubit.retry(p.clientMessageId),
                                    );
                                  }
                                  final message = state.messages[chronological];
                                  return ChatMessageBubble(
                                    key: ValueKey(message.id),
                                    body: message.body,
                                    sentAt: message.sentAt,
                                    customer:
                                        message.author == ChatAuthor.customer,
                                    status: chatReceiptLabel(
                                      t,
                                      message,
                                      metadata,
                                    ),
                                  );
                                },
                              ),
                      ),
                    if (!_atNewest)
                      TextButton.icon(
                        key: const Key('chat-newest'),
                        onPressed: () {
                          _scroll.jumpTo(0);
                          _scheduleRead();
                        },
                        icon: const Icon(Icons.arrow_downward),
                        label: Text(t.chatNewest),
                      ),
                    ChatComposer(
                      enabled: state.canSend,
                      maxLength: cubit.policy.maxBodyCodePoints,
                      onSend: (body) =>
                          _resumed &&
                          ModalRoute.of(context)?.isCurrent != false &&
                          cubit.send(body),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _failure(AppLocalizations t, String code) => switch (code) {
  'VALIDATION_ERROR' => t.chatValidation,
  'DRIVER_CHANGED' ||
  'CHAT_UNAVAILABLE' ||
  'TRIP_NOT_FOUND' => t.chatUnavailable,
  'CHAT_CLOSED' => t.chatReadOnly,
  'SESSION_ENDED' => t.chatSessionEnded,
  _ => t.chatConnectionError,
};
