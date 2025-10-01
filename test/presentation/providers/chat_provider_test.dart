import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';
import 'package:asistente_biblico/domain/entities/message.dart';
import 'package:mockito/annotations.dart';
import 'package:asistente_biblico/infrastructure/services/bible_service.dart';


@GenerateMocks([BibleService])
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('ChatProvider', () {
    late ChatProvider provider;

    setUp(() {
      provider = ChatProvider();
    });

    test('initial state is correct', () {
      expect(provider.messageList, isEmpty);
      expect(provider.currentState, SearchState.initial);
    });

    test('setUserName capitalizes first letter', () {
      provider.setUserName('maria');
      expect(provider.userName, 'Maria');
    });

    test('setUserName empty string', () {
      provider.setUserName('');
      expect(provider.userName, '');
    });

    test('add user chat message', () {
  provider = ChatProvider(initializeChat: false);
  provider.setUserName('Ana');
  provider.addUserChatMessage('Hola');
  expect(provider.messageList.length, 1);
  expect(provider.messageList[0].text, 'Hola');
  expect(provider.messageList[0].fromWho, FromWho.userChatMessage);
    });

    // Puedes agregar más tests para métodos públicos relevantes
  });
}
