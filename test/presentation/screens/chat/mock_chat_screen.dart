import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

class MockChatScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const MockChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('System Chat Messages'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: chatProvider.chatScrollController,
              itemCount: chatProvider.messageList.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messageList[index];
                return ListTile(
                  title: Text(message.text),
                );
              },
            ),
          ),
          AnimatedPadding(
            padding: EdgeInsets.only(bottom: keyboardPadding),
            duration: const Duration(milliseconds: 100),
            child: TextFormField(
              onFieldSubmitted: chatProvider.sendMessage,
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}