import 'package:flutter/material.dart';

/// Widget para entrada de texto de mensagens com botão de envio.
/// Suporta gerenciamento de foco e callbacks para envio de mensagens.
class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const MessageFieldBox({
    super.key, 
    required this.onValue,
    this.onTap,
    this.focusNode,
  });

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  
  // Constantes para melhor manutenção
  static const String _hintText = "Busca por tema, palabra o referencia bíblica…";
  static const double _borderRadius = 40.0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Solicitar foco apenas se não for um focusNode externo
    if (widget.focusNode == null) {
      // Agendar para após a construção do widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// Processa o envio da mensagem e limpa o campo de texto
  void _handleSubmit() {
    final textValue = _textController.text.trim();
    if (textValue.isEmpty) return;

    _textController.clear();
    widget.onValue(textValue);
    _focusNode.requestFocus();
  }

  /// Gerencia o toque no campo de texto
  void _handleTap() {
    widget.onTap?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      onTapOutside: (_) => _focusNode.unfocus(),
      onTap: _handleTap,
      focusNode: _focusNode,
      controller: _textController,
      decoration: _buildInputDecoration(),
      onFieldSubmitted: (_) => _handleSubmit(),
    );
  }

  /// Constrói a decoração do campo de texto
  InputDecoration _buildInputDecoration() {
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(_borderRadius),
    );

    return InputDecoration(
      hintText: _hintText,
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      filled: true,
      suffixIcon: IconButton(
        onPressed: _handleSubmit,
        icon: const Icon(Icons.send_outlined),
      ),
    );
  }
}
