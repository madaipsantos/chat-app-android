import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:asistente_biblico/presentation/screens/welcome/welcome_screen.dart';
import 'package:asistente_biblico/presentation/providers/chat_provider.dart';
import 'package:asistente_biblico/core/constants/chat_messages_constants.dart';

void main() {
  testWidgets('WelcomeScreen muestra título y campo de texto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ChatProvider(initializeChat: false),
          child: const WelcomeScreen(),
        ),
      ),
    );
    expect(find.text(ChatMessagesConstants.welcomeTitle), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
  });

  testWidgets('WelcomeScreen muestra error si el campo está vacío', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ChatProvider(initializeChat: false),
          child: const WelcomeScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();
    expect(find.text(ChatMessagesConstants.errorEnterName), findsOneWidget);
  });

  testWidgets('WelcomeScreen navega al chat si el nombre es válido', (WidgetTester tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        builder: (context, child) => ChangeNotifierProvider(
          create: (_) => ChatProvider(initializeChat: false),
          child: child!,
        ),
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/chat': (context) => const Scaffold(body: Text('Pantalla Chat')),
        },
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Madai');
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();
    expect(find.text('Pantalla Chat'), findsOneWidget);
  });
}
