import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:asistente_biblico/domain/entities/message.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';
import 'package:asistente_biblico/presentation/widgets/chat/system_chat_message_bubble.dart';
import 'package:asistente_biblico/presentation/widgets/chat/user_chat_message_bubble.dart';
import 'package:asistente_biblico/presentation/widgets/chat/verse_message_bubble.dart';
import 'package:asistente_biblico/presentation/widgets/shared/message_field_box.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';

/// Chat screen displaying the conversation and input field.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: const _ChatView(),
    );
  }

  /// Builds the app bar for the chat screen.
  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          backgroundImage: const AssetImage(
            'assets/images/imagebot.png',
          ),
        ),
      ),
      title: const Text(
        ChatMessagesConstants.chatTitle,
        style: TextStyle(
          color: Color.fromARGB(255, 43, 62, 185),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}

/// Internal chat view with message list and input field.
class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView>
    with SingleTickerProviderStateMixin {
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  bool _showHand = false;

  @override
  void initState() {
    super.initState();
    // Set context in ChatProvider after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).setContext(context);
    });
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _handAnimation = Tween<double>(
      begin: -0.6,
      end: 0.3,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_handController);
  }

  @override
  void dispose() {
    _handController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Scrolls the chat list to the bottom.
  void _scrollToBottom() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!chatProvider.chatScrollController.hasClients) return;
      chatProvider.chatScrollController.animateTo(
        chatProvider.chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Builds the message list widget.
  Widget _buildMessageList(ChatProvider chatProvider) {
    return ListView.builder(
      controller: chatProvider.chatScrollController,
      itemCount: chatProvider.messageList.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messageList[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// Builds the appropriate message bubble based on message type.
  Widget _buildMessageBubble(Message message) {
    return switch (message.fromWho) {
      FromWho.systemChatMessage => SystemChatMessageBubble(message: message),
      FromWho.userChatMessage => UserChatMessageBubble(message: message),
      FromWho.verseMessage => VerseMessageBubble(message: message),
    };
  }

  /// Handles sending a message from the input field.
  void _handleMessageSend(String value) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(value);
    _scrollToBottom();

    // Show and animate the hand icon if the message is exactly "salir"
    if (value.trim().toLowerCase() == 'salir') {
      setState(() => _showHand = true);
      _handController.repeat(reverse: true);

      // Hide the hand after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _handController.stop();
          setState(() => _showHand = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Expanded(child: _buildMessageList(chatProvider)),
                AnimatedPadding(
                  padding: EdgeInsets.only(bottom: keyboardPadding),
                  duration: const Duration(milliseconds: 100),
                  child: MessageFieldBox(
                    focusNode: _messageFocusNode,
                    onValue: _handleMessageSend,
                    onTap: _scrollToBottom,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showHand)
          Positioned(
            bottom: keyboardPadding + 70,
            right: 30,
            child: AnimatedBuilder(
              animation: _handAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: math.pi * _handAnimation.value,
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.amber,
                    size: 100,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}