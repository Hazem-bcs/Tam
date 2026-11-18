import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.enabled,
    required this.maxLength,
    required this.onSend,
    this.maxHeight = 180,
  });
  final bool enabled;
  final int maxLength;
  final double maxHeight;
  final bool Function(String) onSend;
  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (widget.onSend(_controller.text)) {
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final length = _controller.text.trim().runes.length;
    final tooLong = length > widget.maxLength;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Material(
              color: colors.surfaceContainerLowest,
              elevation: AppElevation.raised,
              borderRadius: BorderRadius.circular(AppRadii.sheet),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                child: SingleChildScrollView(
                  child: TextField(
                    key: const Key('chat-input'),
                    controller: _controller,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: t.chatMessageHint,
                      error: tooLong ? Text(t.chatValidation) : null,
                      isDense: true,
                      constraints: const BoxConstraints(
                        minHeight: AppDimensions.minTapTarget,
                      ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton.filled(
            key: const Key('chat-send'),
            tooltip: t.chatSend,
            style: IconButton.styleFrom(
              minimumSize: const Size.square(AppDimensions.minTapTarget),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              disabledBackgroundColor: colors.onSurface.withValues(alpha: .08),
              disabledForegroundColor: colors.onSurface.withValues(alpha: .38),
              shape: const CircleBorder(),
            ),
            onPressed: widget.enabled && length > 0 && !tooLong ? _send : null,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
