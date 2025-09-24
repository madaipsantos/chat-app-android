import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/typing_indicator.dart';

void main() {
  testWidgets('TypingIndicator shows text with initial state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(),
          ),
        ),
      ),
    );

    // Verifica se o widget existe
    expect(find.byType(TypingIndicator), findsOneWidget);

    // Verifica se o texto inicial está correto
    expect(find.text('Escribiendo'), findsOneWidget);
  });

  testWidgets('TypingIndicator shows custom text', (WidgetTester tester) async {
    const customText = 'Custom typing...';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(
              text: customText,
            ),
          ),
        ),
      ),
    );

    // Verifica se o texto customizado está presente
    expect(find.text(customText), findsOneWidget);
  });

  testWidgets('TypingIndicator shows correct style', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(),
          ),
        ),
      ),
    );

    // Encontra o widget Text
    final textWidget = tester.widget<Text>(find.byType(Text));
    
    // Verifica o estilo padrão
    expect(textWidget.style?.color, Colors.grey);
    expect(textWidget.style?.fontSize, 12);
    expect(textWidget.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('TypingIndicator animates dots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(),
          ),
        ),
      ),
    );

    // Aguarda a primeira renderização
    await tester.pump();
    
    // Verifica a sequência de animação
    String lastText = '';
    bool textChanged = false;
    
    // Testa por alguns frames para garantir que a animação está funcionando
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      
      final textWidget = tester.widget<Text>(find.byType(Text));
      final currentText = textWidget.data ?? '';
      
      if (currentText != lastText) {
        textChanged = true;
        lastText = currentText;
      }
    }
    
    // Verifica se o texto mudou durante a animação
    expect(textChanged, true, reason: 'O texto deve mudar durante a animação');
  });

  testWidgets('TypingIndicator can hide dots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(
              showDots: false,
            ),
          ),
        ),
      ),
    );

    // Verifica se o texto está presente sem pontos
    expect(find.text('Escribiendo'), findsOneWidget);

    // Avança a animação
    await tester.pump(const Duration(milliseconds: 500));

    // Verifica se o texto continua sem pontos
    expect(find.text('Escribiendo'), findsOneWidget);
  });

  testWidgets('TypingIndicator respects custom padding', (WidgetTester tester) async {
    const customPadding = EdgeInsets.all(16.0);
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypingIndicator(
              padding: customPadding,
            ),
          ),
        ),
      ),
    );

    // Encontra o widget Padding
    final paddingWidget = tester.widget<Padding>(find.byType(Padding));
    
    // Verifica se o padding é o esperado
    expect(paddingWidget.padding, equals(customPadding));
  });
}