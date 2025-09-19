import 'package:flutter/material.dart';

// 1. Mude para StatefulWidget
class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

// 2. Crie a classe State
class _MessageFieldBoxState extends State<MessageFieldBox> {
  late TextEditingController textController;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    // Auto-foco ao iniciar
    Future.delayed(Duration.zero, () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final textValue = textController.text;
    if (textValue.isEmpty) return;

    textController.clear();
    widget.onValue(textValue);
    focusNode.requestFocus(); // Mantém o foco após enviar
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(40),
    );

    final inputDecoration = InputDecoration(
      hintText: "End your message with a ?",
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      filled: true,
      suffixIcon: IconButton(
        onPressed: _handleSubmit,
        icon: const Icon(Icons.send_outlined),
      ),
    );

    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      onTapOutside: (event) => focusNode.unfocus(),
      focusNode: focusNode,
      controller: textController,
      decoration: inputDecoration,
      onFieldSubmitted: (value) => _handleSubmit(),
    );
  }
}
