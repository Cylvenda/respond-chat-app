import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onDelete,
    required this.onCopy,
  });

  Color _getMessageColor() {
    if (message.isUserMessage) {
      return AppTheme.primaryColor;
    }

    switch (message.type) {
      case MessageType.warning:
        return AppTheme.errorColor;
      case MessageType.tip:
        return AppTheme.infoColor;
      case MessageType.resource:
        return AppTheme.successColor;
      default:
        return AppTheme.secondaryColor;
    }
  }

  Color _getTextColor() {
    return message.isUserMessage ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final maxWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width * 0.6;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: message.isUserMessage
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: _getMessageColor(),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: message.isAssistantMessage
                    ? MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: _getTextColor(),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          strong: TextStyle(
                            color: _getTextColor(),
                            fontWeight: FontWeight.bold,
                          ),
                          h1: TextStyle(
                            color: _getTextColor(),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: TextStyle(
                            color: _getTextColor(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: TextStyle(
                            color: _getTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: TextStyle(
                            color: _getTextColor(),
                            fontSize: 14,
                          ),
                          blockquote: TextStyle(
                            color: _getTextColor(),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          code: TextStyle(
                            color: _getTextColor(),
                            fontSize: 13,
                            fontFamily: 'monospace',
                            backgroundColor: _getTextColor().withValues(alpha: 0.1),
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: _getTextColor().withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    : SelectableText(
                        message.content,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: _getTextColor().withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onCopy,
                      child: Icon(
                        Icons.copy,
                        size: 14,
                        color: _getTextColor().withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete,
                        size: 14,
                        color: _getTextColor().withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
