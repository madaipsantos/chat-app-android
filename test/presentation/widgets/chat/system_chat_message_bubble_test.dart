import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/system_chat_message_bubble.dart';
import 'package:yes_no_app/domain/entities/message.dart';

void main() {
  testWidgets('SystemChatMessageBubble displays message text correctly', (WidgetTester tester) async {
    final message = Message(
      text: 'Mensaje del sistema',
      fromWho: FromWho.systemChatMessage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SystemChatMessageBubble(
            message: message,
          ),
        ),
      ),
    );

    // Verifica si el texto del mensaje está presente
    expect(find.text('Mensaje del sistema'), findsOneWidget);

    // Verifica si existe un Container para el estilo de la burbuja
    expect(find.byType(Container), findsOneWidget);

    // Verifica el alineamiento
    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerLeft);

    // Verifica el Container
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    
    // Verifica las propiedades del Container
    expect(decoration.borderRadius, BorderRadius.circular(20.0));
    expect(container.padding, const EdgeInsets.symmetric(horizontal: 20, vertical: 10));
    expect(container.margin, const EdgeInsets.symmetric(vertical: 5));
  });

  testWidgets('SystemChatMessageBubble accepts custom properties', (WidgetTester tester) async {
    final message = Message(
      text: 'Mensaje personalizado',
      fromWho: FromWho.systemChatMessage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SystemChatMessageBubble(
            message: message,
            borderRadius: 10.0,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(8),
          ),
        ),
      ),
    );

    // Verifica el Container con propiedades personalizadas
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    
    expect(decoration.borderRadius, BorderRadius.circular(10.0));
    expect(container.padding, const EdgeInsets.all(15));
    expect(container.margin, const EdgeInsets.all(8));
  });

  testWidgets('SystemChatMessageBubble text has correct style', (WidgetTester tester) async {
    final message = Message(
      text: 'Mensaje del sistema',
      fromWho: FromWho.systemChatMessage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SystemChatMessageBubble(
            message: message,
          ),
        ),
      ),
    );

    // Verifica el estilo del texto
    final textWidget = tester.widget<Text>(find.text('Mensaje del sistema'));
    final textStyle = textWidget.style;
    
    expect(textStyle?.color, Colors.white);
  });
}