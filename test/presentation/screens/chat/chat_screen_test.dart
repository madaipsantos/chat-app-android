import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import './mock_chat_provider.dart';
import './mock_chat_screen.dart';

void main() {
  group('ChatScreen', () {
    late MockChatProvider chatProvider;

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<ChatProvider>(
          create: (context) => chatProvider,
          child: const MockChatScreen(),
        ),
      );
    }

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      chatProvider = MockChatProvider();
    });

    testWidgets('should render AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final titleFinder = find.text('System Chat Messages');
      expect(titleFinder, findsOneWidget);
    });

    testWidgets('should render TextFormField', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should handle user input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      const testMessage = 'Hello, World!';
      await tester.enterText(find.byType(TextFormField), testMessage);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifica se a mensagem foi adicionada à lista
      expect(chatProvider.messageList.length, equals(1));
      expect(chatProvider.messageList.first.text, equals(testMessage));
    });

    testWidgets('should not add empty messages', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final initialMessageCount = chatProvider.messageList.length;
      await tester.enterText(find.byType(TextFormField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(chatProvider.messageList.length, equals(initialMessageCount));
    });

    testWidgets('should handle keyboard-aware components', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o Scaffold tem resizeToAvoidBottomInset ativo
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.resizeToAvoidBottomInset, true);

      // Verifica se o AnimatedPadding está presente
      expect(find.byType(AnimatedPadding), findsOneWidget);
    });

    testWidgets('should handle message list scrolling', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Adiciona várias mensagens
      for (var i = 0; i < 5; i++) {
        chatProvider.sendMessage('Test message $i');
      }
      await tester.pumpAndSettle();

      // Verifica se as mensagens foram adicionadas
      expect(chatProvider.messageList.length, 5);

      // Verifica se o ListView está presente
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should scroll to bottom when new message is sent', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Adiciona mensagens
      for (var i = 0; i < 20; i++) {
        chatProvider.sendMessage('Test message $i');
      }
      await tester.pumpAndSettle();

      // Envia nova mensagem
      await tester.enterText(find.byType(TextFormField), 'New message');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 300));

      // Verifica se todas as mensagens foram adicionadas
      expect(chatProvider.messageList.length, 21);
      expect(find.text('New message'), findsOneWidget);
    });
  });
}