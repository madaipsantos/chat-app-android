import 'package:flutter/material.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

/// Widget that displays user messages in a chat bubble style.
class UserChatMessageBubble extends StatelessWidget {
  static const double _borderRadius = 20.0;
  static const EdgeInsets _bubblePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const double _messageSpacing = 5.0;

  /// The message to display.
  final Message message;

  const UserChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMessageBubble(colors),
        const SizedBox(height: _messageSpacing),
      ],
    );
  }

  /// Builds the user message bubble.
  Widget _buildMessageBubble(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Padding(
        padding: _bubblePadding,
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}