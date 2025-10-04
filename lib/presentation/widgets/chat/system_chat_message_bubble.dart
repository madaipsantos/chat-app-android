import 'package:flutter/material.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

/// Widget that displays system messages in a chat bubble style.
/// Shows the message text in a visually distinct bubble for system messages.
class SystemChatMessageBubble extends StatelessWidget {
  
  /// The message to display.
  final Message message;

  /// Border radius of the bubble.
  final double borderRadius;

  /// Inner padding of the bubble.
  final EdgeInsets padding;

  /// Outer margin of the bubble.
  final EdgeInsets margin;

  const SystemChatMessageBubble({
    super.key,
    required this.message,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
        margin: margin,
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}