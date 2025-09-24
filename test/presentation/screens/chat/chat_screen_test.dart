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

    testWidgets('should render TextField', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle user input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      const testMessage = 'Hello, World!';
      await tester.enterText(find.byType(TextField), testMessage);
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
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(chatProvider.messageList.length, equals(initialMessageCount));
    });
  });
}