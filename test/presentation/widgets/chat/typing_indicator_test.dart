import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asistente_biblico/presentation/widgets/chat/typing_indicator.dart';

void main() {
  testWidgets('TypingIndicator muestra el texto por defecto', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator()),
    ));
    expect(find.text('Escribiendo'), findsOneWidget);
  });

  testWidgets('TypingIndicator muestra texto personalizado', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator(text: 'Bot está escribiendo')),
    ));
    expect(find.text('Bot está escribiendo'), findsOneWidget);
  });

  testWidgets('TypingIndicator muestra puntos animados', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator()),
    ));
    // Estado inicial
    expect(find.text('Escribiendo'), findsOneWidget);
    // Avanzar animación varias veces
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Escribiendo.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Escribiendo..'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Escribiendo...'), findsOneWidget);
  });

  testWidgets('TypingIndicator oculta puntos si showDots es false', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator(showDots: false)),
    ));
    expect(find.text('Escribiendo'), findsOneWidget);
    expect(find.text('Escribiendo.'), findsNothing);
    expect(find.text('Escribiendo..'), findsNothing);
    expect(find.text('Escribiendo...'), findsNothing);
  });
}
