import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:asistente_biblico/presentation/screens/chat/chat_screen.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';
import 'package:asistente_biblico/domain/entities/message.dart';

void main() {
  testWidgets('ChatScreen muestra AppBar y lista de mensajes vacía', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ChatProvider(initializeChat: false),
          child: const ChatScreen(),
        ),
      ),
    );

  // Verifica que el título del chat esté presente
  expect(find.text(ChatMessagesConstants.chatTitle), findsOneWidget);
    // Verifica que la lista de mensajes esté vacía
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('ChatScreen muestra mensaje enviado por el usuario', (WidgetTester tester) async {
    final provider = ChatProvider(initializeChat: false);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const ChatScreen(),
        ),
      ),
    );

  // Simula que el usuario escribe y envía un mensaje
  await tester.enterText(find.byType(TextField), 'Hola mundo');
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Verifica que el mensaje aparece en la lista
  expect(find.text('Hola mundo'), findsOneWidget);
  });

  testWidgets('ChatScreen muestra burbujas de mensaje según el tipo', (WidgetTester tester) async {
    final provider = ChatProvider(initializeChat: false);
    provider.addUserChatMessage('Mensaje usuario');
    provider.addUserChatMessage('Otro mensaje');
    provider.messageList.add(
      Message(text: 'Mensaje sistema', fromWho: FromWho.systemChatMessage),
    );
    provider.messageList.add(
      Message(text: 'Mensaje versículo', fromWho: FromWho.verseMessage),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const ChatScreen(),
        ),
      ),
    );
  await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Mensaje usuario'), findsOneWidget);
    expect(find.text('Mensaje sistema'), findsOneWidget);
    expect(find.text('Mensaje versículo'), findsOneWidget);
  });
}
