import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../bloc/chat_cubit.dart';
import '../widgets/chat_background.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_status_banner.dart';
import '../widgets/chat_timeline.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final _scroll = ScrollController();
  final _timelineKey = GlobalKey(), _latestMessageKey = GlobalKey();
  bool _resumed = true, _atNewest = true;
  int _lastSequence = 0;
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
      final messageBox = _latestMessageKey.currentContext?.findRenderObject();
      final viewport = _timelineKey.currentContext?.findRenderObject();
      if (last != null &&
          messageBox is RenderBox &&
          viewport is RenderBox &&
          messageBox.hasSize &&
          viewport.hasSize &&
          (messageBox.localToGlobal(Offset.zero) & messageBox.size).overlaps(
            viewport.localToGlobal(Offset.zero) & viewport.size,
          )) {
        cubit.displayedThrough(last.sequence);
      }
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
      listener: (_, state) {
        final sequence = state.messages.lastOrNull?.sequence ?? 0;
        if (!_atNewest && sequence > _lastSequence && _scroll.hasClients) {
          final offset = _scroll.offset;
          final extent = _scroll.position.maxScrollExtent;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scroll.hasClients && !_atNewest) {
              final delta = _scroll.position.maxScrollExtent - extent;
              _scroll.jumpTo(
                (offset + delta).clamp(0, _scroll.position.maxScrollExtent),
              );
            }
          });
        }
        _lastSequence = sequence;
        _scheduleRead();
      },
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();
        final metadata = state.metadata;
        final name = Localizations.localeOf(context).languageCode == 'ar'
            ? metadata?.driverName
            : metadata?.driverNameEn;
        return Scaffold(
          body: ChatBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Column(
                      children: [
                        ChatHeader(
                          name: name ?? t.chatTitle,
                          onBack: widget.onBack,
                          onRefresh: cubit.refresh,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * .16,
                          ),
                          child: ChatStatusBanner(state: state),
                        ),
                        Expanded(
                          child: ChatTimeline(
                            key: _timelineKey,
                            latestMessageKey: _latestMessageKey,
                            state: state,
                            now: cubit.now,
                            controller: _scroll,
                            onLoadOlder: cubit.loadOlder,
                            onRetry: cubit.retry,
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
                          maxHeight: (constraints.maxHeight * .28).clamp(
                            40,
                            180,
                          ),
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
            ),
          ),
        );
      },
    );
  }
}
