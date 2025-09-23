import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/widgets/chat/typing_indicator.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/widgets/chat/system_chat_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/user_chat_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_field_box.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://www.shutterstock.com/image-vector/chat-bot-icon-virtual-smart-600nw-2478937553.jpg',
            ),
          ),
        ),
        title: const Text('System Chat Mesages'),
        centerTitle: true,
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
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
                  switch (message.fromWho) {
                    case FromWho.systemChatMessage:
                      return SystemChatMessageBubble(message: message);
                    case FromWho.userChatMessage:
                      return UserChatMessageBubble(message: message);
                    case FromWho.typingIndicator:
                      return const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 8),
                        child: TypingIndicator(),
                      );
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: keyboardPadding),
              child: MessageFieldBox(
                onValue: (value) => chatProvider.sendMessage(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
