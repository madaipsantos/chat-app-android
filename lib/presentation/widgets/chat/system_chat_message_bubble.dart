import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

/// Widget que exibe mensagens de sistema em formato de bolha.
/// 
/// Apresenta o texto da mensagem em uma bolha com estilo visual
/// adequado para mensagens do sistema.
class SystemChatMessageBubble extends StatelessWidget {
  /// A mensagem a ser exibida
  final Message message;
  
  /// Raio da borda da bolha
  final double borderRadius;
  
  /// Espaçamento interno da bolha
  final EdgeInsets padding;
  
  /// Espaçamento externo da bolha
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
