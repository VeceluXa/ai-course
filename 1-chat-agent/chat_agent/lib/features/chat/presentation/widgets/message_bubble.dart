import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final ChatMessage message;
  final VoidCallback? onRetry;

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = _isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = _isUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    final actions = <PopupMenuEntry<String>>[
      const PopupMenuItem(value: 'copy', child: Text('Copy')),
      if (message.isError && onRetry != null)
        const PopupMenuItem(value: 'retry', child: Text('Retry')),
    ];

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: InkWell(
          onLongPress: () => _copy(context),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isUser)
                        Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                        )
                      else
                        SelectionArea(
                          child: MarkdownBody(
                            data: message.content.isEmpty ? ' ' : message.content,
                            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                              p: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                            ),
                          ),
                        ),
                      if (message.isError && onRetry != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          message.errorMessage ?? 'Failed to generate a response.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (actions.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) {
                    if (value == 'copy') {
                      _copy(context);
                    } else if (value == 'retry') {
                      onRetry?.call();
                    }
                  },
                  itemBuilder: (_) => actions,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
