import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final length = _controller.text.trim().runes.length;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: TamTextField(
                key: const Key('chat-input'),
                controller: _controller,
                enabled: widget.enabled,
                labelText: t.chatMessageHint,
                maxLines: null,
                helperText: t.chatCharacterCount(length, widget.maxLength),
                keyboardType: TextInputType.multiline,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton.filled(
            key: const Key('chat-send'),
            tooltip: t.chatSend,
            onPressed:
                widget.enabled && length > 0 && length <= widget.maxLength
                ? () {
                    if (widget.onSend(_controller.text)) {
                      _controller.clear();
                      setState(() {});
                    }
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
