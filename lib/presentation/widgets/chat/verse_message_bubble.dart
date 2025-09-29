import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class VerseMessageBubble extends StatelessWidget {
  static const _borderRadius = 20.0;
  static const _bubblePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _messageSpacing = 5.0;

  final Message message;

  const VerseMessageBubble({
    super.key, 
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMessageBubble(context),
        const SizedBox(height: _messageSpacing),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Padding(
        padding: _bubblePadding,
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onTertiary,
          ),
        ),
      ),
    );
  }
}