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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final length = _controller.text.trim().runes.length;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: colors.surfaceContainerLowest,
        elevation: AppElevation.raised,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: SingleChildScrollView(
                    child: TextField(
                      key: const Key('chat-input'),
                      controller: _controller,
                      enabled: widget.enabled,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: t.chatMessageHint,
                        helperText: length > 0
                            ? t.chatCharacterCount(length, widget.maxLength)
                            : null,
                        filled: true,
                        fillColor: colors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sheet),
                          borderSide: BorderSide.none,
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
                  foregroundColor: colors.onPrimary,
                  disabledForegroundColor: colors.onSurface.withValues(
                    alpha: .38,
                  ),
                ),
                onPressed:
                    widget.enabled && length > 0 && length <= widget.maxLength
                    ? () {
                        if (widget.onSend(_controller.text)) {
                          _controller.clear();
                          setState(() {});
                        }
                      }
                    : null,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
