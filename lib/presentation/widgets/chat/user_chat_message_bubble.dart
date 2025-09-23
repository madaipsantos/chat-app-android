import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class UserChatMessageBubble extends StatelessWidget {
  static const _borderRadius = 20.0;
  static const _bubblePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _messageSpacing = 5.0;

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