import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

class MockChatProvider extends ChatProvider {
  MockChatProvider() : super(initializeChat: false);

  @override
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    messageList.add(Message(
      text: text,
      fromWho: FromWho.userChatMessage,
    ));
    notifyListeners();
  }

  @override
  Future<void> moveScrollToBottom() async {
    // Não faz nada no mock
  }
}