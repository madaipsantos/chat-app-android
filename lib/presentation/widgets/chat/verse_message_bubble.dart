import 'package:flutter/material.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

/// Widget that displays a Bible verse message in a chat bubble style.
class VerseMessageBubble extends StatelessWidget {
  static const double _borderRadius = 20.0;
  static const EdgeInsets _bubblePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const double _messageSpacing = 5.0;

  /// The message to display.
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

  /// Builds the verse message bubble.
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