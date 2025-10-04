import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:flutter/material.dart';

/// Widget for message text input with send button.
/// Supports focus management and callbacks for sending messages.
class MessageFieldBox extends StatefulWidget {
  /// Callback when a message is sent.
  final ValueChanged<String> onValue;

  /// Optional callback when the field is tapped.
  final VoidCallback? onTap;

  /// Optional external focus node.
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

  static const String _hintText = ChatMessagesConstants.messageFieldHint;
  static const double _borderRadius = 40.0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Request focus only if not using an external focus node
    if (widget.focusNode == null) {
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

  /// Handles message submission and clears the text field.
  void _handleSubmit() {
    final textValue = _textController.text.trim();
    if (textValue.isEmpty) return;

    _textController.clear();
    widget.onValue(textValue);
    _focusNode.requestFocus();
  }

  /// Handles tap on the text field.
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

  /// Builds the input decoration for the text field.
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