import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/widgets/chat/inteligent_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/user_message_bubble.dart';
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
              'https://1.bp.blogspot.com/-DTJch3FMmQg/T7WZW8_tCfI/AAAAAAAAAn8/MvqD67OYvE8/s1600/aniston0uo1.jpg',
            ),
          ),
        ),
        title: const Text('Inteligent Chat'),
        centerTitle: true,
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    final chatprovider = context.watch<ChatProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: chatprovider.chatScrollController,
                itemCount: chatprovider.messageList.length,
                itemBuilder: (context, index) {
                  final message = chatprovider.messageList[index];
                  return (message.fromWho == FromWho.inteligentMessage)
                      ? InteligentMessageBubble()
                      : UsuarioMessageBubble(message: message);
                },
              ),
            ),
            MessageFieldBox(
              onValue: (value) {
                chatprovider.sendMessage(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
